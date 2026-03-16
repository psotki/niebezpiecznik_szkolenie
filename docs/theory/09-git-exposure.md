---
title: .git Exposure — Source Code Leaks
sidebar_position: 10
tags: [recon, attack, source-code]
---

:::info TL;DR
An exposed `.git/` directory on a web server lets attackers reconstruct the entire source code of an application — including secrets and API keys from the full commit history.
:::

## What is it?
When a `.git/` directory is accidentally deployed to a production web server and directory listing is enabled (or individual files are accessible), attackers can download the raw Git objects and reconstruct the full repository. This exposes all source code, commit history, configuration files, and any secrets that were ever committed — even if they were later deleted from the latest version.

## How it works
The DotGit browser extension auto-detects exposed `.git`, `.svn`, and `.env` paths while browsing. Once a leak is confirmed, `git-dumper` downloads the full repository:

```bash
# Install git-dumper
pipx install git-dumper

# Dump the exposed repository
git-dumper https://target.com/.git/ ./output
```

After dumping, the attacker has a full local clone and can run `git log`, `git show`, and `grep` to find hardcoded credentials and API keys across all historical commits.

## Real-world example
A developer deploys a web application by uploading the project folder, including the `.git/` directory, to a public server. An attacker uses the DotGit extension to spot the exposure, runs `git-dumper` to reconstruct the repo, and finds an AWS secret key committed six months ago and never rotated.

## How to defend
- Never deploy the `.git/` directory to production servers
- Block access to `/.git` in your web server configuration:
  ```nginx
  location ~ /\.git {
      deny all;
  }
  ```
- Use `.gitignore` and secret scanning tools to prevent secrets from ever entering the repository
- Rotate any credentials that may have been exposed via git history
- Audit deployments regularly with tools like the DotGit extension

:::tip 💡 Easy to remember
Committing a secret is like writing it in permanent marker — even if you paint over it, the full history is always there.
:::
