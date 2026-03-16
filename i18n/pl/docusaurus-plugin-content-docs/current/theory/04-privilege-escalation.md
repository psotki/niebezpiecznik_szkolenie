---
title: Eskalacja uprawnień
sidebar_position: 5
tags: [privilege-escalation, linux, access-control, sudo, suid, cve]
---

:::info TL;DR
Eskalacja uprawnień zamienia ograniczony przyczółek w pełną kontrolę nad systemem — często poprzez wykorzystanie błędnych konfiguracji, słabych reguł sudo lub niezałatanych CVE.
:::

## Co to jest?

Eskalacja uprawnień to proces uzyskiwania wyższego poziomu dostępu, niż początkowo przyznano — zazwyczaj od zwykłego użytkownika do roota lub administratora. Jest to kluczowy krok po eksploitacji: napastnik, który może wykonywać tylko ograniczone polecenia, szuka każdej ścieżki do podniesienia swoich uprawnień. W systemach Linux popularne wektory to błędnie skonfigurowane uprawnienia sudo, binaria SUID oraz znane CVE w zainstalowanym oprogramowaniu.

## Jak to działa

Napastnik z powłoką o niskich uprawnieniach przeszukuje system w poszukiwaniu możliwości eskalacji. Katalog GTFOBins zawiera listę binarnych plików Uniksa, które można nadużyć do wyjścia z ograniczonych środowisk lub eskalacji uprawnień. Narzędzie `Traitor` automatyzuje to skanowanie.

```bash
# Run Traitor to automatically scan for escalation paths
./traitor

# Aggressive mode — tries more techniques
./traitor -a
```

Popularne wektory eskalacji w Linuksie:
- Błędne konfiguracje `sudo` — binarium dozwolone przez sudo, które może uruchomić powłokę
- Binaria SUID — pliki wykonywalne uruchamiane z uprawnieniami swojego właściciela (często roota) niezależnie od tego, kto je uruchomił
- Niezałatane CVE w jądrze lub zainstalowanych usługach

## Przykład z życia wzięty

Po uzyskaniu powłoki z niskimi uprawnieniami na serwerze Linux tester uruchamia `./traitor -a`. Narzędzie wykrywa, że `vim` jest wymieniony w pliku sudoers bez wymagania hasła. Używając techniki GTFOBins dla `vim`, tester uruchamia ucieczkę do powłoki wewnątrz edytora i w ciągu kilku sekund uzyskuje powłokę roota.

## Jak się bronić

- Stosuj zasadę najmniejszych uprawnień — przyznaj tylko te uprawnienia, których dany użytkownik lub usługa naprawdę potrzebuje
- Regularnie audytuj pliki `sudoers`; unikaj wpisów `NOPASSWD` dla potężnych binarnych plików
- Identyfikuj i usuwaj niepotrzebne binaria SUID (`find / -perm -4000`)
- Regularnie aktualizuj oprogramowanie — wiele ścieżek eskalacji opiera się na znanych CVE z publicznymi exploitami
- Używaj narzędzi takich jak `Traitor` defensywnie na własnych systemach, aby znaleźć ścieżki zanim zrobią to napastnicy

:::tip 💡 Łatwe do zapamiętania
Eskalacja uprawnień jest jak nowy pracownik, który zaczyna w dziale pocztowym i — znajdując niezamknięty gabinet kierownika oraz zapomnianym kluczem głównym — zdobywa kartę dostępu dyrektora generalnego.
:::
