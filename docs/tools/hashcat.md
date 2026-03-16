---
title: Hashcat
sidebar_position: 11
tags: [tool, crypto, cracking]
---

> **One-liner:** GPU-accelerated password hash cracking tool supporting dozens of hash types including JWT, MD5, bcrypt, and NTLM.

## When to use it

- Cracking a captured password hash (MD5, SHA1, bcrypt, NTLM)
- Brute-forcing a JWT secret (HS256/HS384/HS512) — key use case from training
- Dictionary attacks against credential dumps

## Key commands

```bash
# JWT (HS256/HS384/HS512) — dictionary attack
hashcat -m 16500 jwt.txt wordlist.txt

# JWT — brute-force 6 lowercase characters
hashcat -m 16500 -a 3 jwt.txt '?l?l?l?l?l?l'

# MD5
hashcat -m 0 -a 0 hashes.txt rockyou.txt

# SHA1
hashcat -m 100 -a 0 hashes.txt rockyou.txt

# bcrypt
hashcat -m 3200 -a 0 hashes.txt rockyou.txt

# NTLM
hashcat -m 1000 -a 0 hashes.txt rockyou.txt
```

### Hash mode reference

| Mode (`-m`) | Hash type |
|-------------|-----------|
| `0` | MD5 |
| `100` | SHA1 |
| `1000` | NTLM |
| `3200` | bcrypt |
| `16500` | JWT (HS256/HS384/HS512) |

### Attack mode reference

| Mode (`-a`) | Type |
|-------------|------|
| `0` | Dictionary |
| `3` | Brute-force / mask |

### Brute-force mask characters

| Placeholder | Character set |
|-------------|--------------|
| `?l` | lowercase a–z |
| `?u` | uppercase A–Z |
| `?d` | digits 0–9 |
| `?s` | special characters |

:::tip 💡 Remember
MD5 cracks in seconds on a GPU; bcrypt is millions of times slower by design — choosing the right hashing algorithm matters enormously for storage security.
:::
