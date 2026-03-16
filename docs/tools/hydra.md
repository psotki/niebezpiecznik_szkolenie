---
title: Hydra
sidebar_position: 10
tags: [tool, exploitation, brute-force]
---

> **One-liner:** Network brute-force tool for attacking login forms, SSH, FTP, and other authentication services.

## When to use it

- Brute-forcing HTTP login forms (POST or Basic Auth)
- Attacking SSH or FTP with credential lists
- Testing whether rate limiting is in place (watch for HTTP 429)

## Key commands

```bash
# HTTP POST form login
hydra -l admin -P wordlist.txt target http-post-form \
  "/login:username=^USER^&password=^PASS^:Invalid credentials" \
  -V -t 10 -I

# HTTP Basic Auth
hydra -l admin -P wordlist.txt target http-get /admin/ -V

# SSH
hydra -l root -P wordlist.txt target ssh

# FTP
hydra -l admin -P wordlist.txt target ftp
```

### HTTP POST form syntax breakdown

```
"/login:username=^USER^&password=^PASS^:Invalid credentials"
  ^      ^                               ^
  path   POST body (^USER^/^PASS^ = placeholders)
                                         failure string
```

### Useful wordlist locations

```
/usr/share/wordlists/rockyou.txt
/usr/share/wordlists/metasploit/unix_users.txt
```

### Rate limiting

If the server returns **HTTP 429**, brute-force protection is active. Reduce threads (`-t`) or stop — continued attempts may lock accounts or trigger alerts.

:::tip 💡 Remember
The failure string in the POST form module must match text in the *failed* login response — not the success response.
:::
