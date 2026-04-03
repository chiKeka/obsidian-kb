---
name: obsidian-kb
description: Use this skill when the user wants to build a knowledge base for their project, create an Obsidian wiki from project data, analyze project structure for knowledge management, or mentions "obsidian-kb", "knowledge base", or "compile wiki".
---

# /obsidian-kb — Build a Project Knowledge Base

Analyze any project's structure and build a custom knowledge base: tiered context packs for LLM consumption + an Obsidian wiki for human browsing. Inspired by Karpathy's LLM Knowledge Base workflow, adapted for LLM-first consumption.

## Usage
```
/obsidian-kb init                # Analyze project, propose architecture
/obsidian-kb build               # Generate compiler, commands, run initial compile
/obsidian-kb rebuild             # Re-run init + build (for when project structure changes)
```

---

## Phase 1: init — Analyze & Design

### Step 1: Scan the Project

Scan the project directory tree. Respect `.gitignore` if it exists. Collect:

1. **Data files** by format:
   - `.jsonl` — JSON Lines (line-delimited records)
   - `.json` — JSON documents or arrays
   - `.yaml` / `.yml` — YAML documents
   - `.csv` / `.tsv` — Tabular data
   - `.toml` — Structured configuration
   - `.md` with YAML frontmatter — Structured markdown

2. **Project signals** — detect what kind of project this is:
   - `package.json` or `tsconfig.json` → JavaScript/TypeScript software project
   - `setup.py` or `pyproject.toml` or `requirements.txt` → Python software project
   - `Cargo.toml` → Rust project
   - `go.mod` → Go project
   - `.bib` or `papers/` or `references/` → Research/academic project
   - JSONL files with `name` + `description` + `domain` fields → Knowledge graph project
   - `clients/` or `projects/` directories → Consulting/portfolio project
   - `docs/` or `documentation/` → Documentation-heavy project
   - `data/` with structured files → Data-centric project

3. **Existing compilation** — check if `data/compiled/` or `data/kb-architecture.yaml` already exist. If so, note them and ask if the user wants to rebuild or update.

Display: "Scanned [N] directories, found [M] data files across [K] formats. Project type: [detected type]."

### Step 2: Sample and Classify Knowledge Atoms

For each data file found:

1. Read 3-5 sample records (first 3-5 lines for JSONL, first 3-5 entries for JSON arrays, etc.)
2. Identify what each record represents — its **knowledge atom type**:
   - What is the primary identifier field? (name, title, id, path, etc.)
   - What is the description/content field?
   - What fields create relationships to other records? (references, links, tags, categories)
   - What grouping dimension exists? (domain, category, module, type, directory)

For **software projects** without structured data files, the knowledge atoms come from the code structure:
- Components/modules (from `src/` directory structure)
- API endpoints (from route definitions)
- Architecture decisions (from `docs/adr/` or `decisions/` directories)
- Configuration (from config files)
- Dependencies (from package manifests)

For **markdown-heavy projects**, extract frontmatter fields as the schema.

Display a table:
```
Source: data/knowledge-graph/frameworks.jsonl
  Format: JSONL (22 records)
  Atom type: framework
  Key field: name
  Description: description
  Group field: domain
  Relationship fields: entangled_with, related_frameworks
  Sample: "Knowledge Gradient Model" (intelligence_systems)

Source: data/reading-list/index.jsonl
  Format: JSONL (50 records)
  Atom type: reading
  Key field: title
  Description: core_arguments
  Group field: domain
  Relationship fields: framework_connections
  Sample: "Thinking in Systems" (intelligence_systems)
```

### Step 3: Map Relationships

For each pair of knowledge atom types, identify:

1. **Explicit references**: Field A in type X contains names/IDs from type Y
   - Example: concept.related_frameworks → framework.name
2. **Shared groupings**: Both types share a grouping field with the same values
   - Example: framework.domain = concept.domain
3. **Hierarchical containment**: Type X is a child/component of type Y
   - Example: API endpoint belongs to a module

Build a relationship map:
```
framework <-> concept (via related_frameworks)
framework <-> reading (via framework_connections)
framework <-> framework (via entangled_with)
concept -- framework (shared domain)
signal -> framework (text mention)
```

### Step 4: Design Tier Structure

Based on the atoms and relationships, design a three-tier compiled context pack structure:

**Tier 0 — Index** (always loaded, ~1000-1500 tokens)
- One-line entry per knowledge atom across ALL types
- Purpose: routing. "What exists in this knowledge base?"
- Output: `data/compiled/index.md`

**Tier 1 — Group Context** (loaded per operation, ~3000-6000 tokens each)
- One file per group value (domain, category, module, directory)
- Contains: all atoms in that group with full descriptions, cross-references, relationship summaries
- Purpose: working context for a specific area
- Output: `data/compiled/[group_dimension]/[group_value].md`
- If no natural grouping exists: use a single "overview" file per atom type

**Tier 2 — Entity Deep Context** (loaded on demand, ~1000-2000 tokens each)
- One file per entity in the richest atom type (the type with most relationships)
- Contains: the entity + summaries of all connected entities + history + related sources
- Purpose: deep work on a specific item
- Output: `data/compiled/[atom_type]/[slug].md`
- Only generate Tier 2 for atom types with rich interconnections. Simple lists don't need deep context pages.

Design the wiki structure in parallel:
- One wiki section per atom type
- Wikilinks between related atoms: `[[section/slug|Display Name]]`
- Frontmatter tags for filtering in Obsidian
- Graph color groups: one color per section

### Step 5: Propose Architecture

Present the full architecture to the user:

```
=== Knowledge Base Architecture Proposal ===

Project: [project name from directory or package.json]
Type: [detected type]

Sources:
  [list of source files with atom types and record counts]

Tier Structure:
  Tier 0 (Index): [what it contains]
  Tier 1 ([group dimension]): [N groups] — [group names]
  Tier 2 ([entity type]): [N entities]

Wiki Structure:
  wiki/
    [section 1]/ — [atom type] ([count] pages)
    [section 2]/ — [atom type] ([count] pages)
    ...
    index.md — Map of Content

Estimated pages: [total]
Estimated compile time: fast (< 5 seconds)

Proceed with build?
```

Wait for user approval. If the user suggests changes, modify the architecture. Once approved, save to `data/kb-architecture.yaml`:

```yaml
project_name: "[name]"
project_type: "[type]"
analyzed_at: "[ISO timestamp]"
sources:
  - path: "[relative path]"
    format: "[jsonl|json|yaml|csv|md|toml]"
    atom_type: "[type name]"
    count: [N]
    key_field: "[field name]"
    description_field: "[field name]"
    group_field: "[field name or null]"
    relationship_fields: ["[field1]", "[field2]"]
tiers:
  tier0:
    output: "data/compiled/index.md"
    token_budget: 1500
  tier1:
    group_dimension: "[field name]"
    groups: ["[group1]", "[group2]"]
    output_pattern: "data/compiled/[dimension]/{group}.md"
    token_budget_per_group: 5000
  tier2:
    atom_type: "[primary type]"
    output_pattern: "data/compiled/[type]/{slug}.md"
    token_budget_per_entity: 1500
wiki:
  root: "wiki/"
  sections:
    - name: "[section name]"
      atom_type: "[type]"
      color: "[hex color]"
```

---

## Phase 2: build — Generate & Compile

### Step 1: Read Architecture Spec

Read `data/kb-architecture.yaml`. If it doesn't exist, run Phase 1 first.

### Step 2: Generate the Compiler

Write `scripts/compile-kb.py` — a Python script tailored to this project. The compiler must:

1. **Load functions for each source format**:
   - `load_jsonl(path)` — read line-delimited JSON
   - `load_json(path)` — read JSON file (handle both objects and arrays)
   - `load_yaml(path)` — read YAML (requires `import yaml` or `pip install pyyaml`)
   - `load_csv(path)` — read CSV with `csv.DictReader`
   - `load_markdown(path)` — extract YAML frontmatter from markdown files
   - Only include loaders for formats actually used in this project

2. **Compile Tier 0**: Read all sources, extract key + one-line description per atom, write `data/compiled/index.md`. Include summary stats (counts per type, group distribution).

3. **Compile Tier 1**: For each group value, collect all atoms in that group across all types. Write full descriptions, cross-references, and relationship summaries. Respect token budget by truncating descriptions proportionally if the group is too large.

4. **Compile Tier 2**: For each entity in the primary atom type:
   - Write the entity's full data
   - Look up and include summaries of connected entities (from relationship fields)
   - Include any other atom types that reference this entity
   - Include history/evolution if available

5. **Wiki compilation** (behind `--human` flag):
   - One page per atom with YAML frontmatter and wikilinks
   - Group overview pages
   - Index page (Map of Content)
   - `.obsidian/` config with graph coloring from architecture spec

6. **Freshness tracking**: Write `data/compiled/freshness.json` with `compiled_at` timestamp and source file modification times.

7. **Idempotent**: Always fully regenerates `data/compiled/`. Never appends.

The compiler should be:
- Self-contained (no external dependencies beyond Python stdlib, unless YAML sources require PyYAML)
- Runnable via `python3 scripts/compile-kb.py` (context packs) or `python3 scripts/compile-kb.py --human` (also wiki)
- Fast (< 5 seconds for typical projects)

**Reference pattern**: Use the BrunoTwin compiler at `scripts/compile-kb.py` in that project as the structural reference — same `load_jsonl`, `slugify`, tier functions, freshness.json pattern. But write the code fresh for this project's specific sources and schema.

### Step 3: Generate Obsidian Config

Create `wiki/.obsidian/` with:

**app.json**:
```json
{
  "showLineNumber": true,
  "strictLineBreaks": false,
  "readableLineLength": true,
  "showFrontmatter": false
}
```

**graph.json**: Generate color groups from the architecture spec's wiki sections. Each section gets a distinct color. Use the `"path:[section]"` query pattern.

### Step 4: Generate /kb Command

Write `.claude/commands/kb.md` tailored to this project. It should support:

```
/kb                              # Show stats and health
/kb compile                      # Run python3 scripts/compile-kb.py
/kb search [query]               # Grep across all compiled pages
/kb [atom_type] [name]           # Load Tier 2 context for a specific entity
/kb gaps                         # Find orphaned atoms and missing relationships
/kb recent                       # Show recent changes to source data
```

The command instructions should tell Claude to:
1. Check `data/compiled/freshness.json` for staleness
2. Load from `data/compiled/` (not raw source files) for queries
3. Fall back to raw source files for detail beyond what compiled packs contain
4. Recompile when sources have changed

### Step 5: Generate /lint-kb Command

Write `.claude/commands/lint-kb.md` with project-specific health checks:

**Universal checks** (work for any project):
1. Broken references — relationship fields pointing to atoms that don't exist
2. Orphaned atoms — atoms with no incoming or outgoing relationships
3. Missing bidirectional links — if A references B, does B reference A?
4. Group coverage — each group should have minimum 3 atoms
5. Staleness — compiled output older than source data
6. Empty fields — atoms missing descriptions or key fields

**Scoring**: `health = 100 - (critical * 10) - (warnings * 2)`

The lint command should:
1. Read all raw source files (JSONL/JSON/YAML/CSV)
2. Run all checks
3. Report findings as CRITICAL / WARNING / INFO
4. Support `--fix` for mechanical fixes (backlinks, staleness)
5. Support `--suggest` for LLM-generated suggestions (missing connections, new atom candidates)

### Step 6: Run Initial Compile

Execute `python3 scripts/compile-kb.py --human` to generate both context packs and wiki.

Report:
```
=== Knowledge Base Built ===

Context Packs (data/compiled/):
  Tier 0: 1 file (~[N] tokens)
  Tier 1: [M] files (~[K] tokens avg)
  Tier 2: [P] files (~[Q] tokens avg)

Obsidian Wiki (wiki/):
  [total] pages across [sections] sections
  Open in Obsidian: File > Open Vault > [project]/wiki

Commands installed:
  /kb — query, search, compile
  /lint-kb — health check

Run /lint-kb to check knowledge base health.
```

---

## Phase 3: rebuild — Re-analyze

When the user runs `/obsidian-kb rebuild`:

1. Re-scan the project (new sources may have been added)
2. Compare against existing `data/kb-architecture.yaml`
3. Show what changed (new sources, removed sources, schema changes)
4. Propose updated architecture
5. On approval, regenerate compiler and recompile

---

## Design Principles

1. **The LLM is both producer and consumer.** Context packs are the primary output. The Obsidian wiki is a human-readable export.

2. **Architecture spec is the contract.** `kb-architecture.yaml` bridges analysis and generation. Users can edit it. It documents what the KB tracks.

3. **Freshness over rebuilding.** The compiler checks source timestamps. Slash commands check `freshness.json`. Recompile only when sources change.

4. **The compiler is project-specific code, not a template instantiation.** You write the compiler fresh each time, tailored to the project's actual schema and relationships. The BrunoTwin compiler is your reference for structure, but the content is unique per project.

5. **Obsidian conventions matter.** Wikilinks use `[[path/slug|Display Name]]` format. Frontmatter uses standard YAML. Tags are lowercase. Graph coloring uses `path:` queries. These make the wiki work well in Obsidian without plugins.
