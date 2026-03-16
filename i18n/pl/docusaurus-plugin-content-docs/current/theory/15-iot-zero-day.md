---
title: IoT, urządzenia smart i zero-day
sidebar_position: 16
tags: [iot, zero-day, attack, recon]
---

:::info TL;DR
Urządzenia IoT rozszerzają powierzchnię ataku poprzez przestarzałe oprogramowanie układowe i domyślne dane uwierzytelniające, co sprawia, że podatności zero-day są szczególnie niebezpieczne, ponieważ te urządzenia rzadko są aktualizowane.
:::

## Co to jest?

Urządzenia IoT (Internet of Things) — smart TV, kamery, routery, czujniki przemysłowe — to sieciowe punkty końcowe, które zazwyczaj działają na wbudowanym oprogramowaniu układowym. **Zero-day** to podatność, która nie ma łatki: producent albo jeszcze o niej nie wie, albo nie wydał poprawki. Zero-day w IoT są szczególnie niebezpieczne, ponieważ urządzenia rzadko są aktualizowane, pozostawiając je bezterminowo narażonymi.

## Jak to działa

Urządzenia IoT często cierpią na:

- **Przestarzałe oprogramowanie układowe** bez mechanizmu automatycznej aktualizacji
- **Domyślne dane uwierzytelniające**, które nigdy nie są zmieniane (np. `admin/admin`)
- **Znane CVE**, które pozostają bez łatek przez miesiące lub lata

Typowy przebieg ataku:

1. **Wykrycie** urządzenia IoT za pomocą skanowania sieci (np. Shodan, nmap)
2. **Eksploitacja** znanych CVE lub domyślnych danych uwierzytelniających w celu uzyskania dostępu
3. **Zdobycie przyczółka sieciowego** na urządzeniu
4. **Pivoting** do systemów wewnętrznych z przejętego urządzenia

## Przykład z rzeczywistości

**Botnet Mirai** (2016) skompromitował setki tysięcy urządzeń IoT — kamer, rejestratorów DVR, routerów — skanując urządzenia z domyślnymi danymi uwierzytelniającymi. Powstały botnet przeprowadził jeden z największych ataków DDoS w historii, paraliżując głównego dostawcę DNS Dyn i zakłócając działanie serwisów takich jak Twitter, Reddit i Netflix. Większość ofiar nigdy nie wiedziała, że ich urządzenia zostały skompromitowane.

## Jak się bronić

- **Segmentacja sieci**: umieszczaj urządzenia IoT w izolowanej sieci VLAN, oddzielonej od krytycznych systemów wewnętrznych
- **Zmiana domyślnych danych uwierzytelniających**: natychmiast zastępuj fabryczne nazwy użytkownika i hasła na każdym urządzeniu
- **Regularne aktualizacje oprogramowania układowego**: subskrybuj biuletyny bezpieczeństwa dostawców i szybko stosuj łatki
- **Monitorowanie ruchu**: alertuj o nietypowych połączeniach wychodzących lub ruchu bocznym z segmentów IoT
- **Wyłączanie nieużywanych usług**: wyłącz UPnP, Telnet i inne niepotrzebnie eksponowane usługi

:::tip 💡 Łatwe do zapamiętania
Pomyśl o urządzeniach IoT jak o niezamkniętych bocznych wejściach w budynku — nawet jeśli główne wejście jest zabezpieczone, atakującemu wystarczy jedno zapomniane, nieskonfigurowane wejście, żeby dostać się do środka.
:::
