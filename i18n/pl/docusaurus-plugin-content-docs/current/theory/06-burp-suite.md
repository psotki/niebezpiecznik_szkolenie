---
title: Burp Suite — przechwytywanie HTTP
sidebar_position: 7
tags: [tool, proxy, recon]
---

:::info TL;DR
Burp Suite to proxy typu man-in-the-middle, który przechwytuje i modyfikuje ruch HTTP/S między przeglądarką a serwerem — jest to podstawowe narzędzie do testowania bezpieczeństwa aplikacji webowych.
:::

## Czym jest?
Burp Suite działa jako proxy MITM umieszczony między przeglądarką a docelowym serwerem. Odszyfrowuje ruch HTTPS, tworząc dwie oddzielne sesje TLS — jedną z przeglądarką i jedną z serwerem. Pozwala to testerowi na inspekcję, modyfikację i ponowne wysyłanie każdego żądania i odpowiedzi w postaci jawnego tekstu.

## Jak działa
Ustaw proxy przeglądarki na `127.0.0.1:8080` i zainstaluj certyfikat CA Burpa, aby przeglądarka ufała jego certyfikatom TLS. Ruch przechodzi następnie przez Burpa zanim dotrze do serwera.

```
Browser → Burp (127.0.0.1:8080) → Target Server
         [intercept / modify]
```

Główne zakładki:
- **Proxy** — przechwytuje i inspekcjonuje żądania w czasie rzeczywistym
- **Repeater** — umożliwia ręczną modyfikację i ponowne wysłanie przechwyconego żądania
- **Intruder** — automatyzuje ataki, takie jak brute-forcing czy fuzzing parametrów

## Przykład z życia
Podczas testowania IDOR tester przechwytuje żądanie do `/api/orders/1001` w Proxy, przekazuje je do Repeatera, zmienia ID zamówienia na `1002` i sprawdza, czy serwer zwraca zamówienie innego użytkownika.

## Jak się bronić
- Wymuszaj sprawdzanie autoryzacji po stronie serwera — nigdy nie ufaj identyfikatorom ani parametrom dostarczanym przez klienta
- Stosuj HTTPS z przypinaniem certyfikatów (certificate pinning) w klientach mobilnych i desktopowych, aby utrudnić korzystanie z proxy
- Loguj i alertuj przy anomalnych wzorcach żądań (np. szybka sekwencyjna enumeracja ID)

:::tip 💡 Łatwe do zapamiętania
Burp to „przycisk pauzy" dla HTTP — pozwala zamrozić żądanie w locie i przepisać je, zanim dotrze do celu.
:::
