---
title: CSRF — Cross-Site Request Forgery
sidebar_position: 13
tags: [csrf, attack, http]
---

:::info TL;DR
CSRF nakłania przeglądarkę zalogowanego użytkownika do wysłania uwierzytelnionego żądania do docelowej witryny bez jego wiedzy, ponieważ przeglądarki automatycznie dołączają pliki cookie do pasujących żądań.
:::

## Co to jest?

Cross-Site Request Forgery (CSRF) to atak zmuszający zalogowanego użytkownika do nieświadomego wykonania działań na stronie internetowej, na której jest już uwierzytelniony. Atakujący nie kradnie danych uwierzytelniających — wykorzystuje fakt, że przeglądarki automatycznie wysyłają pliki cookie wraz z żądaniami do właściwej domeny.

## Jak to działa

1. Atakujący hostuje złośliwą stronę zawierającą ukryty formularz lub tag obrazu wskazujący na docelową witrynę.
2. Ofiara, która jest zalogowana na docelowej stronie, odwiedza złośliwą stronę.
3. Przeglądarka ofiary automatycznie wysyła żądanie do docelowej witryny, dołączając prawidłowy plik cookie sesji.
4. Docelowa witryna widzi prawidłowe uwierzytelnione żądanie i je przetwarza.

Ofiara nic nie zauważa, a atakujący nigdy nie musi znać tokenu sesji.

## Przykład z rzeczywistości

Złośliwa strona zawiera ukryty formularz, który wysyła metodą POST żądanie do `bank.com/transfer` z parametrami kontrolowanymi przez atakującego (odbiorca, kwota). Gdy zalogowana ofiara wczyta stronę, jej przeglądarka automatycznie przesyła formularz z plikiem cookie sesji, a bank przetwarza przelew.

## Jak się bronić

- **Tokeny CSRF**: umieszczaj unikalny, nieprzewidywalny token per-sesja w każdym formularzu zmieniającym stan; weryfikuj go po stronie serwera
- **Pliki cookie SameSite=Strict**: przeglądarka nie wyśle pliku cookie w żadnym żądaniu cross-site
- **Sprawdzaj nagłówki Origin/Referer** po stronie serwera, aby potwierdzić, że żądanie pochodzi z oczekiwanej domeny
- **Wzorzec Double Submit Cookie**: ustaw losową wartość zarówno w pliku cookie, jak i w parametrze żądania; weryfikuj, czy są zgodne po stronie serwera

:::tip 💡 Łatwe do zapamiętania
CSRF jest jak sfałszowany list — bank widzi Twój podpis (plik cookie) na liście, którego nigdy nie napisałeś, bo ktoś podstępem nakłonił Cię do nieświadomego podpisania pustej kartki.
:::
