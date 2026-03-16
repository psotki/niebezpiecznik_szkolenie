---
title: IoT, Smart Devices & Zero-day
sidebar_position: 16
tags: [iot, zero-day, attack, recon]
---

:::info TL;DR
IoT devices expand the attack surface with outdated firmware and default credentials, making zero-day vulnerabilities especially dangerous since these devices are rarely patched.
:::

## What is it?

IoT (Internet of Things) devices — smart TVs, cameras, routers, industrial sensors — are network-connected endpoints that typically run embedded firmware. A **zero-day** is a vulnerability that is unpatched: the vendor either doesn't know about it yet or hasn't released a fix. Zero-days in IoT are especially dangerous because devices are rarely updated, leaving them exposed indefinitely.

## How it works

IoT devices commonly suffer from:

- **Outdated firmware** with no automatic update mechanism
- **Default credentials** that are never changed (e.g., `admin/admin`)
- **Known CVEs** that remain unpatched for months or years

A typical attack flow:

1. **Discover** the IoT device via network scan (e.g., Shodan, nmap)
2. **Exploit** a known CVE or default credentials to gain access
3. **Gain a network foothold** on the device
4. **Pivot** to internal systems from the compromised device

## Real-world example

The **Mirai botnet** (2016) compromised hundreds of thousands of IoT devices — cameras, DVRs, routers — by scanning for devices using default credentials. The resulting botnet launched one of the largest DDoS attacks in history, taking down major DNS provider Dyn and disrupting services like Twitter, Reddit, and Netflix. Most victims never knew their devices were compromised.

## How to defend

- **Network segmentation**: place IoT devices on an isolated VLAN, separate from critical internal systems
- **Change default credentials**: immediately replace factory usernames and passwords on every device
- **Regular firmware updates**: subscribe to vendor security advisories and apply patches promptly
- **Monitor traffic**: alert on unusual outbound connections or lateral movement from IoT segments
- **Disable unused services**: turn off UPnP, Telnet, and other unnecessary exposed services

:::tip 💡 Easy to remember
Think of IoT devices like unlocked side doors in a building — even if the front entrance is secure, an attacker only needs one forgotten, unpatched door to get inside.
:::
