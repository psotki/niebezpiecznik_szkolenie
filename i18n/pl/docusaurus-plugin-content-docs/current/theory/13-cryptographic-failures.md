---
title: Błędy kryptograficzne
sidebar_position: 14
tags: [crypto, attack, owasp-a02]
---

:::info TL;DR
Cryptographic Failures (OWASP A02:2021) obejmuje słabe algorytmy, złą konfigurację TLS, niezabezpieczone przechowywanie haseł i wycieki sekretów w kodzie — wszystko to może prowadzić do ujawnienia wrażliwych danych.
:::

## Co to jest?

OWASP A02:2021 — Cryptographic Failures (dawniej „Sensitive Data Exposure") obejmuje szeroką kategorię słabości: słabe lub przestarzałe algorytmy, złą konfigurację TLS, niezabezpieczone przechowywanie haseł oraz sekrety umieszczone w kodzie źródłowym.

## Jak to działa

Typowe wzorce błędów:

- **Słabe hashowanie**: MD5 i SHA1 są z założenia szybkie, co sprawia, że można je trywialnie złamać offline za pomocą narzędzi takich jak hashcat. bcrypt jest celowo wolny — miliony razy wolniejszy niż MD5.
- **Sekrety w kodzie**: klucze API, hasła i tokeny umieszczone w repozytoriach mogą zostać wykryte przez automatyczne skanery lub każdego, kto ma dostęp do historii git.
- **Zła konfiguracja TLS**: przestarzałe wersje protokołów lub słabe zestawy szyfrów narażają ruch na przechwycenie.

## Przykład z rzeczywistości

Łamanie wycieczniętego hasha MD5:
```
hashcat -m 0 hashes.txt rockyou.txt
```

Ten sam atak przeciwko bcrypt jest rzędy wielkości wolniejszy:
```
hashcat -m 3200 hashes.txt rockyou.txt
```

Skanowanie kodu źródłowego i historii git w poszukiwaniu wyciekniętych sekretów:
```
grep -r "password=\|secret=\|api_key=\|AKIA\|Bearer" .
```

Zautomatyzowane skanery historii git: `trufflehog`, `gitleaks`.

## Jak się bronić

- Używaj **bcrypt** lub **Argon2** do hashowania haseł — nigdy MD5 ani SHA1
- Wymuszaj **TLS 1.3** i wyłącz przestarzałe wersje protokołów
- **Skanuj historię git** w poszukiwaniu sekretów przed upublicznieniem repozytoriów (trufflehog, gitleaks)
- Rotuj wszelkie sekrety, które mogły zostać ujawnione

:::tip 💡 Łatwe do zapamiętania
Przechowywanie haseł w MD5 jest jak zamknięcie sejfu kombinacją, którą można odgadnąć w jedną sekundę. bcrypt sprawia, że każde odgadnięcie zajmuje całą sekundę — ten sam zamek wymaga teraz lat do złamania brutalną siłą.
:::
