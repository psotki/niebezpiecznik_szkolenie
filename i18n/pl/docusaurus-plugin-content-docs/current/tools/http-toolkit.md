---
title: HTTP Toolkit
sidebar_position: 6
tags: [tool, proxy, mobile]
---

> **Jedno zdanie:** Przechwytuje ruch HTTP ze szczególnym uwzględnieniem aplikacji mobilnych — zwłaszcza Android przez ADB.

## Kiedy używać

- Analizowanie wywołań API wykonywanych przez aplikację mobilną
- Znajdowanie nieudokumentowanych endpointów nieujawnionych w interfejsach webowych
- Testowanie bezpieczeństwa API aplikacji Android

## Instalacja

Pobierz z [https://httptoolkit.com/](https://httptoolkit.com/)

### Konfiguracja dla Android

```bash
# Podłącz urządzenie Android i sprawdź czy ADB je widzi
adb devices

# Uruchom HTTP Toolkit — automatycznie skonfiguruje proxy urządzenia i
# zainstaluje swój certyfikat CA przez ADB
```

Po podłączeniu HTTP Toolkit przechwytuje cały ruch aplikacji z urządzenia.

:::tip 💡 Pamiętaj
HTTP Toolkit obsługuje konfigurację proxy przez ADB automatycznie — nie musisz ręcznie konfigurować ustawień sieciowych na urządzeniu.
:::
