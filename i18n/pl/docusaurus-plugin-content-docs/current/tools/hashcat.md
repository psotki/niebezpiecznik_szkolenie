---
title: Hashcat
sidebar_position: 11
tags: [tool, crypto, cracking]
---

> **Jedno zdanie:** Narzędzie do łamania skrótów haseł akcelerowane GPU, obsługujące dziesiątki typów skrótów, w tym JWT, MD5, bcrypt i NTLM.

## Kiedy używać

- Łamanie przechwyconego skrótu hasła (MD5, SHA1, bcrypt, NTLM)
- Brute-forcing sekretu JWT (HS256/HS384/HS512) — kluczowy przypadek użycia ze szkolenia
- Ataki słownikowe na zrzuty danych uwierzytelniających

## Kluczowe komendy

```bash
# JWT (HS256/HS384/HS512) — atak słownikowy
hashcat -m 16500 jwt.txt wordlist.txt

# JWT — brute-force 6 małych liter
hashcat -m 16500 -a 3 jwt.txt '?l?l?l?l?l?l'

# MD5
hashcat -m 0 -a 0 hashes.txt rockyou.txt

# SHA1
hashcat -m 100 -a 0 hashes.txt rockyou.txt

# bcrypt
hashcat -m 3200 -a 0 hashes.txt rockyou.txt

# NTLM
hashcat -m 1000 -a 0 hashes.txt rockyou.txt
```

### Tabela trybów skrótów

| Mode (`-m`) | Hash type |
|-------------|-----------|
| `0` | MD5 |
| `100` | SHA1 |
| `1000` | NTLM |
| `3200` | bcrypt |
| `16500` | JWT (HS256/HS384/HS512) |

### Tabela trybów ataku

| Mode (`-a`) | Type |
|-------------|------|
| `0` | Dictionary |
| `3` | Brute-force / mask |

### Znaki masek brute-force

| Placeholder | Character set |
|-------------|--------------|
| `?l` | lowercase a–z |
| `?u` | uppercase A–Z |
| `?d` | digits 0–9 |
| `?s` | special characters |

:::tip 💡 Pamiętaj
MD5 pęka w sekundy na GPU; bcrypt jest zaprojektowany tak, żeby być miliony razy wolniejszy — wybór odpowiedniego algorytmu haszowania ma ogromne znaczenie dla bezpieczeństwa przechowywania haseł.
:::
