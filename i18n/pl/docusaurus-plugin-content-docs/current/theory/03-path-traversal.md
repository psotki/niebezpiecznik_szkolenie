---
title: Path Traversal
sidebar_position: 4
tags: [path-traversal, access-control, directory-traversal, misconfiguration]
---

:::info TL;DR
Path traversal pozwala napastnikowi wyjść poza zamierzony katalog przez wstrzyknięcie sekwencji `../` do ścieżki pliku, docierając do plików, których aplikacja nigdy nie miała serwować.
:::

## Co to jest?

Path traversal (zwany też directory traversal) to podatność, w której napastnik manipuluje wejściowymi ścieżkami plików, aby uzyskać dostęp do plików i katalogów poza zamierzonym zakresem. Typowo wykorzystuje niewystarczające oczyszczanie danych wejściowych w aplikacjach webowych lub konfiguracjach reverse proxy. Udany atak może ujawnić pliki konfiguracyjne serwera, dane uwierzytelniające lub kod źródłowy.

## Jak to działa

Wstawiając sekwencje `../` do adresu URL lub parametru, napastnik wspina się w górę drzewa katalogów. Serwery lub proxy, które nie normalizują ani nie walidują ścieżek przed kierowaniem żądań, są podatne. Napastnicy używają też zakodowanych i zaciemnionych wariantów, aby ominąć naiwne filtry.

Popularne warianty omijania filtrów:
```
/..;/admin
/%2e%2e;/admin
/admin%20
/admin%09
```

## Przykład z życia wzięty

Podczas szkolenia zademonstrowano błędną konfigurację obejmującą Jira, Tomcat i Nginx. Nginx był skonfigurowany tak, aby blokować dostęp do `/admin`, ale Tomcat otrzymywał surową, nieznormalizowaną ścieżkę. Żądając `/..;/admin`, ominięto regułę Nginx, podczas gdy Tomcat poprawnie rozwiązał ścieżkę do `/admin` — przyznając dostęp do chronionego panelu.

## Jak się bronić

- Normalizuj i rozwiązuj wszystkie ścieżki plików po stronie serwera przed ich przetworzeniem lub przekierowaniem
- Używaj list dozwolonych (allowlist), aby definiować, które ścieżki są prawidłowe — odrzucaj wszystko poza oczekiwanym zbiorem
- Upewnij się, że reverse proxy (Nginx, HAProxy) i serwery backendowe (Tomcat, Jetty) stosują spójną normalizację ścieżek
- Nigdy nie polegaj wyłącznie na regułach dopasowywania ciągów znaków (np. „blokuj, jeśli URL zawiera /admin") — stosuj kontrole strukturalne

:::tip 💡 Łatwe do zapamiętania
Path traversal jest jak polecenie dla archiwisty „weź folder A, przejdź dwa poziomy wyżej, a potem otwórz archiwum zastrzeżone" — jeśli podąża dosłownie za ścieżką bez sprawdzania uprawnień na każdym kroku, wychodzi poza zamierzony obszar. `../` w adresie URL to dokładnie taka instrukcja: przejdź o jeden poziom wyżej w drzewie katalogów.
:::
