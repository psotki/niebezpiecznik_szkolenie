---
title: Gobuster / DirBuster
sidebar_position: 2
tags: [tool, recon]
---

> **Jedno zdanie:** Przeszukuje metodą brute-force katalogi i pliki na serwerach WWW przy użyciu list słów, aby odkryć ukrytą zawartość.

## Kiedy używać

- Szukanie ukrytych paneli administracyjnych niepołączonych z główną stroną
- Lokalizowanie plików kopii zapasowych, plików konfiguracyjnych lub przypadkowo wystawionych katalogów `.git`
- Odkrywanie endpointów przed głębszymi testami

## Instalacja

```bash
# Kali Linux
sudo apt install gobuster

# macOS
brew install gobuster
```

## Kluczowe komendy

| Command | What it does |
|---------|-------------|
| `gobuster dir -u https://target.com -w /wordlist.txt -t 50` | Podstawowy brute-force katalogów z 50 wątkami |
| `gobuster dir -u https://target.com -w /wordlist.txt -x php,html,bak,txt,json,xml` | Dodatkowo wyszukuje pliki z określonymi rozszerzeniami |
| `gobuster dir -u https://target.com -w /wordlist.txt -q -o results.txt` | Tryb cichy, zapis wyników do pliku |

### Przydatne flagi

| Flag | Meaning |
|------|---------|
| `-x` | Rozszerzenia plików do dołączenia (np. `php,html,bak,txt,json,xml`) |
| `-t` | Liczba równoległych wątków |
| `-q` | Tryb cichy (mniej szumu w wyjściu) |
| `-o` | Zapisz wyniki do pliku |

### Lokalizacje list słów

```
/usr/share/wordlists/dirb/common.txt   # wbudowana na Kali
SecLists                                # listy społecznościowe, szersze pokrycie
```

:::tip 💡 Pamiętaj
DirBuster to wersja GUI od OWASP; gobuster to szybszy odpowiednik w wierszu poleceń — w praktyce preferuj gobuster.
:::
