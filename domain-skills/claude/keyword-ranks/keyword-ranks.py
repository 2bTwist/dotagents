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
