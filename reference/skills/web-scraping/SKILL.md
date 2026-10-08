---
name: web-scraping
description: Extract structured data from websites — static pages, JS-rendered apps, APIs behind the scenes, pagination, rate limits. Use when asked to scrape, crawl, extract, or collect data from web pages.
---

# Web Scraping

## Decision ladder (cheapest that works)

1. **Check for a public API first** — inspect network tab logic: most sites load data via XHR/fetch JSON endpoints. Hitting those beats HTML parsing every time.
2. **Static HTML** → `curl` + parse. Test: `curl -sL <url> | grep -c '<article'` — if content is in the raw HTML, no browser needed.
3. **JS-rendered** → Playwright MCP (`browser_navigate` then read accessibility snapshot — deterministic, no vision needed).
4. **Protected/heavy targets** → say so; recommend Crawl4AI (self-hosted, Docker) or a paid API rather than fighting anti-bot systems inline.

## Parsing patterns

```bash
# quick field extraction without python deps
curl -sL "$URL" | grep -oP '<h2[^>]*>\K[^<]+'
# structured: python stdlib html.parser or lxml if installed
python3 - <<'EOF'
from lxml import html
t = html.parse('/tmp/page.html')
print(t.xpath('//a[@class="title"]/@href'))
EOF
```

Save fetched pages to `/tmp/opencode/` — never re-fetch inside a loop what you can parse once.

## Politeness & legality

- Honor robots.txt for crawls; identify with a real User-Agent; throttle (≥1s between requests).
- Never scrape behind login/paywalls without the account owner's consent.

## Pagination

- Detect the JSON API's `page`/`offset` param and loop with `while` + stop condition on empty result set — don't click "next" 200 times in a browser.

## Output contract

Deliver data as CSV/JSONL with a stated schema. Print row count + 2 sample rows so the user can sanity-check without opening the file.
