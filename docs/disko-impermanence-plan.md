# Plan: Integrate disko + nixos-anywhere + Impermanence

## Context

The current NixOS configuration manages disk layouts manually through per-host `hardware-configuration.nix` files. This makes it difficult to:
- Reprovision hosts remotely (no nixos-anywhere support)
- Maintain consistent disk layouts across hosts
- Recover from disk failures declaratively
- Push updates to remote hosts (vega, dionysus)

By adding **disko** (declarative disk partitioning), **nixos-anywhere** (remote provisioning), and **impermanence** (persistent state management), we gain:
- Single-command remote provisioning: `nix run github:nix-community/nixos-anywhere -- --flake .#ares`
- Reproducible disk layouts declared in code
- @persist subvolume for state that survives reimaging (SSH keys, Docker volumes, etc.)
- ZRAM + BTRFS swapfile for all hosts (ZRAM priority 100, swapfile priority 50)

## Design Decisions (confirmed with user)

| Decision | Choice |
|----------|--------|
| Filesystem | BTRFS on all hosts |
| Encryption | LUKS per-host (ares=yes, others=off initially, easy to enable) |
| @persist subvol | Yes — enables impermanence pattern |
| @swap subvol | Yes — BTRFS swapfile with nodatacow, ZRAM priority 100 |
| Mount options | `compress=zstd:1,noatime` (default), `nodatacow` for @swap |
| Subvolumes | `@`, `@home`, `@nix`, `@persist`, `@swap` |
| Swap sizing | Minimal — sized for hibernation of typical RAM usage, NOT full RAM |

### Swap sizing rationale

The swapfile exists for two reasons only:
1. **Hibernation** — needs enough space to write RAM contents to disk
2. **Emergency overflow** — when ZRAM (priority 100) is exhausted

The swapfile should NOT match total RAM. In practice, hibernating rarely uses all RAM
because heavy workloads (simulations, experiments) are the exception, not the norm.
Strategy: size swapfile at ~25-40% of total RAM (enough for hibernation of typical
workload, with ZRAM compressing what's actually in memory).

| Host | RAM | Swapfile | Rationale |
|------|-----|----------|-----------|
| ares | ~32-64GB | 8-16GB | Laptop: hibernate typical workload (~8-16GB used) |
| janus | ~8-16GB | 4-8GB | Desktop: moderate use |
| vega | ~32GB | 8GB | Compute: hibernate rare, but available |
| dionysus | ~16GB | 4-8GB | Appliance: minimal hibernation need |

ZRAM (priority 100) handles 99% of swap traffic. The swapfile (priority 50) only
activates for hibernation or extreme memory pressure.

## Disk Layout (parameterized)

```
Disk: /dev/nvme0n1 (or /dev/sda — per host)
├── Partition 1: ESP (512M, FAT32) → /boot
└── Partition 2: BTRFS pool (rest of disk)
    OR: LUKS2 container → BTRFS pool (when encrypt=true)
        ├── Subvol @        → /           (compress=zstd:1,noatime)
        ├── Subvol @home    → /home       (compress=zstd:1,noatime)
        ├── Subvol @nix     → /nix        (compress=zstd:1,noatime)
        ├── Subvol @persist → /persist     (compress=zstd:1,noatime, neededForBoot)
        └── Subvol @swap    → /swap        (nodatacow, noatime)
            └── swapfile: varies per host (priority 50, ZRAM has priority 100)
```

## Implementation Steps

### Step 1: Add flake inputs

**File**: `flake.nix`

Add to inputs:
```nix
disko = {
  url = "github:nix-community/disko";
  inputs.nixpkgs.follows = "nixpkgs";
};

impermanence = {
  url = "github:nix-community/impermanence";
};
```

Add `disko.nixosModules.disko` and `impermanence.nixosModules.impermanence` to `sharedModules`.

### Step 2: Create disko template module

**New file**: `modules/disko/btrfs.nix`

A function that generates disko configs, parameterized by:
- `device` — disk device path (e.g., `/dev/nvme0n1`)
- `encrypt` — bool, whether to use LUKS
- `swapSize` — size of swapfile (default varies by host RAM, ~25-40% of total)
- `hostId` — needed for ZFS compatibility warning avoidance

This template produces the standard 5-subvolume BTRFS layout with optional LUKS wrapping.

### Step 3: Create per-host disk configs

**New files**:
- `hosts/ares/disk-config.nix` — LUKS + BTRFS, device `/dev/nvme0n1`
- `hosts/janus/disk-config.nix` — BTRFS (no LUKS initially), device TBD
- `hosts/vega/disk-config.nix` — BTRFS (no LUKS initially), device TBD
- `hosts/dionysus/disk-config.nix` — BTRFS (no LUKS initially), device TBD

Each imports the shared template with host-specific parameters.

### Step 4: Update flake.nix to add diskoConfigurations

Add `diskoConfigurations` output for each host so `nixos-anywhere` can find them:
```nix
diskoConfigurations = {
  ares = import ./hosts/ares/disk-config.nix;
  # etc.
};
```

### Step 5: Update host configuration.nix files

For each host, replace the `hardware-configuration.nix` import with:
```nix
imports = [
  ./disk-config.nix  # disko replaces hardware-configuration.nix for filesystems
];
```

Keep hardware-configuration.nix for hardware-specific settings (kernel modules, CPU microcode) but remove filesystem/LUKS/swap declarations from it — disko manages those.

### Step 6: Create impermanence module

**New file**: `modules/system/impermanence.nix`

Configure `environment.persistence."/persist"` with:
- System directories: `/etc/ssh`, `/var/lib/systemd`, `/var/lib/nix`, `/var/log`, `/etc/machine-id`
- Per-user directories (based on host): `home/jpolo/.ssh`, etc.
- `neededForBoot = true` on the `/persist` mount

This module will be conditionally enabled per-host.

### Step 7: Update btrbk module

**File**: `modules/system/btrbk.nix`

Currently references `/dev/disk/by-uuid/...` for mounting the btrfs-root. With disko, this becomes declarative. Update to:
- Use the disko-managed device path
- Add `@persist` to snapshot targets
- Keep `@nix` excluded (reproducible)

### Step 8: Simplify hardware-configuration.nix files

For **ares**: Remove filesystem, LUKS, and swap entries (disko manages these). Keep only:
- `boot.initrd.availableKernelModules`
- `boot.kernelModules`
- `nixpkgs.hostPlatform`
- `hardware.cpu.amd.updateMicrocode`

For **janus, vega, dionysus**: Same pattern — strip filesystem declarations, keep hardware detection.

### Step 9: Add ZRAM + swapfile configuration module

**New file**: `modules/system/swap.nix` (or add to existing optimization module)

Configure:
- ZRAM swap with priority 100 (high, used first)
- BTRFS swapfile with priority 50 (low, overflow/hibernation only)
- Swapfile sized at ~25-40% of RAM (for hibernation of typical workload, not full RAM)
- Per-host swapfile sizes: ares=16GB, janus=8GB, vega=8GB, dionysus=8GB

### Step 10: Update SSH module for nixos-anywhere

**File**: `modules/system/ssh.nix`

Ensure:
- `services.openssh.enable = true`
- Root login is disabled by default
- SSH host keys are persisted via impermanence

### Step 11: Update flake.nix host modules

For each host in `flake.nix`, add the disko config import:
```nix
ares = nixpkgs.lib.nixosSystem {
  modules = sharedModules ++ [
    ./hosts/ares/disk-config.nix  # disko config
    ./hosts/ares/configuration.nix
  ];
};
```

## Files to Create

| File | Purpose |
|------|---------|
| `modules/disko/btrfs.nix` | Parameterized BTRFS disko template |
| `hosts/ares/disk-config.nix` | Ares disk config (LUKS + BTRFS) |
| `hosts/janus/disk-config.nix` | Janus disk config (BTRFS, no LUKS) |
| `hosts/vega/disk-config.nix` | Vega disk config (BTRFS, no LUKS) |
| `hosts/dionysus/disk-config.nix` | Dionysus disk config (BTRFS, no LUKS) |
| `modules/system/impermanence.nix` | Impermanence persistence module |
| `modules/system/swap.nix` | ZRAM + swapfile module |

## Files to Modify

| File | Change |
|------|--------|
| `flake.nix` | Add disko + impermanence inputs, diskoConfigurations output, update host modules |
| `hosts/ares/hardware-configuration.nix` | Strip filesystem/LUKS/swap entries |
| `hosts/ares/configuration.nix` | Import disk-config.nix, enable impermanence |
| `hosts/janus/hardware-configuration.nix` | Strip filesystem entries |
| `hosts/janus/configuration.nix` | Import disk-config.nix, enable impermanence |
| `hosts/vega/hardware-configuration.nix` | Strip filesystem entries |
| `hosts/vega/configuration.nix` | Import disk-config.nix, enable impermanence |
| `hosts/dionysus/hardware-configuration.nix` | Strip filesystem entries |
| `hosts/dionysus/configuration.nix` | Import disk-config.nix, enable impermanence |
| `modules/system/default.nix` | Import new swap + impermanence modules |
| `modules/system/btrbk.nix` | Update mount references for disko, add @persist |

## Verification

1. **Dry-run**: `nix eval --extra-experimental-features 'nix-command flakes' .#nixosConfigurations.ares.config.fileSystems` — verify mount points
2. **disko dry-run**: `nix run github:nix-community/disko -- --dry-run .#ares` — verify partition layout
3. **Build test**: `nix build .#nixosConfigurations.ares.config.system.build.toplevel` — verify system builds
4. **VM test**: `nix run github:nix-community/nixos-anywhere -- --vm-test .#ares` — test install in VM
5. **Actual deployment** (ares first, as it's local): `sudo nh os switch` after migration