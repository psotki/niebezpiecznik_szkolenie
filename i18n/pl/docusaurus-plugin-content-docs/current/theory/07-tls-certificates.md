---
title: TLS i certyfikaty
sidebar_position: 8
tags: [crypto, tls, defense]
---

:::info TL;DR
TLS tworzy szyfrowany kanał między klientem a serwerem za pomocą łańcucha zaufania certyfikatów — błędnie skonfigurowany TLS naraża użytkowników na podsłuch i osłabia bezpieczeństwo wszystkich funkcji zbudowanych na jego podstawie.
:::

## Czym jest?
TLS tworzy szyfrowany kanał między klientem a serwerem, zapobiegając podsłuchiwaniu i modyfikowaniu danych podczas przesyłania. Zaufanie jest ustanawiane za pośrednictwem Urzędów Certyfikacji (CA): przeglądarka ufa CA, a CA poręcza za serwer, podpisując jego certyfikat. TLS 1.3 to aktualnie zalecana wersja — stosuje szybszy handshake 1-RTT i usuwa słabe zestawy szyfrów obecne w TLS 1.2.

## Jak działa
Podczas handshake'u serwer prezentuje swój certyfikat. Klient weryfikuje podpis CA, a następnie obie strony uzgadniają zestaw szyfrów i wyprowadzają klucze sesji. Cały dalszy ruch jest szyfrowany.

Logi Certificate Transparency (CT) to publiczne rejestry każdego certyfikatu kiedykolwiek wystawionego przez CA. Zarówno atakujący, jak i obrońcy używają logów CT do enumeracji subdomen celu.

```bash
# Query CT logs to find subdomains
curl "https://crt.sh/?q=%.example.com&output=json" | jq '.[].name_value'
```

## Przykład z życia
Organizacja uruchamiająca TLS 1.0 na starszym serwerze jest podatna na ataki downgrade protokołu. Skan na `https://www.ssllabs.com/ssltest/` zwraca ocenę F, ujawniając słabą konfigurację zanim atakujący ją wykorzysta.

## Jak się bronić
- Używaj TLS 1.3; wyłącz TLS 1.0, TLS 1.1 i SSLv3
- Używaj silnych zestawów szyfrów (unikaj RC4, 3DES, szyfrów eksportowych)
- Wygeneruj bezpieczną konfigurację TLS serwera na https://ssl-config.mozilla.org/
- Przetestuj bieżącą konfigurację na https://www.ssllabs.com/ssltest/
- Monitoruj logi Certificate Transparency pod kątem nieautoryzowanych certyfikatów wystawionych dla Twoich domen

:::tip 💡 Łatwe do zapamiętania
TLS to koperta — logi CT to urząd pocztowy prowadzący publiczny rejestr każdej kiedykolwiek wysłanej koperty.
:::
