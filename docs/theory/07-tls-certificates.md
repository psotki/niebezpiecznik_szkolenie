---
title: TLS & Certificates
sidebar_position: 8
tags: [crypto, tls, defense]
---

:::info TL;DR
TLS creates an encrypted channel between client and server using a certificate trust chain — misconfigured TLS exposes users to interception and weakens the security of every feature built on top of it.
:::

## What is it?
TLS creates an encrypted channel between a client and a server, preventing eavesdropping and tampering in transit. Trust is established through Certificate Authorities (CAs): the browser trusts the CA, and the CA vouches for the server by signing its certificate. TLS 1.3 is the current recommended version — it uses a faster 1-RTT handshake and removes weak cipher suites that were present in TLS 1.2.

## How it works
During the handshake, the server presents its certificate. The client verifies the CA signature, then both sides agree on a cipher suite and derive session keys. All subsequent traffic is encrypted.

Certificate Transparency (CT) logs are public records of every certificate ever issued by a CA. Attackers and defenders alike use CT logs to enumerate subdomains of a target.

```bash
# Query CT logs to find subdomains
curl "https://crt.sh/?q=%.example.com&output=json" | jq '.[].name_value'
```

## Real-world example
An organization running TLS 1.0 on a legacy server is vulnerable to protocol downgrade attacks. A scan on `https://www.ssllabs.com/ssltest/` returns an F rating, revealing the weak configuration before an attacker exploits it.

## How to defend
- Use TLS 1.3; disable TLS 1.0, TLS 1.1, and SSLv3
- Use strong cipher suites (avoid RC4, 3DES, export-grade ciphers)
- Generate a safe server TLS config at https://ssl-config.mozilla.org/
- Test your current config at https://www.ssllabs.com/ssltest/
- Monitor Certificate Transparency logs for unauthorized certificates issued for your domains

:::tip 💡 Easy to remember
TLS is the envelope — CT logs are the post office keeping a public record of every envelope ever sent.
:::
