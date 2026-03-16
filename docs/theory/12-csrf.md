---
title: CSRF — Cross-Site Request Forgery
sidebar_position: 13
tags: [csrf, attack, http]
---

:::info TL;DR
CSRF tricks a logged-in user's browser into sending an authenticated request to a target site without their knowledge, because browsers automatically attach cookies to matching requests.
:::

## What is it?

Cross-Site Request Forgery (CSRF) is an attack that forces a logged-in user to unknowingly perform actions on a website they are already authenticated on. The attacker does not steal credentials — they abuse the fact that browsers automatically send cookies with requests to the relevant domain.

## How it works

1. The attacker hosts a malicious page containing a hidden form or image tag pointing to the target site.
2. The victim, who is logged in to the target site, visits the malicious page.
3. The victim's browser automatically sends a request to the target site, including the valid session cookie.
4. The target site sees a legitimate authenticated request and processes it.

The victim never sees anything happen and the attacker never needs to know the session token.

## Real-world example

A malicious page contains a hidden form that POSTs to `bank.com/transfer` with attacker-controlled parameters (recipient, amount). When the logged-in victim loads the page, their browser submits the form automatically with their session cookie, and the bank processes the transfer.

## How to defend

- **CSRF tokens**: include a unique, per-session unpredictable token in every state-changing form; verify it server-side
- **SameSite=Strict cookies**: the browser will not send the cookie in any cross-site request
- **Check Origin/Referer headers** server-side to confirm the request originated from the expected domain
- **Double Submit Cookie pattern**: set a random value in both a cookie and a request parameter; verify they match server-side

:::tip 💡 Easy to remember
CSRF is like a forged letter — the bank sees your signature (cookie) on a letter you never wrote, because someone tricked you into unknowingly signing a blank page.
:::
