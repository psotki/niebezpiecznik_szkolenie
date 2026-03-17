#!/bin/bash
# ============================================================
# A02:2021 — Cryptographic Failures
# Kali Linux Attack & Analysis Script
# ============================================================
# Tools used: curl, openssl, hashcat, john, python3, trufflehog
# Usage: bash a02_cryptographic_failures.sh
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

TARGET="http://TARGET_IP_OR_DOMAIN"
WORDLIST="/usr/share/wordlists/rockyou.txt"

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║  A02:2021 — Cryptographic Failures Lab          ║"
echo "╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 1: TLS / HTTPS Configuration Check
# ─────────────────────────────────────────────
echo -e "${BOLD}[1] TLS Configuration Analysis${NC}"
echo -e "${YELLOW}    Checking for weak protocols, ciphers, and expired certificates${NC}"
echo ""

TARGET_HOST=$(echo "$TARGET" | sed 's|https\?://||' | cut -d'/' -f1)
TARGET_PORT=443

echo -e "    ${CYAN}Testing TLS on ${TARGET_HOST}:${TARGET_PORT}${NC}"
echo ""

# Check certificate expiry
echo -e "    ${CYAN}[1a] Certificate info:${NC}"
echo | openssl s_client -connect "${TARGET_HOST}:${TARGET_PORT}" 2>/dev/null | \
  openssl x509 -noout -dates -subject -issuer 2>/dev/null || \
  echo -e "    ${YELLOW}[!] Could not connect via TLS. Is the target using HTTPS?${NC}"
echo ""

# Check for weak SSL/TLS protocols
echo -e "    ${CYAN}[1b] Testing for SSLv3 (POODLE):${NC}"
openssl s_client -ssl3 -connect "${TARGET_HOST}:${TARGET_PORT}" 2>&1 | \
  grep -E "CONNECTED|handshake failure|alert" | head -2 || true

echo -e "    ${CYAN}[1c] Testing for TLS 1.0 (deprecated):${NC}"
openssl s_client -tls1 -connect "${TARGET_HOST}:${TARGET_PORT}" 2>&1 | \
  grep -E "CONNECTED|handshake failure|alert" | head -2 || true

echo -e "    ${CYAN}[1d] Testing for TLS 1.1 (deprecated):${NC}"
openssl s_client -tls1_1 -connect "${TARGET_HOST}:${TARGET_PORT}" 2>&1 | \
  grep -E "CONNECTED|handshake failure|alert" | head -2 || true

echo ""
echo -e "    ${YELLOW}[TIP] Use testssl.sh for comprehensive TLS analysis:${NC}"
echo -e "    ${BOLD}testssl.sh ${TARGET_HOST}${NC}"
echo -e "    ${BOLD}curl -sSf https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh | bash -s ${TARGET_HOST}${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 2: HTTP Security Headers Check
# ─────────────────────────────────────────────
echo -e "${BOLD}[2] HTTP Security Headers Analysis${NC}"
echo -e "${YELLOW}    Checking for missing or misconfigured security headers${NC}"
echo ""

echo -e "    ${CYAN}Fetching response headers from $TARGET...${NC}"
echo ""

HEADERS=$(curl -s -I --max-time 10 "$TARGET" 2>/dev/null)
if [ -z "$HEADERS" ]; then
  echo -e "    ${YELLOW}[!] No response. Check TARGET variable.${NC}"
else
  check_header() {
    local header="$1"
    local expected="$2"
    if echo "$HEADERS" | grep -qi "^$header:"; then
      local value=$(echo "$HEADERS" | grep -i "^$header:" | head -1 | cut -d':' -f2- | xargs)
      echo -e "    ${GREEN}[✓ PRESENT]${NC} $header: $value"
    else
      echo -e "    ${RED}[✗ MISSING]${NC} $header — $expected"
    fi
  }

  check_header "Strict-Transport-Security"  "Add: max-age=31536000; includeSubDomains; preload"
  check_header "Content-Security-Policy"    "Add to prevent XSS"
  check_header "X-Frame-Options"            "Add: SAMEORIGIN or DENY"
  check_header "X-Content-Type-Options"     "Add: nosniff"
  check_header "Referrer-Policy"            "Add: strict-origin-when-cross-origin"
  check_header "Permissions-Policy"         "Restrict browser features"
  check_header "X-XSS-Protection"           "Add: 1; mode=block (legacy)"
fi
echo ""

# ─────────────────────────────────────────────
# SECTION 3: Password Hash Cracking Demo
# ─────────────────────────────────────────────
echo -e "${BOLD}[3] Password Hash Cracking (Hashcat & John)${NC}"
echo -e "${YELLOW}    Demonstrating why MD5/SHA-1 are insufficient for passwords${NC}"
echo ""

echo -e "    ${CYAN}[3a] MD5 vs bcrypt — Speed comparison on this machine${NC}"
echo ""

# Test MD5 hash cracking speed (non-destructive benchmark)
echo -e "    ${CYAN}Benchmarking MD5 (hashcat -b -m 0):${NC}"
hashcat -b -m 0 --quiet 2>/dev/null | grep -E "Speed|H/s" | head -3 || \
  echo -e "    ${YELLOW}[!] hashcat benchmark requires a GPU or --force flag on VMs:${NC}"
echo -e "    hashcat -b -m 0 --force"
echo ""

echo -e "    ${CYAN}Benchmarking bcrypt (hashcat -b -m 3200):${NC}"
hashcat -b -m 3200 --quiet 2>/dev/null | grep -E "Speed|H/s" | head -3 || \
  echo -e "    hashcat -b -m 3200 --force"
echo ""

echo -e "    ${CYAN}[3b] Cracking example MD5 hashes (dictionary attack)${NC}"
echo ""

# Create a sample hash file for demo
mkdir -p /tmp/a02_demo
cat > /tmp/a02_demo/sample_md5_hashes.txt << 'EOF'
5f4dcc3b5aa765d61d8327deb882cf99
e10adc3949ba59abbe56e057f20f883e
25f9e794323b453885f5181f1b624d0b
d8578edf8458ce06fbc5bb76a58c5ca4
EOF

echo -e "    Sample MD5 hashes written to /tmp/a02_demo/sample_md5_hashes.txt"
echo -e "    (These are: password, 123456, 123456789, qwerty)"
echo ""
echo -e "    ${YELLOW}# Crack with hashcat (MD5, dictionary):${NC}"
echo -e "    ${BOLD}hashcat -m 0 -a 0 /tmp/a02_demo/sample_md5_hashes.txt $WORDLIST --force${NC}"
echo ""
echo -e "    ${YELLOW}# Or use john:${NC}"
echo -e "    ${BOLD}john --format=raw-md5 --wordlist=$WORDLIST /tmp/a02_demo/sample_md5_hashes.txt${NC}"
echo ""

echo -e "    ${CYAN}[3c] Generate example hashes for comparison:${NC}"
echo ""
TEST_PASSWORD="mysecretpassword"
MD5_HASH=$(echo -n "$TEST_PASSWORD" | md5sum | cut -d' ' -f1)
SHA1_HASH=$(echo -n "$TEST_PASSWORD" | sha1sum | cut -d' ' -f1)
SHA256_HASH=$(echo -n "$TEST_PASSWORD" | sha256sum | cut -d' ' -f1)
BCRYPT_HASH=$(python3 -c "import bcrypt; print(bcrypt.hashpw(b'$TEST_PASSWORD', bcrypt.gensalt(12)).decode())" 2>/dev/null || echo "[install: pip3 install bcrypt]")

echo -e "    Password:       ${BOLD}$TEST_PASSWORD${NC}"
echo -e "    MD5:            ${RED}$MD5_HASH${NC} (crackable in seconds)"
echo -e "    SHA-1:          ${RED}$SHA1_HASH${NC} (crackable in minutes)"
echo -e "    SHA-256:        ${YELLOW}$SHA256_HASH${NC} (crackable with GPU, no iterations)"
echo -e "    bcrypt(cost=12):${GREEN}$BCRYPT_HASH${NC} (millions of times harder)"
echo ""

# ─────────────────────────────────────────────
# SECTION 4: Secret Scanning in Source Code
# ─────────────────────────────────────────────
echo -e "${BOLD}[4] Secret Scanning — Detecting Leaked Credentials${NC}"
echo -e "${YELLOW}    Scanning local files and git history for accidentally committed secrets${NC}"
echo ""

echo -e "    ${CYAN}[4a] Pattern-based secret scan with grep:${NC}"
echo ""
SCAN_DIR="${1:-$(pwd)}"
echo -e "    Scanning: $SCAN_DIR"
echo ""

SECRET_PATTERNS=(
  "password\s*=\s*['\"][^'\"]{4,}['\"]"
  "passwd\s*=\s*['\"][^'\"]{4,}['\"]"
  "secret\s*=\s*['\"][^'\"]{4,}['\"]"
  "api_key\s*=\s*['\"][^'\"]{4,}['\"]"
  "apikey\s*=\s*['\"][^'\"]{4,}['\"]"
  "AKIA[0-9A-Z]{16}"
  "Authorization:\s*Bearer\s+[A-Za-z0-9._-]+"
  "-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----"
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  MATCHES=$(grep -rniE "$pattern" "$SCAN_DIR" \
    --include="*.py" --include="*.js" --include="*.ts" --include="*.php" \
    --include="*.rb" --include="*.env" --include="*.config" --include="*.conf" \
    --include="*.yml" --include="*.yaml" --include="*.json" \
    --exclude-dir=".git" --exclude-dir="node_modules" 2>/dev/null | head -3)
  if [ -n "$MATCHES" ]; then
    echo -e "    ${RED}[SECRET FOUND]${NC} Pattern: $pattern"
    echo "$MATCHES" | while IFS= read -r line; do
      echo -e "      ${YELLOW}$line${NC}"
    done
    echo ""
  fi
done

echo ""
echo -e "    ${CYAN}[4b] Git history secret scan (trufflehog):${NC}"
echo ""
echo -e "    ${YELLOW}# Install trufflehog:${NC}"
echo -e "    ${BOLD}pip3 install trufflehog${NC}"
echo -e "    ${YELLOW}# Scan current git repo:${NC}"
echo -e "    ${BOLD}trufflehog git file://. --only-verified${NC}"
echo -e "    ${YELLOW}# Scan a remote GitHub repo:${NC}"
echo -e "    ${BOLD}trufflehog github --repo=https://github.com/TARGET/REPO${NC}"
echo ""
echo -e "    ${CYAN}[4c] gitleaks — scan for secrets in git history:${NC}"
echo -e "    ${BOLD}gitleaks detect --source . -v${NC}"
echo ""

echo -e "${CYAN}${BOLD}[A02 Complete]${NC} Review weak TLS, missing headers, crackable hashes, and any exposed secrets."
echo ""
