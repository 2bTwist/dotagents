---
name: aso-and-apple-ads
description: App Store Optimization and Apple Search Ads strategy for iOS apps. Use when planning ASO, keyword research, Apple Search Ads campaigns, pricing strategy, or app launch marketing.
---

# ASO & Apple Search Ads Skill

## When to Use This Skill

Trigger when the user is:
- Launching a new iOS app and needs ASO strategy
- Setting up Apple Search Ads campaigns
- Doing keyword research for App Store
- Planning pricing/monetization (affects ad economics)
- Optimizing App Store listing (title, subtitle, keywords, screenshots, description)
- Analyzing ad campaign performance
- Planning cross-localization or international expansion

---

## ASO Fundamentals

### What Apple Indexes for Search

| Field | Limit | Indexed? | Weight |
|-------|-------|----------|--------|
| Title | 30 chars | Yes | Strongest |
| Subtitle | 30 chars | Yes | Strong |
| Keyword Field | 100 chars | Yes | Moderate |
| Promotional Text | 170 chars | No | Conversion only |
| Description | 4,000 chars | No | Conversion only |
| Screenshot text | — | Yes (OCR) | Weak |

### Keyword Field Rules

- Comma-separated, NO spaces after commas
- Never duplicate words across title/subtitle/keywords — Apple takes the WORST ranking, not the best
- No plurals needed — Apple indexes both automatically
- Don't include app name or category — auto-indexed
- Use all 100 characters — every unused char is wasted
- Difficulty under 50 is the target — above 50 you won't rank without ads or massive external traffic

### ASO Change Cadence

- Change ONE thing at a time
- Wait 5-7 days between changes for Apple's indexing to stabilize
- Measure before and after every change
- Order of changes: Keywords first → Title/Subtitle → Screenshots → Description

### Cross-Localization (Free Keyword Expansion)

For the US App Store, Apple indexes 10 locales:
- Primary: English (US)
- Cross-localized: Arabic, Chinese (Simplified), Chinese (Traditional), French, Korean, Portuguese (Brazil), Russian, Spanish (Mexico), Vietnamese

Each locale = +160 indexable characters (30 title + 30 subtitle + 100 keywords).

Rules:
- Can use ENGLISH keywords in all locale slots
- No ranking boost from repeating keywords across locales — use unique terms per locale
- Keywords don't combine across locales — only within a single locale
- Only use a locale for cross-localization if that market is NOT a priority for real localization

**The trick:** If a keyword doesn't fit in your US title, put it in a cross-locale title (e.g., Russian). It gets higher weight than the US keyword field because titles rank higher than keyword fields.

### Three Levels of International Expansion

| Level | What | Translation? | When |
|-------|------|-------------|------|
| 1. Cross-localization | English keywords in non-English locale slots | No | First ASO pass — boost US rankings |
| 2. English-market optimization | UK/CA/AU keyword fields | No | When Astro shows lower difficulty |
| 3. Full localization | Translate app UI + screenshots + metadata | Yes | Only when data shows organic traffic from that country |

### Screenshots

- First 3 screenshots are critical — users decide in 7 seconds
- 96% of top apps use portrait orientation
- Screenshot text IS indexed by Apple — use high-value keywords in captions
- Lead with value proposition if you have < 100 ratings. Lead with social proof if you have 1000+ ratings
- Must show actual in-app UI (Apple rejects misleading visuals)
- Use a tool like App Screens (appscreens.com) to generate all device sizes from one design

---

## Apple Search Ads

### Key Metrics

| Metric | Full Name | What It Means | Example |
|--------|-----------|---------------|---------|
| CPT | Cost Per Tap | What Apple charges per ad tap | $1.00/tap |
| CPA | Cost Per Acquisition | Total spend ÷ downloads | $3.00/install |
| CAC | Customer Acquisition Cost | Same as CPA | $3.00/install |
| LTV | Lifetime Value | Total revenue per user after Apple's 30% cut | $11.17 |
| TTR | Tap-Through Rate | Taps ÷ Impressions | 10% |
| CR | Conversion Rate | Downloads ÷ Taps | 40% |

**The formula:** CPA = CPT ÷ Conversion Rate

**The full chain:**
```
Impression (free) → Tap (CPT) → Download (CPA) → Subscribe → Stay (LTV)
                                                              ↓
                                            LTV:CAC ratio — profitable if > 1.0x
```

### Ad Placements

| Placement | User Intent | Cost | Controls |
|-----------|------------|------|----------|
| Search Results | Highest — actively searching | Lowest CPA | Keywords, Search Match, CPPs, budget |
| Search Tab | Low — browsing suggestions | High CPA | Budget, CPT only |
| Today Tab | Lowest — just opened App Store | Highest CPA | Budget, CPT, CPPs |
| Product Pages | Medium — browsing competitors | Medium CPA | Budget, CPT only |

**Always start with Search Results.** Highest intent = cheapest downloads.

### Bid Strategies

**Maximize Conversions (autopilot)**
- Apple handles all bidding
- You set: Target CPA + Daily Budget
- Requires Search Match ON
- Let run 2 weeks minimum before judging
- Best for: discovery, learning, new campaigns

**Manage Bids (manual control)**
- You set max CPT per keyword
- Full control over spend allocation
- Best for: proven keywords, exact match campaigns
- Bid aggressively on exact match (proven winners)
- Bid moderately on broad match (exploring)

### Campaign Structure (4 campaigns)

| Campaign | Match Type | Purpose | Budget Priority |
|----------|-----------|---------|----------------|
| Brand | Exact | Defend your app name from competitors | Low (cheap, low volume early on) |
| Category | Exact | Target generic searches for your app type | Medium |
| Competitor | Exact | Show up when users search competitor names | High ROI |
| Discovery | Broad + Search Match | Find new keywords | Learning budget |

### Discovery → Exact Match Pipeline

1. Run Discovery campaign with Search Match ON
2. After 7-14 days, check search terms report
3. Winners (good CPA) → move to Category/Competitor as exact match
4. Add those keywords as negatives in Discovery (don't pay twice)
5. Losers (bad CPA) → add as negative keywords everywhere
6. Irrelevant matches → add as negative keywords
7. Discovery keeps finding NEW keywords
8. Repeat

### Negative Keywords (common for most apps)

Block searches that are semantically related but wrong audience. Examples:
- Medical/clinical terms if you're a wellness app (not a medical device)
- Dating terms if you're a couples app (existing relationships, not finding dates)
- Competitor-specific features you don't have
- Adjacent categories (pregnancy tracker, period tracker, etc.)

### Ad Creative Variations

Use Custom Product Pages (CPPs) to tailor the landing experience:
- Different screenshot orders per ad group
- Match screenshots to search intent
- Someone searching "couples app" → couple features first
- Someone searching "mood tracker" → solo features first
- Up to 70 CPPs per app, one active ad variation per ad group

Seasonal variations:
- Update CPPs for holidays relevant to your app
- Valentine's Day, Mental Health Awareness Month, New Year, etc.

### Budget Strategy for Small Apps ($100 credits)

1. Start with ONE Discovery campaign: $5/day, $3 CPA, Search Match ON
2. Let run 7-14 days (~$35-70 spent)
3. Review search terms report
4. Create Exact match campaign with winners
5. Don't create Brand campaign until people search your name
6. Don't use Today Tab or Search Tab — not cost-effective at low budgets

### Ad Economics — When to Spend Real Money

Calculate before scaling:
```
Revenue per subscriber = Price × 0.70 (after Apple's 30%)
LTV = Revenue per subscriber × Average months retained
Blended CPA = Total ad spend ÷ Total downloads
Revenue per download = LTV × (free-to-paid conversion rate)

Profitable when: Revenue per download > Blended CPA
```

**Don't spend real money on ads until your funnel is optimized.** Fix onboarding drop-offs, improve paywall conversion, increase retention FIRST. Ads amplify what's already working — they can't fix a leaky funnel.

---

## Pricing Strategy (Set BEFORE Ads)

Before running ads, know your economics:
- Monthly vs yearly pricing affects LTV dramatically
- Apple takes 30% (15% after year 1 for small developers < $1M)
- Calculate break-even CPA before setting ad budgets
- Free trial length affects conversion rate
- Yearly subscribers have ~3-4x higher LTV than monthly

---

## Tools

| Tool | Purpose | Cost |
|------|---------|------|
| Astro (tryastro.app) | Keyword research, difficulty/popularity, rank tracking | $9/mo |
| Apple Search Ads keyword planner | Apple's own popularity scores, keyword suggestions | Free |
| App Store Connect Analytics | Impressions, conversion, downloads, territory data | Free |
| App Screens (appscreens.com) | Screenshot generation for all device sizes | Free tier available |
| PostHog / analytics | Measure in-app funnel (onboarding → activation → subscription) | Free tier |

---

## Non-Obvious Tricks & Hard-Won Lessons

### Keyword Weight Hack (Cross-Locale Titles)

Keywords in a title rank higher than keywords in a keyword field — even cross-locale titles. If "mood tracker" doesn't fit in your US title, put it in the RUSSIAN title. It gets title-level weight for US rankings, not keyword-field weight. This is stronger than putting it in any keyword field.

### Duplicating Keywords HURTS You

Never repeat a keyword across title, subtitle, and keyword field. Apple takes the WORST ranking, not the best. If "mood" is in your title AND keyword field, it can actually rank lower than if it were only in the title. Remove duplicates aggressively.

### Screenshot Text Is Indexed

Apple OCR-scans your screenshot captions and indexes the words. Your screenshot caption "Track Where You Feel It" means Apple indexes "track", "where", "feel" for search. Design screenshot captions with high-value keywords intentionally — they serve double duty (conversion + search ranking).

### Reviews Directly Impact Rankings Per Country

Higher average rating in a specific country = better search rankings in that country. If you have 5.0 stars in Canada but 3.5 in the US, you'll rank better in Canada for the same keyword. This means review prompt timing matters — prompt happy users, not frustrated ones.

### Look at Revenue, Not Downloads

A keyword with 20K downloads but $0 revenue is a vanity metric. Before targeting a keyword, check what the top 5 apps ranking for it are actually earning. If they're all free with no monetization, that keyword's users don't pay for apps.

### App Store Boost (First 3 Days)

Apple gives new apps a visibility boost during the first ~3 days after initial publish. Can result in ~300 downloads and 15-30 trials if ASO is set up well. This means your ASO must be PERFECT before you hit publish — not after. You only get this boost once.

### Ads "Cheat" Organic Rankings

Running Search Ads on a keyword temporarily boosts your ORGANIC ranking for that keyword too. The downloads you get from ads signal to Apple that your app is relevant for that search. This is why even $5/day of ad spend can improve organic rankings.

### If Ads Don't Spend

If your campaign runs for 24-48 hours with $0 spend, your CPA target is too low for the keywords Apple is matching. Increase target CPA by 10-20% per day until it starts spending. Apple won't show your ad if it can't hit your CPA target.

### Conversion Rate Benchmarks

- App Store product page conversion under 10% → rework screenshots urgently
- Apple Search Ads tap-to-download conversion under 50% → screenshots/title don't match the keyword
- A/B test screenshots via Product Page Optimization (PPO) — never guess what works

### A/B Test Your Icon

Your app icon is the single most important visual for conversion. Use PPO to A/B test alternate icons (requires alternate icons compiled into the binary). Small icon changes can move conversion rate by 10-20%.

### Localization Requires Full Translation

When localizing for a real market (not cross-localization), you must translate ALL of: title, subtitle, keyword field, screenshots, and description. Use native speakers, not machine translation. Some features resonate differently by culture.

### Follow the Data for Country Expansion

Don't guess which countries to localize for. Monitor App Store Connect territory data and analytics. If you see unexpected downloads from Korea, add Korean localization. The video creator added Korean only after seeing organic trials from Korea.

### Review Response Strategy

- Reply to ALL reviews within 24-48 hours
- Always courteous, even negative reviews — your response is visible to everyone
- Show you're actively fixing reported problems
- Acknowledge positive reviews
- Responses can influence users to update their rating

### The Discovery → Exact Match Pipeline

This is the core Search Ads loop that runs forever:

```
Discovery finds keyword → test for 1-2 weeks → check results
  ↓ winner: move to exact match campaign, add as negative in discovery
  ↓ loser: add as negative keyword everywhere
  ↓ unclear: let run longer
Discovery is now forced to find NEW keywords → repeat
```

The exact match campaigns make money. Discovery spends money to learn. Over time, more budget shifts from discovery to exact match as you find more winners.

---

## Checklist for New App Launch

### Before Launch
- [ ] Keyword research — find 20+ keywords with difficulty < 50
- [ ] Title: brand + highest-value keyword (30 chars)
- [ ] Subtitle: secondary keyword phrase (30 chars)
- [ ] Keyword field: no duplicates with title/subtitle, use all 100 chars
- [ ] Screenshots: 8 total, first 3 critical, keyword-rich captions
- [ ] Description: value-prop led first 3 lines, feature bullets, privacy mention
- [ ] Promotional text: 170 chars, updateable anytime
- [ ] Set up analytics (PostHog or equivalent) with funnel tracking
- [ ] Implement review prompt at positive moments (after 5th/15th use)

### Launch Week
- [ ] Capture baseline metrics (impressions, conversion, downloads)
- [ ] Create Apple Search Ads account, claim $100 credits
- [ ] Launch Discovery campaign ($5/day, Search Match ON)
- [ ] Check territory data — where are downloads coming from?

### Week 2-3
- [ ] Measure keyword ranking changes (Astro)
- [ ] Review Search Ads search terms report
- [ ] Move winners to exact match campaign
- [ ] Add negative keywords for irrelevant matches
- [ ] Check if conversion rate > 10% (if not, rework screenshots)

### Month 2
- [ ] Cross-localize keywords (9 locale slots for US boost)
- [ ] Add UK/CA/AU keyword fields if difficulty is lower
- [ ] Run PPO A/B test on screenshots (need sufficient traffic)
- [ ] Consider Competitor campaign (bid on competitor names)
- [ ] Calculate LTV:CAC — is paid acquisition viable?

### Month 3+
- [ ] Custom Product Pages for different search intents
- [ ] Seasonal ad variations
- [ ] Consider full localization for countries showing organic traffic
- [ ] In-App Events for seasonal visibility
- [ ] App preview video
