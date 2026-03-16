---
title: Privilege Escalation
sidebar_position: 5
tags: [privilege-escalation, linux, access-control, sudo, suid, cve]
---

:::info TL;DR
Privilege escalation turns a low-privilege foothold into full system control — often by exploiting misconfigurations, weak sudo rules, or unpatched CVEs.
:::

## What is it?

Privilege escalation is the process of gaining a higher level of access than was initially granted — typically from a regular user to root or administrator. It is a critical post-exploitation step: an attacker who can only run limited commands looks for any path to elevate their rights. On Linux systems, common vectors include misconfigured sudo permissions, SUID binaries, and known CVEs in installed software.

## How it works

An attacker with a low-privilege shell scans the system for escalation opportunities. The GTFOBins catalog lists Unix binaries that can be abused to break out of restricted environments or escalate privileges. The tool `Traitor` automates this scan.

```bash
# Run Traitor to automatically scan for escalation paths
./traitor

# Aggressive mode — tries more techniques
./traitor -a
```

Common escalation vectors on Linux:
- `sudo` misconfigurations — a binary allowed via sudo that can spawn a shell
- SUID binaries — executables that run as their owner (often root) regardless of who launches them
- Unpatched CVEs in the kernel or installed services

## Real-world example

After gaining a low-privilege shell on a Linux server, a tester runs `./traitor -a`. The tool detects that `vim` is listed in the sudoers file without a password requirement. Using the GTFOBins technique for `vim`, the tester runs a shell escape inside the editor and obtains a root shell within seconds.

## How to defend

- Apply the principle of least privilege — grant only the permissions each user or service genuinely needs
- Audit `sudoers` files regularly; avoid `NOPASSWD` entries for powerful binaries
- Identify and remove unnecessary SUID binaries (`find / -perm -4000`)
- Patch regularly — many escalation paths rely on known CVEs with public exploits
- Use tools like `Traitor` defensively on your own systems to find paths before attackers do

:::tip 💡 Easy to remember
Privilege escalation is like a new employee who starts in the mailroom and, by finding an unlocked manager's office and a forgotten master key, ends up with the CEO's access card.
:::
