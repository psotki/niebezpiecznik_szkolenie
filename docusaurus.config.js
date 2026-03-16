// @ts-check
const { themes: prismThemes } = require('prism-react-renderer');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'CyberSec KB',
  tagline: 'OWASP-focused cybersecurity knowledge base',
  favicon: 'img/favicon.ico',

  url: 'https://localhost',
  baseUrl: '/',

  trailingSlash: false,

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'pl'],
    localeConfigs: {
      en: { label: 'English', direction: 'ltr', htmlLang: 'en' },
      pl: { label: 'Polski', direction: 'ltr', htmlLang: 'pl' },
    },
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          routeBasePath: 'docs',
        },
        blog: false,
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        defaultMode: 'dark',
        disableSwitch: false,
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: '🔐 CyberSec KB',
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'theorySidebar',
            position: 'left',
            label: '📚 Security Theory',
          },
          {
            type: 'docSidebar',
            sidebarId: 'toolsSidebar',
            position: 'left',
            label: '🛠 Tools Reference',
          },
          {
            type: 'docSidebar',
            sidebarId: 'websitesSidebar',
            position: 'left',
            label: '🌐 Websites',
          },
          {
            type: 'docSidebar',
            sidebarId: 'labsSidebar',
            position: 'left',
            label: '🧪 Labs',
          },
          {
            type: 'localeDropdown',
            position: 'right',
          },

        ],
      },
      prism: {
        theme: prismThemes.dracula,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['bash', 'python', 'java', 'php', 'json', 'yaml'],
      },
      docs: {
        sidebar: {
          hideable: true,
          autoCollapseCategories: true,
        },
      },
    }),
};

module.exports = config;
