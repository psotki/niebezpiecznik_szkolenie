---
title: Ujawnienie .git — wycieki kodu źródłowego
sidebar_position: 10
tags: [recon, attack, source-code]
---

:::info TL;DR
Ujawniony katalog `.git/` na serwerze webowym pozwala atakującym zrekonstruować cały kod źródłowy aplikacji — łącznie z sekretami i kluczami API z pełnej historii commitów.
:::

## Czym jest?
Gdy katalog `.git/` zostanie przypadkowo wdrożony na produkcyjny serwer webowy, a listowanie katalogów jest włączone (lub poszczególne pliki są dostępne), atakujący mogą pobrać surowe obiekty Git i zrekonstruować pełne repozytorium. Ujawnia to cały kod źródłowy, historię commitów, pliki konfiguracyjne oraz wszelkie sekrety, które kiedykolwiek zostały zacommitowane — nawet jeśli zostały później usunięte z najnowszej wersji.

## Jak działa
Rozszerzenie przeglądarki DotGit automatycznie wykrywa ujawnione ścieżki `.git`, `.svn` i `.env` podczas przeglądania. Po potwierdzeniu wycieku `git-dumper` pobiera pełne repozytorium:

```bash
# Install git-dumper
pipx install git-dumper

# Dump the exposed repository
git-dumper https://target.com/.git/ ./output
```

Po wykonaniu dumpu atakujący posiada pełny lokalny klon i może uruchamiać `git log`, `git show` oraz `grep`, aby znajdować zahardkodowane dane uwierzytelniające i klucze API we wszystkich historycznych commitach.

## Przykład z życia
Deweloper wdraża aplikację webową, przesyłając folder projektu — włącznie z katalogiem `.git/` — na publiczny serwer. Atakujący używa rozszerzenia DotGit, aby wykryć ekspozycję, uruchamia `git-dumper` w celu zrekonstruowania repozytorium i znajduje klucz sekretny AWS zacommitowany sześć miesięcy temu, który nigdy nie został zmieniony.

## Jak się bronić
- Nigdy nie wdrażaj katalogu `.git/` na serwery produkcyjne
- Zablokuj dostęp do `/.git` w konfiguracji serwera webowego:
  ```nginx
  location ~ /\.git {
      deny all;
  }
  ```
- Używaj `.gitignore` i narzędzi do skanowania sekretów, aby zapobiec ich trafianiu do repozytorium
- Rotuj wszelkie dane uwierzytelniające, które mogły zostać ujawnione przez historię git
- Regularnie audytuj wdrożenia za pomocą narzędzi takich jak rozszerzenie DotGit

:::tip 💡 Łatwe do zapamiętania
Zacommitowanie sekretu to jak napisanie go trwałym markerem — nawet jeśli go zamalujesz, pełna historia zawsze tam jest.
:::
