---
title: DNS — Domain Squatting i Certificate Transparency
sidebar_position: 15
tags: [dns, recon, defense]
---

:::info TL;DR
Atakujący rejestrują domeny imitujące Twoją markę, a logi Certificate Transparency ujawniają subdomeny, które mogłeś nie zdawać sobie sprawy, że są publiczne — obie kwestie wymagają monitorowania.
:::

## Co to jest?

Dwa powiązane zagrożenia na poziomie DNS, które dotyczą zarówno atakujących, jak i obrońców:

- **Domain Squatting / Typosquatting**: rejestrowanie domen ściśle przypominających prawdziwą domenę (np. `paypa1.com`, `g00gle.com`) w celu wykorzystania błędów użytkownika lub zaufania.
- **Certificate Transparency**: publiczny, dołączany log wszystkich wystawionych certyfikatów TLS, który każdy może odpytać — przydatny zarówno do rekonesansu, jak i obrony.

## Jak to działa

**Domain squatting** opiera się na tym, że użytkownicy błędnie wpisują domenę lub nie zauważają subtelnych podstawień znaków. Squatowane domeny są używane do phishingu, dystrybucji złośliwego oprogramowania i pozyskiwania danych uwierzytelniających.

**Certificate Transparency** wymaga od urzędów certyfikacji logowania każdego wystawianego przez nie certyfikatu. Oznacza to, że każda subdomena, która kiedykolwiek otrzymała certyfikat TLS, pojawia się w publicznej bazie danych — w tym usługi wewnętrzne i środowiska staging, które operatorzy mogli zamierzać utrzymać w tajemnicy.

## Przykład z rzeczywistości

Sprawdzanie, czy Twoja domena jest squatowana, za pomocą dnstwist:
```
dnstwist --registered --mxcheck --geoip example.com
```

Narzędzie generuje permutacje Twojej domeny i sprawdza, które z nich są zarejestrowane i mają skonfigurowane serwery pocztowe — silny wskaźnik aktywnej infrastruktury phishingowej.

Odpytywanie Certificate Transparency w poszukiwaniu subdomen przez [crt.sh](https://crt.sh):
```
https://crt.sh/?q=%.example.com
```

Ujawnia to subdomeny, które mogą nie pojawić się w publicznym DNS — serwery staging, wewnętrzne API lub zapomniane usługi.

## Jak się bronić

- Proaktywnie monitoruj squatowane domeny: [https://haveibeensquatted.com](https://haveibeensquatted.com)
- Regularnie uruchamiaj `dnstwist` na swoich domenach
- Odpytuj `crt.sh` dla swojej domeny, aby zidentyfikować niezamierzone publiczne subdomeny zanim zrobią to atakujący
- Upewnij się, że usługi wewnętrzne i staging nie są eksponowane z publicznie zaufanymi certyfikatami TLS

:::tip 💡 Łatwe do zapamiętania
Certificate Transparency jest jak publiczna tablica ogłoszeń, na której widnieje lista każdych drzwi, na które kiedykolwiek założyłeś kłódkę — świetna dla audytorów, ale też dla atakujących.
:::
