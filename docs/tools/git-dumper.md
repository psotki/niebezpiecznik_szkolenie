---
title: git-dumper
sidebar_position: 4
tags: [tool, recon, source-code]
---

> **One-liner:** Downloads an exposed `.git` repository from a web server so you can inspect its full history and contents.

## When to use it

- You find a server with an accessible `/.git/` directory (e.g. `https://target.com/.git/HEAD` returns 200)
- Extracting source code, credentials, or configuration secrets committed to version control
- Post-dump: reviewing history for accidentally committed API keys, passwords, or internal paths

## Install

```bash
pipx install git-dumper
```

## Key commands

```bash
# Dump the exposed repo to a local directory
git-dumper https://target.com/.git/ ./output

# After dumping — explore the history
git log                         # view commit history
git diff HEAD~1 HEAD            # diff last two commits
grep -r "password\|secret\|api_key" ./output   # hunt for secrets
```

### Companion tool

**DotGit** browser extension (Firefox / Chrome) — auto-detects exposed `.git`, `.svn`, and `.env` files while you browse. Flags them in the toolbar so you never miss one.

:::tip 💡 Remember
Always run `git log` after dumping — developers often delete a secret file in a later commit, but the secret is still visible in the history.
:::
