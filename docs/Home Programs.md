---
tags: [home-manager, programs, reference]
---

# Home Programs

Reference page for all home-manager programs, services, and shell configurations.

## Programs

### ai-tools.nix

**File:** `home/programs/ai-tools.nix`

Configurable AI development tools with per-tool enable flags under `programs.ai-tools.tools`:

| Tool | Option | Description |
|------|--------|-------------|
| Gemini CLI | `gemini-cli.enable` | Google's Gemini command-line interface |
| GitHub Copilot CLI | `github-copilot-cli.enable` | GitHub Copilot terminal integration |
| Claude Code | `claude-code.enable` | Anthropic's Claude terminal agent |
| Pi Coding Agent (omp) | `pi-coding-agent.enable` | Oh My Pi coding agent — wraps `omp` binary |

When `pi-coding-agent` is enabled:
- Shell alias `pi` → `omp`
- `~/.pi/agent` and `~/.omp` symlinked to `/etc/nixos/pi-agent-data`
- The `omp` wrapper (`home/programs/omp-wrapper.nix`) launches via `bunx --bun @oh-my-pi/pi-coding-agent` with Docker sandbox, injecting the Ollama API key from sops secrets

---

### git.nix

**File:** `home/programs/git.nix`
**Profile gate:** `home.profiles.cli`

| Setting | Value |
|---------|-------|
| `init.defaultBranch` | `main` |
| `pull.rebase` | `true` |
| `push.autoSetupRemote` | `true` |
| `core.editor` | `nvim` |
| `safe.directory` | `/etc/nixos` |

**Git aliases:** `st`, `co`, `br`, `ci`, `unstage`, `last`, `lg`
**GH CLI:** Enabled with `git_protocol = "ssh"`, editor = `nvim`
**Git LFS:** Enabled

---

### kitty.nix

**File:** `home/programs/kitty.nix`
**Profile gate:** `home.profiles.desktop`

| Setting | Value |
|---------|-------|
| Font | JetBrains Mono, size 12 |
| `background_opacity` | `0.9` |
| `window_padding_width` | 8 |
| `cursor_shape` | `beam` |
| `cursor_blink_interval` | 0 (disabled) |
| `repaint_delay` | 10 |
| `input_delay` | 3 |
| `allow_remote_control` | `yes` (for Noctalia theme sync) |

Includes matugen-generated colors from `${XDG_CONFIG_HOME}/kitty/themes/noctalia.conf`.

---

### neovim.nix

**File:** `home/programs/neovim.nix`

LazyVim-based configuration with Nix-managed plugin set. Key points:

- **`defaultEditor = true`**, `viAlias = true`, `vimAlias = true`
- **Plugins managed via Nix** through `lazy.nvim` link farm (`NIX_LAZY_PATH`)
- System clipboard integration (`unnamedplus`)
- Treesitter with all grammars
- Language extras: TypeScript, JSON, Markdown, Rust, Go, Python
- AI tools: CodeCompanion (Ollama, `qwen3.6:35b`), Minuet (ghost text autocomplete)
- Custom plugins: harpoon2, sniprun, obsidian-nvim, pathfinder-nvim, snacks-nvim
- Snacks explorer replaces neo-tree/oil/mini.files
- Toggle commands: `<leader>uL` (light/dark mode), `<leader>ua` (AI autocomplete)
- **LSP servers** provided as `extraPackages`: nixd, pyright, ruff, rust-analyzer, gopls, clang-tools, texlab, marksman, and more
- **Ranger** configured with Kitty image previews

---

### firefox.nix

**File:** `home/programs/firefox.nix`
**Profile gate:** `home.profiles.desktop`

| Setting | Value |
|---------|-------|
| Default search | DuckDuckGo (forced) |
| Container sync | Forced |
| Do Not Track | Enabled |
| Tracking Protection | Enabled |
| WebRender | Enabled (`gfx.webrender.all`) |
| VA-API | Enabled (`media.ffmpeg.vaapi.enabled`) |
| Sponsored content | Disabled |
| Extension auto-disable | Disabled (`extensions.autoDisableScopes = 0`) |

**Extensions:** uBlock Origin, Bitwarden, Privacy Badger, Tree Style Tab, Multi-Account Containers, Dark Reader, Refined GitHub, SponsorBlock

**Optional:** Tridactyl vim navigation (`home.firefox.vimNavigation.enable`) — adds native messaging host and `<C-i>` editor binding.

---

### tmux.nix

**File:** `home/programs/tmux.nix`
**Profile gate:** `home.profiles.cli`

| Setting | Value |
|---------|-------|
| Terminal | `tmux-256color` |
| History limit | 100,000 |
| Key mode | `vi` |
| Base index | 1 |
| Mouse | Enabled |
| Prefix | `Ctrl-a` (rebind from `Ctrl-b`) |
| Escape time | 0 |
| Status position | Top |

**Plugins:** resurrect, continuum, yank, Catppuccin (mocha flavor)

**Custom scripts:**
- `tmux-sessionizer` — fzf-based project/session switcher (searches `~/Projects`, `~/Documents`, nixos config)
- `tmux-killer` — fzf-based session killer
- `ts-tools` — launches AI and system monitor sessions

**Key bindings:** `|` split-h, `-` split-v, `h/j/k/l` pane nav, `f` sessionizer, `Ctrl-v` paste from Wayland

---

### walker.nix

**File:** `home/programs/walker.nix`
**Profile gate:** `home.profiles.desktop` + `environment == "hyprland"`

Application launcher for Wayland with Elephant backend.

**Modules:** Applications, Runner (`>`), Web Search (`?`), Finder (`~`), Custom (`:`) — includes ⚡ Power Profiles menu

**Search engines:** Google, DuckDuckGo

**Systemd services:** `walker.service` (depends on `elephant.service`), `elephant.service`

**Styling:** Imports `noctalia.css` from matugen, JetBrainsMono Nerd Font at 14px

**Power profiles:** Eco, Balanced-Eco, Balanced, Performance, Performance Plus — selectable via Walker dmenu

---

### web-apps.nix

**File:** `home/programs/web-apps.nix`

Generates `.desktop` entries for web applications, each individually toggleable via `programs.web-apps.apps.<name>.enable`.

Browser choice follows `home.profiles.desktop.browsers.chromium` — Firefox by default, Chromium if enabled.

| Category | Apps |
|----------|------|
| Communication | Gmail, Google Calendar, Outlook, WhatsApp, Telegram |
| Development | GitHub, GitLab, Overleaf, ChatGPT, Claude, Perplexity |
| Creative | Figma, Canva, Excalidraw |
| Productivity | Notion, Google Docs, Google Drive, Microsoft 365 |
| Entertainment | YouTube, Netflix, Spotify |

---

### xcompose.nix

**File:** `home/programs/xcompose.nix`
**Profile gate:** `home.profiles.desktop` + `environment == "hyprland"`

Custom X compose sequences (`.XCompose`):

| Sequence | Output |
|----------|--------|
| `<Multi_key> e m` | 📧 |
| `<Multi_key> h e a r t` | ❤️ |
| `<Multi_key> s t a r` | ⭐ |
| `<Multi_key> c h e c k` | ✓ |
| `<Multi_key> x m a r k` | ✗ |
| `<Multi_key> arrow l/r/u/d` | ← → ↑ ↓ |
| `<Multi_key> i n f` | ∞ |
| `<Multi_key> s u m` | ∑ |
| `<Multi_key> p i` | π |
| `<Multi_key> d e l t a` | Δ |

Input method: `fcitx` (GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS)

---

### swayosd.nix

**File:** `home/programs/swayosd.nix`
**Profile gate:** `home.profiles.desktop` + `environment == "hyprland"`

On-screen display for volume and brightness on Wayland. Runs as `swayosd-server` systemd user service after `graphical-session.target`.

---

### power-user.nix

**File:** `home/programs/power-user.nix`

Extensive power-user package set (~200 packages) and tool configurations:

**Key tools by category:**

| Category | Packages |
|----------|----------|
| Code search | ast-grep, semgrep |
| Git | gh-dash, gitleaks, git-crypt |
| Network | rustscan |
| Database | pgcli, mycli, litecli, usql |
| Containers | dive, ctop, lazydocker, podman-compose |
| Kubernetes | kubectx, stern, kustomize |
| IaC | terraform-ls, tflint, terragrunt, pulumi |
| HTTP | xh |
| Data | jless, dasel |
| Sync | rclone, syncthing |
| Passwords | pass, gopass |
| Encryption | age |
| Backup | restic |
| GPU | nvtop (AMD) |
| Process | pm2 |
| Build | just, gnumake, cmake, meson, ninja |
| Docs | zeal |
| Notes | obsidian, logseq |
| Time | timewarrior, watson |
| Screenshots | flameshot, peek, grim, slurp |
| Fonts | Fira Code, JetBrains Mono, Hack (nerd-fonts) |
| LS | yaml-language-server, dockerfile-language-server, bash-language-server, taplo |
| Formatters | shfmt, sql-formatter |
| Linters | shellcheck, hadolint, yamllint |
| VM | quickemu |
| Multiplexers | zellij, byobu |
| File managers | lf, vifm, nnn (with plugins) |
| Disk | gparted |
| PDF | pdftk |
| E-books | calibre |
| Markdown | glow, mdcat |
| Diagrams | graphviz, plantuml |
| Math | octave |
| Data science | jupyter |
| 3D | openscad |
| ASCII | figlet, toilet, lolcat, cmatrix |
| System | pv, progress |
| Modern CLI | sd, choose, skim |
| Transfer | croc, magic-wormhole |
| QR | qrencode |
| IRC | weechat |
| Email | neomutt |
| RSS | newsboat |
| Music | ncmpcpp |
| Tracing | sysdig |

**Also configures:** Helix editor (catppuccin-mocha), ripgrep, SSH (control master, agent forwarding, keep-alive), GPG agent (with SSH support, pinentry-gnome3), nnn file manager (with bookmarks and plugins).

---

### terminal-tools.nix

**File:** `home/programs/terminal-tools.nix`
**Profile gate:** `home.profiles.cli`

Comprehensive terminal tooling:

| Tool | Key Settings |
|------|-------------|
| **Zellij** | Catppuccin-mocha theme, `Alt+h/j/k/l` pane nav, default shell = zsh, no pane frames |
| **Atuin** | Shell history sync (5 min), fuzzy search, vim-normal keymap, preview enabled |
| **Direnv** | nix-direnv enabled, `.env` loading, non-strict |
| **Zoxide** | Zsh integration, smarter `cd` |
| **FZF** | Catppuccin colors, `fd` as default command, bat preview for files, tree preview for dirs |
| **Bat** | Catppuccin-mocha theme, line numbers + changes header |
| **Yazi** | File manager with custom linemode (permissions + size + mtime), image/video/PDF/text open rules, `.` toggle hidden, `s` sort menu |
| **Fastfetch** | System info on shell start |
| **Eza** | `--group-directories-first`, `--header`, `--icons` |
| **Ripgrep** | Smart-case, hidden, max-columns 150 |
| **Btop** | Noctalia theme |
| **Alacritty** | JetBrainsMono Nerd Font 11px, 95% opacity, 5px padding, noctalia theme import |

---

### mpv.nix

**File:** `home/programs/mpv.nix`

Installs the `mpv` media player package.

---

### ark.nix

**File:** `home/programs/ark.nix`

Installs `kdePackages.ark` (KDE archive manager).

---

### evince.nix

**File:** `home/programs/evince.nix`

Installs `evince` (GNOME PDF viewer).

---

### loupe.nix

**File:** `home/programs/loupe.nix`

Installs `loupe` (GNOME image viewer).

---

### vms.nix

**File:** `home/programs/vms.nix`

VM management tools and aliases:

**Packages:** remmina, freerdp, tigervnc

**Shell aliases:**

| Alias | Command |
|-------|---------|
| `vl` / `vls` | `sudo virsh list --all` |
| `vstart` | `sudo virsh start` |
| `vstop` | `sudo virsh shutdown` |
| `vforce` | `sudo virsh destroy` |
| `vinfo` | `sudo virsh dominfo` |
| `vcon` | `sudo virsh console` |
| `vview` | `virt-viewer` |
| `qvm` | `quickemu --vm` |
| `win11` / `w11` | `win11-vm` |
| `vsnap` | `sudo virsh snapshot-create-as` |
| `vsnaplist` | `sudo virsh snapshot-list` |
| `vsnaprevert` | `sudo virsh snapshot-revert` |
| `vclone` | `sudo virt-clone` |
| `vnet` | `sudo virsh net-list --all` |
| `vnetstart` | `sudo virsh net-start` |
| `vnetstop` | `sudo virsh net-destroy` |

**Config:** Sets `uri_default = "qemu:///system"` in `libvirt/libvirt.conf`

---

### omp-wrapper.nix

**File:** `home/programs/omp-wrapper.nix`

Shell application wrapper for Oh My Pi coding agent (`omp`). Launches `bunx --bun @oh-my-pi/pi-coding-agent` with:
- Docker sandbox (`--sandbox=docker:mom-sandbox`)
- Project root enforcement (`--project-root=$(pwd)`)
- Optional Ollama API key injection from sops secret path
- Optional `PI_EXTRA_MOUNTS` for additional Docker mounts

---

## Home Services

### ollama.nix

**File:** `home/services/ollama.nix`
**Options:** `services.ollama-service.enable`, `services.ollama-service.acceleration` (`"rocm"` | `"cuda"` | `null`)

Runs Ollama as a systemd user service bound to `0.0.0.0:11434` (accessible from Docker containers via `host.docker.internal`).

**Acceleration:**
- `rocm` — sets `HSA_OVERRIDE_GFX_VERSION=11.0.0` and `ROCR_VISIBLE_DEVICES=0` (for AMD GPUs)
- `cuda` — for NVIDIA GPUs
- `null` (default) — CPU only

---

### mako.nix

**File:** `home/services/mako.nix`
**Profile gate:** `home.profiles.desktop`

Wayland notification daemon:

| Setting | Value |
|---------|-------|
| Width | 350 |
| Height | 150 |
| Margin | 10 |
| Padding | 15 |
| Border radius | 10 |
| Default timeout | 5000 ms |
| Anchor | `top-right` |
| Icons | Enabled, max 48px |
| Group by | `app-name` |

**Timeouts by urgency:** Low = 3s, Normal = 5s, High = no timeout (0)

---

### hyprsunset.nix

**File:** `home/services/hyprsunset.nix`
**Profile gate:** `home.profiles.desktop` + `environment == "hyprland"`

Blue light filter for Hyprland. Runs `hyprsunset -t 4500` as a systemd user service (color temperature: 4500K).

---

### media-automations.nix

**File:** `home/services/media-automations.nix`
**Options:** `services.media-automations.enable`, `services.media-automations.autoPause.enable` (default: `true`)

Auto-pause service that monitors PulseAudio/PipeWire for audio sink removal events. When an audio device is disconnected, all media players are paused via `playerctl -a pause`.

---

## Hyprland Configs

### hyprland.nix

**File:** `home/hyprland/hyprland.nix`
**Profile gate:** `home.profiles.desktop` + `environment == "hyprland"`

Full Hyprland window manager configuration. Key settings:

**Monitors:** eDP-1 (1920×1200@60), HDMI-A-1 (1920×1080@60), DP-1 (1920×1080@60, rotated)

**Layout:** Native scrolling, column width 75%

**General:** gaps_in=5, gaps_out=10, border_size=2, rounding=3, active_opacity=0.9, inactive_opacity=0.8

**Input:** US+ES keyboard, `altwin:swap_alt_win`, `grp:alt_shift_toggle`, `compose:caps`, natural scroll, touchpad scroll_factor=0.4

**Exec-once:** hypridle, mako, fcitx5, swayosd, polkit-gnome, nm-applet, blueman-applet, hyprpm reload

**Custom scripts:** `universal-copy`, `universal-paste`, `toggle-transparency`, `focus-obsidian`, `walker-launcher`, `smart-resize`

**Key bindings (selection):**
- `SUPER+RETURN` → terminal (kitty)
- `SUPER+SPACE` → walker launcher
- `SUPER+B` → browser (firefox)
- `SUPER+N` → Noctalia control center
- `SUPER+O` → focus Obsidian
- `SUPER+C/V/X` → universal clipboard
- `SUPER+F` → fullscreen, `SUPER+T` → toggle float
- `SUPER+R` → rotate layout (row ↔ column)
- `SUPER+S` → special workspace (magic)
- `SUPER+1-0` → workspace 1-10
- `SUPER+SHIFT+1-0` → move window to workspace
- `SUPER+BackSpace` → toggle transparency
- `SUPER+ESC` → Noctalia session menu
- Numpad "Stream Deck" for media, audio, system controls

---

### hyprlock.nix

**File:** `home/hyprland/hyprlock.nix`
**Profile gate:** `home.profiles.desktop` + `environment == "hyprland"`

Lock screen with blurred screenshot background (3 blur passes, brightness 0.82):

- **Time display:** 120px JetBrains Mono, white
- **Date display:** 24px, white
- **User label:** "Hi $USER", 20px
- **Input field:** 300×50px, centered, dot cursor, 3px outline, check/fail color feedback
- **No grace period** (immediate lock)

---

### hypridle.nix

**File:** `home/hyprland/hypridle.nix`
**Profile gate:** `home.profiles.desktop` + `environment == "hyprland"`

Idle daemon with progressive timeouts:

| Timeout | Action |
|---------|--------|
| 5 min | Dim brightness to 10% |
| 10 min | Lock session |
| 11 min | DPMS off |
| 30 min | Suspend |

On resume from dim: restore previous brightness.

---

### waybar.nix

**File:** `home/hyprland/waybar.nix`
**Profile gate:** `home.profiles.desktop` + `environment == "hyprland"`

Status bar with systemd integration. Layout: **Left** → menu + workspaces | **Center** → clock + update indicator + recording indicator | **Right** → tray expander + bluetooth + network + pulseaudio + CPU + battery

**Modules:**
- **Workspaces:** Persistent 1–5, active indicator 󱓻, number icons
- **Clock:** `{:A %H:%M}`, alt format with date/week number
- **Network:** WiFi signal icons, disconnected 󰤮, bandwidth tooltip
- **Battery:** Icon set with charging states, critical blink animation, power tooltip
- **Pulseaudio:** Volume icons, right-click mute, scroll step 5%
- **Custom update:** Hourly check, click → `kitty -e update-system`
- **Custom recording indicator:** Shows "REC" when wf-recorder is running
- **Custom menu:** 󱓻 icon, click → walker, right-click → kitty

**Styling:** Catppuccin Mocha palette, JetBrainsMono Nerd Font 13px, semi-transparent background (`rgba(30, 30, 46, 0.9)`)

---

### noctalia.nix

**File:** `home/hyprland/noctalia.nix`
**Profile gate:** `home.profiles.desktop` + `environment == "hyprland"`

Noctalia shell theme system built on Quickshell + Matugen (Material You color generation).

**Packages:** noctalia, quickshell, matugen, playerctl, brightnessctl, pamixer, pavucontrol, wlsunset, tesseract, hyprpicker, fd, ripgrep

**Noctalia settings (selection):**

| Section | Key Settings |
|---------|-------------|
| General | Scale 1.0, backend=hyprland, cursor=Bibata-Modern-Classic |
| Bar | Top, 42px, exclusive, modules: workspaces, media, clock, network, volume, brightness, battery, VPN, updates |
| ControlCenter | Right, 400px, modules: brightness, volume, network, bluetooth, settings |
| Notifications | Top-right, 5s display, max 3 |
| Theme | Dark mode, matugen system colors, accent `#b4a7e6`, JetBrains Mono 12px |
| Wallpaper | `/home/jpolo/Pictures/Wallpapers`, crop fill mode |
| NightLight | 20:00–08:00, 4000K |
| VPN | Toggle with `um-vpn` default |
| Clock | 24h format, hover for full date |

**Matugen templates:** kitty, alacritty, btop, walker, discord (Vencord), KDE globals — all regenerated from wallpaper colors via Material You M3-Rainbow scheme.

---

## Shell Configs

### zsh.nix

**File:** `home/shell/zsh.nix`
**Profile gate:** `home.profiles.cli`

Primary shell with Oh My Zsh, completions, autosuggestions, and syntax highlighting.

**History:** 100,000 entries, dedup, shared, ignore-space, extended format

**Plugins:** git, sudo, docker, docker-compose, kubectl, terraform, rust, nix-shell, fast-syntax-highlighting, zsh-autocomplete, zsh-you-should-use

**Key aliases (selection):**

| Category | Notable Aliases |
|----------|----------------|
| Navigation | `..`, `...`, `....` |
| Modern CLI | `ls`→eza, `cat`→bat, `du`→dust, `df`→duf, `top`→btm, `ps`→procs |
| Git | `gs`, `gst`, `ga`, `gc`, `gcm`, `gp`, `gpf`, `glo`, `glg`, `gstash` |
| NixOS | `nos`, `nob`, `not`, `nd`, `ns`, `nb`, `nfu`, `nfc`, `cleanup` |
| Docker | `d`, `dc`, `dcu`, `dps`, `dex`, `dlogs` |
| Kubernetes | `k`, `kgp`, `kgs`, `kl`, `kex`, `kdesc`, `kapp` |
| System | `vim`→nvim, `ports`, `listening`, `myip` |
| Safety | `cp -i`, `mv -i` |
| Vega remote | `vqueue`, `vstatus`, `vlog`, `vsync`, `vpull`, `vrun`, `vport` |
| AI | `aider`, `claude-qwen`, `perplexity`→gemini |

**Custom functions:** `resolve`, `count-dirs`, `count-elements`, `tmux-attach`, `fe` (fzf edit), `fcd` (fzf cd), `fgl` (fzf git log), `fkill` (fzf kill), `dsh` (docker shell), `note`, `extract`, `mkcd`, `cleanup-walker`, `vega-notify`

**Vim mode:** `bindkey -v` with cursor shape feedback (block for normal, beam for insert)

**Keybindings:** `Ctrl+f` → tmux-sessionizer, `Ctrl+g` → fzf directory widget, `Ctrl+r/s` → history search, `Alt+h/j/k/l` → word motion

---

### starship.nix

**File:** `home/shell/starship.nix`
**Profile gate:** `home.profiles.cli`

Starship prompt with custom format string:

```
$directory$nix_shell$git_branch$git_status$character
```

| Module | Style |
|--------|-------|
| Character | ➜ green (success) / red (error) |
| Directory | Bold cyan, truncation length 2, truncate to repo |
| Git branch | Purple with  symbol |
| Git status | Bold red |
| Nix shell | Blue  symbol |
| Python | Yellow  symbol |
| Rust | Red  symbol |
| Node.js | Green  symbol |
| Docker | Blue  symbol |
| Kubernetes |  symbol, always shown |
| AWS | Yellow  symbol |
| Battery | 🔋/⚡/💀 icons, red <10%, yellow <30% |
| Time | Shown, bold white |
| Command duration | Yellow for commands >500ms |

---

### power-user-functions.nix

**File:** `home/shell/power-user-functions.nix`

Advanced Zsh plugins and shell functions:

**Plugins (from GitHub):**
- `zsh-nix-shell` v0.8.0
- `fast-syntax-highlighting` v1.55
- `zsh-autocomplete` 24.09.04
- `zsh-you-should-use` 1.7.3

**Shell functions (selection):**

| Function | Description |
|----------|-------------|
| `z.lua` | Enhanced directory jumping (fzf integration) |
| `qfind` | Find and bat files matching pattern |
| `please` | Repeat last command with sudo |
| `x` | Extract any archive format |
| `serve` | Quick HTTP server (default port 8000) |
| `wttr` | Weather via wttr.in |
| `cheat` | Cheat.sh lookup |
| `convert-to-mp3` | FFmpeg audio conversion |
| `optimg` | Optimize PNG/JPG images |
| `bak` | Backup with timestamp |
| `watch-cmd` | Monitor command output |
| `json` | Pretty-print JSON with jq |
| `pstree` | Process tree (via procs) |
| `memtop` / `cputop` | Top memory/CPU consumers |
| `netstat-listen` | List listening ports |
| `port` | Find process by port |
| `duh` | Disk usage by directory |
| `count` | Count files in directory |
| `genpass` | Generate random password |
| `gclone` | Git clone and cd |
| `nix-shell-pure` | Pure nix-shell |
| `nvl` | Neovim light mode |
| `n` | Quick daily note |
| `todo` | Quick todo list |
| `sysinfo` | System info summary |
| `docker-clean` | Docker system prune |
| `kctx` | Kubectl context switch |
| `ssha` | SSH with agent forwarding |
| `rcp` | Rsync with progress |
| `largest` | Find top 20 largest files |
| `calc` | BC calculator |
| `man` | Colored man pages |
| `fh` | FZF history search |
| `fk` | FZF kill |
| `gwt` | Git worktree with FZF |
| `bench` | Hyperfine benchmark |
| `stats` | Full system stats (CPU, memory, disk, network) |

**Directory bookmarks:** `~nix`, `~proj`, `~dots`, `~dl`

**Pushd settings:** AUTO_PUSHD, PUSHD_IGNORE_DUPS, PUSHD_SILENT, numbered `cd` aliases (`1`–`9`)

---

## Cross-Links

- [[Home Profiles]] — Which programs are enabled per profile
- [[Hyprland]] — System-level Hyprland configuration
- [[Shell & Terminal]] — Terminal emulator and shell ecosystem overview
- [[Dev Shells]] — Nix develop environments