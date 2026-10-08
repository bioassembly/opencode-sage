---
name: security-audit
description: Audit a PHP/CodeIgniter 4 web app for OWASP Top-10 vulnerabilities (SQLi, XSS, CSRF, IDOR, session, upload, secrets). Use when asked to assess security vulnerabilities, do a security review, or harden a web app.
---

## What I do
- Systematically audit a PHP web app (esp. CodeIgniter 4) for OWASP Top-10 2025 classes
- Distinguish live-reproducible findings from code-read findings; assign severity
- Produce findings in the repo's existing BUGS.txt GitHub-issue format
- Cross-reference against existing BUGS.txt so only UNIQUE findings are added

## OWASP Top 10 2025 checklist (audit order)
- A01 Broken Access Control — IDOR, missing role/ownership checks, mass assignment
- A02 Security Misconfiguration — debug on, default creds, verbose errors, CORS *, missing headers
- A03 Software Supply Chain — unpinned/known-vuln deps, untrusted vendor code
- A04 Cryptographic Failures — hardcoded keys, weak hashes (md5/sha1), plaintext secrets, no HTTPS enforcement
- A05 Injection — SQLi (raw concat, orderBy/like on user input), command injection, XSS (reflected+stored), LDAP, path traversal
- A06 Insecure Design — missing rate limit, no business-logic validation, trust in client state
- A07 Identification & Auth Failures — weak login, no lockout, session fixation, missing MFA, OAuth state/nonce
- A08 Software & Data Integrity Failures — unsafe deserialization, CI/CD integrity, backup restore trust
- A09 Security Logging & Monitoring — no audit trail, no alerting on auth failures
- A10 Sensitive Data Exposure — PII/secrets in logs, dumps, git history, API responses

## PHP / CodeIgniter 4 specific patterns to grep
```bash
# SQLi: raw query / string-built SQL / orderBy+like on request input
rg -n "query\(|->select\(|->where\(|orderBy|like\(" app/ | grep -i "request\|get\|post\|\$"
# XSS: unescaped echo of request/DB data in views
rg -n "<=\s*\$[a-zA-Z_]" app/**/Views/ | grep -v "esc("
# Command injection
rg -n "exec\(|shell_exec\|system\(|passthru\|popen\|proc_open\|`\$" app/
# Unsafe deserialization
rg -n "unserialize\(" app/
# Weak crypto / hardcoded secrets
rg -ni "md5\(|sha1\(|password_hash|AES|openssl|iv|key\s*=" app/
# Path traversal in file ops
rg -n "file_get_contents|fopen|readfile|move_uploaded_file|unlink|include|require" app/ | grep -i "\$"
# Mass assignment / raw request to model
rg -n "save\(|insert\(|update\(" app/ | grep -i "request\|->getPost\|->getVar"
# Session: fixation, missing regenerate, cookie flags
rg -n "regenerate|setTempdata|session\(\)->set|cookieHTTPOnly|cookieSecure|cookieSamesite" app/
```

## CodeIgniter 4 hardening checklist
- CSRF: `$csrfProtection` on; use session-based (not cookie) for stricter; `$tokenRandomize = true`; csrf filter in global Filters; verify token on ALL state-changing POSTs (not just some)
- Escaping: every dynamic `<?= $var ?>` in views wrapped in `esc($var)`; `esc()` default is HTML — use `esc($x, 'js')`/`'attr'` where needed
- Input: `$request->validate()` with rules on every controller method that mutates data; never trust client-supplied IDs/roles
- Auth: session `regenerate(true)` on login/privilege change; set `cookieHTTPOnly=true`, `cookieSecure=true`, `cookieSamesite=Lax`; store minimal session data; use a real session driver (DB/Redis) not files in prod
- Files: use `Services::uploader` with `allowedFileTypes`, `maxSize`, `randomName`/`detectMimeType`; never use raw uploaded filename; store outside webroot or block script execution
- Secrets: no hardcoded keys in source; load from env; rotate any committed secret; `.env`/`env` in .gitignore AND untracked
- DB: use query builder / bindings (`$db->query($sql, [$params])`) — never string-interpolate values; allow-list column names for orderBy/sort
- Errors: `$app->showErrorDetails`/CI_ENVIRONMENT=production off in prod; no stack traces to client
- Headers: add CSP, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Strict-Transport-Security
- Rate limit: throttle login + sensitive POSTs (CI4 has no built-in; use Throttler or middleware)

## Severity assignment
- CRITICAL: remote code exec, full DB compromise, auth bypass, live secret exposed
- HIGH: stored XSS, IDOR on sensitive data, SQLi requiring auth, session fixation, business-logic bypass
- MEDIUM: reflected XSS, CSRF on low-impact action, missing validation, info disclosure, weak crypto on non-critical data
- LOW: missing hardening header, latent/defense-in-depth, code smell with no current exploit
- DEV-STAGE: acceptable in dev, must fix before prod (default creds, no CI, no rate limit)

## Process
1. Read repo AGENTS.md + existing BUGS.txt to know what's ALREADY found
2. Run the grep patterns above; triage each hit by reading surrounding code
3. For each candidate: confirm the data flow (tainted source -> unsafe sink, no sanitization)
4. Mark [LIVE] if reproducible against running app, else [CODE]
5. Only ADD findings not already in BUGS.txt; reuse existing IDs/sections, append new ones
6. Assign severity per rubric; note CWE + OWASP category

## When to use me
- "Assess the security vulnerabilities", "do a security audit/review", "find security bugs", "harden this app"
- Before production release of a PHP/CI4 web app
- When a new feature adds input handling, auth, file upload, or DB queries
