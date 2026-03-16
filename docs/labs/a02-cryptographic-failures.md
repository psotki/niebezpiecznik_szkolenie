---
title: A02 — Cryptographic Failures
sidebar_position: 3
tags: [lab, owasp-a02, tls, hashing, secrets]
---

# A02 — Cryptographic Failures

## What this lab covers

- TLS configuration analysis — certificate expiry, deprecated protocols, cipher suites
- HTTP security headers — checking for HSTS, CSP, X-Frame-Options, and others
- Password hash cracking — MD5, SHA1, bcrypt with hashcat and john
- Secret scanning — grep patterns and git history tools

## Configuration

```bash
TARGET="TARGET_HOSTNAME_OR_IP"
PORT="443"
WORDLIST="/usr/share/wordlists/rockyou.txt"
```

## Exercise 1: TLS Analysis

### Certificate expiry check

```bash
echo | openssl s_client -connect $TARGET:$PORT 2>/dev/null \
  | openssl x509 -noout -dates -subject
```

### Test for deprecated protocols (these should fail on a secure server)

```bash
# SSLv3 — should fail
openssl s_client -connect $TARGET:$PORT -ssl3 2>&1 | grep -E "CONNECTED|handshake failure"

# TLS 1.0 — should fail
openssl s_client -connect $TARGET:$PORT -tls1 2>&1 | grep -E "CONNECTED|handshake failure"

# TLS 1.1 — should fail
openssl s_client -connect $TARGET:$PORT -tls1_1 2>&1 | grep -E "CONNECTED|handshake failure"

# TLS 1.2 — acceptable
openssl s_client -connect $TARGET:$PORT -tls1_2 2>&1 | grep -E "CONNECTED|handshake failure"

# TLS 1.3 — preferred
openssl s_client -connect $TARGET:$PORT -tls1_3 2>&1 | grep -E "CONNECTED|handshake failure"
```

:::tip
For comprehensive TLS analysis use [testssl.sh](https://testssl.sh/) or [SSL Labs](https://www.ssllabs.com/ssltest/) for a full rated report.
:::

## Exercise 2: HTTP Security Headers

Check which security headers are present:

```bash
curl -sI "https://$TARGET" | grep -iE \
  "Strict-Transport-Security|Content-Security-Policy|X-Frame-Options|X-Content-Type-Options|Referrer-Policy|Permissions-Policy"
```

| Header | Purpose |
|--------|---------|
| `Strict-Transport-Security` | Forces HTTPS — prevents downgrade attacks |
| `Content-Security-Policy` | Restricts resource loading — mitigates XSS |
| `X-Frame-Options` | Prevents clickjacking via iframes |
| `X-Content-Type-Options` | Prevents MIME-type sniffing |
| `Referrer-Policy` | Controls referrer information leakage |
| `Permissions-Policy` | Restricts browser feature access (camera, mic, etc.) |

Missing headers are findings. Use [Google CSP Evaluator](https://csp-evaluator.withgoogle.com/) to analyze CSP quality.

## Exercise 3: Password Hash Cracking

### MD5 (cracks in seconds)

```bash
hashcat -m 0 hashes.txt $WORDLIST
```

### SHA1

```bash
hashcat -m 100 hashes.txt $WORDLIST
```

### bcrypt (significantly slower — by design)

```bash
hashcat -m 3200 hashes.txt $WORDLIST
```

### Using John the Ripper

```bash
john --format=raw-md5 --wordlist=$WORDLIST hashes.txt
john --format=raw-sha1 --wordlist=$WORDLIST hashes.txt
```

:::note
bcrypt's intentional slowness is what makes it appropriate for password storage. MD5 and SHA1 are not suitable for passwords — they are designed to be fast, which is the opposite of what you want.
:::

## Exercise 4: Secret Scanning

### grep for hardcoded credentials in source files

```bash
grep -rE "password\s*=|secret\s*=|api_key\s*=" . --include="*.php" --include="*.js" --include="*.py" --include="*.env"
grep -rE "AKIA[0-9A-Z]{16}" .       # AWS access key IDs
grep -rE "Bearer [a-zA-Z0-9._-]+" . # Bearer tokens
```

### Scan git history for leaked secrets

```bash
# trufflehog — entropy-based and regex scanning
trufflehog git file://. --only-verified

# gitleaks — rule-based secret detection
gitleaks detect --source . -v
```

:::warning
Secrets committed to git history remain accessible even after deletion from the latest commit. Always rotate any credential found in git history immediately.
:::
