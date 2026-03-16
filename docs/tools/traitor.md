---
title: Traitor
sidebar_position: 8
tags: [tool, privesc]
---

> **One-liner:** Automatic Linux privilege escalation tool that scans for and exploits common escalation vectors after you have shell access.

## When to use it

- After gaining a shell on a Linux machine — run immediately to find escalation paths
- Enumerating GTFOBins, sudo misconfigurations, and SUID binaries automatically
- Trying CVE-based local privilege escalation without manual enumeration

## Install

```bash
# Download the binary and make it executable
curl -fsSL https://github.com/liamg/traitor/releases/latest/download/traitor-amd64 -o traitor
chmod +x traitor
```

## Key commands

| Command | What it does |
|---------|-------------|
| `./traitor` | Scan and attempt safe escalation paths |
| `./traitor -a` | Aggressive mode — tries all vectors including riskier ones |

### What it scans for

- GTFOBins (binaries that can be abused for privilege escalation)
- `sudo` misconfigurations
- SUID binaries
- CVE-based local exploits

:::tip 💡 Remember
Run `./traitor` (safe mode) first — aggressive mode (`-a`) may cause noise or instability on the target system.
:::
