#!/bin/bash
# ============================================================
# OWASP Top 10 (2021) — Kali Linux Lab Setup Script
# Web Application Security Training
# ============================================================
# Run this FIRST to check all required tools are installed.
# Usage: bash 00_lab_setup.sh

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

banner() {
  echo -e "${CYAN}"
  echo "  ██████╗ ██╗    ██╗ █████╗ ███████╗██████╗"
  echo "  ██╔═══██╗██║    ██║██╔══██╗██╔════╝██╔══██╗"
  echo "  ██║   ██║██║ █╗ ██║███████║███████╗██████╔╝"
  echo "  ██║   ██║██║███╗██║██╔══██║╚════██║██╔═══╝"
  echo "  ╚██████╔╝╚███╔███╔╝██║  ██║███████║██║"
  echo "   ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚═╝"
  echo -e "  ${BOLD}OWASP Top 10 (2021) — Kali Linux Attack Lab${NC}"
  echo -e "${CYAN}  Ethical use only. Run only against systems you own or have permission to test.${NC}"
  echo ""
}

check_tool() {
  if command -v "$1" &>/dev/null; then
    echo -e "  ${GREEN}[✓]${NC} $1"
  else
    echo -e "  ${RED}[✗]${NC} $1 — NOT FOUND (install: $2)"
    MISSING+=("$1")
  fi
}

banner
echo -e "${BOLD}[*] Checking required tools...${NC}"
MISSING=()

check_tool "nmap"      "apt install nmap"
check_tool "curl"      "apt install curl"
check_tool "gobuster"  "apt install gobuster"
check_tool "nikto"     "apt install nikto"
check_tool "sqlmap"    "apt install sqlmap"
check_tool "hydra"     "apt install hydra"
check_tool "john"      "apt install john"
check_tool "hashcat"   "apt install hashcat"
check_tool "openssl"   "apt install openssl"
check_tool "python3"   "apt install python3"
check_tool "pip3"      "apt install python3-pip"
check_tool "wfuzz"     "apt install wfuzz"
check_tool "ffuf"      "apt install ffuf"
check_tool "jwt_tool"  "pip3 install jwt_tool  OR  git clone https://github.com/ticarpi/jwt_tool"

echo ""
if [ ${#MISSING[@]} -gt 0 ]; then
  echo -e "${YELLOW}[!] Missing tools: ${MISSING[*]}${NC}"
  echo -e "${YELLOW}[!] Install all missing tools with:${NC}"
  echo -e "    sudo apt update && sudo apt install -y nmap curl gobuster nikto sqlmap hydra john hashcat openssl python3 python3-pip wfuzz ffuf"
  echo -e "    pip3 install jwt_tool"
else
  echo -e "${GREEN}[✓] All tools present. Lab ready.${NC}"
fi

echo ""
echo -e "${BOLD}[*] Available lab scripts:${NC}"
echo -e "  ${CYAN}a01_broken_access_control.sh${NC}  — IDOR, path traversal, JWT attacks, CSRF"
echo -e "  ${CYAN}a02_cryptographic_failures.sh${NC}  — Weak hashing, secret scanning"
echo -e "  ${CYAN}a03_injection.sh${NC}               — SQL injection (sqlmap), XSS, XXE"
echo -e "  ${CYAN}a05_misconfiguration.sh${NC}        — Directory listing, headers, XXE"
echo -e "  ${CYAN}a06_vulnerable_components.sh${NC}   — Dependency scanning"
echo -e "  ${CYAN}a07_auth_failures.sh${NC}           — Brute force, password cracking"
echo -e "  ${CYAN}a08_integrity_failures.sh${NC}      — Deserialization, supply chain"
echo -e "  ${CYAN}a10_ssrf.sh${NC}                    — SSRF probing"

echo ""
echo -e "${YELLOW}[!] LEGAL REMINDER: Only test systems you own or have explicit written permission to test.${NC}"
echo -e "${YELLOW}[!] Unauthorised testing is illegal and unethical.${NC}"
echo ""
