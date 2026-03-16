---
title: HTTP Headers & CF-Connecting-IP Spoofing
sidebar_position: 12
tags: [http, headers, spoofing, attack]
---

:::info TL;DR
If a server blindly trusts IP headers like CF-Connecting-IP or X-Forwarded-For without verifying the request actually came through Cloudflare, attackers can spoof any IP address.
:::

## What is it?

Cloudflare adds a `CF-Connecting-IP` header to requests it proxies, containing the real client IP. Servers behind Cloudflare often read this header to identify clients. The related `X-Forwarded-For` header is used similarly by other proxies and load balancers.

## How it works

When a request flows through Cloudflare, Cloudflare sets `CF-Connecting-IP` to the originating client's IP. The origin server reads this value and uses it for logging, rate limiting, or access control.

The problem: if an attacker bypasses Cloudflare and connects directly to the origin server, they can include any value they like in the `CF-Connecting-IP` header. The origin has no way to distinguish a legitimate Cloudflare-injected header from one the attacker fabricated — unless it verifies the request actually arrived from a Cloudflare IP address.

## Real-world example

An attacker discovers the origin IP of a server sitting behind Cloudflare. They send a direct HTTP request to that IP with a crafted header:

```
CF-Connecting-IP: 1.2.3.4
```

If the server uses this header for IP allowlisting or rate-limit bypass logic, the attacker has effectively spoofed a trusted IP. The same technique applies to `X-Forwarded-For` in any proxy setup.

## How to defend

- **Whitelist Cloudflare IP ranges at the firewall level** so the origin only accepts connections from Cloudflare: [https://www.cloudflare.com/ips/](https://www.cloudflare.com/ips/)
- Only trust `CF-Connecting-IP` when you are certain all traffic is routed through Cloudflare
- Treat `X-Forwarded-For` as untrusted input unless the upstream proxy is strictly controlled

:::tip 💡 Easy to remember
Trusting CF-Connecting-IP without checking the source is like accepting a VIP wristband from someone who walked in through the back door — the wristband only means something if the doorman put it there.
:::
