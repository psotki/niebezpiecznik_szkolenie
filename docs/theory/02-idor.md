---
title: IDOR (Insecure Direct Object Reference)
sidebar_position: 3
tags: [idor, access-control, authorization, owasp]
---

:::info TL;DR
IDOR lets an attacker access other users' data simply by changing an ID in the URL — because the server never checks if you're allowed to see it.
:::

## What is it?

IDOR (Insecure Direct Object Reference) is an access control vulnerability where an application exposes internal object references — like database IDs — directly in URLs or parameters. The server trusts the client to only request their own data and performs no server-side authorization check, so anyone can access anyone else's records by changing the ID.

## How it works

A user accesses their own profile at `https://app.com/profile?id=42`. By changing the `id` parameter to another number, they can view or modify a completely different user's data — no authentication bypass required, just curiosity and a URL bar.

```
# Accessing your own profile
GET /profile?id=42

# Accessing someone else's profile — no authorization check server-side
GET /profile?id=43
GET /profile?id=1
```

## Real-world example

During the training, a tester cycled through IDs 1–20 on a profile endpoint. Each request returned a different user's full profile data — name, email, address — with no error or access denied response. The server assumed that if you knew the ID, you were allowed to see it.

## How to defend

- Enforce server-side authorization on every request — check that the authenticated user owns the requested resource
- Replace sequential integer IDs with UUIDs (e.g., `a3f9c2d1-...`) to make guessing impractical
- Never rely on obscurity — a hard-to-guess ID is not a substitute for an authorization check
- Log and alert on access patterns that suggest enumeration (many sequential ID requests)

:::tip 💡 Easy to remember
IDOR is like a hotel where every room has a number on the door and no lock — just changing the number gets you into anyone's room.
:::
