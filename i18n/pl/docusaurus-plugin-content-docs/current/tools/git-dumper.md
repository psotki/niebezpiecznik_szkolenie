---
title: git-dumper
sidebar_position: 4
tags: [tool, recon, source-code]
---

> **Jedno zdanie:** Pobiera wystawione repozytorium `.git` z serwera WWW, umożliwiając inspekcję jego pełnej historii i zawartości.

## Kiedy używać

- Gdy znajdziesz serwer z dostępnym katalogiem `/.git/` (np. `https://target.com/.git/HEAD` zwraca 200)
- Wydobywanie kodu źródłowego, danych uwierzytelniających lub sekretów konfiguracyjnych zacommitowanych do systemu kontroli wersji
- Po pobraniu: przeglądanie historii w poszukiwaniu przypadkowo zacommitowanych kluczy API, haseł lub wewnętrznych ścieżek

## Instalacja

```bash
pipx install git-dumper
```

## Kluczowe komendy

```bash
# Pobierz wystawione repozytorium do lokalnego katalogu
git-dumper https://target.com/.git/ ./output

# Po pobraniu — eksploruj historię
git log                         # przeglądaj historię commitów
git diff HEAD~1 HEAD            # różnica między dwoma ostatnimi commitami
grep -r "password\|secret\|api_key" ./output   # szukaj sekretów
```

### Narzędzie uzupełniające

**DotGit** rozszerzenie przeglądarki (Firefox / Chrome) — automatycznie wykrywa wystawione pliki `.git`, `.svn` i `.env` podczas przeglądania. Sygnalizuje je na pasku narzędzi, żebyś żadnego nie przeoczył.

:::tip 💡 Pamiętaj
Zawsze uruchamiaj `git log` po pobraniu — deweloperzy często usuwają plik z sekretem w późniejszym commicie, ale sekret nadal jest widoczny w historii.
:::
