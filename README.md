# cybersecurity
Code Repository for Public Cybersecurity

# PAN-OS Certificate Import & Commit Script

Automated certificate import and commit utility for Palo Alto Networks PAN-OS firewalls and Panorama templates using the XML API.

---

## Overview

This Bash script automates the process of importing an SSL/TLS certificate and private key (PEM keypair) into a Palo Alto Networks firewall or a Panorama template. If the import succeeds, the script commits the configuration and optionally commits the change to a Panorama template stack.

---

## Features

- Imports PEM keypairs via the PAN-OS XML API
- Supports Panorama templates and template stacks
- Verifies successful import before committing
- Polls commit job status until completion or timeout
- Cleans up temporary files securely

---

## Requirements

### System
- Bash
- curl
- xmllint (libxml2-utils)

### PAN-OS / Panorama
- XML API enabled
- API key with certificate import and commit permissions

---

## License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.

SPDX Identifier:
```
SPDX-License-Identifier: GPL-3.0-only
```

Full license text: https://www.gnu.org/licenses/gpl-3.0.html

---

## Author & Maintainer

- **Author:** Sung Lee
- **Organization:** City University of New York (CUNY)
- **Maintainer:** Sung Lee <sung.lee@cuny.edu>

---

## Exit Codes

| Code | Meaning |
|------|--------|
| `0`  | Certificate import and commit completed successfully |
| `1`  | Import failed, commit failed, or commit did not complete |
``

## Version

- **Current Version:** 1.0.0

---

## Disclaimer

This software is provided **as-is**, without warranty of any kind. Always test in non-production environments first.

