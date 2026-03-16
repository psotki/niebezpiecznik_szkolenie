---
title: Gobuster / DirBuster
sidebar_position: 2
tags: [tool, recon]
---

> **One-liner:** Brute-force directories and files on web servers using wordlists to discover hidden content.

## When to use it

- Finding hidden admin panels not linked from the main site
- Locating backup files, config files, or accidentally exposed `.git` directories
- Discovering endpoints before deeper testing

## Install

```bash
# Kali Linux
sudo apt install gobuster

# macOS
brew install gobuster
```

## Key commands

| Command | What it does |
|---------|-------------|
| `gobuster dir -u https://target.com -w /wordlist.txt -t 50` | Basic directory brute-force with 50 threads |
| `gobuster dir -u https://target.com -w /wordlist.txt -x php,html,bak,txt,json,xml` | Also search for specific file extensions |
| `gobuster dir -u https://target.com -w /wordlist.txt -q -o results.txt` | Quiet mode, save output to file |

### Useful flags

| Flag | Meaning |
|------|---------|
| `-x` | File extensions to append (e.g. `php,html,bak,txt,json,xml`) |
| `-t` | Number of concurrent threads |
| `-q` | Quiet mode (less output noise) |
| `-o` | Write results to a file |

### Wordlist locations

```
/usr/share/wordlists/dirb/common.txt   # built-in on Kali
SecLists                                # community wordlists, broader coverage
```

:::tip 💡 Remember
DirBuster is the OWASP GUI version; gobuster is the faster CLI equivalent — prefer gobuster in practice.
:::
