---
name: keyword-ranks
description: Pull current App Store keyword ranks for any app using Apple's free iTunes Search API. Bypasses paid ASO tools (Astro, AppTweak, SensorTower) by reading Apple's own search results directly. Use when the user wants to check keyword ranks, generate a rank snapshot, or document an ASO measurement point in a Change Log. Does NOT pull popularity or difficulty.
---

# Keyword Ranks

Programmatically pull App Store keyword ranks for a given app and country, with no auth and no signing.

## When to Use

Trigger when the user wants any of:
- "Check keyword ranks", "pull ranks", "where do we rank for X"
- "Generate a rank snapshot", "Change Log row" for ASO measurement
- Comparison against a previous baseline (e.g., post-release rank delta after N days)
- Multi-country rank pulls (US + GB + CA + AU)

Do NOT use for:
- Keyword popularity (Apple's score 0-100). Use Astro's UI or Apple Search Ads API.
- Keyword difficulty. Proprietary metric, not available from Apple directly.
- Conversion rate / impressions / page views. Those live in App Store Connect Analytics.
- Competitor keyword research. Use the `aso-audit` skill.

## How It Works (the discovery)

Paid ASO tools (Astro, AppTweak, SensorTower) compute "rank" by:
1. Calling Apple's App Store catalog/search endpoint for each tracked keyword.
2. Finding the target app's `trackId` in the result list.
3. Position in results = rank.

Apple's public `https://itunes.apple.com/search` endpoint returns the same search data with **no auth, no signing, no API key**. The rank derivation is trivial. Paid tools' value is in UI, history storage, popularity/difficulty enrichment — not data access for current rank.

Endpoint shape:
```
GET https://itunes.apple.com/search
    ?term=<urlencoded keyword>
    &country=<lowercase iso, e.g. us>
    &entity=software
    &limit=200
```

Response: JSON with `resultCount` and `results: [{ trackId, trackName, ... }, ...]`. Iterate through `results`, look for your `trackId`, return the 1-indexed position. If not found in the first 200 → "not in top results."

## Setup

1. **Ensure the script exists.** If `scripts/aso/keyword-ranks.py` (or equivalent project location) is missing, create it. Use the template at the bottom of this file.
2. **Collect inputs:**
   - **App ID** — Apple's numeric trackId. Find in App Store URL: `https://apps.apple.com/<cc>/app/<name>/id<APPID>`.
   - **Country code(s)** — lowercase ISO 3166: `us`, `gb`, `de`, `fr`, `ca`, `au`, etc.
   - **Keyword list** — comma-separated. If the project has a tracked keyword set in `docs/aso/APP_STORE_OPTIMIZATION.md` or similar, use it.
3. **Read `app-marketing-context.md`** in the project root if it exists — may have canonical app ID + keyword list saved.

## Execution

```bash
python3 scripts/aso/keyword-ranks.py \
    --app-id <APPID> \
    --country <CC> \
    --keywords "kw1,kw2,kw3,..."
```

Output is a Markdown table to stdout.

For multi-country, run once per country and combine:
```bash
for cc in us gb ca au; do
  python3 scripts/aso/keyword-ranks.py --country $cc --keywords "..." > /tmp/ranks-$cc.md
done
```

Apple rate-limits aggressive scraping but the default 0.3s delay between requests is conservative. For 10 keywords across 4 countries (40 requests total) you'll see no throttling.

## Writing the result

After running, format the snapshot as a Change Log row in the project's ASO doc (typically `docs/aso/APP_STORE_OPTIMIZATION.md`). Compare to the most recent prior snapshot in that doc — note rank deltas, gains, losses.

Template row format:
```
| YYYY-MM-DD | Rank snapshot via keyword-ranks skill (US, N keywords). Headlines: <kw> #<rank>, <kw> +<delta>, <kw> LOST. | <prior baseline metrics> | <today metrics if available> | <one-line diagnosis> |
```

## Limits and caveats

- **Top 200 results only by default.** If your app ranks below #200 for a keyword, you get "not found." Increase `--limit` to 500 if needed but Apple may truncate.
- **No history.** This skill returns a single point in time. Use the project's ASO doc Change Log as the history store.
- **Rank ≠ what users see.** Apple's search results are personalized (locale, prior installs, A/B tests). The script gives the unauthenticated baseline — close to what a clean device would see, but not identical to any individual user's experience.
- **Don't use this for ad hoc curiosity.** Each invocation is a real measurement. Document it. Otherwise you'll forget what was measured when.

## Python script template

If `scripts/aso/keyword-ranks.py` doesn't exist, write this:

```python
#!/usr/bin/env python3
"""
keyword-ranks.py — Pull App Store keyword ranks via Apple's public iTunes
Search API. No auth required. Output is a Markdown table.

Defaults are set for BeSeen; override via flags for any other app.
"""

import argparse, json, sys, time, urllib.parse, urllib.request
from datetime import date

ITUNES_SEARCH_URL = "https://itunes.apple.com/search"
USER_AGENT = "Mozilla/5.0 (keyword-ranks/1.0)"

def fetch_search(term: str, country: str, limit: int = 200) -> dict:
    params = {
        "term": term,
        "country": country,
        "entity": "software",
        "limit": str(limit),
    }
    url = f"{ITUNES_SEARCH_URL}?{urllib.parse.urlencode(params)}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=15) as r:
        return json.loads(r.read().decode("utf-8"))

def find_rank(payload: dict, app_id: str) -> int | None:
    for i, app in enumerate(payload.get("results", []), 1):
        if str(app.get("trackId")) == str(app_id):
            return i
    return None

def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--app-id", default="6760330166", help="Apple numeric trackId")
    p.add_argument("--country", default="us", help="lowercase ISO country code")
    p.add_argument("--keywords",
        default="couple mood journal,couple mood,partner mood,couple journal,mood journal couples,body map,check in,reflect,honest,resilience",
        help="comma-separated keyword list")
    p.add_argument("--limit", type=int, default=200, help="results per keyword (max ~200)")
    p.add_argument("--delay", type=float, default=0.3, help="seconds between requests")
    args = p.parse_args()

    keywords = [k.strip() for k in args.keywords.split(",") if k.strip()]
    print(f"# Rank snapshot — app {args.app_id} — {args.country.upper()} — {date.today().isoformat()}")
    print()
    print("| Keyword | Rank | / Total |")
    print("| --- | ---: | ---: |")
    for kw in keywords:
        try:
            data = fetch_search(kw, args.country, args.limit)
            total = data.get("resultCount", len(data.get("results", [])))
            rank = find_rank(data, args.app_id)
            rank_str = "—" if rank is None else str(rank)
            print(f"| {kw} | {rank_str} | {total} |")
        except Exception as e:
            print(f"| {kw} | ERROR | {e} |", file=sys.stderr)
        time.sleep(args.delay)
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

## Origin

This skill was extracted from a May 2026 session reverse-engineering Astro (the indie ASO Mac app by Matteo Spada). Discovery: Astro's `POST /v1/popularity` and `GET /v1/catalog/us/search?term=...` are the only two endpoints that drive its rank-tracking UI. The catalog/search endpoint is just a wrapper around Apple's iTunes Search API. Hence the entire rank-tracking feature can be replicated in ~50 lines of Python with zero auth.

What stopped the broader RE: Astro signs every request with HMAC-SHA256 using a runtime-derived key (not in the binary as a static string), and pins TLS for several AWS endpoints. So fully replaying Astro's `/v1/popularity` would require Frida/LLDB hooks to extract the key. Out of scope here — popularity belongs in Apple Search Ads API or the Astro UI for now.
