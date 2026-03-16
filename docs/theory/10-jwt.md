---
title: JWT — JSON Web Token
sidebar_position: 11
tags: [crypto, auth, jwt, attack]
---

:::info TL;DR
JWT is a three-part base64-encoded token used for authentication, but misconfigurations like weak secrets or the alg:none attack can allow attackers to forge tokens.
:::

## What is it?

JWT (JSON Web Token) is a three-part structure encoded as `header.payload.signature`.

- **Header**: specifies the algorithm (HS256, RS256, none) and token type
- **Payload**: contains claims such as user ID, role, and expiry — not encrypted, only base64-encoded
- **Signature**: an HMAC or RSA signature used to verify integrity

## How it works

The server issues a signed token. On subsequent requests the client sends the token, and the server verifies the signature before trusting the claims in the payload. Because the payload is only base64-encoded (not encrypted), anyone can read it — the signature is the only thing preventing tampering.

## Real-world example

Key vulnerabilities and how they are exploited:

- **alg:none attack**: remove the signature and change the algorithm field to `"none"`. Vulnerable libraries accept the token as valid.
- **Weak secret**: HS256 secrets can be cracked offline with hashcat mode 16500:
  ```
  hashcat -m 16500 jwt.txt wordlist.txt
  ```
- **RS256 → HS256 confusion**: attacker uses the server's public key as the HMAC secret when the library accepts both algorithm types.
- **CVE-2018-0114 (node-jose)**: a library bug that allowed full signature bypass.

Tool for manual testing:
```
python3 jwt_tool.py <TOKEN> -X a
```

Tool for learning JWT in practice: [Keycloak](https://www.keycloak.org) (open-source IAM).

## How to defend

- Always verify the signature server-side before trusting any claims
- Use strong, randomly generated secrets for HS256
- Explicitly reject the `alg:none` algorithm
- Pin the expected algorithm server-side rather than reading it from the token header

:::tip 💡 Easy to remember
A JWT is like a sealed envelope — anyone can read what's written on the outside, but only the sender's wax seal (signature) proves it hasn't been tampered with. If you accept envelopes with no seal, anyone can forge them.
:::
