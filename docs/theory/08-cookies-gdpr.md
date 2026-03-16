---
title: Cookies & GDPR
sidebar_position: 9
tags: [cookies, gdpr, defense]
---

:::info TL;DR
Cookie security attributes protect users from XSS and CSRF attacks, while GDPR mandates that consent for non-essential cookies must be freely given and never pre-ticked.
:::

## What is it?
Cookies store state between HTTP requests. There are three main types: Session cookies (expire when the browser closes), Persistent cookies (have an explicit expiry date), and Third-party cookies (set by a domain other than the one the user is visiting, used for cross-site tracking). Each cookie can carry security attributes that control how browsers handle it.

## How it works
Security attributes are set in the `Set-Cookie` response header:

```http
Set-Cookie: sessionId=abc123; HttpOnly; Secure; SameSite=Strict
```

- **HttpOnly** — JavaScript cannot read this cookie, limiting damage from XSS
- **Secure** — cookie is only sent over HTTPS connections
- **SameSite=Strict** — cookie is never sent with cross-site requests (strong CSRF protection)
- **SameSite=Lax** — cookie is sent with top-level navigations but not with embedded cross-site requests
- **SameSite=None** — cookie is sent in all contexts (requires `Secure`)

## Real-world example
A site presents a cookie consent banner with a pre-checked box for analytics cookies labelled "I agree." Under GDPR, this is illegal — pre-checked consent boxes do not constitute valid freely given consent.

## How to defend
- Set `HttpOnly` on all session cookies
- Set `Secure` on all cookies
- Set `SameSite=Strict` or `Lax` on session and authentication cookies
- Never use pre-checked consent boxes for non-essential cookies (GDPR violation)
- Avoid cookie walls that make site access conditional on accepting tracking
- Use the Rentgen Firefox addon to scan pages for trackers and identify potential GDPR violations

:::tip 💡 Easy to remember
`HttpOnly` locks the cookie away from JavaScript — like a safe that only the server holds the key to.
:::
