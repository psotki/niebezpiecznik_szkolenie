---
title: A06 — Vulnerable Components
sidebar_position: 6
tags: [lab, owasp-a06, fingerprinting, dependency-scanning]
---

# A06 — Vulnerable Components

## What this lab covers

- Technology fingerprinting — identifying server software and versions from HTTP headers
- CMS detection — WordPress, Drupal, Joomla version disclosure
- JavaScript library detection — finding outdated front-end libraries with known CVEs
- Dependency scanning — automated tools for each major ecosystem

## Configuration

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
```

## Exercise 1: Technology Fingerprinting

### HTTP response headers

```bash
curl -sI "$TARGET" | grep -iE "Server:|X-Powered-By:|X-Generator:|X-AspNet-Version:|X-AspNetMvc-Version:"
```

These headers often disclose the web server (nginx 1.18.0), language runtime (PHP/7.4.3), or framework version — enough to identify CVEs.

### WhatWeb

```bash
whatweb -a 3 "$TARGET"
```

### nmap service detection scripts

```bash
nmap -sV --script=http-headers,http-server-header,http-generator "$TARGET" -p "$PORT"
```

## Exercise 2: CMS Detection

### WordPress

```bash
# Login page presence
curl -s -o /dev/null -w "%{http_code}" "$TARGET/wp-login.php"

# Version from readme (often accessible even if login is locked)
curl -s "$TARGET/readme.html" | grep -i "version"

# wp-scan for full enumeration
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

## Exercise 3: JavaScript Library Detection

Search page source for common library signatures:

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

Once versions are identified, check for known CVEs:
- [Snyk Vulnerability Database](https://snyk.io/vuln/)
- [NIST NVD](https://nvd.nist.gov/vuln/search)

## Exercise 4: Dependency Scanning (Defense)

Use these tools in your CI pipeline to catch vulnerable dependencies before they reach production.

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

### Docker images

```bash
# Trivy — scans OS packages and application dependencies
trivy image your-image:tag
```

### Universal (OWASP Dependency-Check)

```bash
dependency-check --project "MyApp" --scan ./src --format HTML --out ./report
```

:::tip
Integrate at least one dependency scanner into your CI/CD pipeline. Automate this — manual checks get skipped under deadline pressure.
:::
