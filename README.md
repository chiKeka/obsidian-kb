# obsidian-kb

A Claude Code skill that analyzes any project's structure and builds a custom knowledge base: **tiered context packs for LLM consumption** + an **Obsidian wiki for human browsing**.

Inspired by [Karpathy's LLM Knowledge Base workflow](https://x.com/karpathy/status/2039805659525644595), adapted for LLM-first consumption.

## What It Does

You point it at a project. It scans the structure, identifies data sources, maps relationships, and generates:

1. **A three-tier compiled context pack system** - markdown files optimized for LLM token efficiency
2. **A Python compiler** - tailored to your project's specific data formats and schema
3. **An Obsidian wiki** - interlinked pages with graph view, frontmatter, and color-coded sections
4. **Slash commands** - `/kb` for querying and `/lint-kb` for health checks

The key insight: **the LLM is both the producer and consumer.** Context packs are the primary output. The Obsidian wiki is a human-readable export you get for free.

## The Three-Tier System

```
Tier 0 - Index (~1000-1500 tokens)
  Always loaded. Full inventory of everything in the knowledge base.
  "What exists here?"

Tier 1 - Group Context (~3000-6000 tokens each)
  Loaded per operation. One file per domain/category/module.
  "Everything about this area."

Tier 2 - Entity Deep Context (~1000-2000 tokens each)
  Loaded on demand. One file per entity with all connections.
  "Everything about this specific thing."
```

This means an LLM can load your entire knowledge base index in ~1200 tokens, drill into a domain in ~4000 tokens, and get full entity context in ~1500 tokens. No wasted context window.

## Install

### Option A: Per-Project (works everywhere, including Claude Co Work)

Copy the skill into any project:

```bash
# From this repo
git clone https://github.com/keka/obsidian-kb.git /tmp/obsidian-kb
bash /tmp/obsidian-kb/install.sh
```

Or manually:

```bash
mkdir -p .claude/skills/obsidian-kb
curl -sL https://raw.githubusercontent.com/keka/obsidian-kb/main/skills/obsidian-kb/SKILL.md \
  -o .claude/skills/obsidian-kb/SKILL.md
```

### Option B: Global (Claude Code CLI and VS Code)

Install once, available in all local projects:

```bash
mkdir -p ~/.claude/skills/obsidian-kb
curl -sL https://raw.githubusercontent.com/keka/obsidian-kb/main/skills/obsidian-kb/SKILL.md \
  -o ~/.claude/skills/obsidian-kb/SKILL.md
```

### Option C: Claude Code Plugin

Add this repo as a plugin dependency in your project (coming soon with Claude Code plugin marketplace).

## Usage

Once installed, use in any Claude Code session:

```
/obsidian-kb init       # Scan project, classify data, propose architecture
/obsidian-kb build      # Generate compiler, commands, run initial compile
/obsidian-kb rebuild    # Re-analyze when project structure changes
```

### Phase 1: init

The skill scans your project and detects:

- **Data files** by format (JSONL, JSON, YAML, CSV, TOML, Markdown with frontmatter)
- **Project type** (software, research, data-centric, consulting, documentation)
- **Knowledge atoms** - what each record represents, its key fields, relationships, groupings
- **Cross-references** between atom types

It proposes an architecture and waits for your approval before generating anything.

### Phase 2: build

After you approve the architecture, it generates:

| File | Purpose |
|------|---------|
| `scripts/compile-kb.py` | Python compiler tailored to your project's schema |
| `data/compiled/index.md` | Tier 0: full inventory |
| `data/compiled/[group]/*.md` | Tier 1: group context packs |
| `data/compiled/[type]/*.md` | Tier 2: entity deep context |
| `wiki/` | Obsidian vault with interlinked pages |
| `wiki/.obsidian/` | Vault config with graph coloring |
| `.claude/commands/kb.md` | `/kb` query command |
| `.claude/commands/lint-kb.md` | `/lint-kb` health check |
| `data/kb-architecture.yaml` | Architecture spec (editable) |
| `data/compiled/freshness.json` | Compilation timestamp for staleness detection |

### Phase 3: Use

After build, you get two new slash commands in your project:

```
/kb                     # Show stats and health
/kb compile             # Re-run the compiler
/kb search [query]      # Search across all compiled pages
/kb [type] [name]       # Load Tier 2 context for a specific entity
/kb gaps                # Find orphaned atoms and missing relationships

/lint-kb                # Full health check with scoring
/lint-kb --fix          # Auto-fix mechanical issues (backlinks, staleness)
/lint-kb --suggest      # LLM-generated suggestions for missing connections
```

## What Projects It Works With

The skill adapts to whatever it finds:

| Project Type | Knowledge Atoms | Tier 1 Grouping |
|-------------|-----------------|-----------------|
| JSONL/JSON data with domain fields | Entities, frameworks, concepts | By domain/category |
| Software (package.json, Cargo.toml, etc.) | Components, APIs, modules, configs | By module/directory |
| Research (papers/, .bib files) | Papers, findings, methods | By research topic |
| Documentation (docs/) | Documentation pages | By section |
| Consulting (clients/, projects/) | Deliverables, risks, briefs | By client/project |
| Generic structured data | User-classified atoms | User-defined grouping |

For software projects without structured data files, it extracts knowledge atoms from the code structure itself - components, API endpoints, architecture decisions, configuration, dependencies.

## How It Works Under the Hood

The skill doesn't use templates. It instructs Claude to:

1. **Analyze** your project's actual data schema by sampling records
2. **Design** a tier structure based on what it finds
3. **Write** a Python compiler from scratch, tailored to your schema
4. **Generate** an Obsidian vault with proper wikilinks and graph coloring
5. **Create** slash commands that know your project's atom types

The compiler it generates is:
- Self-contained Python (stdlib only, unless your data uses YAML)
- Idempotent (full regeneration each run, never appends)
- Fast (< 5 seconds for typical projects)
- Runnable via `python3 scripts/compile-kb.py` (context packs) or `python3 scripts/compile-kb.py --human` (also wiki)

The architecture spec (`data/kb-architecture.yaml`) is the contract between analysis and generation. You can edit it before building. It documents what the knowledge base tracks.

## Design Principles

1. **LLM-first.** Context packs are optimized for token-efficient LLM consumption. The Obsidian wiki is a bonus human export.

2. **Architecture spec is the contract.** `kb-architecture.yaml` bridges analysis and generation. Editable. Inspectable.

3. **Freshness over rebuilding.** The compiler tracks source timestamps. Slash commands check `freshness.json`. Recompile only when sources change.

4. **The compiler is project-specific code.** Not a template instantiation. Written fresh each time for your project's actual schema and relationships.

5. **Obsidian conventions.** Wikilinks use `[[path/slug|Display Name]]`. Frontmatter uses standard YAML. Tags are lowercase. Graph coloring uses `path:` queries. Works in Obsidian without plugins.

## Example: Knowledge Graph Project

For a project with JSONL files containing frameworks, concepts, and a reading list:

```
=== Knowledge Base Architecture Proposal ===

Project: my-research
Type: Knowledge graph / Data-centric

Sources:
  data/frameworks.jsonl     — framework (22 records)
  data/concepts.jsonl       — concept (35 records)
  data/reading-list.jsonl   — reading (50 records)

Tier Structure:
  Tier 0 (Index): All 107 atoms, one-line each
  Tier 1 (domain): 5 groups — systems, institutions, infrastructure, culture, opportunity
  Tier 2 (framework): 22 deep context pages

Wiki Structure:
  wiki/
    frameworks/  — 22 pages
    concepts/    — 35 pages
    reading/     — 50 pages
    index.md     — Map of Content

Estimated pages: 108
```

## Example: Software Project

For a TypeScript project with src/, docs/, and API routes:

```
=== Knowledge Base Architecture Proposal ===

Project: my-api
Type: TypeScript software project

Sources:
  src/components/    — component (15 modules)
  src/routes/        — endpoint (28 routes)
  docs/adr/          — decision (8 ADRs)
  package.json       — dependency (42 deps)

Tier Structure:
  Tier 0 (Index): All atoms inventory
  Tier 1 (module): 6 groups — auth, billing, core, api, utils, config
  Tier 2 (component): 15 deep context pages

Wiki Structure:
  wiki/
    components/  — 15 pages
    endpoints/   — 28 pages
    decisions/   — 8 pages
    index.md     — Map of Content
```

## Credits

Inspired by [Andrej Karpathy's tweet](https://x.com/karpathy/status/2039805659525644595) about building knowledge bases for LLM consumption. The three-tier compiled context pack system was developed as an LLM-optimized adaptation of that workflow.

## License

MIT
