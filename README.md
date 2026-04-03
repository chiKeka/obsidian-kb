# obsidian-kb

A Claude Code skill that scans any project and builds a custom knowledge base: **tiered context packs for LLM consumption** + an **Obsidian wiki for human browsing**.

Inspired by [Karpathy's LLM Knowledge Base workflow](https://x.com/karpathy/status/2039805659525644595).

## Install

One command. Run this inside any project:

```bash
curl -sL https://raw.githubusercontent.com/chiKeka/obsidian-kb/main/install.sh | bash
```

That's it. Now open Claude Code and run `/obsidian-kb init`.

To install globally (available in all local projects, CLI and VS Code only):

```bash
curl -sL https://raw.githubusercontent.com/chiKeka/obsidian-kb/main/install.sh | bash -s -- --global
```

## What It Does

You run `/obsidian-kb init`. It scans your project, figures out what data you have, and proposes a knowledge base architecture. You approve it, run `/obsidian-kb build`, and it generates:

- **A three-tier context pack system** - markdown files optimized for LLM token efficiency
- **A Python compiler** - tailored to your project's specific data schema
- **An Obsidian wiki** - interlinked pages with graph view and color-coded sections
- **`/kb` command** - query, search, and compile your knowledge base
- **`/lint-kb` command** - health checks and structural integrity scoring

## The Three Tiers

```
Tier 0 - Index (~1200 tokens)
  Always loaded. Full inventory of everything in the KB.
  Purpose: routing - "what exists here?"

Tier 1 - Group Context (~4000 tokens each)
  One file per domain/category/module.
  Purpose: working context for a specific area.

Tier 2 - Entity Deep Context (~1500 tokens each)
  One file per entity with all its connections.
  Purpose: deep work on a specific thing.
```

An LLM can load your entire KB index in ~1200 tokens, drill into a domain in ~4000, and get full entity context in ~1500. No wasted context window.

## Usage

```
/obsidian-kb init       # Scan project, propose architecture
/obsidian-kb build      # Generate everything, run initial compile
/obsidian-kb rebuild    # Re-analyze when project structure changes
```

After build, you also get:

```
/kb                     # Stats and health
/kb compile             # Re-run the compiler
/kb search [query]      # Search across compiled pages
/kb gaps                # Find orphans and missing relationships

/lint-kb                # Health check with scoring
/lint-kb --fix          # Auto-fix mechanical issues
```

## Works With Any Project

The skill adapts to whatever it finds:

| Project Type | What It Extracts |
|-------------|------------------|
| Data files (JSONL, JSON, YAML, CSV) | Entities, relationships, groupings |
| Software (any language) | Components, APIs, modules, configs, dependencies |
| Research / academic | Papers, findings, methods |
| Documentation | Pages, sections, cross-references |
| Consulting / portfolio | Deliverables, risks, briefs |

For software projects without structured data, it extracts knowledge atoms from the code structure itself.

## How It Works

The skill doesn't use templates. It instructs Claude to:

1. **Scan** your project and sample actual data records
2. **Classify** what each record represents (knowledge atom types)
3. **Map** relationships between atom types
4. **Design** a tier structure based on what it finds
5. **Write** a Python compiler from scratch for your schema
6. **Generate** an Obsidian vault with wikilinks and graph coloring

The architecture spec (`data/kb-architecture.yaml`) is saved as a contract between analysis and generation. You can edit it before building.

The generated compiler is self-contained Python (stdlib only), idempotent, and fast (< 5 seconds). Run it with `python3 scripts/compile-kb.py` for context packs or `python3 scripts/compile-kb.py --human` to also generate the wiki.

## Credits

Inspired by [Andrej Karpathy](https://x.com/karpathy/status/2039805659525644595). The three-tier compiled context pack system was developed as an LLM-optimized adaptation of that workflow.

## License

MIT
