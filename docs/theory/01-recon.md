---
title: Reconnaissance
sidebar_position: 2
tags: [recon, google-dorking, directory-listing, osint, tools]
---

:::info TL;DR
Reconnaissance is the process of gathering information about a target before attacking — the more you know, the easier the attack.
:::

## What is it?

Reconnaissance is the first phase of an attack, where an attacker maps out a target's exposed surface. It includes finding hidden directories, exposed files, API endpoints, and configuration data — often without sending a single malicious request. Much of it can be done passively using public tools and search engines.

## How it works

Attackers use search engine operators (Google Dorks) to find indexed sensitive content, and tools like gobuster or DirBuster to brute-force hidden paths. When a web server has no `index.html`, it may auto-list all files in the directory (Directory Listing / "Index of /"), exposing backups, configs, and source files.

```bash
# Brute-force directories on a target
gobuster dir -u https://target.com -w /wordlist.txt -t 50
```

Common Google Dork operators:
- `intitle:` — search page titles
- `inurl:` — search within URLs
- `filetype:` — filter by file extension
- `site:` — restrict to a domain
- `cache:` — view cached version of a page

## Real-world example

An attacker uses `filetype:sql site:target.com` to find an indexed database dump. Separately, they visit `https://target.com/backup/` and find the server auto-lists all files because no `index.html` is present — exposing a `.env` file with database credentials.

## How to defend

- Disable directory listing on all web servers (e.g., `Options -Indexes` in Apache)
- Avoid exposing sensitive files (`.env`, `.sql`, `.bak`) in web-accessible directories
- Use `robots.txt` carefully — it can advertise hidden paths to attackers
- Monitor for your domain in Google Dork results
- Use `dnstwist` to detect typosquatted domains targeting your brand

:::tip 💡 Easy to remember
Reconnaissance is like casing a bank before a robbery — attackers walk around, look through windows, and check the doors before ever trying to break in.
:::
