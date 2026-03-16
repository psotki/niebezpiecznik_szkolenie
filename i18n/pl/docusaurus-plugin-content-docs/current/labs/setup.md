---
title: Konfiguracja laboratorium
sidebar_position: 1
---

# ⚙️ Konfiguracja laboratorium

Przed uruchomieniem jakiegokolwiek laboratorium upewnij się, że w środowisku Kali Linux zainstalowane są wymagane narzędzia.

:::warning Wymagania wstępne
Laboratoria wymagają Kali Linux (lub porównywalnej dystrybucji do pentestów). Uruchamiaj je wyłącznie za wyraźnym zezwoleniem na systemach, które posiadasz lub masz upoważnienie do testowania.
:::

## Wymagane narzędzia

Zainstaluj wszystko jednocześnie:

```bash
sudo apt update && sudo apt install -y \
  nmap curl gobuster nikto sqlmap \
  hydra john hashcat openssl \
  python3 python3-pip wfuzz ffuf
```

## Narzędzia Python

```bash
pip3 install jwt_tool trufflehog gitleaks
```

## Narzędzia opcjonalne (używane w konkretnych laboratoriach)

```bash
# jwt_tool (ze źródeł)
git clone https://github.com/ticarpi/jwt_tool /opt/jwt_tool

# phpggc (łańcuchy gadżetów deserializacji PHP)
git clone https://github.com/ambionics/phpggc.git /opt/phpggc

# ysoserial (deserializacja Java)
wget https://github.com/frohoff/ysoserial/releases/latest/download/ysoserial-all.jar -O /opt/ysoserial.jar

# SSRFmap (automatyczna eksploatacja SSRF)
git clone https://github.com/swisskyrepo/SSRFmap.git /opt/SSRFmap
```

## Listy słów

| Ścieżka | Zastosowanie |
|---------|-------------|
| `/usr/share/wordlists/dirb/common.txt` | Brute-forcing katalogów i plików |
| `/usr/share/wordlists/rockyou.txt` | Łamanie haseł |
| `/usr/share/wordlists/metasploit/unix_users.txt` | Enumeracja nazw użytkowników |

## Konfiguracja laboratorium

Każdy skrypt laboratoryjny zawiera blok konfiguracyjny na początku. Edytuj go przed uruchomieniem:

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
WORDLIST="/usr/share/wordlists/dirb/common.txt"
```

## Indeks laboratoriów OWASP

| Laboratorium | Kategoria OWASP |
|-------------|----------------|
| [A01 — Broken Access Control](./a01-broken-access-control) | A01:2021 |
| [A02 — Cryptographic Failures](./a02-cryptographic-failures) | A02:2021 |
| [A03 — Injection](./a03-injection) | A03:2021 |
| [A05 — Security Misconfiguration](./a05-misconfiguration) | A05:2021 |
| [A06 — Vulnerable Components](./a06-vulnerable-components) | A06:2021 |
| [A07 — Authentication Failures](./a07-auth-failures) | A07:2021 |
| [A08 — Integrity Failures](./a08-integrity-failures) | A08:2021 |
| [A10 — SSRF](./a10-ssrf) | A10:2021 |
