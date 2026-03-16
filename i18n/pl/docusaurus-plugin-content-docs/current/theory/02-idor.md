---
title: IDOR (Insecure Direct Object Reference)
sidebar_position: 3
tags: [idor, access-control, authorization, owasp]
---

:::info TL;DR
IDOR pozwala napastnikowi uzyskać dostęp do danych innych użytkowników przez zwykłą zmianę identyfikatora w URL — bo serwer nigdy nie sprawdza, czy masz do tego prawo.
:::

## Co to jest?

IDOR (Insecure Direct Object Reference) to podatność kontroli dostępu, w której aplikacja ujawnia wewnętrzne referencje do obiektów — takie jak identyfikatory z bazy danych — bezpośrednio w adresach URL lub parametrach. Serwer ufa, że klient będzie żądał wyłącznie własnych danych, i nie wykonuje żadnej weryfikacji autoryzacji po stronie serwera, dlatego każdy może uzyskać dostęp do rekordów dowolnego innego użytkownika, zmieniając identyfikator.

## Jak to działa

Użytkownik uzyskuje dostęp do własnego profilu pod adresem `https://app.com/profile?id=42`. Zmieniając parametr `id` na inną liczbę, może przeglądać lub modyfikować dane zupełnie innego użytkownika — bez żadnego obejścia uwierzytelniania, wystarczy ciekawość i pasek adresu.

```
# Accessing your own profile
GET /profile?id=42

# Accessing someone else's profile — no authorization check server-side
GET /profile?id=43
GET /profile?id=1
```

## Przykład z życia wzięty

Podczas szkolenia tester iterował po identyfikatorach od 1 do 20 na endpoincie profilu. Każde żądanie zwracało pełne dane profilu innego użytkownika — imię i nazwisko, adres e-mail, adres — bez żadnego błędu ani odpowiedzi „odmowa dostępu". Serwer zakładał, że jeśli znasz identyfikator, masz prawo go zobaczyć.

## Jak się bronić

- Wymuszaj autoryzację po stronie serwera dla każdego żądania — sprawdzaj, czy uwierzytelniony użytkownik jest właścicielem żądanego zasobu
- Zastąp sekwencyjne identyfikatory całkowitoliczbowe identyfikatorami UUID (np. `a3f9c2d1-...`), aby zgadywanie stało się niepraktyczne
- Nigdy nie polegaj na zaciemnieniu — trudny do odgadnięcia identyfikator nie zastępuje weryfikacji autoryzacji
- Rejestruj i alarmuj o wzorcach dostępu sugerujących enumerację (wiele sekwencyjnych żądań o identyfikatory)

:::tip 💡 Łatwe do zapamiętania
IDOR jest jak hotel, w którym każdy pokój ma numer na drzwiach, ale bez zamka — wystarczy zmienić numer, żeby wejść do czyjegokolwiek pokoju.
:::
