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

1. **Ensure the script exists.** If `scripts/aso/keyword-ranks.py` (or equivalent project location) is missing, create it by copying the sibling [`keyword-ranks.py`](keyword-ranks.py).
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

## Origin

Extracted from a May 2026 session reverse-engineering Astro (the indie ASO Mac app by Matteo Spada). Astro's rank-tracking UI is driven by just two endpoints — `POST /v1/popularity` and `GET /v1/catalog/us/search?term=...` — and the catalog/search one is a thin wrapper around Apple's iTunes Search API, so the whole rank-tracking feature replicates in ~50 lines of Python with zero auth. Popularity is the part that stays out of reach here: Astro signs every request with HMAC-SHA256 from a runtime-derived key (not a static string in the binary) and pins TLS, so replaying `/v1/popularity` would need Frida/LLDB hooks to extract the key. Popularity belongs in the Apple Search Ads API or the Astro UI for now.
