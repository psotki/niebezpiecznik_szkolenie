---
title: HTTP Toolkit
sidebar_position: 6
tags: [tool, proxy, mobile]
---

> **One-liner:** Intercepts HTTP traffic with a focus on mobile apps — especially Android via ADB.

## When to use it

- Analyzing API calls made by a mobile app
- Finding undocumented endpoints not exposed in web interfaces
- Testing API security of Android applications

## Install

Download from [https://httptoolkit.com/](https://httptoolkit.com/)

### Setup for Android

```bash
# Connect Android device and verify ADB sees it
adb devices

# Launch HTTP Toolkit — it will configure the device proxy and
# install its CA certificate automatically via ADB
```

Once connected, HTTP Toolkit intercepts all app traffic from the device.

:::tip 💡 Remember
HTTP Toolkit handles the ADB proxy setup automatically — you don't need to manually configure network settings on the device.
:::
