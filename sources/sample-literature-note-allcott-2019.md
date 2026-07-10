# Allcott et al. (2019): Food Deserts and the Causes of Nutritional Inequality

## Citation
Allcott, H., Diamond, R., Dubé, J.-P., Handbury, J., Rahkovsky, I., & Schnell, M. (2019). Food deserts and the causes of nutritional inequality. *Quarterly Journal of Economics*, 134(4), 1793–1844. doi:10.1093/qje/qjz015. Advance Access May 20, 2019.

---

## Core Question
Why do low-income households consume less nutritious diets, and how much of this "nutritional inequality" is attributable to limited store availability (supply-side / food desert effect) versus differences in consumer preferences, income, and knowledge (demand-side)?

---

## Data & Methods

| Aspect | Details |
|--------|---------|
| **Demand Data** | Nielsen Homescan panel: ~169,000 unique households, ~39,000/year in 2004–2006, ~61,000/year in 2007–2016 (p.1799) |
| **Supply Data** | Nielsen RMS (Retail Measurement Services): ~42,000 unique stores from 160 retail chains, ~35,000/year, covering ~40% of U.S. grocery purchases (p.1800) |
| **Entry Data** | TDLinx geocoded census of all food retailers: 6,721 supermarket entries in the U.S. from 2004–2016 (p.1795, 1802) |
| **Establishment Data** | ZIP Code Business Patterns (ZBP): establishment counts by NAICS and employment size, 2004–2016 (p.1802) |
| **Geography** | United States, national |
| **Time Period** | 2004–2016 |
| **Nutrition Measure** | Linearized Healthy Eating Index (HEI), normalized to mean 0 and SD 1 across households. Correlation with "true" HEI: 0.91 (p.1803) |
| **Reduced-Form Designs** | (1) Event study around supermarket entry; (2) Household moves across ZIP codes/counties |
| **Structural Model** | Grocery demand model building on Dubois, Griffith, and Nevo (2014): CES within product groups, Cobb-Douglas across product groups, linear preferences for observed nutrient characteristics (p.1820–1821) |
| **Price Instrument** | Novel IV exploiting chain-specific comparative pricing advantages × chains' geographic presence across markets (p.1823–1825). First-stage F: 243–260 (p.1825) |
| **Key Outcome** | Counterfactual decomposition of the nutrition–income gap into supply- and demand-side contributions |

---

## Key Findings

### 1. The Nutrition–Income Gap
Top income quartile buys groceries with a Health Index **0.56 standard deviations** higher than the bottom quartile (conditional on household size, age, year; p.1805). This gap has been growing: from 0.54 SD in 2004–2007 to 0.61 in 2012–2016 (footnote 9, p.1805).

### 2. Supermarket Entry Has Economically Small Effects (Reduced-Form)
Event study around 6,721 supermarket entries (Section IV.A, Table II, Figure IV):
- **Entrant expenditure share**: Increases ~2 percentage points within a year of entry (p.1810)
- **Health Index effect**: At most 0.02 SD in any given quarter, not statistically different from zero in most specifications (Table II, Panel B; p.1812, 1814)
- **Mechanism**: New entrants primarily *divert sales from other supermarkets*, not from drug/convenience stores. Even in food deserts, the grocery/supermarket/club store combined expenditure share barely changes (p.1812)
- **Key statistic**: Even households in ZIP codes with no supermarkets still buy 85% of their groceries from supermarkets (p.1796) — they travel to reach them
- **Bound**: Local access to supermarkets explains no more than **≈1.5%** of the nutrition–income gap (0.02 × 0.44/0.56; p.1814)

### 3. Place Effects Are Small (Movers Analysis)
Household moves across ZIP codes/counties (Section IV.B, Table III, Figure V):
- Convergence toward local area Health Index is positive but statistically insignificant after controlling for demographics (Figure V bottom panels; p.1818)
- **Upper bound**: Place effects explain no more than **2.0%** of the nutrition–income gap (ZIP code moves) to **3.2%** (county moves) (p.1820)
- This includes ALL place-related factors (peer effects, local food culture, etc.), not just supermarket access

### 4. Decomposition: ~9% Supply / ~91% Demand (Structural Model)
Figure VI (p.1832) and Section VII.A (p.1833):
- **Equalizing prices alone** across income groups: essentially no effect on Health Index gap
- **Equalizing prices + product characteristics** (full supply-side equalization): closes **9%** of the gap
- **Equalizing nutrient preferences** (observed + unobserved characteristics): closes an additional **~82%**
- **Equalizing product group preferences**: closes the remaining portion — total demand-side = **91%**
- **Robustness range** (alternative specifications with additional regional FEs): supply accounts for **7–12%**, demand for **88–93%** (p.1833)

### 5. WTP for Healthy Eating Differs Dramatically by Income (Table IV)
Structural preference estimates by income quartile (p.1828–1829):
- Q1 (lowest) WTP for maximum HEI score bundle: **$0.43 per 1,000 calories**
- Q4 (highest) WTP: **$1.14 per 1,000 calories** — almost 3× as much
- Higher-income households have stronger preferences for 6 of 8 "healthy" dietary components
- Added sugar is the only component where high- and low-income households have *opposite-signed* preferences (p.1829)

### 6. What Explains Demand Differences? (Figure VII)
Decomposition of demand-side preference variation (p.1835):
- **Education**: Explains ~20% of income–healthy grocery demand relationship
- **Nutrition knowledge**: Explains ~14%
- **Race, employment, marital status**: Smaller contributions
- **Census division**: Non-trivial geographic component

### 7. SNAP Subsidy Counterfactual (Table V)
Simulated means-tested healthy food subsidy (Section VII.C, p.1836–1838):
- Subsidy matching the effect of one supermarket entry (0.9% gap reduction): costs **$84 million/year**
- Subsidy matching full supply-side equalization (9% gap reduction): costs **$830 million/year**
- Subsidy to fully close the gap (100%): costs **$11 billion/year** (~15% of SNAP budget)
- Comparison: HFFI has spent ~$220M on store entry subsidies; that money could match the same nutritional effect via demand-side subsidies at $84M/year (p.1838)

---

## Model Specification

**Utility function** (Eq. 5, p.1821):
$$U(x, \mathbf{z}, \mathbf{y}; \Theta, \Psi) = \sum_{j=1}^{J} \mu_j \ln \left( \sum_{k=1}^{K_j} \Psi_{kj} y_{kj}^{\theta_j} \right) + \sum_{c=1}^{C} \beta_c z_c + \lambda x$$

Where:
- $\mu_j$ = satiation rate for product group $j$; $\theta_j$ = within-group CES parameter
- $\Psi_{kj}$ = perceived product differentiation for product $k$ in group $j$
- $\beta_c$ = marginal utility of characteristic $c$ (nutrient content); $z_c$ = total consumption of characteristic $c$
- $\lambda$ = marginal utility of outside good $x$ (non-grocery spending)
- Cobb-Douglas across J = 45 product groups (elasticity of substitution = 1 across groups)
- CES within product groups (allows flexible substitution across individual UPCs)
- Linear in observed characteristics (12 dietary components entering the HEI: sodium, whole fruit, other fruit, whole grains, refined grains, sea/plant protein, meat protein, dairy, added sugar, solid fats, plus unobserved ξ)

**Empirical demand equation** (Eq. 7, p.1822):
$$\ln Y_{ijt} = -\ln \left( \bar{p}_{jt} - \sum_{c=2}^{C} \hat{\beta}_c \bar{a}_{ijct} - \xi \right) + \delta_j + \phi_m + \phi_t + \varepsilon_{ijt}$$

Where $Y_{ijt}$ = calories consumed by household $i$ in product group $j$, year $t$; $\bar{p}_{jt}$ = average price/calorie; $\bar{a}_{ijct}$ = average characteristic $c$ per calorie. All parameters estimated separately by income quartile.

**Price Instrument** (Eq. 9, p.1824):
$$P_{jmt} = \frac{\sum_{r \in m} N_{rmt} N_{jrt} \cdot \sum_{k=1}^{K_j} N_{ht} \Delta \ln(p_{hrt,-m})}{\sum_{r \in m} N_{rmt} N_{jrt} \cdot \sum_{k=1}^{K_j} N_{ht}}$$

Exploits the fact that different chains have different comparative advantages in sourcing different products (e.g., West Coast chains can source produce cheaply). Variation comes from chain-specific pricing × chains' geographic presence. Market $m$ excluded from own-market prices. Identifying assumption: chains' comparative pricing advantages are uncorrelated with local idiosyncratic product preferences (Eq. 10; p.1825).

**NOTE**: This paper does NOT contain a store choice model. It models product/category demand. Store choice is not modeled structurally — the reduced-form event studies capture store access effects without a structural store choice specification.

---

## Parameters We Use

| Parameter | Value | Source | Note |
|-----------|-------|--------|------|
| Supply-side bound | ≤9% (primary); 7–12% (range) | Figure VI, p.1833 | Share of nutrition–income gap attributable to food desert / supply differences |
| Supermarket entry effect | ≤1.5% of gap | Table II + calculation, p.1814 | Upper bound from reduced-form event study |
| Place effects bound | ≤2–3.2% of gap | Table III, p.1820 | From movers analysis; includes ALL place factors |
| WTP gradient | Q1: $0.43; Q4: $1.14 per 1000 cal | Table IV, p.1828–1829 | 2.65× ratio — preferences, not access, drive gap |

**Critical Insight**: Allcott et al. establish that new supermarket placement alone can close no more than ~1.5% of the nutrition–income gap (reduced-form) or ~9% at most if all supply conditions were equalized (structural). This does NOT mean placement is useless — it means our model should frame welfare gains primarily in terms of *consumer surplus from reduced travel costs and improved competitive pressure*, not nutritional improvement per se.

---

## Relevance to Our Study

- **Frames realistic expectations**: Municipal supermarket placement will not solve nutritional inequality. The welfare case should emphasize travel cost savings, competitive pressure on existing stores, and consumer choice expansion — not health outcomes.
- **Supermarket entry diverts from other supermarkets**: Allcott's finding that entrants primarily steal share from *other supermarkets* (not convenience stores) is important for our competitive exit modeling. Our exit model needs to account for this — new municipal stores may push out private supermarkets, partially offsetting gains.
- **Travel distance finding**: Average American travels 5.2 miles to shop, 90% by car (p.1815, NHTS 2009). Even low-income households (4.8 miles) and food desert households (nearly 7 miles) travel to supermarkets. This supports our use of travel time as a key utility component.
- **Food desert definition overlap**: 24% of all population-weighted ZIP codes have no supermarket; 55% of low-income (<$25K median) ZIPs have none (p.1808). This provides a national baseline for our NYC-specific analysis.
- **SNAP subsidy cost-effectiveness**: The $84M/year equivalence between entry subsidies and demand subsidies (Table V) suggests our municipal supermarket's welfare gains should be benchmarked against equivalent-cost demand-side interventions.
- **Handbury is a co-author on both this and Cao** — methodological consistency; she knows the food access + distance literature from both the product demand and store choice sides.
- **Cobb-Douglas across product groups**: Their functional form assumption (unit elasticity across product groups) differs from our format-level choice model. We model store/format choice; they model what people buy conditional on where they shop.
- **Education and nutrition knowledge**: The 20% (education) and 14% (nutrition knowledge) contributions to demand-side inequality suggest complementary non-placement interventions that could be paired with municipal supermarket siting.

---

## Caveats & Limitations

1. **Product Demand, Not Store Choice**: This paper models what households buy (product group expenditure), not where they shop. It does not estimate distance coefficients for store choice. Our model's distance elasticities cannot be borrowed from this paper.

2. **Packaged Goods Only**: Homescan primarily captures packaged goods with UPCs. Bulk produce, meat counter, and bakery items are largely excluded (though a "magnet" subsample of ~8,000 households records these; p.1800). Fresh produce — arguably the most important nutritional differentiator — is underrepresented.

3. **No Online Grocery**: Data is 2004–2016 and does not capture online grocery shopping, which has since grown dramatically (especially post-COVID). The supply-side contribution may be larger now if online access has changed.

4. **National Averages May Not Apply to NYC**: The paper's finding that people travel far to supermarkets (5.2 miles average) reflects a car-dominant national picture. In NYC, where transit is primary and trip distances are shorter, the supply-side constraint may bind more tightly. The 1.5% entry effect may understate the NYC-specific impact.

5. **Entry ≠ Municipal Supermarket**: The 6,721 entries studied are *private sector* entrants that look similar to existing stores. A municipal supermarket with subsidized pricing, curated healthy assortment, and targeted placement could have a qualitatively different effect than a typical private entry.

6. **Health Index Is Not Welfare**: Allcott's Health Index measures nutritional quality. Our model measures consumer surplus from store choice. A supermarket placement could significantly increase consumer surplus (through reduced travel time and competitive effects) even if it barely moves the needle on nutrition.

7. **Endogeneity of Entry**: Supermarket entries are not random — chains enter where they expect profit. The event study with household fixed effects partially addresses this, but the entry effect could still be attenuated if chains enter areas where nutrition is already relatively good.

---

## Key Tables/Figures

| Element | Content | Page |
|---------|---------|------|
| **Table I** | Descriptive statistics: Homescan households + ZIP code establishment counts | p.1801 |
| **Figure I** | Nutrition–income relationship: added sugar, whole grain, produce, Health Index vs. income | p.1804 |
| **Figure II** | Store-level healthfulness by ZIP code median income (RMS data) | p.1806 |
| **Figure III** | Store counts per 1,000 residents by ZIP income: fewer supermarkets, more drug/convenience stores in low-income areas | p.1807 |
| **Table II** | Supermarket entry event study: expenditure share + Health Index effects (Panel A: shares, Panel B: HI) | p.1813 |
| **Figure IV** | Event study graphs: entrant share, grocery/super/club share, Health Index — full sample and food deserts | p.1811 |
| **Table III** | Movers: association of household HI with local area HI (ZIP code and county) | p.1819 |
| **Figure V** | Movers event study: trips in new vs. old county, HI convergence coefficients | p.1818 |
| **Table IV** | Structural preference estimates (β̃_c) for 12 dietary components by income quartile + WTP for max HEI | p.1828 |
| **Figure VI** | Counterfactual decomposition: predicted HI under sequential equalization of supply and demand | p.1832 |
| **Figure VII** | Gelbach decomposition: education (~20%), nutrition knowledge (~14%), and other contributions | p.1836 |
| **Table V** | SNAP subsidy counterfactual: cost to close 0.9%, 9%, and 100% of gap ($84M, $830M, $11B) | p.1837 |
| **Eq. 5** | Utility function: CES within groups, Cobb-Douglas across, linear in characteristics | p.1821 |
| **Eq. 7** | Empirical demand equation (log calories on implicit price) | p.1822 |
| **Eq. 9** | Price instrument construction (chain comparative advantage × geographic presence) | p.1824 |

---

## Notes for Calibration

- **Do NOT cite Allcott for distance/store choice parameters** — this paper does not estimate a store choice model or distance coefficients
- **Use for framing**: The 9% supply / 91% demand decomposition is the strongest justification for why our model focuses on consumer surplus rather than health outcomes
- **Use the 1.5% entry bound** to calibrate realistic expectations for the nutritional impact of placement
- **The $84M–$830M subsidy equivalence** provides a cost-effectiveness benchmark for municipal supermarket proposals
- **Supermarket-to-supermarket diversion** finding is essential for our competitive exit model — expect new entry to primarily cannibalize other supermarkets
- **Pair with Cao (2024)**: Allcott shows placement has bounded nutrition effects; Cao shows distance coefficients are underestimated by OLS. Together they say: placement matters more for consumer surplus (welfare from reduced travel) than for health, and that welfare effect is larger than naive estimates suggest.

---

*Updated: March 19, 2026 — Full 1:1 verification against PDF (pp.1793–1844). Complete rewrite: corrected model specification (was incorrectly described as "CES over categories + logit store choice" — actually CES within groups, Cobb-Douglas across, no store choice model), corrected identification strategy (was "randomized treatment" — actually event studies + novel price IV from chain comparative advantages), corrected time period (2004–2016 not 2004–2006), removed fabricated β_delivery parameter, corrected all table references (were all guessed and mostly wrong), added full economic detail: Table IV WTP estimates, Figure VI decomposition mechanics, Table V subsidy counterfactuals, movers analysis bounds, NHTS travel statistics.*
