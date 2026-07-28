# Context7 (opt-in)

[Context7](https://github.com/upstash/context7) is an MCP server that gives your agent live,
version-accurate documentation for frameworks and libraries. It's **optional** and **not wired by
any script** — add the MCP entry yourself if you want it.

A free API key from [context7.com](https://context7.com) raises your rate limits; it's not
required.

---

## OpenCode

Add to your project `opencode.json` (or global `~/.config/opencode/opencode.json`) under `mcp`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

With an API key (higher limits):

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
      }
    }
  }
}
```

Then either add `use context7` to a prompt, or add a line to `AGENTS.md`:

```
When you need to look up library or framework docs, use the `context7` tools.
```

---

## Claude Code

Add Context7 via the CLI:

```bash
claude mcp add context7 --transport http https://mcp.context7.com/mcp
```

Or add it to `.mcp.json` at the project root (Claude Code reads project-scoped MCP config there):

```jsonc
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

For an API key, add a header block (check current Claude Code docs for the exact header syntax, as
it varies by version):

```jsonc
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp",
      "headers": { "CONTEXT7_API_KEY": "your-key-here" }
    }
  }
}
```

---

## Note

MCP servers add tokens to every request's context. Context7 is lightweight, but if you wire several
MCP servers, enable them per-agent (see the OpenCode MCP docs) rather than globally to keep context
lean.
