import React from 'react';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';

const features = [
  {
    icon: '📚',
    title: 'Security Theory',
    desc: '16 OWASP-aligned topics — from recon and IDOR to XSS and JWT. Each concept with TL;DR and a real-world analogy.',
    link: '/docs/theory/intro',
    cls: 'feature-card--theory',
  },
  {
    icon: '🛠',
    title: 'Tools Reference',
    desc: 'Quick-reference for every tool covered in training: what it does, when to use it, and copy-paste commands.',
    link: '/docs/tools/intro',
    cls: 'feature-card--tools',
  },
  {
    icon: '🌐',
    title: 'Websites',
    desc: 'Curated list of all websites, labs, and online tools referenced in the training — with purpose and URL.',
    link: '/docs/websites/reference',
    cls: 'feature-card--websites',
  },
  {
    icon: '🧪',
    title: 'Labs',
    desc: '8 hands-on Kali labs covering OWASP Top 10 — step-by-step commands, payloads, and expected results.',
    link: '/docs/labs/setup',
    cls: 'feature-card--labs',
  },
];

export default function Home() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout title="Home" description="ADHD-friendly cybersecurity knowledge base">
      <header className="hero-cybersec">
        <div>
          <h1 className="hero-cybersec__title">🔐 CyberSec KB</h1>
          <p className="hero-cybersec__subtitle">
            Your OWASP-focused cybersecurity notes — organized, searchable, and built for quick recall.
            <br />
            <span style={{ fontSize: '0.9em', opacity: 0.7 }}>Based on Niebezpiecznik training · March 2026</span>
          </p>
          <div className="hero-cybersec__buttons">
            <Link className="button button--primary button--lg" to="/docs/theory/intro">
              📚 Start with Theory
            </Link>
            <Link className="button button--secondary button--lg" to="/docs/labs/setup">
              🧪 Jump to Labs
            </Link>
          </div>
        </div>
      </header>

      <main>
        <div className="features-grid">
          {features.map((f) => (
            <Link key={f.title} to={f.link} className={`feature-card ${f.cls}`}>
              <span className="feature-card__icon">{f.icon}</span>
              <div className="feature-card__title">{f.title}</div>
              <div className="feature-card__desc">{f.desc}</div>
            </Link>
          ))}
        </div>

        <div style={{ textAlign: 'center', padding: '20px 40px 60px', color: 'var(--ifm-color-content-secondary)', fontSize: '0.85rem' }}>
          <p>💡 Use the search bar (top-right) to find any topic instantly.</p>
          <p>All content sourced exclusively from Niebezpiecznik training materials.</p>
        </div>
      </main>
    </Layout>
  );
}
