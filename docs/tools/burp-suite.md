---
title: Burp Suite
sidebar_position: 5
tags: [tool, proxy, recon]
---

> **One-liner:** HTTP/HTTPS proxy that intercepts, modifies, and replays web requests between your browser and a server.

## When to use it

- IDOR testing — change object IDs in requests to access other users' data
- Parameter tampering — modify hidden form fields or request parameters
- Cookie manipulation — edit session tokens or role flags
- Brute-forcing parameters with Intruder
- Replaying and tweaking individual requests with Repeater

## Install

Download from [https://portswigger.net/burp](https://portswigger.net/burp). Community edition is free.

### Setup

```
1. Set browser proxy to 127.0.0.1:8080
2. Download Burp CA certificate from http://burpsuite (while proxied)
3. Install the CA cert in your browser's trusted certificate store
```

Burp creates two TLS sessions (MITM): browser ↔ Burp ↔ server.

## Key tabs

| Tab | What it does |
|-----|-------------|
| **Proxy** | Intercept and modify live requests in real time |
| **Repeater** | Manually modify and resend individual requests |
| **Intruder** | Automated attacks — brute-force parameters, fuzzing payloads |
| **Scanner** *(Pro only)* | Automated vulnerability scanning |

:::tip 💡 Remember
Repeater is your best friend for manual testing — send a request there from Proxy with right-click, then iterate freely without touching the browser.
:::
