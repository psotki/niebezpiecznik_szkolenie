---
title: Wykrywanie endpointów
sidebar_position: 6
tags: [recon, owasp-a01]
---

:::info TL;DR
Wykrywanie endpointów to praktyka znajdowania ukrytych endpointów API i paneli administracyjnych poprzez zgadywanie wzorców URL — ma to znaczenie, ponieważ dostępne ukryte ścieżki mogą dać napastnikowi bezpośredni dostęp do wrażliwych funkcji.
:::

## Co to jest?
Wykrywanie endpointów polega na brute-force'owaniu lub zgadywaniu wzorców URL w celu znalezienia ścieżek, które nie są publicznie linkowane. Napastnicy szukają paneli administracyjnych, plików kopii zapasowych, endpointów konfiguracyjnych i katalogów kontroli wersji. Te ukryte ścieżki są często omyłkowo pozostawione dostępnymi i mogą ujawniać krytyczne funkcje.

## Jak to działa
Narzędzia takie jak DirBuster i gobuster brute-force'ują ścieżki ze słowników, wysyłając żądania HTTP do każdej kandydackiej ścieżki i rejestrując te, które zwracają odpowiedź.

```bash
gobuster dir -u https://target.com -w /usr/share/wordlists/dirb/common.txt
```

Popularne ukryte ścieżki do sprawdzenia: `/admin`, `/backup`, `/config`, `/.git`, `/.svn`.

## Przykład z życia wzięty
Endpoint `/api/jsonws` w Liferay jest znana ukrytą powierzchnią API, która była wykorzystywana razem z exploitem Metasploit do uzyskania zdalnego wykonania kodu na niezaktualizowanych instancjach.

## Jak się bronić
- Blokuj dostęp do wrażliwych ścieżek (`/.git`, `/.svn`, `/backup`, `/config`) w konfiguracji serwera WWW
- Unikaj wdrażania paneli administracyjnych na publicznie dostępnych ścieżkach
- Zwracaj spójne odpowiedzi (np. 404) dla nieistniejących ścieżek, aby ograniczyć wyciek informacji
- Regularnie audytuj publicznie dostępne endpointy

:::tip 💡 Łatwe do zapamiętania
Jeśli widzisz `/api/v1/users`, spróbuj `/api/v1/admin` — napastnicy myślą w kategoriach rodzeństwa ścieżek.
:::
