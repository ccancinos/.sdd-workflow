# Permissions Deny-List (opt-in)

A security-first deny-list that stops agents from reading or writing sensitive files (SSH keys,
`.env`, cloud credentials, keychains, etc.).

**This is a second layer of the same idea as [Principle 3 — agents are engineering
boundaries](../concepts/architecture.md#principle-3--agents-are-engineering-boundaries).** Each SDD
phase agent already restricts its own tools in frontmatter (e.g. `sdd-explore` and `sdd-verify`
cannot edit at all). This deny-list adds a **project-wide guardrail on top of that** — a boundary
that applies to every agent, not just the phase agents.

It's **optional** and **not applied by any script** — `link.sh` never edits your `opencode.json` or
Claude `settings.json`. Add it yourself if you want it.

## Sensitive paths to deny

```
~/.ssh/*
~/.ssh/**/*
**/*.pem
**/*.key
**/.env*
~/.credentials/*
~/.aws/credentials
~/.config/gh/hosts.yml
~/Library/Keychains/*
**/secrets/*
**/*.p12
**/*.pfx
```

---

## OpenCode

OpenCode gates file reads/writes through the `permission` block in `opencode.json`. The `read` and
`edit` keys accept a map of glob → action (`allow` | `ask` | `deny`); the last matching rule wins,
so put `*` first.

Add (or merge) this into your project `opencode.json` (create it at the umbrella/repo root if it
doesn't exist):

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "read": {
      "*": "allow",
      "**/.env*": "deny",
      "**/*.pem": "deny",
      "**/*.key": "deny",
      "**/*.p12": "deny",
      "**/*.pfx": "deny",
      "**/secrets/*": "deny",
      "~/.ssh/*": "deny",
      "~/.ssh/**/*": "deny",
      "~/.aws/credentials": "deny",
      "~/.config/gh/hosts.yml": "deny",
      "~/.credentials/*": "deny",
      "~/Library/Keychains/*": "deny"
    },
    "edit": {
      "*": "allow",
      "**/.env*": "deny",
      "**/*.pem": "deny",
      "**/*.key": "deny",
      "**/secrets/*": "deny"
    }
  }
}
```

Because `opencode.json` files are **merged** (project overrides global), you can also put this in
your global `~/.config/opencode/opencode.json` once and have it apply everywhere.

---

## Claude Code

Claude Code gates access through `permissions` in `settings.json`
(`~/.claude/settings.json` for global, or `.claude/settings.json` in the project).

```jsonc
{
  "permissions": {
    "deny": [
      "Read(~/.ssh/**)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Read(**/.env*)",
      "Read(~/.aws/credentials)",
      "Read(~/.config/gh/hosts.yml)",
      "Read(~/Library/Keychains/**)",
      "Read(**/secrets/**)",
      "Read(**/*.p12)",
      "Read(**/*.pfx)",
      "Edit(**/.env*)",
      "Edit(**/*.pem)",
      "Edit(**/*.key)",
      "Edit(**/secrets/**)"
    ]
  }
}
```

Check the exact matcher syntax in the current Claude Code docs — the rule-string format has evolved
across versions. Verify with a quick test (ask the agent to read a dummy `.env`) after adding it.

---

## How this relates to the agents' own permissions

| Layer | Scope | Enforced by |
| --- | --- | --- |
| **Per-agent boundaries** | One agent's tools (e.g. `sdd-explore` can't edit) | Agent frontmatter — always on |
| **This deny-list** | Every agent, sensitive paths | Your `opencode.json` / `settings.json` — opt-in |

The two compose: even the one phase that *can* write code (`sdd-apply`) still can't touch a denied
path if you've added this list. Defense in depth.
