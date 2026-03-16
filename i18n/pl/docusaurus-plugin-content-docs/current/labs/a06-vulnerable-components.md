---
title: A06 — Vulnerable Components
sidebar_position: 6
tags: [lab, owasp-a06, fingerprinting, dependency-scanning]
---

# A06 — Vulnerable Components

## Zakres laboratorium

- Fingerprinting technologii — identyfikacja oprogramowania serwera i wersji z nagłówków HTTP
- Wykrywanie CMS — ujawnianie wersji WordPress, Drupal, Joomla
- Wykrywanie bibliotek JavaScript — znajdowanie przestarzałych bibliotek front-endowych ze znanymi CVE
- Skanowanie zależności — zautomatyzowane narzędzia dla każdego głównego ekosystemu

## Konfiguracja

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
```

## Ćwiczenie 1: Fingerprinting technologii

### Nagłówki odpowiedzi HTTP

```bash
curl -sI "$TARGET" | grep -iE "Server:|X-Powered-By:|X-Generator:|X-AspNet-Version:|X-AspNetMvc-Version:"
```

Te nagłówki często ujawniają serwer WWW (nginx 1.18.0), środowisko uruchomieniowe języka (PHP/7.4.3) lub wersję frameworka — wystarczające do identyfikacji CVE.

### WhatWeb

```bash
whatweb -a 3 "$TARGET"
```

### Skrypty wykrywania usług nmap

```bash
nmap -sV --script=http-headers,http-server-header,http-generator "$TARGET" -p "$PORT"
```

## Ćwiczenie 2: Wykrywanie CMS

### WordPress

```bash
# Sprawdzenie obecności strony logowania
curl -s -o /dev/null -w "%{http_code}" "$TARGET/wp-login.php"

# Wersja z readme (często dostępna nawet przy zablokowanym logowaniu)
curl -s "$TARGET/readme.html" | grep -i "version"

# wp-scan do pełnej enumeracji
wpscan --url "$TARGET" --enumerate p,t,u
```

### Drupal

```bash
curl -s "$TARGET/CHANGELOG.txt" | head -5
```

### Joomla

```bash
curl -s -o /dev/null -w "%{http_code}" "$TARGET/administrator/"
curl -s "$TARGET/administrator/manifests/files/joomla.xml" | grep -i "<version>"
```

## Ćwiczenie 3: Wykrywanie bibliotek JavaScript

Przeszukaj kod źródłowy strony w poszukiwaniu typowych sygnatur bibliotek:

```bash
PAGE=$(curl -s "$TARGET")

# jQuery
echo "$PAGE" | grep -oiE "jquery[.-]([0-9]+\.){2}[0-9]+" | head -3

# Bootstrap
echo "$PAGE" | grep -oiE "bootstrap[.-]([0-9]+\.){2}[0-9]+" | head -3

# AngularJS
echo "$PAGE" | grep -oiE "angular[.-]([0-9]+\.){2}[0-9]+" | head -3

# React
echo "$PAGE" | grep -oiE "react[.-]([0-9]+\.){2}[0-9]+" | head -3
```

Po zidentyfikowaniu wersji sprawdź znane CVE:
- [Snyk Vulnerability Database](https://snyk.io/vuln/)
- [NIST NVD](https://nvd.nist.gov/vuln/search)

## Ćwiczenie 4: Skanowanie zależności (obrona)

Używaj tych narzędzi w potoku CI, aby wykrywać podatne zależności zanim trafią na produkcję.

### Node.js / npm

```bash
npm audit
npx audit-ci --moderate
```

### Python

```bash
pip install safety
safety check

pip-audit
```

### Java (Maven)

```bash
mvn dependency-check:check
```

### PHP (Composer)

```bash
composer audit
```

### Obrazy Docker

```bash
# Trivy — skanuje pakiety systemu operacyjnego i zależności aplikacji
trivy image your-image:tag
```

### Uniwersalne (OWASP Dependency-Check)

```bash
dependency-check --project "MyApp" --scan ./src --format HTML --out ./report
```

:::tip
Zintegruj co najmniej jeden skaner zależności ze swoim potokiem CI/CD. Zautomatyzuj to — ręczne kontrole są pomijane pod presją terminów.
:::
