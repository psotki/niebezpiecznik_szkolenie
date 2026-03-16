---
title: Websites & Online Tools
sidebar_position: 1
---

# 🌐 Websites & Online Tools

All websites referenced in the Niebezpiecznik cybersecurity training.

## Testing & Analysis Tools

| Website | Purpose | URL |
|---------|---------|-----|
| SSL Labs | Test server TLS/SSL configuration, get A+ to F rating | https://www.ssllabs.com/ssltest/ |
| SSL Config Generator | Generate secure TLS config for Nginx, Apache, HAProxy | https://ssl-config.mozilla.org/ |
| crt.sh | Certificate Transparency search — discover subdomains and issued certificates | https://crt.sh |
| Have I Been Squatted | Check if lookalike domains of your brand are registered | https://haveibeensquatted.com |
| Google CSP Evaluator | Analyze Content Security Policy headers for weaknesses | https://csp-evaluator.withgoogle.com/ |

## XSS Practice & CTF Challenges

| Website | Purpose | URL |
|---------|---------|-----|
| prompt.ml | XSS challenges — 16 levels + 4 hidden, filter bypass practice | https://prompt.ml/ |
| escape.alf.nu | XSS challenges — "alert(1) to win!" — 15 challenges | https://escape.alf.nu/ |
| jsfuck.com | JavaScript encoder using only `[]()!+` characters — useful for XSS filter bypass | https://jsfuck.com/ |

## Tools & Libraries

| Website | Purpose | URL |
|---------|---------|-----|
| HTTP Toolkit | Intercept HTTP/HTTPS traffic including from mobile apps via ADB | https://httptoolkit.com/ |
| DOMPurify (GitHub) | HTML sanitizer library for JavaScript | https://github.com/cure53/DOMPurify |
| Keycloak | Open-source identity & access management — learn JWT, SSO, OAuth2 in practice | https://www.keycloak.org |

## Infrastructure & Reference

| Website | Purpose | URL |
|---------|---------|-----|
| Cloudflare IPs | Official list of Cloudflare IP ranges — use for firewall whitelisting | https://www.cloudflare.com/ips/ |

## Google Dorking Cheat Sheet

Use these Google search operators to find exposed information:

| Operator | Example | Finds |
|----------|---------|-------|
| `site:` | `site:example.com` | All indexed pages on a domain |
| `intitle:` | `intitle:"Index of /"` | Pages with this text in title |
| `inurl:` | `inurl:admin` | Pages with "admin" in URL |
| `filetype:` | `filetype:sql` | Files of a specific type |
| `cache:` | `cache:example.com` | Google's cached version |
| Combined | `site:example.com filetype:bak` | Backup files on target domain |
| Combined | `intitle:"Index of /" site:example.com` | Directory listings on target |
