# Permissions (opt-in)

A security-first deny-list that stops agents from reading or writing sensitive files (SSH keys,
`.env`, cloud credentials, keychains, etc.). This is **optional** and **not applied by any script** —
`link.sh` never edits your `opencode.json` or Claude `settings.json`. Add it yourself if you want
it.

The deny-list below is a security-first default `permissions` set.

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

## Note on the SDD agents' own permissions

Independently of this deny-list, each SDD phase agent already restricts its own tools via its
frontmatter (`tools:` for Claude Code, `permission:` for OpenCode). For example `sdd-explore` and
`sdd-verify` cannot edit files. This deny-list is an additional, project-wide guardrail on top of
that.
