---
title: Cryptographic Failures
sidebar_position: 14
tags: [crypto, attack, owasp-a02]
---

:::info TL;DR
Cryptographic Failures (OWASP A02:2021) covers weak algorithms, poor TLS config, insecure password storage, and secrets leaking in code — all of which can expose sensitive data.
:::

## What is it?

OWASP A02:2021 — Cryptographic Failures (formerly "Sensitive Data Exposure") covers a broad category of weaknesses: weak or outdated algorithms, poor TLS configuration, insecure password storage, and secrets committed to source code.

## How it works

Common failure patterns:

- **Weak hashing**: MD5 and SHA1 are fast by design, which makes them trivial to crack offline with tools like hashcat. bcrypt is intentionally slow — millions of times slower than MD5.
- **Secrets in code**: API keys, passwords, and tokens committed to repositories can be found by automated scanners or anyone with read access to git history.
- **Poor TLS config**: outdated protocol versions or weak cipher suites expose traffic to interception.

## Real-world example

Cracking a leaked MD5 hash:
```
hashcat -m 0 hashes.txt rockyou.txt
```

The same attack against bcrypt is orders of magnitude slower:
```
hashcat -m 3200 hashes.txt rockyou.txt
```

Scanning source code and git history for leaked secrets:
```
grep -r "password=\|secret=\|api_key=\|AKIA\|Bearer" .
```

Automated git history scanners: `trufflehog`, `gitleaks`.

## How to defend

- Use **bcrypt** or **Argon2** for password hashing — never MD5 or SHA1
- Enforce **TLS 1.3** and disable legacy protocol versions
- **Scan git history** for secrets before making repositories public (trufflehog, gitleaks)
- Rotate any secrets that may have been exposed

:::tip 💡 Easy to remember
Storing passwords with MD5 is like locking a vault with a combination that takes one second to guess. bcrypt makes each guess take a full second — the same lock now takes years to brute-force.
:::
