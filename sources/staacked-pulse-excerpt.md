# staacked pulse

> Sneaker-resale Shopify storefront (shopstaacked.com, store handle
> `3es5s0-7b`) for a live-selling business on Whatnot (77.5K) and
> TikTok (@shopstaacked, 12K). Custom Liquid theme (no OS 2.0
> sections/JSON) + a live-status aggregator on Netlify that reads the
> team's ops portal to auto-flip "live now" UI. Sells mostly 1-of-1
> pairs, so sold-out hiding matters.

## Current state

(Updated 2026-07-07) **LIVE = v1.6 (#153509396659), published 2026-07-07**
(rollbacks: v1.5.1 #153506644147, v1.4.1 #153503072435, both unpublished).
Final polish before publish: header text all bold-700 (nav/search/go/
cart), size-group labels (toddler…adult) green 16px. v1.6 = wordmark-image brand +
spinning syndicate badge (after the wordmark), brand green #50d641 for
bold item names (volt only on CTAs; cart badge + "go" now brand green),
mobile header = two rows (no menu drawer — deleted), /search mobile fix
(.page-search), footer © removed + accessibility link, whatnot+tiktok
floating fabs carry ALL live status ("whatnot — live now" when live),
in-stock-only size/lid chips on cards, size-conversion facet (one
checkbox per canonical size, "9 / 10.5w (24)" verified = 24 pairs) +
53 homepage chips w/ halves + dual labels. Round 2: homepage order
size→bestsellers→recent→brand, uniform GREEN headers + black bold item
titles, fabs turn RED when live (verified END-TO-END with a real
aggregator override — red fab + "live now on whatnot" banner, ~70s test). **Store-level ALREADY LIVE:**
all 2,838 variant weights forced to 3 lb (sweep+webhook keep enforcing);
user built + FIXED shipping tiers themselves (2026-07-07: rates cover up
to 8 items/24 lb; >8-item carts get no rate by DESIGN — user accepts the
block, policy states the 8-item cap); Accessibility page live at
/pages/accessibility (WCAG 2.1 AA statement, page id 122962804915).
**VA docs live**: staacked-catalog.netlify.app/how-it-works.html.
**Review page v2** (2026-07-07): password gates the PAGE (pw = REVIEW_PW
= Warehouse2025!, old pw dead); per-photo × ejects one shoe; floating
basket + group-name AUTOCOMPLETE replaces key-based merging; machine
