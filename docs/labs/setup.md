---
title: Lab Setup
sidebar_position: 1
---

# ⚙️ Lab Setup

Before running any lab, ensure your Kali Linux environment has the required tools installed.

:::warning Prerequisites
These labs require Kali Linux (or a comparable pentesting distro). Run with explicit permission on systems you own or are authorized to test.
:::

## Required tools

Install everything at once:

```bash
sudo apt update && sudo apt install -y \
  nmap curl gobuster nikto sqlmap \
  hydra john hashcat openssl \
  python3 python3-pip wfuzz ffuf
```

## Python tools

```bash
pip3 install jwt_tool trufflehog gitleaks
```

## Optional tools (used in specific labs)

```bash
# jwt_tool (from source)
git clone https://github.com/ticarpi/jwt_tool /opt/jwt_tool

# phpggc (PHP deserialization gadget chains)
git clone https://github.com/ambionics/phpggc.git /opt/phpggc

# ysoserial (Java deserialization)
wget https://github.com/frohoff/ysoserial/releases/latest/download/ysoserial-all.jar -O /opt/ysoserial.jar

# SSRFmap (automated SSRF exploitation)
git clone https://github.com/swisskyrepo/SSRFmap.git /opt/SSRFmap
```

## Wordlists

| Path | Use |
|------|-----|
| `/usr/share/wordlists/dirb/common.txt` | Directory/file brute-forcing |
| `/usr/share/wordlists/rockyou.txt` | Password cracking |
| `/usr/share/wordlists/metasploit/unix_users.txt` | Username enumeration |

## Lab configuration

Each lab script has a configuration block at the top. Edit these before running:

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
WORDLIST="/usr/share/wordlists/dirb/common.txt"
```

## OWASP Labs index

| Lab | OWASP Category |
|-----|---------------|
| [A01 — Broken Access Control](./a01-broken-access-control) | A01:2021 |
| [A02 — Cryptographic Failures](./a02-cryptographic-failures) | A02:2021 |
| [A03 — Injection](./a03-injection) | A03:2021 |
| [A05 — Security Misconfiguration](./a05-misconfiguration) | A05:2021 |
| [A06 — Vulnerable Components](./a06-vulnerable-components) | A06:2021 |
| [A07 — Authentication Failures](./a07-auth-failures) | A07:2021 |
| [A08 — Integrity Failures](./a08-integrity-failures) | A08:2021 |
| [A10 — SSRF](./a10-ssrf) | A10:2021 |
