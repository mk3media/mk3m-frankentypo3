# Contributing to TYPO3 FrankenPHP

Thank you for helping improve the **TYPO3 FrankenPHP & Valkey Docker** setup! We welcome feedback, improvements, bug reports, and contributions from the community.

---

## 💬 Community & Questions

- **Bug Reports & Ideas**: Please use the [GitHub Issues tracker](../../issues).
- **TYPO3 Community**: For general TYPO3 CMS discussions and support, connect on the official [TYPO3 Slack](https://typo3.org/community/teams/slack).
- **FrankenPHP & Caddy**: For upstream server topics, check out the [FrankenPHP Discussions](https://github.com/dunglas/frankenphp/discussions) and [Caddy Community Forum](https://caddy.community/).

---

## 🐛 Reporting Bugs

When submitting an issue, please provide sufficient details to help reproduce and resolve it:
1. **Environment**: Host OS (macOS, Linux), Docker & Docker Compose version, and target TYPO3 version (e.g., v13.4, v14.x).
2. **Steps to Reproduce**: Clear instructions from a fresh checkout.
3. **Logs**: Relevant container output (`docker compose logs web` or `make logs`).

---

## 💡 Suggesting Features & Enhancements

To ensure additions keep the setup clean, secure, and broadly applicable:
- Open a GitHub issue or discussion first to talk through the proposed idea before writing code.
- Detail the use case and how it benefits TYPO3 FrankenPHP projects.

---

## 🛠️ Pull Request Process

1. **Branch**: Create a descriptive feature branch from `main`:
   ```bash
   git checkout -b feat/your-improvement
   ```
2. **Conventions**:
   - Use atomic Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`).
   - Keep settings environment-driven via `.env` (avoid hardcoding personal domains or credentials).
   - Preserve security hardening (unprivileged container flags, Caddy CSP, PHP execution blocks in upload folders).
3. **Local Testing**:
   - Ensure the image builds cleanly:
     ```bash
     docker compose build web
     ```
   - Verify services start up and pass healthchecks:
     ```bash
     docker compose up -d
     docker compose ps
     ```
4. **Submit**: Open a Pull Request against `main` with a brief summary of the changes.
