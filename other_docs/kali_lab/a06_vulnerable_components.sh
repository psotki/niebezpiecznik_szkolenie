#!/bin/bash
# ============================================================
# A06:2021 — Vulnerable and Outdated Components
# Kali Linux Attack & Analysis Script
# ============================================================
# Tools used: curl, nmap, nikto, python3, whatweb
# Usage: bash a06_vulnerable_components.sh
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

TARGET="http://TARGET_IP_OR_DOMAIN"
TARGET_HOST=$(echo "$TARGET" | sed 's|https\?://||' | cut -d':' -f1 | cut -d'/' -f1)

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║  A06:2021 — Vulnerable Components Lab           ║"
echo "╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 1: Technology Fingerprinting
# ─────────────────────────────────────────────
echo -e "${BOLD}[1] Technology Fingerprinting${NC}"
echo -e "${YELLOW}    Identifying server software, frameworks, and CMS versions${NC}"
echo ""

echo -e "    ${CYAN}[1a] HTTP response headers (server version disclosure):${NC}"
echo ""
curl -s -I --max-time 10 "$TARGET" 2>/dev/null | grep -iE \
  "Server:|X-Powered-By:|X-Generator:|X-AspNet-Version:|X-Runtime:|X-Version:" | \
  while IFS= read -r line; do
    echo -e "    ${RED}[VERSION DISCLOSED]${NC} $line"
  done

echo ""
echo -e "    ${CYAN}[1b] WhatWeb — web technology fingerprinter:${NC}"
if command -v whatweb &>/dev/null; then
  whatweb "$TARGET" --color=never 2>/dev/null | head -20
else
  echo -e "    ${YELLOW}[!] whatweb not found. Install: apt install whatweb${NC}"
  echo -e "    ${BOLD}whatweb $TARGET${NC}"
fi
echo ""

echo -e "    ${CYAN}[1c] nmap service and script detection:${NC}"
echo -e "    ${BOLD}nmap -sV --script=http-headers,http-server-header,banner -p 80,443,8080 $TARGET_HOST${NC}"
echo ""
nmap -sV --script=http-headers,banner \
  -p 80,443,8080,8443 \
  --open \
  -T4 \
  "$TARGET_HOST" 2>/dev/null | grep -E "PORT|open|http-|banner|version|Apache|nginx|IIS|PHP|WordPress|Drupal" | head -30 || \
  echo -e "    ${YELLOW}[!] nmap failed. Try: nmap -sV $TARGET_HOST${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 2: CMS Version Detection
# ─────────────────────────────────────────────
echo -e "${BOLD}[2] CMS Detection and Version Identification${NC}"
echo -e "${YELLOW}    Checking for WordPress, Drupal, Joomla, and other CMS fingerprints${NC}"
echo ""

# WordPress
WP_RESPONSE=$(curl -s --max-time 10 "$TARGET/wp-login.php" 2>/dev/null)
if echo "$WP_RESPONSE" | grep -qi "WordPress\|wp-login"; then
  echo -e "    ${RED}[WORDPRESS FOUND]${NC} $TARGET/wp-login.php"
  WP_VERSION=$(curl -s --max-time 10 "$TARGET/readme.html" 2>/dev/null | grep -oP 'Version \K[\d.]+' | head -1)
  [ -n "$WP_VERSION" ] && echo -e "    ${RED}  Version: $WP_VERSION${NC}"
  echo -e "    ${YELLOW}  Run WPScan:${NC} wpscan --url $TARGET --enumerate u,vp,vt --api-token YOUR_TOKEN"
fi

# Drupal
DRUPAL=$(curl -s --max-time 10 "$TARGET/CHANGELOG.txt" 2>/dev/null | head -1)
if echo "$DRUPAL" | grep -qi "Drupal"; then
  echo -e "    ${RED}[DRUPAL FOUND]${NC} Version: $(echo "$DRUPAL" | head -c 60)"
  echo -e "    ${YELLOW}  Check: https://www.drupal.org/security${NC}"
fi

# Joomla
JOOMLA=$(curl -s --max-time 10 "$TARGET/administrator/" 2>/dev/null)
if echo "$JOOMLA" | grep -qi "Joomla"; then
  echo -e "    ${RED}[JOOMLA FOUND]${NC} Admin panel at $TARGET/administrator/"
  echo -e "    ${YELLOW}  Run: joomscan -u $TARGET${NC}"
fi

# Apache version
APACHE_VERSION=$(curl -s -I --max-time 10 "$TARGET" 2>/dev/null | grep -i "^Server:" | grep -oP 'Apache/[\d.]+')
if [ -n "$APACHE_VERSION" ]; then
  echo -e "    ${RED}[APACHE]${NC} $APACHE_VERSION — check CVE database for this version"
fi

# nginx version
NGINX_VERSION=$(curl -s -I --max-time 10 "$TARGET" 2>/dev/null | grep -i "^Server:" | grep -oP 'nginx/[\d.]+')
if [ -n "$NGINX_VERSION" ]; then
  echo -e "    ${RED}[NGINX]${NC} $NGINX_VERSION — check CVE database for this version"
fi

echo ""

# ─────────────────────────────────────────────
# SECTION 3: JavaScript Library Detection
# ─────────────────────────────────────────────
echo -e "${BOLD}[3] JavaScript Library Version Detection${NC}"
echo -e "${YELLOW}    Identifying client-side libraries and checking for known CVEs${NC}"
echo ""

echo -e "    ${CYAN}Fetching main page and scanning for JS library versions...${NC}"
echo ""
PAGE_CONTENT=$(curl -s --max-time 15 "$TARGET" 2>/dev/null)

# jQuery
JQUERY=$(echo "$PAGE_CONTENT" | grep -oP 'jquery[.-](\d+\.\d+\.?\d*)(\.min)?\.js' | head -1)
JQUERY_VER=$(echo "$PAGE_CONTENT" | grep -oP '\"jQuery v\K[\d.]+' | head -1)
[ -z "$JQUERY_VER" ] && JQUERY_VER=$(echo "$PAGE_CONTENT" | grep -oP 'jquery/\K[\d.]+' | head -1)
[ -n "$JQUERY" ] && echo -e "    ${YELLOW}[jQuery]${NC} Found: $JQUERY"
[ -n "$JQUERY_VER" ] && echo -e "    ${YELLOW}[jQuery]${NC} Version: $JQUERY_VER — Check: https://security.snyk.io/package/npm/jquery/$JQUERY_VER"

# Bootstrap
BOOTSTRAP=$(echo "$PAGE_CONTENT" | grep -oP 'bootstrap[.-](\d+\.\d+\.?\d*)(\.min)?\.js' | head -1)
[ -n "$BOOTSTRAP" ] && echo -e "    ${YELLOW}[Bootstrap]${NC} Found: $BOOTSTRAP"

# Angular
ANGULAR=$(echo "$PAGE_CONTENT" | grep -oP 'angular[.-](\d+\.\d+\.?\d*)(\.min)?\.js' | head -1)
[ -n "$ANGULAR" ] && echo -e "    ${YELLOW}[Angular.js]${NC} Found: $ANGULAR"

# React
REACT=$(echo "$PAGE_CONTENT" | grep -oP 'react[.-](\d+\.\d+\.?\d*)(\.min)?\.js' | head -1)
[ -n "$REACT" ] && echo -e "    ${YELLOW}[React]${NC} Found: $REACT"

echo ""
echo -e "    ${YELLOW}[TIP] Check all detected versions against:${NC}"
echo -e "    ${BOLD}https://security.snyk.io${NC}  (library vulnerability database)"
echo -e "    ${BOLD}https://nvd.nist.gov${NC}       (National Vulnerability Database)"
echo ""

# ─────────────────────────────────────────────
# SECTION 4: Local Dependency Scanning
# ─────────────────────────────────────────────
echo -e "${BOLD}[4] Local Dependency Scanning (if you have app source code)${NC}"
echo ""

echo -e "    ${CYAN}[4a] Node.js / npm:${NC}"
echo -e "    ${BOLD}cd /path/to/nodeapp && npm audit --json | python3 -m json.tool${NC}"
echo -e "    ${BOLD}npx audit-ci --moderate${NC}"
echo ""

echo -e "    ${CYAN}[4b] Python:${NC}"
echo -e "    ${BOLD}pip3 install safety && safety check -r requirements.txt${NC}"
echo -e "    ${BOLD}pip3 install pip-audit && pip-audit${NC}"
echo ""

echo -e "    ${CYAN}[4c] Java (Maven):${NC}"
echo -e "    ${BOLD}mvn org.owasp:dependency-check-maven:check${NC}"
echo ""

echo -e "    ${CYAN}[4d] PHP (Composer):${NC}"
echo -e "    ${BOLD}composer audit${NC}"
echo ""

echo -e "    ${CYAN}[4e] Docker image scan (Trivy):${NC}"
echo -e "    ${BOLD}trivy image nginx:1.18 --severity HIGH,CRITICAL${NC}"
echo -e "    ${BOLD}trivy fs /path/to/app/ --severity HIGH,CRITICAL${NC}"
echo ""

echo -e "    ${CYAN}[4f] OWASP Dependency-Check (universal, supports Java/.NET/Python/JS):${NC}"
echo -e "    ${BOLD}dependency-check --scan /path/to/project --out /tmp/dc_report --format HTML${NC}"
echo ""

echo -e "${CYAN}${BOLD}[A06 Complete]${NC} Cross-reference all identified versions against CVE databases."
echo ""
