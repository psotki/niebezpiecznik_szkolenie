---
title: Nikto
sidebar_position: 12
tags: [tool, scanning, recon]
---

> **One-liner:** Web server vulnerability scanner that finds misconfigurations, default files, outdated software, and dangerous HTTP headers.

## When to use it

- Quick reconnaissance before deeper manual testing
- Finding low-hanging fruit: default credentials, exposed admin paths, missing security headers
- Identifying outdated server software versions

## Key commands

```bash
# Basic scan
nikto -h http://target -p 80

# Full scan with specific plugins
nikto -h http://target -Plugins headers,paths,auth,outdated
```

### Available plugins

| Plugin | What it checks |
|--------|---------------|
| `headers` | Security headers (HSTS, X-Frame-Options, CSP, etc.) |
| `paths` | Common dangerous paths and default files |
| `auth` | Default credentials |
| `outdated` | Outdated server software versions |
| `shellshock` | Shellshock vulnerability |
| `dominos` | Domino server checks |

### What Nikto scans for

- Outdated server software versions
- Dangerous HTTP methods (PUT, DELETE, TRACE)
- Default credentials on common services
- Common vulnerability signatures

:::tip 💡 Remember
Nikto is noisy — it is not stealthy and will appear in server logs. Use it when detection is not a concern, or after confirming scope with the client.
:::
