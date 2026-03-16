---
title: dnstwist
sidebar_position: 3
tags: [tool, recon, dns]
---

> **Jedno zdanie:** Generuje permutacje domen (warianty typosquattingu) i sprawdza, czy są zarejestrowane.

## Kiedy używać

- Sprawdzanie, czy domena Twojej marki jest squattowana przez atakujących
- Rekonesans celu — odkrywanie lookalike domen używanych do phishingu
- Monitorowanie nowo zarejestrowanych wariantów domeny

## Instalacja

```bash
pip install dnstwist
```

## Kluczowe komendy

| Command | What it does |
|---------|-------------|
| `dnstwist example.com` | Podstawowy skan — generuje permutacje i sprawdza rejestrację |
| `dnstwist --registered --mxcheck --geoip example.com` | Pełne sprawdzenie: tylko zarejestrowane domeny, z rekordami MX i geolokalizacją |

### Pola wyjściowe

- Status rejestracji (zarejestrowana / niezarejestrowana)
- Adres IP
- Serwery nazw
- Rekordy MX (z `--mxcheck`)
- Geolokalizacja (z `--geoip`)

:::tip 💡 Pamiętaj
`--registered` filtruje wyniki tylko do domen faktycznie zarejestrowanych — znacznie ogranicza szum przy dużych skanach.
:::
