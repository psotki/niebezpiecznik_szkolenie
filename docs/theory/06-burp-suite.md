---
title: Burp Suite — HTTP Interception
sidebar_position: 7
tags: [tool, proxy, recon]
---

:::info TL;DR
Burp Suite is a man-in-the-middle proxy that intercepts and manipulates HTTP/S traffic between your browser and a server, making it the go-to tool for web application security testing.
:::

## What is it?
Burp Suite acts as a MITM proxy positioned between the browser and the target server. It decrypts HTTPS traffic by creating two separate TLS sessions — one with the browser and one with the server. This allows a tester to inspect, modify, and replay every request and response in plain text.

## How it works
Set your browser proxy to `127.0.0.1:8080` and install the Burp CA certificate so your browser trusts Burp's TLS certificates. Traffic then flows through Burp before reaching the server.

```
Browser → Burp (127.0.0.1:8080) → Target Server
         [intercept / modify]
```

Key tabs:
- **Proxy** — intercept and inspect live requests
- **Repeater** — manually modify and resend a captured request
- **Intruder** — automate attacks such as brute-forcing or fuzzing parameters

## Real-world example
When testing for IDOR, a tester captures a request to `/api/orders/1001` in Proxy, forwards it to Repeater, changes the order ID to `1002`, and checks whether the server returns another user's order.

## How to defend
- Enforce server-side authorization checks — never trust client-supplied IDs or parameters
- Use HTTPS with certificate pinning in mobile/thick clients to complicate proxying
- Log and alert on anomalous request patterns (e.g., rapid sequential ID enumeration)

:::tip 💡 Easy to remember
Burp is the "pause button" for HTTP — it lets you freeze a request mid-flight and rewrite it before it lands.
:::
