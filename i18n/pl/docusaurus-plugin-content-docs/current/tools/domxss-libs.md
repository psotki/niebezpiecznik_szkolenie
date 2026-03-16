---
title: DOMPurify & escape-goat — Biblioteki obrony przed XSS
sidebar_position: 14
tags: [tool, defense, xss, javascript]
---

> **Jedno zdanie:** Biblioteki JavaScript po stronie klienta do bezpiecznego wstawiania treści dostarczanych przez użytkownika do DOM — zapobieganie XSS na etapie wyjścia.

## Kiedy używać

- Przed każdym przypisaniem do `innerHTML` zawierającym treść dostarczoną przez użytkownika lub niezaufaną — użyj DOMPurify
- Gdy wstawiasz czysty tekst do kontekstu HTML (nie sam HTML) — użyj escape-goat
- Jako warstwa obrony uzupełniająca (a nie zastępująca) sanityzację po stronie serwera

## Kluczowe rozróżnienie

| Approach | Use when | Method |
|----------|----------|--------|
| **Escaping** | Wstawianie czystego tekstu do HTML | Zamień `<`, `>`, `&`, `"`, `'` na encje HTML |
| **Sanitizing** | Dozwolenie na część HTML z usunięciem niebezpiecznych elementów | Parsuj i wycinaj niebezpieczne tagi/atrybuty |

---

## DOMPurify

Sanityzator HTML — usuwa niebezpieczny HTML/JS z wejścia, zachowując bezpieczne znaczniki.

```bash
npm install dompurify
```

```js
import DOMPurify from 'dompurify';

// Zwraca czysty HTML z usuniętymi niebezpiecznymi elementami/atrybutami
const clean = DOMPurify.sanitize(dirty);
element.innerHTML = clean;
```

- Standard produkcyjny dla bezpiecznego użycia `innerHTML`
- GitHub: [https://github.com/cure53/DOMPurify](https://github.com/cure53/DOMPurify)

---

## setHTML()

Nowoczesne API przeglądarki do bezpiecznego wstawiania HTML z automatyczną sanityzacją — bez potrzeby stosowania biblioteki.

```js
element.setHTML(untrustedHTML);
```

- Uwaga dotycząca wsparcia przeglądarek: Firefox 148+ (od marca 2026)

---

## escape-goat

Lekka biblioteka npm do escapowania HTML (nie sanityzacji).

```bash
npm install escape-goat
```

```js
import {escapeHtml} from 'escape-goat';

// Zamienia <, >, &, ", ' na encje HTML
const safe = escapeHtml(userString);
element.textContent = safe;  // lub użyj w szablonie HTML
```

- Użyj, gdy wstawiasz czysty tekst — nie HTML — do kontekstu HTML

:::tip 💡 Pamiętaj
Escaping ≠ sanityzacja: escape-goat sprawia, że tekst jest bezpieczny do osadzenia w HTML; DOMPurify sprawia, że HTML jest bezpieczny do renderowania. Użyj odpowiedniego narzędzia do tego, co wstawiasz.
:::
