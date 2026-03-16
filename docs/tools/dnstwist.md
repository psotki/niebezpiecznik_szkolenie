---
title: dnstwist
sidebar_position: 3
tags: [tool, recon, dns]
---

> **One-liner:** Generates domain permutations (typosquatting variants) and checks whether they are registered.

## When to use it

- Checking if your brand's domain is being squatted by attackers
- Recon on a target — discovering lookalike domains used for phishing
- Monitoring for newly registered variants of a domain

## Install

```bash
pip install dnstwist
```

## Key commands

| Command | What it does |
|---------|-------------|
| `dnstwist example.com` | Basic scan — generates permutations and checks registration |
| `dnstwist --registered --mxcheck --geoip example.com` | Full check: only registered domains, with MX records and geolocation |

### Output fields

- Registration status (registered / unregistered)
- IP address
- Nameservers
- MX records (with `--mxcheck`)
- Geolocation (with `--geoip`)

:::tip 💡 Remember
`--registered` filters output to only domains that are actually registered — cuts noise significantly on large scans.
:::
