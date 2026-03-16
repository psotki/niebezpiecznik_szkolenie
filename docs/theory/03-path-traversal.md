---
title: Path Traversal
sidebar_position: 4
tags: [path-traversal, access-control, directory-traversal, misconfiguration]
---

:::info TL;DR
Path traversal lets an attacker escape the intended directory by injecting `../` sequences into a file path, reaching files the application was never meant to serve.
:::

## What is it?

Path traversal (also called directory traversal) is a vulnerability where an attacker manipulates file path inputs to access files and directories outside the intended scope. It typically exploits insufficient input sanitization in web applications or reverse proxy configurations. A successful attack can expose server configuration files, credentials, or source code.

## How it works

By inserting `../` sequences into a URL or parameter, an attacker walks up the directory tree. Servers or proxies that fail to normalize or validate paths before routing requests are vulnerable. Attackers also use encoded and obfuscated variants to bypass naive filters.

Common bypass variants:
```
/..;/admin
/%2e%2e;/admin
/admin%20
/admin%09
```

## Real-world example

In the training, a misconfiguration involving Jira, Tomcat, and Nginx was demonstrated. Nginx was configured to block access to `/admin`, but Tomcat received the raw, un-normalized path. By requesting `/..;/admin`, the Nginx rule was bypassed while Tomcat resolved the path correctly to `/admin` — granting access to the protected panel.

## How to defend

- Normalize and resolve all file paths server-side before processing or routing them
- Use allowlists to define which paths are valid — reject anything outside the expected set
- Ensure reverse proxies (Nginx, HAProxy) and backend servers (Tomcat, Jetty) apply consistent path normalization
- Never rely solely on string-matching rules (e.g., "block if URL contains /admin") — use structural checks

:::tip 💡 Easy to remember
Path traversal is like a hotel guest asking for "room 100, then go up two floors and left" — if the receptionist follows directions literally instead of checking the room number, they end up somewhere they shouldn't be.
:::
