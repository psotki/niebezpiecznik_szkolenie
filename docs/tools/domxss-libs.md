---
title: DOMPurify & escape-goat — XSS Defense Libraries
sidebar_position: 14
tags: [tool, defense, xss, javascript]
---

> **One-liner:** Client-side JavaScript libraries for safely inserting user-supplied content into the DOM — preventing XSS at the output stage.

## When to use it

- Before any `innerHTML` assignment that includes user-supplied or untrusted content — use DOMPurify
- When inserting plain text into an HTML context (not HTML itself) — use escape-goat
- As a defense layer in addition to (not instead of) server-side sanitization

## Key distinction

| Approach | Use when | Method |
|----------|----------|--------|
| **Escaping** | Inserting plain text into HTML | Convert `<`, `>`, `&`, `"`, `'` to HTML entities |
| **Sanitizing** | Allowing some HTML but removing dangerous parts | Parse and strip dangerous tags/attributes |

---

## DOMPurify

HTML sanitizer — removes dangerous HTML/JS from input while preserving safe markup.

```bash
npm install dompurify
```

```js
import DOMPurify from 'dompurify';

// Returns clean HTML with dangerous elements/attributes stripped
const clean = DOMPurify.sanitize(dirty);
element.innerHTML = clean;
```

- Production standard for safe `innerHTML` usage
- GitHub: [https://github.com/cure53/DOMPurify](https://github.com/cure53/DOMPurify)

---

## setHTML()

Modern browser API for safe HTML insertion with automatic sanitization — no library needed.

```js
element.setHTML(untrustedHTML);
```

- Browser support note: Firefox 148+ (as of March 2026)

---

## escape-goat

Lightweight npm library for HTML escaping (not sanitizing).

```bash
npm install escape-goat
```

```js
import {escapeHtml} from 'escape-goat';

// Converts <, >, &, ", ' to HTML entities
const safe = escapeHtml(userString);
element.textContent = safe;  // or use in HTML template
```

- Use when you are inserting plain text — not HTML — into an HTML context

:::tip 💡 Remember
Escaping ≠ sanitizing: escape-goat makes text safe to embed in HTML; DOMPurify makes HTML safe to render. Use the right tool for what you are inserting.
:::
