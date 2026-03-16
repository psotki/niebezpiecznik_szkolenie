---
title: Burp Suite
sidebar_position: 5
tags: [tool, proxy, recon]
---

> **Jedno zdanie:** Proxy HTTP/HTTPS przechwytujące, modyfikujące i odtwarzające żądania sieciowe między przeglądarką a serwerem.

## Kiedy używać

- Testowanie IDOR — zmiana identyfikatorów obiektów w żądaniach w celu uzyskania dostępu do danych innych użytkowników
- Manipulowanie parametrami — modyfikacja ukrytych pól formularzy lub parametrów żądań
- Manipulowanie ciasteczkami — edycja tokenów sesji lub flag ról
- Brute-forcing parametrów za pomocą Intruder
- Odtwarzanie i modyfikowanie pojedynczych żądań za pomocą Repeater

## Instalacja

Pobierz z [https://portswigger.net/burp](https://portswigger.net/burp). Wersja Community jest bezpłatna.

### Konfiguracja

```
1. Set browser proxy to 127.0.0.1:8080
2. Download Burp CA certificate from http://burpsuite (while proxied)
3. Install the CA cert in your browser's trusted certificate store
```

Burp tworzy dwie sesje TLS (MITM): przeglądarka ↔ Burp ↔ serwer.

## Kluczowe zakładki

| Tab | What it does |
|-----|-------------|
| **Proxy** | Przechwytywanie i modyfikowanie żądań na żywo w czasie rzeczywistym |
| **Repeater** | Ręczna modyfikacja i ponowne wysyłanie pojedynczych żądań |
| **Intruder** | Automatyczne ataki — brute-force parametrów, fuzzing payloadów |
| **Scanner** *(tylko Pro)* | Automatyczne skanowanie podatności |

:::tip 💡 Pamiętaj
Repeater to Twój najlepszy przyjaciel podczas testów manualnych — wyślij żądanie tam z Proxy kliknięciem prawym przyciskiem myszy, a następnie swobodnie iteruj bez dotykania przeglądarki.
:::
