---
title: Rozpoznanie
sidebar_position: 2
tags: [recon, google-dorking, directory-listing, osint, tools]
---

:::info TL;DR
Rozpoznanie to proces zbierania informacji o celu przed atakiem — im więcej wiesz, tym łatwiejszy atak.
:::

## Co to jest?

Rozpoznanie to pierwsza faza ataku, w której napastnik mapuje wystawioną powierzchnię celu. Obejmuje znajdowanie ukrytych katalogów, odsłoniętych plików, endpointów API i danych konfiguracyjnych — często bez wysyłania ani jednego złośliwego żądania. Znaczna część rozpoznania może być prowadzona pasywnie przy użyciu publicznych narzędzi i wyszukiwarek.

## Jak to działa

Napastnicy używają operatorów wyszukiwarek (Google Dorks) do znajdowania zaindeksowanych wrażliwych treści oraz narzędzi takich jak gobuster lub DirBuster do brute-force'owania ukrytych ścieżek. Gdy serwer WWW nie ma pliku `index.html`, może automatycznie wylistować wszystkie pliki w katalogu (Directory Listing / "Index of /"), ujawniając kopie zapasowe, konfiguracje i pliki źródłowe.

```bash
# Brute-force directories on a target
gobuster dir -u https://target.com -w /wordlist.txt -t 50
```

Popularne operatory Google Dork:
- `intitle:` — przeszukuje tytuły stron
- `inurl:` — przeszukuje adresy URL
- `filetype:` — filtruje po rozszerzeniu pliku
- `site:` — ogranicza wyniki do domeny
- `cache:` — wyświetla zbuforowaną wersję strony

## Przykład z życia wzięty

Napastnik używa `filetype:sql site:target.com`, aby znaleźć zaindeksowany zrzut bazy danych. Następnie odwiedza `https://target.com/backup/` i odkrywa, że serwer automatycznie listuje wszystkie pliki, ponieważ brak pliku `index.html` — ujawniając plik `.env` z danymi uwierzytelniającymi do bazy danych.

## Jak się bronić

- Wyłącz listowanie katalogów na wszystkich serwerach WWW (np. `Options -Indexes` w Apache)
- Unikaj umieszczania wrażliwych plików (`.env`, `.sql`, `.bak`) w katalogach dostępnych przez sieć
- Używaj `robots.txt` ostrożnie — może reklamować ukryte ścieżki napastnikom
- Monitoruj, czy twoja domena pojawia się w wynikach Google Dork
- Używaj `dnstwist` do wykrywania domen typosquattingowych wymierzonych w twoją markę

:::tip 💡 Łatwe do zapamiętania
Rozpoznanie jest jak obserwowanie banku przed napadem — napastnicy chodzą wokół, zaglądają przez okna i sprawdzają drzwi, zanim w ogóle spróbują się włamać.
:::
