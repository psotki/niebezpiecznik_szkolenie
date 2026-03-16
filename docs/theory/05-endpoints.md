---
title: Endpoint Discovery
sidebar_position: 6
tags: [recon, owasp-a01]
---

:::info TL;DR
Endpoint discovery is the practice of finding hidden API endpoints and admin panels by guessing URL patterns — and it matters because exposed hidden paths can give attackers direct access to sensitive functionality.
:::

## What is it?
Endpoint discovery involves brute-forcing or pattern-guessing URLs to find paths that are not linked publicly. Attackers look for admin panels, backup files, configuration endpoints, and version control directories. These hidden paths are often left accessible by mistake and can expose critical functionality.

## How it works
Tools like DirBuster and gobuster brute-force paths from wordlists, sending HTTP requests to each candidate path and recording which ones return a response.

```bash
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt
```

Common hidden paths to check: `/admin`, `/backup`, `/config`, `/.git`, `/.svn`.

## Real-world example
The `/api/jsonws` endpoint in Liferay is a known hidden API surface that has been used with a Metasploit exploit to gain remote code execution on unpatched instances.

## How to defend
- Block access to sensitive paths (`/.git`, `/.svn`, `/backup`, `/config`) in web server config
- Avoid deploying admin panels on publicly reachable paths
- Return consistent responses (e.g., 404) for non-existent paths to reduce information leakage
- Regularly audit publicly accessible endpoints

:::tip 💡 Easy to remember
If you can see `/api/v1/users`, try `/api/v1/admin` — attackers think in siblings.
:::
