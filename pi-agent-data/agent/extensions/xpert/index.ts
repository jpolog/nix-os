import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import * as yaml from "js-yaml";

// ── Types ──────────────────────────────────────────────────────────────

interface Team {
	id: string;
	label: string;
	emoji: string;
	description: string;
	agents: string[];
	skills: string[];
	kind: "workflow" | "language" | "category";
}

interface AgentInfo {
	name: string;
	description: string;
	category: string;
	model: string;
	filePath: string;
}

interface SkillInfo {
	name: string;
	description: string;
	dir: string;
}
interface DiscoveredModel {
	id: string;
	name: string;
	params: string;
	reasoning: boolean;
	context: number;
	max_tokens: number;
	local: boolean;
	cloud: boolean;
	source: string;
	strengths: string[];
	weaknesses: string[];
	multimodal?: boolean;
	thinking?: string;
	family?: string;
	quantization?: string;
}

interface CommandContext {
	ui: {
		select: (msg: string, opts: string[]) => Promise<string | undefined>;
		notify: (msg: string, level: string) => void;
		confirm: (msg: string) => Promise<boolean>;
	};
}

// ── Constants ───────────────────────────────────────────────────────────

const AGENTS_DIR = path.join(os.homedir(), ".omp", "agent", "agents");
const SKILLS_DIR = path.join(os.homedir(), ".omp", "agent", "skills");
const CONFIG_PATH = path.join(os.homedir(), ".omp", "agent", "config.yml");
const MODELS_LOCAL_PATH = path.join(os.homedir(), ".omp", "models.local.json");

// ── Team definitions ────────────────────────────────────────────────────
// Every one of the 154 custom agents must appear in at least one team.

const TEAMS: Team[] = [
	// ── Workflow teams (cross-cutting, task-oriented) ───────────────────
	{
		id: "phd-research",
		label: "PhD Research",
		emoji: "🎓",
		description: "Full academic research pipeline: literature discovery, retrieval, review, writing, revision, and citation formatting.",
		agents: [
			"res-phd-academic-writer",
			"res-phd-peer-reviewer",
			"res-phd-literature-searcher",
			"res-phd-plagiarism-guard",
			"res-phd-literature-retriever",
			"res-phd-literature-reviewer",
			"res-phd-research-methodologist",
			"res-phd-data-analyst",
			"res-phd-citation-formatter",
		],
		skills: ["academic-writing", "literature-search", "style-guard", "literature-retrieval"],
		kind: "workflow",
	},
	{
		id: "python-dev",
		label: "Python Development",
		emoji: "🐍",
		description: "Python specialist with backend, AI/ML, and data analysis. For building Python projects end-to-end.",
		agents: [
			"lang-python-pro",
			"lang-django-developer",
			"lang-fastapi-developer",
			"dev-backend-developer",
			"data-ai-engineer",
			"data-data-analyst",
			"data-data-scientist",
			"data-data-engineer",
		],
		skills: ["nixify"],
		kind: "workflow",
	},
	{
		id: "rust-dev",
		label: "Rust Development",
		emoji: "🦀",
		description: "Rust systems programming with security review and performance optimization.",
		agents: ["lang-rust-engineer", "qual-code-reviewer", "qual-security-auditor"],
		skills: ["nixify"],
		kind: "workflow",
	},
	{
		id: "typescript-frontend",
		label: "TypeScript & Frontend",
		emoji: "⚛️",
		description: "Full-stack TypeScript with React, Next.js, Angular, Vue, and modern frontend tooling.",
		agents: [
			"lang-typescript-pro",
			"lang-react-specialist",
			"lang-nextjs-developer",
			"dev-frontend-developer",
			"dev-ui-designer",
			"lang-node-specialist",
			"lang-angular-architect",
			"lang-vue-expert",
			"lang-javascript-pro",
		],
		skills: ["nixify", "webapp-testing"],
		kind: "workflow",
	},
	{
		id: "go-dev",
		label: "Go Development",
		emoji: "🐹",
		description: "Go specialist with backend and infrastructure support.",
		agents: ["lang-golang-pro", "dev-backend-developer", "infra-devops-engineer"],
		skills: ["nixify"],
		kind: "workflow",
	},
	{
		id: "java-dev",
		label: "Java Development",
		emoji: "☕",
		description: "Java enterprise with Spring Boot and backend architecture.",
		agents: ["lang-java-architect", "lang-spring-boot-engineer", "dev-backend-developer"],
		skills: ["nixify"],
		kind: "workflow",
	},
	{
		id: "devops-shipping",
		label: "DevOps & Shipping",
		emoji: "🚢",
		description: "Deploy, containerize, orchestrate, and ship. Docker, Terraform, Terragrunt, Kubernetes, SRE.",
		agents: [
			"infra-devops-engineer",
			"infra-docker-expert",
			"infra-terraform-engineer",
			"infra-terragrunt-expert",
			"infra-kubernetes-specialist",
			"infra-sre-engineer",
			"infra-cloud-architect",
			"infra-deployment-engineer",
		],
		skills: ["nixify"],
		kind: "workflow",
	},
	{
		id: "security-review",
		label: "Security & Code Review",
		emoji: "🔒",
		description: "Deep security audit, code review, penetration testing, AD security, and compliance.",
		agents: [
			"qual-code-reviewer",
			"qual-security-auditor",
			"qual-ad-security-reviewer",
			"qual-penetration-tester",
			"qual-compliance-auditor",
			"infra-security-engineer",
		],
		skills: [],
		kind: "workflow",
	},
	{
		id: "documentation",
		label: "Documentation & Writing",
		emoji: "📝",
		description: "Technical writing, API docs, academic writing, peer review, and knowledge management.",
		agents: [
			"dx-documentation-engineer",
			"spec-api-documenter",
			"dx-readme-generator",
			"res-phd-academic-writer",
			"res-phd-citation-formatter",
			"res-phd-peer-reviewer",
			"obsidian-vault-manager",
		],
		skills: ["academic-writing", "style-guard"],
		kind: "workflow",
	},
	{
		id: "data-science",
		label: "Data Science & ML",
		emoji: "📊",
		description: "Statistical analysis, ML engineering, data pipelines, NLP, and database optimization.",
		agents: [
			"data-data-scientist",
			"data-machine-learning-engineer",
			"data-ml-engineer",
			"data-ai-engineer",
			"data-data-analyst",
			"data-nlp-engineer",
			"data-data-engineer",
			"data-database-optimizer",
		],
		skills: [],
		kind: "workflow",
	},
	{
		id: "fullstack-web",
		label: "Full-Stack Web App",
		emoji: "🌐",
		description: "End-to-end web development: backend API, frontend, database, testing, GraphQL.",
		agents: [
			"dev-fullstack-developer",
			"dev-backend-developer",
			"dev-frontend-developer",
			"lang-typescript-pro",
			"lang-node-specialist",
			"data-postgres-pro",
			"qual-test-automator",
			"dev-graphql-architect",
		],
		skills: ["nixify", "webapp-testing"],
		kind: "workflow",
	},
	{
		id: "mobile-dev",
		label: "Mobile Development",
		emoji: "📱",
		description: "Cross-platform mobile: React Native, Flutter, Swift, Kotlin.",
		agents: [
			"dev-mobile-developer",
			"lang-expo-react-native-expert",
			"lang-flutter-expert",
			"lang-swift-expert",
			"lang-kotlin-specialist",
		],
		skills: [],
		kind: "workflow",
	},
	{
		id: "architecture",
		label: "Architecture & Design",
		emoji: "🏛️",
		description: "API design, microservices, cloud architecture, platform engineering.",
		agents: [
			"dev-api-designer",
			"dev-microservices-architect",
			"infra-cloud-architect",
			"infra-platform-engineer",
			"dev-graphql-architect",
		],
		skills: [],
		kind: "workflow",
	},
	{
		id: "quality-assurance",
		label: "Quality Assurance",
		emoji: "🧪",
		description: "QA strategy, test automation, debugging, performance, accessibility.",
		agents: [
			"qual-qa-expert",
			"qual-test-automator",
			"qual-debugger",
			"qual-error-detective",
			"qual-performance-engineer",
			"qual-accessibility-tester",
			"qual-ui-ux-tester",
		],
		skills: [],
		kind: "workflow",
	},

	// ── Language teams ─────────────────────────────────────────────────
	{
		id: "lang-python",
		label: "Python",
		emoji: "🐍",
		description: "Python ecosystem: core, Django, FastAPI, data science, AI.",
		agents: ["lang-python-pro", "lang-django-developer", "lang-fastapi-developer", "data-data-scientist", "data-ai-engineer"],
		skills: ["nixify"],
		kind: "language",
	},
	{
		id: "lang-rust",
		label: "Rust",
		emoji: "🦀",
		description: "Rust systems programming with code review.",
		agents: ["lang-rust-engineer", "qual-code-reviewer"],
		skills: ["nixify"],
		kind: "language",
	},
	{
		id: "lang-typescript",
		label: "TypeScript & JS",
		emoji: "⚛️",
		description: "TypeScript, React, Next.js, Node.js, Angular, Vue, and JavaScript.",
		agents: ["lang-typescript-pro", "lang-react-specialist", "lang-nextjs-developer", "lang-node-specialist", "lang-angular-architect", "lang-vue-expert", "lang-javascript-pro"],
		skills: ["nixify", "webapp-testing"],
		kind: "language",
	},
	{
		id: "lang-go",
		label: "Go",
		emoji: "🐹",
		description: "Go with DevOps support.",
		agents: ["lang-golang-pro", "infra-devops-engineer"],
		skills: ["nixify"],
		kind: "language",
	},
	{
		id: "lang-java",
		label: "Java",
		emoji: "☕",
		description: "Java enterprise with Spring Boot.",
		agents: ["lang-java-architect", "lang-spring-boot-engineer"],
		skills: ["nixify"],
		kind: "language",
	},
	{
		id: "lang-cpp",
		label: "C++",
		emoji: "⚙️",
		description: "C++ systems programming and embedded systems.",
		agents: ["lang-cpp-pro", "spec-embedded-systems"],
		skills: ["nixify"],
		kind: "language",
	},
	{
		id: "lang-csharp",
		label: "C# / .NET",
		emoji: "🟣",
		description: "C#, .NET Core, and .NET Framework 4.8.",
		agents: ["lang-csharp-developer", "lang-dotnet-core-expert", "lang-dotnet-framework-4.8-expert"],
		skills: ["nixify"],
		kind: "language",
	},
	{
		id: "lang-php",
		label: "PHP",
		emoji: "🐘",
		description: "PHP with Laravel and Symfony.",
		agents: ["lang-php-pro", "lang-laravel-specialist", "lang-symfony-specialist"],
		skills: [],
		kind: "language",
	},
	{
		id: "lang-ruby",
		label: "Ruby",
		emoji: "💎",
		description: "Ruby on Rails development.",
		agents: ["lang-rails-expert"],
		skills: [],
		kind: "language",
	},
	{
		id: "lang-elixir",
		label: "Elixir",
		emoji: "🧪",
		description: "Elixir with OTP and Phoenix.",
		agents: ["lang-elixir-expert"],
		skills: [],
		kind: "language",
	},
	{
		id: "lang-swift",
		label: "Swift",
		emoji: "🍎",
		description: "Swift for iOS and server-side.",
		agents: ["lang-swift-expert", "dev-mobile-developer"],
		skills: [],
		kind: "language",
	},
	{
		id: "lang-sql",
		label: "SQL",
		emoji: "🗃️",
		description: "SQL with PostgreSQL and database optimization.",
		agents: ["lang-sql-pro", "data-postgres-pro", "data-database-optimizer"],
		skills: [],
		kind: "language",
	},
	{
		id: "lang-powershell",
		label: "PowerShell",
		emoji: "💻",
		description: "PowerShell 5.1, 7+, module architecture, and UI.",
		agents: ["lang-powershell-5.1-expert", "lang-powershell-7-expert", "dx-powershell-module-architect", "dx-powershell-ui-architect"],
		skills: [],
		kind: "language",
	},

	// ── Category teams (entire prefix) ─────────────────────────────────
	{
		id: "cat-dev",
		label: "Development (dev)",
		emoji: "🏗️",
		description: "All dev-* agents: API design, backend, frontend, fullstack, mobile, and more.",
		agents: [
			"dev-api-designer",
			"dev-backend-developer",
			"dev-design-bridge",
			"dev-electron-pro",
			"dev-frontend-developer",
			"dev-fullstack-developer",
			"dev-graphql-architect",
			"dev-microservices-architect",
			"dev-mobile-developer",
			"dev-ui-designer",
			"dev-websocket-engineer",
		],
		skills: [],
		kind: "category",
	},
	{
		id: "cat-infra",
		label: "Infrastructure (infra)",
		emoji: "☁️",
		description: "All infra-* agents: cloud, containers, Kubernetes, Terraform, security, SRE.",
		agents: [
			"infra-azure-infra-engineer",
			"infra-cloud-architect",
			"infra-database-administrator",
			"infra-deployment-engineer",
			"infra-devops-engineer",
			"infra-devops-incident-responder",
			"infra-docker-expert",
			"infra-incident-responder",
			"infra-kubernetes-specialist",
			"infra-network-engineer",
			"infra-platform-engineer",
			"infra-security-engineer",
			"infra-sre-engineer",
			"infra-terraform-engineer",
			"infra-terragrunt-expert",
			"infra-windows-infra-admin",
		],
		skills: [],
		kind: "category",
	},
	{
		id: "cat-qual",
		label: "Quality (qual)",
		emoji: "✅",
		description: "All qual-* agents: QA, testing, code review, security, compliance, debugging.",
		agents: [
			"qual-accessibility-tester",
			"qual-ad-security-reviewer",
			"qual-ai-writing-auditor",
			"qual-architect-reviewer",
			"qual-chaos-engineer",
			"qual-code-reviewer",
			"qual-compliance-auditor",
			"qual-debugger",
			"qual-error-detective",
			"qual-penetration-tester",
			"qual-performance-engineer",
			"qual-powershell-security-hardening",
			"qual-qa-expert",
			"qual-security-auditor",
			"qual-test-automator",
			"qual-ui-ux-tester",
		],
		skills: [],
		kind: "category",
	},
	{
		id: "cat-data",
		label: "Data & AI (data)",
		emoji: "📊",
		description: "All data-* agents: data science, ML, AI, data engineering, NLP, databases.",
		agents: [
			"data-ai-engineer",
			"data-data-analyst",
			"data-data-engineer",
			"data-data-scientist",
			"data-database-optimizer",
			"data-llm-architect",
			"data-machine-learning-engineer",
			"data-ml-engineer",
			"data-mlops-engineer",
			"data-nlp-engineer",
			"data-postgres-pro",
			"data-prompt-engineer",
			"data-reinforcement-learning-engineer",
		],
		skills: [],
		kind: "category",
	},
	{
		id: "cat-dx",
		label: "Developer Experience (dx)",
		emoji: "🔧",
		description: "All dx-* agents: builds, CLIs, docs, git, refactoring, tooling.",
		agents: [
			"dx-build-engineer",
			"dx-cli-developer",
			"dx-dependency-manager",
			"dx-documentation-engineer",
			"dx-dx-optimizer",
			"dx-git-workflow-manager",
			"dx-legacy-modernizer",
			"dx-mcp-developer",
			"dx-powershell-module-architect",
			"dx-powershell-ui-architect",
			"dx-readme-generator",
			"dx-refactoring-specialist",
			"dx-slack-expert",
			"dx-tooling-engineer",
		],
		skills: [],
		kind: "category",
	},
	{
		id: "cat-meta",
		label: "Meta-Orchestration (meta)",
		emoji: "🎛️",
		description: "All meta-* agents: multi-agent coordination, context, error handling, workflow.",
		agents: [
			"meta-agent-installer",
			"meta-agent-organizer",
			"meta-codebase-orchestrator",
			"meta-context-manager",
			"meta-error-coordinator",
			"meta-it-ops-orchestrator",
			"meta-knowledge-synthesizer",
			"meta-multi-agent-coordinator",
			"meta-performance-monitor",
			"meta-task-distributor",
			"meta-workflow-orchestrator",
		],
		skills: [],
		kind: "category",
	},
	{
		id: "cat-biz",
		label: "Business (biz)",
		emoji: "💼",
		description: "All biz-* agents: business analysis, marketing, legal, product, sales.",
		agents: [
			"biz-business-analyst",
			"biz-content-marketer",
			"biz-customer-success-manager",
			"biz-legal-advisor",
			"biz-license-engineer",
			"biz-product-manager",
			"biz-project-manager",
			"biz-sales-engineer",
			"biz-scrum-master",
			"biz-technical-writer",
			"biz-ux-researcher",
			"biz-wordpress-master",
		],
		skills: [],
		kind: "category",
	},
	{
		id: "cat-spec",
		label: "Specialized (spec)",
		emoji: "🎯",
		description: "All spec-* agents: blockchain, fintech, healthcare, IoT, quant, game dev.",
		agents: [
			"spec-api-documenter",
			"spec-blockchain-developer",
			"spec-embedded-systems",
			"spec-fintech-engineer",
			"spec-game-developer",
			"spec-healthcare-admin",
			"spec-iot-engineer",
			"spec-m365-admin",
			"spec-mobile-app-developer",
			"spec-payment-integration",
			"spec-quant-analyst",
			"spec-risk-manager",
			"spec-seo-specialist",
		],
		skills: [],
		kind: "category",
	},
	{
		id: "cat-res",
		label: "Research (res)",
		emoji: "🔬",
		description: "All res-* agents: PhD research, market research, competitive analysis, trends.",
		agents: [
			"res-competitive-analyst",
			"res-data-researcher",
			"res-market-researcher",
			"res-phd-academic-writer",
			"res-phd-citation-formatter",
			"res-phd-data-analyst",
			"res-phd-literature-retriever",
			"res-phd-literature-reviewer",
			"res-phd-literature-searcher",
			"res-phd-peer-reviewer",
			"res-phd-plagiarism-guard",
			"res-phd-research-methodologist",
			"res-project-idea-validator",
			"res-research-analyst",
			"res-scientific-literature-researcher",
			"res-search-specialist",
			"res-trend-analyst",
		],
		skills: [],
		kind: "category",
	},
	{
		id: "cat-lang",
		label: "Languages (lang)",
		emoji: "🗣️",
		description: "All lang-* agents: every language specialist across the catalog.",
		agents: [
			"lang-angular-architect",
			"lang-cpp-pro",
			"lang-csharp-developer",
			"lang-django-developer",
			"lang-dotnet-core-expert",
			"lang-dotnet-framework-4.8-expert",
			"lang-elixir-expert",
			"lang-expo-react-native-expert",
			"lang-fastapi-developer",
			"lang-flutter-expert",
			"lang-golang-pro",
			"lang-java-architect",
			"lang-javascript-pro",
			"lang-kotlin-specialist",
			"lang-laravel-specialist",
			"lang-nextjs-developer",
			"lang-node-specialist",
			"lang-php-pro",
			"lang-powershell-5.1-expert",
			"lang-powershell-7-expert",
			"lang-python-pro",
			"lang-rails-expert",
			"lang-react-specialist",
			"lang-rust-engineer",
			"lang-spring-boot-engineer",
			"lang-sql-pro",
			"lang-swift-expert",
			"lang-symfony-specialist",
			"lang-typescript-pro",
			"lang-vue-expert",
		],
		skills: [],
		kind: "category",
	},
];

// ── Helpers ─────────────────────────────────────────────────────────────

function parseYamlConfig(content: string): Record<string, unknown> {
	try {
		return (yaml.load(content) as Record<string, unknown>) || {};
	} catch {
		return {};
	}
}

function loadDiscoveredModels(): DiscoveredModel[] {
	try {
		const content = fs.readFileSync(MODELS_LOCAL_PATH, "utf-8");
		const data = JSON.parse(content) as { local_models: DiscoveredModel[] };
		return data.local_models || [];
	} catch {
		return [];
	}
}

function stringifyYamlConfig(config: Record<string, unknown>): string {
	return yaml.dump(config, { lineWidth: -1, noRefs: true });
}

function getDisabledAgents(): Set<string> {
	try {
		const content = fs.readFileSync(CONFIG_PATH, "utf-8");
		const config = parseYamlConfig(content);
		const task = (config.task || {}) as Record<string, unknown>;
		const list = (task.disabledAgents || []) as string[];
		return new Set(list);
	} catch {
		return new Set();
	}
}

function setDisabledAgents(disabled: Set<string>): void {
	const content = fs.readFileSync(CONFIG_PATH, "utf-8");
	const config = parseYamlConfig(content);
	const task = ((config.task || {}) as Record<string, unknown>);
	task.disabledAgents = Array.from(disabled).sort();
	config.task = task;
	fs.writeFileSync(CONFIG_PATH, stringifyYamlConfig(config), "utf-8");
}

function loadAgents(): AgentInfo[] {
	const agents: AgentInfo[] = [];
	try {
		const entries = fs.readdirSync(AGENTS_DIR).filter(f => f.endsWith(".md")).sort();
		for (const entry of entries) {
			const filePath = path.join(AGENTS_DIR, entry);
			const content = fs.readFileSync(filePath, "utf-8");
			const fmMatch = content.match(/^---\n([\s\S]*?)\n---/);
			if (!fmMatch) continue;
			const fm = fmMatch[1];
			let name = "", description = "", model = "";
			for (const line of fm.split("\n")) {
				const nm = line.match(/^name:\s*(.+)$/);
				if (nm) name = nm[1].trim();
				const dm = line.match(/^description:\s*["']?(.+?)["']?\s*$/);
				if (dm) description = dm[1].trim();
				const mm = line.match(/^model:\s*(.+)$/);
				if (mm) model = mm[1].trim();
			}
			if (!name) continue;
			const category = name.split("-")[0];
			agents.push({ name, description, category, model, filePath });
		}
	} catch { /* dir may not exist */ }
	return agents;
}

function loadSkills(): SkillInfo[] {
	const skills: SkillInfo[] = [];
	try {
		const entries = fs.readdirSync(SKILLS_DIR).filter(d => {
			return fs.existsSync(path.join(SKILLS_DIR, d, "SKILL.md"));
		}).sort();
		for (const entry of entries) {
			const skillFile = path.join(SKILLS_DIR, entry, "SKILL.md");
			const content = fs.readFileSync(skillFile, "utf-8");
			const fmMatch = content.match(/^---\n([\s\S]*?)\n---/);
			if (!fmMatch) continue;
			const fm = fmMatch[1];
			let name = "", description = "";
			for (const line of fm.split("\n")) {
				const nm = line.match(/^name:\s*(.+)$/);
				if (nm) name = nm[1].trim();
				const dm = line.match(/^description:\s*["']?(.+?)["']?\s*$/);
				if (dm) description = dm[1].trim();
			}
			if (!name) continue;
			skills.push({ name, description, dir: entry });
		}
	} catch { /* dir may not exist */ }
	return skills;
}

function progressBar(active: number, total: number, width = 10): string {
	if (total === 0) return "░".repeat(width);
	const filled = Math.round((active / total) * width);
	return "█".repeat(filled) + "░".repeat(width - filled);
}

function teamStatusLabel(active: number, total: number): string {
	if (active === 0) return "OFF";
	if (active === total) return "ON ";
	return "PART";
}

// ── Rendering ────────────────────────────────────────────────────────────

function renderTeamDetail(team: Team, disabled: Set<string>, agents: AgentInfo[]): string {
	const lines: string[] = [];
	let activeCount = 0;

	lines.push(`${team.emoji} ${team.label}`);
	lines.push(`${team.description}`);
	lines.push("");

	for (const agentId of team.agents) {
		const isDisabled = disabled.has(agentId);
		const agent = agents.find(a => a.name === agentId);
		const status = isDisabled ? "✗" : "✓";
		const modelLabel = agent ? (agent.model.split("/").pop() || agent.model) : "?";
		if (!isDisabled) activeCount++;
		lines.push(`  ${status} ${agentId.padEnd(36)} (${modelLabel})`);
	}

	if (team.skills.length > 0) {
		lines.push("");
		lines.push(`Paired skills: ${team.skills.join(", ")}`);
	}

	lines.push("");
	lines.push(`${activeCount}/${team.agents.length} agents active`);

	return lines.join("\n");
}

function renderStatusOverview(disabled: Set<string>): string {
	const lines: string[] = [];

	lines.push("Team Activation Status");
	lines.push("═".repeat(70));
	lines.push("");

	const workflowTeams = TEAMS.filter(t => t.kind === "workflow");
	const languageTeams = TEAMS.filter(t => t.kind === "language");
	const categoryTeams = TEAMS.filter(t => t.kind === "category");

	lines.push("WORKFLOW TEAMS");
	for (const team of workflowTeams) {
		const active = team.agents.filter(id => !disabled.has(id)).length;
		const total = team.agents.length;
		const bar = progressBar(active, total);
		const label = teamStatusLabel(active, total);
		lines.push(`${team.emoji} ${team.label.padEnd(28)} [${bar}] ${String(active).padStart(2)}/${total}  ${label}`);
	}

	lines.push("");
	lines.push("LANGUAGE TEAMS");
	for (const team of languageTeams) {
		const active = team.agents.filter(id => !disabled.has(id)).length;
		const total = team.agents.length;
		const bar = progressBar(active, total);
		const label = teamStatusLabel(active, total);
		lines.push(`${team.emoji} ${team.label.padEnd(28)} [${bar}] ${String(active).padStart(2)}/${total}  ${label}`);
	}

	lines.push("");
	lines.push("CATEGORY TEAMS");
	for (const team of categoryTeams) {
		const active = team.agents.filter(id => !disabled.has(id)).length;
		const total = team.agents.length;
		const bar = progressBar(active, total);
		const label = teamStatusLabel(active, total);
		lines.push(`${team.emoji} ${team.label.padEnd(28)} [${bar}] ${String(active).padStart(2)}/${total}  ${label}`);
	}

	return lines.join("\n");
}

function renderCategoryDetail(team: Team, disabled: Set<string>, agents: AgentInfo[]): string {
	const lines: string[] = [];
	let activeCount = 0;

	lines.push(`${team.emoji} ${team.label} — Category View`);
	lines.push(`${team.description}`);
	lines.push("");

	for (const agentId of team.agents) {
		const isDisabled = disabled.has(agentId);
		const agent = agents.find(a => a.name === agentId);
		const status = isDisabled ? "✗" : "✓";
		const modelLabel = agent ? (agent.model.split("/").pop() || agent.model) : "?";
		if (!isDisabled) activeCount++;
		lines.push(`  ${status} ${agentId.padEnd(36)} (${modelLabel})`);
	}

	lines.push("");
	lines.push(`${activeCount}/${team.agents.length} agents active`);

	return lines.join("\n");
}

// ── Extension ────────────────────────────────────────────────────────────

export default function xpertExtension(pi: ExtensionAPI) {
	pi.registerCommand("xpert", {
		description: "Team-based expert agent browser and manager",
		handler: async (args, ctx) => {
			const arg = (args || "").trim().toLowerCase();
			const agents = loadAgents();
			const disabled = getDisabledAgents();

			// ── /xpert status ──────────────────────────────────────────
			if (arg === "status") {
				pi.sendMessage({
					customType: "xpert-status",
					content: renderStatusOverview(disabled),
					display: true,
					attribution: "user",
				}, { triggerTurn: false });
				ctx.ui.notify("Team status loaded", "info");
				return;
			}

			// ── /xpert models ──────────────────────────────────────────
			if (arg === "models") {
				const discovered = loadDiscoveredModels();
				const config = parseYamlConfig(fs.readFileSync(CONFIG_PATH, "utf-8"));
				const currentDefault = ((config.modelRoles || {}) as Record<string, string>).default || "ollama/glm-5.1:cloud";

				let content = "**Ollama Model Catalog**\n\n";
				content += `Default model: \`${currentDefault}\`\n\n`;

				if (discovered.length === 0) {
					content += "_No locally discovered models beyond the curated catalog._\n";
					content += "_Pull a model with `ollama pull <model>` and run `ollama-discover` to make it appear here._\n";
				} else {
					content += `Discovered **${discovered.length}** additional model(s) available in your local Ollama:\n\n`;
					for (const m of discovered) {
						const source = m.source === "cloud" ? "☁️" : "🏠";
						const reasoning = m.reasoning ? "🧠" : "";
						const multimodal = m.multimodal ? "👁️" : "";
						const ctx = m.context >= 262144 ? `${Math.round(m.context / 1024)}K` : `${m.context}`;
						const maxTok = m.max_tokens >= 1024 ? `${Math.round(m.max_tokens / 1024)}K` : `${m.max_tokens}`;
						content += `${source} \`${m.id}\` — ${m.name}`;
						if (m.params && m.params !== "unknown") content += ` (${m.params})`;
						content += `\n`;
						content += `   ${reasoning}${multimodal} ctx=${ctx} out=${maxTok}`;
						if (m.quantization) content += ` quant=${m.quantization}`;
						content += `\n`;
					}
					content += `\nTo use a discovered model, set it in config.yml:\n`;
					content += `\`\`\`yaml\nmodelRoles:\n  default: ollama/<model-name>:<tag>\n\`\`\`\n`;
					content += `\nOr override a specific role:\n\`\`\`yaml\nmodelRoles:\n  agentic-engineering: ollama/<model-name>:<tag>\n\`\`\``;
				}

				pi.sendMessage({
					customType: "xpert-models",
					content,
					display: true,
					attribution: "user",
				}, { triggerTurn: false });
				ctx.ui.notify(`Found ${discovered.length} discovered model(s)`, "info");
				return;
			}

			// ── /xpert on <team-id> ────────────────────────────────────
			if (arg.startsWith("on ")) {
				const teamId = arg.slice(3).trim();
				const team = TEAMS.find(t => t.id === teamId);
				if (!team) {
					ctx.ui.notify(`Unknown team: "${teamId}". Available: ${TEAMS.map(t => t.id).join(", ")}`, "warning");
					return;
				}
				const currentDisabled = getDisabledAgents();
				for (const agentId of team.agents) {
					currentDisabled.delete(agentId);
				}
				setDisabledAgents(currentDisabled);
				const activeCount = team.agents.filter(id => !currentDisabled.has(id)).length;
				pi.sendMessage({
					customType: "xpert-activate",
					content: `${team.emoji} Activated **${team.label}** — ${activeCount}/${team.agents.length} agents enabled.\n\n${renderTeamDetail(team, currentDisabled, agents)}`,
					display: true,
					attribution: "user",
				}, { triggerTurn: false });
				ctx.ui.notify(`${team.label} activated (${activeCount} agents)`, "info");
				return;
			}

			// ── /xpert off <team-id> ───────────────────────────────────
			if (arg.startsWith("off ")) {
				const teamId = arg.slice(3).trim();
				const team = TEAMS.find(t => t.id === teamId);
				if (!team) {
					ctx.ui.notify(`Unknown team: "${teamId}". Available: ${TEAMS.map(t => t.id).join(", ")}`, "warning");
					return;
				}
				const currentDisabled = getDisabledAgents();
				for (const agentId of team.agents) {
					currentDisabled.add(agentId);
				}
				setDisabledAgents(currentDisabled);
				pi.sendMessage({
					customType: "xpert-deactivate",
					content: `${team.emoji} Deactivated **${team.label}** — all ${team.agents.length} agents disabled.`,
					display: true,
					attribution: "user",
				}, { triggerTurn: false });
				ctx.ui.notify(`${team.label} deactivated`, "info");
				return;
			}

			// ── Interactive: hierarchical navigation ──────────────────────

			// Level 1: Top-level action selection
			const mainOptions = [
				"📂 Browse Teams",
				"🏷️ Browse Categories",
				"⚡ Quick Toggle",
				"📊 Status Overview",
				"🔮 Discovered Models",
			];

			const mainChoice = await ctx.ui.select("Xpert — Agent Team Manager", mainOptions);
			if (!mainChoice) return;

			// ── Browse Teams (workflow + language) ────────────────────────
			if (mainChoice === "📂 Browse Teams") {
				await browseTeams(pi, ctx, agents);
				return;
			}

			// ── Browse Categories ────────────────────────────────────────
			if (mainChoice === "🏷️ Browse Categories") {
				await browseCategories(pi, ctx, agents);
				return;
			}

			// ── Quick Toggle ────────────────────────────────────────────
			if (mainChoice === "⚡ Quick Toggle") {
				await quickToggle(pi, ctx, agents);
				return;
			}

			// ── Status Overview ─────────────────────────────────────────
			if (mainChoice === "📊 Status Overview") {
				pi.sendMessage({
					customType: "xpert-status",
					content: renderStatusOverview(getDisabledAgents()),
					display: true,
					attribution: "user",
				}, { triggerTurn: false });
				ctx.ui.notify("Status overview loaded", "info");
				return;
			}

			// ── Discovered Models ────────────────────────────────────────
			if (mainChoice === "🔮 Discovered Models") {
				const discovered = loadDiscoveredModels();
				const config = parseYamlConfig(fs.readFileSync(CONFIG_PATH, "utf-8"));
				const currentDefault = ((config.modelRoles || {}) as Record<string, string>).default || "ollama/glm-5.1:cloud";

				let content = "**Ollama Model Catalog**\n\n";
				content += `Default model: \`${currentDefault}\`\n\n`;

				if (discovered.length === 0) {
					content += "_No locally discovered models beyond the curated catalog._\n";
					content += "_Pull a model with `ollama pull <model>` and run `ollama-discover` to make it appear here._\n";
				} else {
					content += `Discovered **${discovered.length}** additional model(s) available in your local Ollama:\n\n`;
					for (const m of discovered) {
						const source = m.source === "cloud" ? "☁️" : "🏠";
						const reasoning = m.reasoning ? "🧠" : "";
						const multimodal = m.multimodal ? "👁️" : "";
						const ctx = m.context >= 262144 ? `${Math.round(m.context / 1024)}K` : `${m.context}`;
						const maxTok = m.max_tokens >= 1024 ? `${Math.round(m.max_tokens / 1024)}K` : `${m.max_tokens}`;
						content += `${source} \`${m.id}\` — ${m.name}`;
						if (m.params && m.params !== "unknown") content += ` (${m.params})`;
						content += `\n`;
						content += `   ${reasoning}${multimodal} ctx=${ctx} out=${maxTok}`;
						if (m.quantization) content += ` quant=${m.quantization}`;
						content += `\n`;
					}
					content += `\nTo use a discovered model, set it in config.yml:\n`;
					content += `\`\`\`yaml\nmodelRoles:\n  default: ollama/<model-name>:<tag>\n\`\`\`\n`;
					content += `\nOr override a specific role:\n\`\`\`yaml\nmodelRoles:\n  agentic-engineering: ollama/<model-name>:<tag>\n\`\`\``;
				}

				pi.sendMessage({
					customType: "xpert-models",
					content,
					display: true,
					attribution: "user",
				}, { triggerTurn: false });
				ctx.ui.notify(`Found ${discovered.length} discovered model(s)`, "info");
				return;
			}
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		const disabled = getDisabledAgents();
		const activeTeams = TEAMS.filter(team => team.agents.some(id => !disabled.has(id)));
		const teamSummary = activeTeams.length > 0
			? activeTeams.slice(0, 5).map(t => t.emoji + " " + t.label).join(", ") + (activeTeams.length > 5 ? " ..." : "")
			: "none";
		ctx.ui.notify(
			`Xpert: ${activeTeams.length}/${TEAMS.length} teams active (${teamSummary}). Use /xpert to manage.`,
			"info",
		);

		// Notify about newly discovered models
		const discovered = loadDiscoveredModels();
		if (discovered.length > 0) {
			const modelNames = discovered.map(m => m.id.split("/").pop()).join(", ");
			ctx.ui.notify(
				`Ollama: ${discovered.length} additional model(s) available — /xpert models to see them`,
				"info",
			);
		}
	});
}

// ── Browse Teams: workflow + language teams ────────────────────────────

async function browseTeams(pi: ExtensionAPI, ctx: CommandContext, agents: AgentInfo[]): Promise<void> {
	const disabled = getDisabledAgents();
	const selectableTeams = TEAMS.filter(t => t.kind === "workflow" || t.kind === "language");

	const options = selectableTeams.map(team => {
		const active = team.agents.filter(id => !disabled.has(id)).length;
		const total = team.agents.length;
		const mark = active === total ? "✓" : active === 0 ? "✗" : "◐";
		const kind = team.kind === "workflow" ? "WF" : "LG";
		return `${mark} ${team.emoji} ${team.label} (${active}/${total}) [${kind}]`;
	});
	options.push("← Back");

	const choice = await ctx.ui.select("Browse Teams — select a team", options);
	if (!choice || choice === "← Back") return;

	const idx = options.indexOf(choice);
	if (idx < 0 || idx >= selectableTeams.length) return;
	const team = selectableTeams[idx];

	await manageTeam(pi, ctx, team, agents);
}

// ── Browse Categories ──────────────────────────────────────────────────

async function browseCategories(pi: ExtensionAPI, ctx: CommandContext, agents: AgentInfo[]): Promise<void> {
	const disabled = getDisabledAgents();
	const catTeams = TEAMS.filter(t => t.kind === "category");

	const options = catTeams.map(team => {
		const active = team.agents.filter(id => !disabled.has(id)).length;
		const total = team.agents.length;
		const mark = active === total ? "✓" : active === 0 ? "✗" : "◐";
		return `${mark} ${team.emoji} ${team.label} (${active}/${total})`;
	});
	options.push("← Back");

	const choice = await ctx.ui.select("Browse Categories — select a category", options);
	if (!choice || choice === "← Back") return;

	const idx = options.indexOf(choice);
	if (idx < 0 || idx >= catTeams.length) return;
	const team = catTeams[idx];

	await manageCategory(pi, ctx, team, agents);
}

// ── Quick Toggle: toggle by prefix ─────────────────────────────────────

async function quickToggle(pi: ExtensionAPI, ctx: CommandContext, agents: AgentInfo[]): Promise<void> {
	const prefixes = ["biz", "data", "dev", "dx", "infra", "lang", "meta", "qual", "res", "spec", "res-phd"];
	const disabled = getDisabledAgents();
	const options = prefixes.map(p => {
		const matching = agents.filter(a => a.name.startsWith(p + "-"));
		const activeCount = matching.filter(a => !disabled.has(a.name)).length;
		const mark = matching.length > 0 && activeCount === matching.length ? "✓" : activeCount === 0 ? "✗" : "◐";
		return `${mark} ${p}-* (${activeCount}/${matching.length})`;
	});
	options.push("← Back");

	const choice = await ctx.ui.select("Quick Toggle — select a prefix to toggle", options);
	if (!choice || choice === "← Back") return;

	const idx = options.indexOf(choice);
	if (idx < 0 || idx >= prefixes.length) return;
	const prefix = prefixes[idx];

	const currentDisabled = getDisabledAgents();
	const matchingAgents = agents.filter(a => a.name.startsWith(prefix + "-"));
	if (matchingAgents.length === 0) {
		ctx.ui.notify(`No agents with prefix "${prefix}-"`, "warning");
		return;
	}

	const allDisabled = matchingAgents.every(a => currentDisabled.has(a.name));
	for (const agent of matchingAgents) {
		if (allDisabled) {
			currentDisabled.delete(agent.name);
		} else {
			currentDisabled.add(agent.name);
		}
	}
	setDisabledAgents(currentDisabled);

	const action = allDisabled ? "Activated" : "Deactivated";
	const count = matchingAgents.length;
	pi.sendMessage({
		customType: "xpert-toggle",
		content: `${action} ${count} agents with prefix \`${prefix}-\`.\n\n${matchingAgents.map(a => `${allDisabled ? "✓" : "✗"} ${a.name}`).join("\n")}`,
		display: true,
		attribution: "user",
	}, { triggerTurn: false });
	ctx.ui.notify(`${action} ${count} agents (${prefix}-*)`, "info");
}

// ── Manage a single team (workflow or language) ─────────────────────────

async function manageTeam(pi: ExtensionAPI, ctx: CommandContext, team: Team, agents: AgentInfo[]): Promise<void> {
	const disabled = getDisabledAgents();

	pi.sendMessage({
		customType: "xpert-team-detail",
		content: renderTeamDetail(team, disabled, agents),
		display: true,
		attribution: "user",
	}, { triggerTurn: false });

	const activeCount = team.agents.filter(id => !disabled.has(id)).length;
	const isFullyActive = activeCount === team.agents.length;
	const isFullyInactive = activeCount === 0;

	const actions: string[] = [];
	if (!isFullyActive) actions.push("✓ Activate all");
	if (!isFullyInactive) actions.push("✗ Deactivate all");
	actions.push("🔄 Toggle individual agents");
	actions.push("← Back");

	const action = await ctx.ui.select(`${team.emoji} ${team.label} — Choose action`, actions);
	if (!action || action === "← Back") return;

	if (action === "✓ Activate all") {
		const d = getDisabledAgents();
		for (const agentId of team.agents) d.delete(agentId);
		setDisabledAgents(d);
		pi.sendMessage({
			customType: "xpert-activate",
			content: `${team.emoji} **${team.label}** activated! All ${team.agents.length} agents enabled.\n\nPaired skills: ${team.skills.map(s => `skill://${s}`).join(", ") || "none"}`,
			display: true,
			attribution: "user",
		}, { triggerTurn: false });
		ctx.ui.notify(`${team.label} activated`, "info");
		return;
	}

	if (action === "✗ Deactivate all") {
		const d = getDisabledAgents();
		for (const agentId of team.agents) d.add(agentId);
		setDisabledAgents(d);
		pi.sendMessage({
			customType: "xpert-deactivate",
			content: `${team.emoji} **${team.label}** deactivated. All ${team.agents.length} agents disabled.`,
			display: true,
			attribution: "user",
		}, { triggerTurn: false });
		ctx.ui.notify(`${team.label} deactivated`, "info");
		return;
	}

	if (action === "🔄 Toggle individual agents") {
		await toggleIndividualAgents(pi, ctx, team, agents);
	}
}

// ── Manage a category team ─────────────────────────────────────────────

async function manageCategory(pi: ExtensionAPI, ctx: CommandContext, team: Team, agents: AgentInfo[]): Promise<void> {
	const disabled = getDisabledAgents();

	pi.sendMessage({
		customType: "xpert-category-detail",
		content: renderCategoryDetail(team, disabled, agents),
		display: true,
		attribution: "user",
	}, { triggerTurn: false });

	const activeCount = team.agents.filter(id => !disabled.has(id)).length;
	const isFullyActive = activeCount === team.agents.length;
	const isFullyInactive = activeCount === 0;

	const actions: string[] = [];
	if (!isFullyActive) actions.push("✓ Enable all");
	if (!isFullyInactive) actions.push("✗ Disable all");
	actions.push("🔄 Toggle individual agents");
	actions.push("← Back");

	const action = await ctx.ui.select(`${team.emoji} ${team.label} — Choose action`, actions);
	if (!action || action === "← Back") return;

	if (action === "✓ Enable all") {
		const d = getDisabledAgents();
		for (const agentId of team.agents) d.delete(agentId);
		setDisabledAgents(d);
		pi.sendMessage({
			customType: "xpert-activate",
			content: `${team.emoji} **${team.label}** enabled! All ${team.agents.length} agents now active.`,
			display: true,
			attribution: "user",
		}, { triggerTurn: false });
		ctx.ui.notify(`${team.label} enabled (${team.agents.length} agents)`, "info");
		return;
	}

	if (action === "✗ Disable all") {
		const d = getDisabledAgents();
		for (const agentId of team.agents) d.add(agentId);
		setDisabledAgents(d);
		pi.sendMessage({
			customType: "xpert-deactivate",
			content: `${team.emoji} **${team.label}** disabled. All ${team.agents.length} agents now inactive.`,
			display: true,
			attribution: "user",
		}, { triggerTurn: false });
		ctx.ui.notify(`${team.label} disabled`, "info");
		return;
	}

	if (action === "🔄 Toggle individual agents") {
		await toggleIndividualAgents(pi, ctx, team, agents);
	}
}

// ── Toggle individual agents within a team ────────────────────────────

async function toggleIndividualAgents(pi: ExtensionAPI, ctx: CommandContext, team: Team, agents: AgentInfo[]): Promise<void> {
	const disabled = getDisabledAgents();

	const agentOptions = team.agents.map(agentId => {
		const isDisabled = disabled.has(agentId);
		const status = isDisabled ? "✗ OFF" : "✓ ON ";
		const agent = agents.find(a => a.name === agentId);
		const modelLabel = agent ? (agent.model.split("/").pop() || agent.model) : "?";
		return `${status}  ${agentId}  (${modelLabel})`;
	});
	agentOptions.push("← Back");

	const choice = await ctx.ui.select(`${team.emoji} ${team.label} — Toggle agent`, agentOptions);
	if (!choice || choice === "← Back") return;

	const idx = agentOptions.indexOf(choice);
	if (idx < 0 || idx >= team.agents.length) return;

	const agentId = team.agents[idx];
	const currentDisabled = getDisabledAgents();

	if (currentDisabled.has(agentId)) {
		currentDisabled.delete(agentId);
	} else {
		currentDisabled.add(agentId);
	}
	setDisabledAgents(currentDisabled);

	const newStatus = currentDisabled.has(agentId) ? "disabled" : "enabled";
	pi.sendMessage({
		customType: "xpert-agent-toggle",
		content: `${currentDisabled.has(agentId) ? "✗" : "✓"} ${agentId} — ${newStatus}`,
		display: true,
		attribution: "user",
	}, { triggerTurn: false });
	ctx.ui.notify(`${agentId} ${newStatus}`, "info");
}