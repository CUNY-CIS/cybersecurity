# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please **do not** open a public issue or disclose it publicly.

Instead, report the issue privately so it can be addressed responsibly.

### Contact

- **Maintainer:** Sung Lee  
- **Email:** sung.lee@cuny.edu

Please include the following information in your report:

- A clear description of the vulnerability
- Steps to reproduce the issue (if applicable)
- Potential impact of the vulnerability
- Any suggested mitigations or fixes

You should expect an acknowledgment within a reasonable timeframe.

---

## Supported Versions

Only the most recent release of this script is supported with security updates.

| Version | Supported |
|---------|-----------|
| 1.0.x   | ✅ Yes |
| &lt; 1.0 | ❌ No |

---

## Security Best Practices

When using or deploying this script:

- **Never commit real API keys, passphrases, or firewall URLs** to public repositories
- Use **environment variables** or a **secrets manager** for sensitive values
- Restrict PAN‑OS API keys to the minimal permissions required
- Regenerate API keys if accidental exposure is suspected
- Test changes in non‑production environments first

---

## Scope

This security policy applies only to vulnerabilities in the script itself.

Operational issues, misconfigurations, or environment‑specific problems are outside the scope of this policy.

---

## Disclaimer

This project is provided "as‑is" without warranty. The maintainer is not responsible for misuse, misconfiguration, or security incidents resulting from deployment.

