---
title: DNS — Domain Squatting & Certificate Transparency
sidebar_position: 15
tags: [dns, recon, defense]
---

:::info TL;DR
Attackers register lookalike domains to impersonate your brand, and Certificate Transparency logs expose subdomains you may not realise are public — both are critical to monitor.
:::

## What is it?

Two related DNS-layer risks that affect both attackers and defenders:

- **Domain Squatting / Typosquatting**: registering domains that closely resemble a legitimate domain (e.g., `paypa1.com`, `g00gle.com`) to exploit user error or trust.
- **Certificate Transparency**: a public, append-only log of all issued TLS certificates that anyone can query — useful for both reconnaissance and defence.

## How it works

**Domain squatting** relies on users mistyping a domain or failing to notice subtle character substitutions. Squatted domains are used for phishing, malware distribution, and credential harvesting.

**Certificate Transparency** requires certificate authorities to log every certificate they issue. This means every subdomain that has ever received a TLS certificate appears in a public database, including internal services and staging environments that operators may have intended to keep quiet.

## Real-world example

Checking whether your domain is being squatted with dnstwist:
```
dnstwist --registered --mxcheck --geoip example.com
```

This generates permutations of your domain and checks which ones are registered and have mail servers configured — a strong indicator of active phishing infrastructure.

Querying Certificate Transparency for subdomains via [crt.sh](https://crt.sh):
```
https://crt.sh/?q=%.example.com
```

This reveals subdomains that may not appear in public DNS — staging servers, internal APIs, or forgotten services.

## How to defend

- Proactively monitor for squatted domains: [https://haveibeensquatted.com](https://haveibeensquatted.com)
- Run `dnstwist` regularly against your own domains
- Query `crt.sh` for your domain to identify unintended public subdomains before attackers do
- Ensure internal and staging services are not exposed with publicly trusted TLS certificates

:::tip 💡 Easy to remember
Domain squatting is like someone opening a shop called "Paypa1" next door to PayPal — most victims won't notice the swapped character until they've already handed over their password. CT logs are the public business registry: every subdomain you've ever put a TLS certificate on is listed there, which means attackers can find your forgotten staging servers before you remember they exist.
:::
