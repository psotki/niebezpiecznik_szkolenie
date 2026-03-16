---
title: Nagłówki HTTP i fałszowanie CF-Connecting-IP
sidebar_position: 12
tags: [http, headers, spoofing, attack]
---

:::info TL;DR
Jeśli serwer bezgranicznie ufa nagłówkom IP, takim jak CF-Connecting-IP lub X-Forwarded-For, bez weryfikacji, że żądanie rzeczywiście przyszło przez Cloudflare, atakujący mogą sfałszować dowolny adres IP.
:::

## Co to jest?

Cloudflare dodaje nagłówek `CF-Connecting-IP` do proxowanych przez siebie żądań, zawierający prawdziwy adres IP klienta. Serwery za Cloudflare często odczytują ten nagłówek w celu identyfikacji klientów. Powiązany nagłówek `X-Forwarded-For` jest podobnie używany przez inne proxy i load balancery.

## Jak to działa

Gdy żądanie przechodzi przez Cloudflare, Cloudflare ustawia `CF-Connecting-IP` na adres IP klienta źródłowego. Serwer źródłowy odczytuje tę wartość i używa jej do logowania, ograniczania szybkości lub kontroli dostępu.

Problem polega na tym, że jeśli atakujący pominie Cloudflare i połączy się bezpośrednio z serwerem źródłowym, może umieścić dowolną wartość w nagłówku `CF-Connecting-IP`. Serwer źródłowy nie ma możliwości odróżnienia prawidłowego nagłówka wstrzykniętego przez Cloudflare od sfałszowanego przez atakującego — chyba że zweryfikuje, że żądanie faktycznie dotarło z adresu IP należącego do Cloudflare.

## Przykład z rzeczywistości

Atakujący wykrywa źródłowy adres IP serwera ukrytego za Cloudflare. Wysyła bezpośrednie żądanie HTTP na ten adres z spreparowanym nagłówkiem:

```
CF-Connecting-IP: 1.2.3.4
```

Jeśli serwer używa tego nagłówka do listy dozwolonych adresów IP lub logiki pomijania limitów szybkości, atakujący skutecznie sfałszował zaufany adres IP. Ta sama technika ma zastosowanie do `X-Forwarded-For` w każdej konfiguracji proxy.

## Jak się bronić

- **Umieść zakresy IP Cloudflare na białej liście na poziomie zapory sieciowej**, aby serwer źródłowy akceptował połączenia wyłącznie od Cloudflare: [https://www.cloudflare.com/ips/](https://www.cloudflare.com/ips/)
- Ufaj `CF-Connecting-IP` tylko wtedy, gdy masz pewność, że cały ruch jest kierowany przez Cloudflare
- Traktuj `X-Forwarded-For` jako niezaufane dane wejściowe, chyba że nadrzędne proxy jest ściśle kontrolowane

:::tip 💡 Łatwe do zapamiętania
Ufanie CF-Connecting-IP bez sprawdzania źródła jest jak akceptowanie opaski VIP od kogoś, kto wszedł tylnym wejściem — opaska ma znaczenie tylko wtedy, gdy założył ją portier.
:::
