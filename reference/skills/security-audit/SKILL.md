---
name: security-audit
description: Audit web applications, backends, and APIs for OWASP Top-10 vulnerabilities (broken access control, injection, XSS, CSRF, SSRF, auth/session flaws, unsafe uploads, leaked secrets). Use when asked to perform a security review, find vulnerabilities, or harden an application.
---

# Web & API Security Audit (OWASP Top-10)

## Scope & Deliverable Contract
- Trace **tainted source -> transformation -> unsafe sink** before reporting any issue; never report unverified grep noise as a vulnerability.
- Distinguish `[LIVE]` (reproduced against a running endpoint/test) from `[CODE]` (verified via static data-flow trace).
- Report severity (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`), `CWE`, `OWASP Top-10` category, exact `file:line`, exploit scenario, and minimal remediation diff.

## OWASP Top-10 Audit Order
1. **A01 Broken Access Control**: IDOR (missing object-level ownership check), privilege escalation, mass assignment / unvalidated schema fields, path traversal (`../` / symlink escape).
2. **A02 Security Misconfiguration**: Debug mode in production, permissive CORS (`Access-Control-Allow-Origin: *` with credentials), missing security headers (`CSP`, `HSTS`, `X-Content-Type-Options`, `X-Frame-Options`), exposed admin/metrics routes.
3. **A03 Supply Chain & Dependencies**: Known vulnerable packages, unpinned runtime dependencies, untrusted build/install hooks.
4. **A04 Cryptographic Failures**: Hardcoded API keys/JWT secrets, weak password or token hashing (`MD5`/`SHA1`), non-constant-time token comparison, predictable RNG (`random` instead of `secrets`/`crypto`).
5. **A05 Injection & Cross-Site Scripting (XSS)**:
   - SQL/NoSQL injection (string interpolation in queries, unallowlisted `ORDER BY` columns).
   - OS command injection (`shell=True`, `child_process.exec`, `system()`/`popen()` on user input).
   - Reflected/Stored/DOM XSS (`innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `set:html`, unescaped template output).
6. **A06 Insecure Design**: Missing rate limits on auth/expensive endpoints, race conditions (TOCTOU on balances/quotas/files), trusting client-side price/role fields.
7. **A07 Identification & Authentication**: Session fixation, missing `HttpOnly`/`Secure`/`SameSite` cookie attributes, JWT `alg: none` or missing audience/expiry validation, OAuth missing `state`/PKCE.
8. **A08 Software & Data Integrity**: Unsafe deserialization (`pickle.loads`, `yaml.load` without `SafeLoader`, `unserialize`, `eval`/`Function`), unsigned webhook payloads.
9. **A09 Logging & Monitoring**: Secrets/PII logged in plaintext, missing audit events on auth/privilege failures, stack traces leaked in HTTP responses.
10. **A10 SSRF & Outbound Request Forgery**: User-controlled URLs passed to `fetch`/`requests`/`httpx`/`urllib`/`curl` without scheme/host allowlisting and private-network blocking.

## Multi-Stack Taint Discovery Patterns
```bash
# Command execution & unsafe eval/deserialization (Python / JS / PHP / Go)
rg -n "subprocess\.(run|Popen|call).*shell\s*=\s*True|os\.system\(|child_process\.(exec|execSync)\(|pickle\.loads\(|yaml\.load\(|unserialize\(|eval\(" .

# Raw SQL string interpolation
rg -n "(execute|query|raw)\s*\(\s*(f[\"']|[\"'`].*\$\{|[\"'].*%s|[\"'].*\.\s*\$)" .

# DOM / Template XSS sinks
rg -n "dangerouslySetInnerHTML|innerHTML\s*=|v-html|set:html|\|\s*safe\b" .

# Hardcoded secrets, private keys, and weak hashes
rg -n "BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY|api[_-]?key\s*[:=]\s*[\"'][A-Za-z0-9_\-]{16,}|md5\(|sha1\(" .

# File upload, path join, and outbound URL (SSRF) sinks
rg -n "send_file|FileResponse|move_uploaded_file|extractall\(|requests\.(get|post)|httpx\.(get|post)|urllib\.request\.urlopen" .
```

## Severity Rubric
- **CRITICAL**: Unauthenticated RCE, SQLi/auth bypass, arbitrary file write/read of secrets, committed live production credentials.
- **HIGH**: Stored XSS, authenticated SQLi/SSRF, IDOR exposing private user/clinical records, CSRF on account-takeover/state-critical actions.
- **MEDIUM**: Reflected XSS, missing rate limiting on auth/compute-heavy endpoints, resource exhaustion / zip-bomb / unbounded upload size.
- **LOW**: Missing defense-in-depth headers, verbose non-secret error messages, dev-only misconfigurations.
