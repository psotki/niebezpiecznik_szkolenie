---
title: Nikto
sidebar_position: 12
tags: [tool, scanning, recon]
---

> **Jedno zdanie:** Skaner podatności serwera WWW, który wykrywa błędne konfiguracje, pliki domyślne, przestarzałe oprogramowanie i niebezpieczne nagłówki HTTP.

## Kiedy używać

- Szybki rekonesans przed głębszym testowaniem manualnym
- Znajdowanie łatwych celów: domyślne dane uwierzytelniające, wystawione ścieżki administracyjne, brakujące nagłówki bezpieczeństwa
- Identyfikowanie przestarzałych wersji oprogramowania serwera

## Kluczowe komendy

```bash
# Podstawowy skan
nikto -h http://target -p 80

# Pełny skan z określonymi pluginami
nikto -h http://target -Plugins headers,paths,auth,outdated
```

### Dostępne pluginy

| Plugin | What it checks |
|--------|---------------|
| `headers` | Nagłówki bezpieczeństwa (HSTS, X-Frame-Options, CSP itp.) |
| `paths` | Powszechne niebezpieczne ścieżki i pliki domyślne |
| `auth` | Domyślne dane uwierzytelniające |
| `outdated` | Przestarzałe wersje oprogramowania serwera |
| `shellshock` | Podatność Shellshock |
| `dominos` | Sprawdzenia serwera Domino |

### Co skanuje Nikto

- Przestarzałe wersje oprogramowania serwera
- Niebezpieczne metody HTTP (PUT, DELETE, TRACE)
- Domyślne dane uwierzytelniające w popularnych usługach
- Powszechne sygnatury podatności

:::tip 💡 Pamiętaj
Nikto jest głośny — nie jest dyskretny i będzie widoczny w logach serwera. Używaj go, gdy wykrycie nie jest problemem, lub po potwierdzeniu zakresu z klientem.
:::
