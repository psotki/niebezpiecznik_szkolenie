---
title: Strony internetowe i narzędzia online
sidebar_position: 1
---

# 🌐 Strony internetowe i narzędzia online

Wszystkie strony internetowe przywoływane w szkoleniu z cyberbezpieczeństwa Niebezpiecznik.

## Narzędzia do testowania i analizy

| Strona | Przeznaczenie | URL |
|--------|--------------|-----|
| SSL Labs | Testowanie konfiguracji TLS/SSL serwera, ocena od A+ do F | https://www.ssllabs.com/ssltest/ |
| SSL Config Generator | Generowanie bezpiecznej konfiguracji TLS dla Nginx, Apache, HAProxy | https://ssl-config.mozilla.org/ |
| crt.sh | Wyszukiwarka Certificate Transparency — odkrywanie subdomen i wystawionych certyfikatów | https://crt.sh |
| Have I Been Squatted | Sprawdzanie, czy zarejestrowano domeny łudząco podobne do Twojej marki | https://haveibeensquatted.com |
| Google CSP Evaluator | Analiza nagłówków Content Security Policy pod kątem słabości | https://csp-evaluator.withgoogle.com/ |

## Ćwiczenia XSS i wyzwania CTF

| Strona | Przeznaczenie | URL |
|--------|--------------|-----|
| prompt.ml | Wyzwania XSS — 16 poziomów + 4 ukryte, ćwiczenia omijania filtrów | https://prompt.ml/ |
| escape.alf.nu | Wyzwania XSS — „alert(1) to win!" — 15 wyzwań | https://escape.alf.nu/ |
| jsfuck.com | Enkoder JavaScript używający wyłącznie znaków `[]()!+` — przydatny do omijania filtrów XSS | https://jsfuck.com/ |

## Narzędzia i biblioteki

| Strona | Przeznaczenie | URL |
|--------|--------------|-----|
| HTTP Toolkit | Przechwytywanie ruchu HTTP/HTTPS, w tym z aplikacji mobilnych przez ADB | https://httptoolkit.com/ |
| DOMPurify (GitHub) | Biblioteka do sanityzacji HTML w JavaScript | https://github.com/cure53/DOMPurify |
| Keycloak | Open-source'owe zarządzanie tożsamością i dostępem — poznaj JWT, SSO, OAuth2 w praktyce | https://www.keycloak.org |

## Infrastruktura i materiały referencyjne

| Strona | Przeznaczenie | URL |
|--------|--------------|-----|
| Cloudflare IPs | Oficjalna lista zakresów IP Cloudflare — używana do whitelistowania w firewallu | https://www.cloudflare.com/ips/ |

## Ściągawka Google Dorking

Używaj tych operatorów wyszukiwania Google, aby znajdować ujawnione informacje:

| Operator | Przykład | Wyszukuje |
|----------|---------|-----------|
| `site:` | `site:example.com` | Wszystkie zaindeksowane strony w domenie |
| `intitle:` | `intitle:"Index of /"` | Strony zawierające dany tekst w tytule |
| `inurl:` | `inurl:admin` | Strony z „admin" w adresie URL |
| `filetype:` | `filetype:sql` | Pliki określonego typu |
| `cache:` | `cache:example.com` | Wersja zbuforowana przez Google |
| Złożony | `site:example.com filetype:bak` | Pliki kopii zapasowych w docelowej domenie |
| Złożony | `intitle:"Index of /" site:example.com` | Listowanie katalogów na celu |
