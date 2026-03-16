---
title: A02 — Cryptographic Failures
sidebar_position: 3
tags: [lab, owasp-a02, tls, hashing, secrets]
---

# A02 — Cryptographic Failures

## Zakres laboratorium

- Analiza konfiguracji TLS — wygaśnięcie certyfikatu, przestarzałe protokoły, zestawy szyfrów
- Nagłówki bezpieczeństwa HTTP — weryfikacja obecności HSTS, CSP, X-Frame-Options i innych
- Łamanie skrótów haseł — MD5, SHA1, bcrypt za pomocą hashcat i john
- Skanowanie sekretów — wzorce grep i narzędzia do historii git

## Konfiguracja

```bash
TARGET="TARGET_HOSTNAME_OR_IP"
PORT="443"
WORDLIST="/usr/share/wordlists/rockyou.txt"
```

## Ćwiczenie 1: Analiza TLS

### Sprawdzenie wygaśnięcia certyfikatu

```bash
echo | openssl s_client -connect $TARGET:$PORT 2>/dev/null \
  | openssl x509 -noout -dates -subject
```

### Test przestarzałych protokołów (powinny zakończyć się błędem na bezpiecznym serwerze)

```bash
# SSLv3 — powinien zakończyć się błędem
openssl s_client -connect $TARGET:$PORT -ssl3 2>&1 | grep -E "CONNECTED|handshake failure"

# TLS 1.0 — powinien zakończyć się błędem
openssl s_client -connect $TARGET:$PORT -tls1 2>&1 | grep -E "CONNECTED|handshake failure"

# TLS 1.1 — powinien zakończyć się błędem
openssl s_client -connect $TARGET:$PORT -tls1_1 2>&1 | grep -E "CONNECTED|handshake failure"

# TLS 1.2 — akceptowalny
openssl s_client -connect $TARGET:$PORT -tls1_2 2>&1 | grep -E "CONNECTED|handshake failure"

# TLS 1.3 — zalecany
openssl s_client -connect $TARGET:$PORT -tls1_3 2>&1 | grep -E "CONNECTED|handshake failure"
```

:::tip
Do kompleksowej analizy TLS użyj [testssl.sh](https://testssl.sh/) lub [SSL Labs](https://www.ssllabs.com/ssltest/), aby uzyskać pełny raport z oceną.
:::

## Ćwiczenie 2: Nagłówki bezpieczeństwa HTTP

Sprawdź, które nagłówki bezpieczeństwa są obecne:

```bash
curl -sI "https://$TARGET" | grep -iE \
  "Strict-Transport-Security|Content-Security-Policy|X-Frame-Options|X-Content-Type-Options|Referrer-Policy|Permissions-Policy"
```

| Nagłówek | Przeznaczenie |
|----------|--------------|
| `Strict-Transport-Security` | Wymusza HTTPS — zapobiega atakom downgrade |
| `Content-Security-Policy` | Ogranicza ładowanie zasobów — łagodzi XSS |
| `X-Frame-Options` | Zapobiega clickjackingowi przez iframe |
| `X-Content-Type-Options` | Zapobiega sniffingowi typów MIME |
| `Referrer-Policy` | Kontroluje wyciek informacji referrer |
| `Permissions-Policy` | Ogranicza dostęp do funkcji przeglądarki (kamera, mikrofon itp.) |

Brakujące nagłówki stanowią podatności. Użyj [Google CSP Evaluator](https://csp-evaluator.withgoogle.com/), aby przeanalizować jakość CSP.

## Ćwiczenie 3: Łamanie skrótów haseł

### MD5 (łamie się w sekundy)

```bash
hashcat -m 0 hashes.txt $WORDLIST
```

### SHA1

```bash
hashcat -m 100 hashes.txt $WORDLIST
```

### bcrypt (znacznie wolniejszy — celowo)

```bash
hashcat -m 3200 hashes.txt $WORDLIST
```

### Użycie John the Ripper

```bash
john --format=raw-md5 --wordlist=$WORDLIST hashes.txt
john --format=raw-sha1 --wordlist=$WORDLIST hashes.txt
```

:::note
Celowa powolność bcrypt sprawia, że nadaje się do przechowywania haseł. MD5 i SHA1 nie są odpowiednie dla haseł — zostały zaprojektowane jako szybkie, co jest dokładnie odwrotnością tego, czego potrzebujesz.
:::

## Ćwiczenie 4: Skanowanie sekretów

### grep w poszukiwaniu zakodowanych na stałe danych uwierzytelniających w plikach źródłowych

```bash
grep -rE "password\s*=|secret\s*=|api_key\s*=" . --include="*.php" --include="*.js" --include="*.py" --include="*.env"
grep -rE "AKIA[0-9A-Z]{16}" .       # Identyfikatory kluczy dostępu AWS
grep -rE "Bearer [a-zA-Z0-9._-]+" . # Tokeny Bearer
```

### Skanowanie historii git pod kątem wyciekniętych sekretów

```bash
# trufflehog — skanowanie entropijne i oparte na wyrażeniach regularnych
trufflehog git file://. --only-verified

# gitleaks — wykrywanie sekretów oparte na regułach
gitleaks detect --source . -v
```

:::warning
Sekrety zatwierdzone do historii git pozostają dostępne nawet po usunięciu ich z najnowszego commita. Zawsze natychmiast rotuj każde dane uwierzytelniające znalezione w historii git.
:::
