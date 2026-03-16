// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  theorySidebar: [
    {
      type: 'doc',
      id: 'theory/intro',
      label: '🗺 Overview',
    },
    {
      type: 'category',
      label: '🔵 Reconnaissance',
      items: ['theory/recon', 'theory/endpoints'],
    },
    {
      type: 'category',
      label: '🔴 Access Control',
      items: ['theory/idor', 'theory/path-traversal', 'theory/privilege-escalation'],
    },
    {
      type: 'category',
      label: '🟠 Web Traffic & Proxies',
      items: ['theory/burp-suite'],
    },
    {
      type: 'category',
      label: '🟡 Cryptography & Trust',
      items: ['theory/tls-certificates', 'theory/cookies-gdpr', 'theory/git-exposure', 'theory/jwt', 'theory/cryptographic-failures'],
    },
    {
      type: 'category',
      label: '🟣 HTTP & Headers',
      items: ['theory/http-headers', 'theory/csrf'],
    },
    {
      type: 'category',
      label: '🟤 DNS & Infrastructure',
      items: ['theory/dns-security', 'theory/iot-zero-day'],
    },
    {
      type: 'category',
      label: '🔴 Injection Attacks',
      items: ['theory/injection-xss'],
    },
  ],

  toolsSidebar: [
    {
      type: 'doc',
      id: 'tools/intro',
      label: '🛠 Tools Overview',
    },
    {
      type: 'category',
      label: '🔵 Reconnaissance',
      items: ['tools/gobuster-dirbuster', 'tools/dnstwist', 'tools/git-dumper'],
    },
    {
      type: 'category',
      label: '🟠 Proxies & Interception',
      items: ['tools/burp-suite', 'tools/http-toolkit'],
    },
    {
      type: 'category',
      label: '🔴 Exploitation',
      items: ['tools/metasploit', 'tools/sqlmap', 'tools/hydra'],
    },
    {
      type: 'category',
      label: '🟡 Privilege Escalation',
      items: ['tools/traitor'],
    },
    {
      type: 'category',
      label: '🟤 Cryptography & Tokens',
      items: ['tools/hashcat', 'tools/jwt-tool'],
    },
    {
      type: 'category',
      label: '🟢 Web Server Scanning',
      items: ['tools/nikto'],
    },
    {
      type: 'category',
      label: '🟢 Defense & Libraries',
      items: ['tools/domxss-libs'],
    },
  ],

  websitesSidebar: [
    {
      type: 'doc',
      id: 'websites/reference',
      label: '🌐 All References',
    },
  ],

  labsSidebar: [
    {
      type: 'doc',
      id: 'labs/setup',
      label: '⚙️ Lab Setup',
    },
    {
      type: 'category',
      label: 'OWASP Labs',
      items: [
        'labs/a01-broken-access-control',
        'labs/a02-cryptographic-failures',
        'labs/a03-injection',
        'labs/a05-misconfiguration',
        'labs/a06-vulnerable-components',
        'labs/a07-auth-failures',
        'labs/a08-integrity-failures',
        'labs/a10-ssrf',
      ],
    },
  ],
};

module.exports = sidebars;
