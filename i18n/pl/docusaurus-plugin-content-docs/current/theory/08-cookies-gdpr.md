---
title: Cookies i RODO
sidebar_position: 9
tags: [cookies, gdpr, defense]
---

:::info TL;DR
Atrybuty bezpieczeństwa cookies chronią użytkowników przed atakami XSS i CSRF, podczas gdy RODO nakłada obowiązek, aby zgoda na niezbędne pliki cookie była wyrażana dobrowolnie i nigdy nie była zaznaczona z góry.
:::

## Czym jest?
Cookies przechowują stan między żądaniami HTTP. Istnieją trzy główne typy: cookies sesyjne (wygasają po zamknięciu przeglądarki), cookies trwałe (mają określoną datę wygaśnięcia) oraz cookies stron trzecich (ustawiane przez domenę inną niż odwiedzana przez użytkownika, używane do śledzenia między witrynami). Każdy cookie może posiadać atrybuty bezpieczeństwa kontrolujące sposób jego obsługi przez przeglądarki.

## Jak działa
Atrybuty bezpieczeństwa są ustawiane w nagłówku odpowiedzi `Set-Cookie`:

```http
Set-Cookie: sessionId=abc123; HttpOnly; Secure; SameSite=Strict
```

- **HttpOnly** — JavaScript nie może odczytać tego cookie, ograniczając skutki ataku XSS
- **Secure** — cookie jest przesyłane tylko przez połączenia HTTPS
- **SameSite=Strict** — cookie nigdy nie jest wysyłane z żądaniami między witrynami (silna ochrona przed CSRF)
- **SameSite=Lax** — cookie jest wysyłane przy nawigacji najwyższego poziomu, ale nie przy osadzonych żądaniach między witrynami
- **SameSite=None** — cookie jest wysyłane we wszystkich kontekstach (wymaga `Secure`)

## Przykład z życia
Strona wyświetla baner zgody na pliki cookie z wcześniej zaznaczonym polem dla cookies analitycznych z etykietą „Zgadzam się". Zgodnie z RODO jest to nielegalne — wstępnie zaznaczone pola zgody nie stanowią ważnej, dobrowolnie wyrażonej zgody.

## Jak się bronić
- Ustaw `HttpOnly` dla wszystkich cookies sesyjnych
- Ustaw `Secure` dla wszystkich cookies
- Ustaw `SameSite=Strict` lub `Lax` dla cookies sesyjnych i uwierzytelniających
- Nigdy nie używaj wstępnie zaznaczonych pól zgody dla niezbędnych cookies (naruszenie RODO)
- Unikaj „ścian ciasteczkowych" (cookie walls), które uzależniają dostęp do strony od zaakceptowania śledzenia
- Użyj dodatku Rentgen do przeglądarki Firefox, aby skanować strony pod kątem trackerów i identyfikować potencjalne naruszenia RODO

:::tip 💡 Łatwe do zapamiętania
`HttpOnly` zamyka cookie przed JavaScriptem — jak sejf, do którego klucz posiada tylko serwer.
:::
