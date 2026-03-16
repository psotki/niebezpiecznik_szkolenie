---
title: Traitor
sidebar_position: 8
tags: [tool, privesc]
---

> **Jedno zdanie:** Automatyczne narzędzie do eskalacji uprawnień w Linuksie, które skanuje i exploituje powszechne wektory eskalacji po uzyskaniu dostępu do powłoki.

## Kiedy używać

- Po uzyskaniu powłoki na maszynie z Linuksem — uruchom natychmiast, aby znaleźć ścieżki eskalacji
- Automatyczne enumerowanie GTFOBins, błędnych konfiguracji sudo i binariów SUID
- Próba lokalnej eskalacji uprawnień opartej na CVE bez ręcznej enumeracji

## Instalacja

```bash
# Pobierz plik binarny i nadaj mu uprawnienia do wykonania
curl -fsSL https://github.com/liamg/traitor/releases/latest/download/traitor-amd64 -o traitor
chmod +x traitor
```

## Kluczowe komendy

| Command | What it does |
|---------|-------------|
| `./traitor` | Skanuj i próbuj bezpiecznych ścieżek eskalacji |
| `./traitor -a` | Tryb agresywny — próbuje wszystkich wektorów, w tym bardziej ryzykownych |

### Co skanuje

- GTFOBins (pliki binarne, które mogą być nadużywane do eskalacji uprawnień)
- Błędne konfiguracje `sudo`
- Binaria SUID
- Lokalne exploity oparte na CVE

:::tip 💡 Pamiętaj
Uruchom najpierw `./traitor` (tryb bezpieczny) — tryb agresywny (`-a`) może generować hałas lub powodować niestabilność systemu docelowego.
:::
