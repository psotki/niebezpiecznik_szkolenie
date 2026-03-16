---
title: JWT — JSON Web Token
sidebar_position: 11
tags: [crypto, auth, jwt, attack]
---

:::info TL;DR
JWT to trójczłonowy token zakodowany w base64, używany do uwierzytelniania, jednak błędy konfiguracji — takie jak słabe sekrety lub atak alg:none — mogą pozwolić atakującym na fałszowanie tokenów.
:::

## Czym jest?

JWT (JSON Web Token) to trójczłonowa struktura zakodowana jako `header.payload.signature`.

- **Header**: określa algorytm (HS256, RS256, none) i typ tokenu
- **Payload**: zawiera roszczenia (claims) takie jak ID użytkownika, rola i czas wygaśnięcia — niezaszyfrowany, jedynie zakodowany w base64
- **Signature**: podpis HMAC lub RSA używany do weryfikacji integralności

## Jak działa

Serwer wystawia podpisany token. W kolejnych żądaniach klient przesyła token, a serwer weryfikuje podpis przed zaufaniem roszczeniom zawartym w payload. Ponieważ payload jest jedynie zakodowany w base64 (nie zaszyfrowany), każdy może go odczytać — jedynie podpis zapobiega jego modyfikacji.

## Przykład z życia

Kluczowe podatności i sposoby ich wykorzystania:

- **Atak alg:none**: usuń podpis i zmień pole algorytmu na `"none"`. Podatne biblioteki akceptują taki token jako prawidłowy.
- **Słaby sekret**: sekrety HS256 można złamać offline przy użyciu hashcat w trybie 16500:
  ```
  hashcat -m 16500 jwt.txt wordlist.txt
  ```
- **Pomylenie RS256 → HS256**: atakujący używa publicznego klucza serwera jako sekretu HMAC, gdy biblioteka akceptuje oba typy algorytmów.
- **CVE-2018-0114 (node-jose)**: błąd biblioteki umożliwiający całkowite ominięcie weryfikacji podpisu.

Narzędzie do ręcznego testowania:
```
python3 jwt_tool.py <TOKEN> -X a
```

Narzędzie do nauki JWT w praktyce: [Keycloak](https://www.keycloak.org) (open-source IAM).

## Jak się bronić

- Zawsze weryfikuj podpis po stronie serwera przed zaufaniem jakimkolwiek roszczeniom
- Używaj silnych, losowo generowanych sekretów dla HS256
- Jawnie odrzucaj algorytm `alg:none`
- Ustal oczekiwany algorytm po stronie serwera zamiast odczytywać go z nagłówka tokenu

:::tip 💡 Łatwe do zapamiętania
JWT to zapieczętowana koperta — każdy może przeczytać to, co jest napisane na zewnątrz, ale tylko pieczęć lakowa nadawcy (podpis) dowodzi, że nie została naruszona. Jeśli akceptujesz koperty bez pieczęci, każdy może je sfałszować.
:::
