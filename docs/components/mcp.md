# MCP Servers

Model Context Protocol (MCP) servers extend opencode with specialized external tools. Every server adds its tool schemas to model requests, so servers are selected for high leverage and efficiency.

## Roster

| Server | Type | Function | Token Cost | Keep Because |
|---|---|---|---|---|
| `context7` | remote | Real-time library & framework API documentation | Low (on-demand) | Eliminates API hallucination from outdated training data |
| `deepwiki` | remote | AI-indexed documentation, wikis, and architecture summaries for open-source GitHub repositories | Low (on-demand) | Instant codebase context for external tools/repos; zero credentials needed |
| `sequential-thinking` | local (npx) | Structured multi-step reasoning scratchpad | Low | Critical for <32B models to structure non-trivial implementation plans |
| `fetch` | local (uvx) | Plain URL to clean markdown (no browser) | Low | Fastest and cheapest web content retrieval |
| `playwright` | local (npx) | Real Chromium browser via accessibility tree | High | Dynamic JS-rendered single-page applications and web testing |
| `memory` | local (npx) | Persistent knowledge graph (entities/relations) | Low | Durable project facts, conventions, and architectural decisions survive restarts |

Config lives in [`reference/opencode.template.json`](../../reference/opencode.template.json) under `"mcp"`.

---

## deepwiki (NEW)

- **Type:** remote (`https://mcp.context7.com/mcp` / `https://mcp.deepwiki.com/mcp`, timeout 20 s)
- **Use when:** exploring open-source repositories, understanding third-party package internals, or reading system architectures.
- **Tools:** `read_wiki_structure`, `read_wiki_contents`, `ask_wiki_question`.
- **Advantage:** Free, requires no authentication, runs on remote infrastructure (zero local VRAM usage).

## context7

- **Type:** remote (`https://mcp.context7.com/mcp`, timeout 20 s)
- **Use when:** referencing any third-party library API (Python, JS, PHP, Nextflow, etc.).
- **Tools:** `resolve-library-id` → `query-docs`. Always resolve first.

## sequential-thinking

- **Type:** local, `npx -y @modelcontextprotocol/server-sequential-thinking@2026.7.4`
- **Use when:** multi-step planning, debugging hypotheses, revising decisions mid-chain.
- **Why it helps:** externalizes reasoning into structured steps, preventing local models from derailing on long generations.

## fetch

- **Type:** local, `uvx mcp-server-fetch`
- **Use when:** reading web pages, GitHub raw files, or REST API endpoints.
- **Rule:** prefer `fetch` over `playwright` for all static HTML/text content.

## playwright

- **Type:** local, `npx -y @playwright/mcp@0.0.79`, env `PLAYWRIGHT_NO_SANDBOX=1`
- **Use when:** interacting with client-rendered SPAs, taking UI screenshots, or driving frontend test suites.

## memory

- **Type:** local, `npx -y @modelcontextprotocol/server-memory@2026.7.4`
- **Storage:** `MEMORY_FILE_PATH` pointing to `~/.config/opencode/memory.json`.
- **Use when:** writing durable facts and conventions before context compaction or session end.

---

## Optional: Serena MCP (Semantic Symbol Engine)

For repositories requiring deep cross-file symbol refactoring across 40+ languages beyond opencode's built-in LSP, Serena can be launched as an MCP server:
```bash
uvx serena-agent start-mcp-server --context agent --project-from-cwd --open-web-dashboard false
```
