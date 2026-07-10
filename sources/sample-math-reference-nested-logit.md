# Mathematical Reference: Nested Logit Welfare Analysis

> **Project**: NYC Municipal Supermarket Siting (RISE Grant)
> **Author**: Noah H. Kim, Columbia University
> **Compiled**: 2026-03-20
> **Verification**: Every equation pulled directly from source PDFs per Literature Verification Protocol v2.5.
> **Sources**: Small & Rosen (1981), Train (2009) Chapters 3–4

---

## 1. Notation Concordance

Our project uses σ for the nest dissimilarity parameter. Train (2009) uses λ_k. Small & Rosen (1981) use λ for marginal utility of income. To avoid confusion:

| Symbol (ours) | Symbol (Train) | Symbol (Small & Rosen) | Meaning |
|---|---|---|---|
| σ | λ_k | — | Nest dissimilarity parameter (0 < σ < 1) |
| β_d | — | — | Coefficient on log-travel-time |
| α_n | — | λ | Marginal utility of income = \|β_d\| |
| V_j | V_nj | W_j | Representative (systematic) utility of alternative j |
| IV_m | I_nk | — | Inclusive value (log-sum) for nest m |

**Critical**: Train's λ_k is our σ. Small & Rosen's λ is our α_n = |β_d|. These are completely different quantities.

---

## 2. Logit Foundations

**Source**: Train (2009) Ch3, pp. 34–57.

### 2.1 Random Utility Setup

Decision maker n faces J alternatives. Utility from alternative j:

```
U_nj = V_nj + ε_nj    ∀j
```

where V_nj is observed (representative) utility and ε_nj is unobserved. ε_nj are iid extreme value (Gumbel Type I).

**Extreme value density** (Train eq 3.1, p. 34):
```
f(ε_nj) = e^{-ε_nj} · e^{-e^{-ε_nj}}
```

**CDF** (Train eq 3.2, p. 34):
```
F(ε_nj) = e^{-e^{-ε_nj}}
```

Variance = π²/6. This normalizes the scale of utility.

### 2.2 Logit Choice Probability

**The logit formula** (Train eq 3.6, p. 36):
```
P_ni = e^{V_ni} / Σ_j e^{V_nj}
```

Derived by integrating (Train eq 3.5):
```
P_ni = ∫ (∏_{j≠i} e^{-e^{-(ε_ni + V_ni - V_nj)}}) · e^{-ε_ni} · e^{-e^{-ε_ni}} dε_ni
```

### 2.3 Scale Parameter

When unobserved utility has variance σ²·(π²/6), dividing through by σ yields (Train p. 40):
```
P_ni = e^{V_ni/σ} / Σ_j e^{V_nj/σ}
```

Only β*/σ is estimable, not β* and σ separately. Conventionally β = β*/σ.

### 2.4 Logit Consumer Surplus (Log-Sum)

**Source**: Train (2009) §3.5, p. 55; originally derived in Williams (1977) and Small & Rosen (1981).

**Expected consumer surplus** (Train eq 3.10, p. 55):
```
E(CS_n) = (1/α_n) · ln(Σ_{j=1}^{J} e^{V_nj}) + C
```

where:
- α_n = marginal utility of income = |coefficient of cost/price variable|
- C = unknown constant (cancels in differences)
- The term `ln(Σ_j e^{V_nj})` is the **log-sum term** (= log of denominator of logit probability)

**Change in consumer surplus** (Train p. 56):
```
ΔE(CS_n) = (1/α_n) · [ln(Σ_{j=1}^{J¹} e^{V¹_nj}) - ln(Σ_{j=1}^{J⁰} e^{V⁰_nj})]
```

Superscripts 0, 1 = before/after policy change. J can change (new alternatives can be added).

**Key assumption**: α_n is constant (independent of income). If violated, formula remains usable for small changes relative to income (Train p. 57).

### 2.5 Derivation from Small & Rosen

**Source**: Small & Rosen (1981), NBER WP 319, §V, pp. 29–34.

The conditional indirect utility is additively separable (Small & Rosen eq 5.1, p. 29):
```
ṽ_j^i(p_j, q_j, y^i) = v^i(y^i) + W_j(p_j, q_j, y^i, s^i) + ε_j^i
```

The general welfare formula for any discrete choice model (Small & Rosen eq 5.5, p. 31):
```
(ΔE)/N = -(1/λ) · ∫_{W_1°}^{W_1^f} π_1(W_1, W_2) dW_1
```

where λ = ∂v/∂y = marginal utility of income (our α_n).

For **logit** specifically, ε_j are iid extreme value, and (5.5) evaluates in closed form. The logit probabilities are (Small & Rosen eq 5.8, p. 34):
```
π_ℓ = exp(W_ℓ) / Σ_{j=1}^{2} exp(W_j),  ℓ = 1,2
```

**THE LOGIT CONSUMER SURPLUS FORMULA** (Small & Rosen eq 5.9, p. 34):
```
(ΔE)/N = -(1/λ) · [ln Σ_j exp(W_j)]|_{W°}^{W^f}
```

This is equivalent to Train's (3.10) applied as a difference. The square brackets denote evaluation at initial vs final values of systematic utility.

Small & Rosen footnote 23 (p. 34): the term `ln Σ_j exp(W_j)` has been called the "inclusive price" or "composite cost" in the transportation literature (Ben-Akiva 1973; Williams 1977).

---

## 3. Nested Logit

**Source**: Train (2009) Ch4, pp. 76–96.

### 3.1 Structure

J alternatives partitioned into K nests B_1, ..., B_K. Within each nest, the unobserved utility components are correlated. The correlation is captured by a dissimilarity parameter λ_k (our σ) for each nest.

Utility decomposition (Train §4.2, p. 80):
```
U_nj = W_nk + Y_nj + ε_nj
```
where W_nk depends only on nest-level variables, Y_nj depends on alternative-level variables within nest k, and ε_nj has a distribution that generates correlation within nests.

### 3.2 Choice Probability

**Nested logit probability** (Train eq 4.2, p. 80):
```
P_ni = [e^{V_ni/λ_k} · (Σ_{j∈B_k} e^{V_nj/λ_k})^{λ_k - 1}] / [Σ_{ℓ=1}^{K} (Σ_{j∈B_ℓ} e^{V_nj/λ_ℓ})^{λ_ℓ}]
```

In our notation (σ = λ_k, uniform across nests):
```
P_ni = [e^{V_ni/σ} · (Σ_{j∈B_k} e^{V_nj/σ})^{σ - 1}] / [Σ_{ℓ=1}^{K} (Σ_{j∈B_ℓ} e^{V_nj/σ})^{σ}]
```

### 3.3 Two-Logit Decomposition

The nested logit probability factors into (Train eq 4.3, p. 82):
```
P_ni = P_{ni|B_k} · P_{nB_k}
```

**Marginal probability** (of choosing nest k) (Train eq 4.4, p. 82):
```
P_{nB_k} = e^{W_nk + λ_k · I_nk} / Σ_ℓ e^{W_nℓ + λ_ℓ · I_nℓ}
```

**Conditional probability** (within nest k) (Train eq 4.5, p. 82):
```
P_{ni|B_k} = e^{Y_ni/λ_k} / Σ_{j∈B_k} e^{Y_nj/λ_k}
```

This is a standard logit among alternatives within nest k, but with utility scaled by 1/λ_k. Note: Train uses Y_ni (within-nest component) here; in our model W_nk = 0, so V_nj = Y_nj.

where the **inclusive value** (IV) for nest k is (Train p. 82):
```
I_nk = ln Σ_{j∈B_k} e^{Y_nj/λ_k}
```

I_nk is often called the "inclusive value" or "inclusive utility" or "log-sum term" (Train p. 83). The coefficient λ_k of I_nk in the upper model is called the log-sum coefficient.

In our notation (with no nest-level W variables, so W_nk = 0 and V_nj = Y_nj):
```
IV_m = ln Σ_{j∈m} e^{V_j/σ}
P_{nest m} = e^{σ · IV_m} / Σ_ℓ e^{σ · IV_ℓ}
```

### 3.4 Interpretation of λ_k (our σ)

- λ_k = 1 → no within-nest correlation → flat (standard) MNL
- 0 < λ_k < 1 → positive within-nest correlation → nested logit
- λ_k = 0 → perfect correlation → all alternatives in nest are identical
- λ_k > 1 or λ_k < 0 → inconsistent with utility maximization (for all explanatory variable values)

**Our model**: σ = 0.50 (uniform across all three nests), indicating moderate within-nest correlation.

### 3.5 IIA Properties of Nested Logit

From Train §4.3 (p. 88), three levels of IIA:
1. **Within-nest, same substitution pattern**: ratio of probabilities of two alternatives in the same nest is independent of all other alternatives (standard IIA within nests)
2. **Within-nest, different substitution**: alternatives in the same nest but different subnests (for 3-level) substitute differently than alternatives in different nests
3. **Cross-nest**: ratio of probabilities of alternatives in *different* nests depends on characteristics of all alternatives in those nests but NOT on alternatives in other nests

---

## 4. GEV Welfare Theory (The Core Result)

**Source**: McFadden (1978); Train (2009) §4.6, pp. 93–95 (GEV generator and nested logit derivation). Note: Train §4.6 derives choice probabilities from G but does not explicitly state SS = ln(G). The welfare result SS = ln(G) is from McFadden (1978) and follows from combining Train §3.5 (logit CS = log of denominator) with the GEV framework.

### 4.1 GEV Generator

McFadden (1978) showed that any function G(Y_1, ..., Y_J) where Y_j ≡ exp(V_j) satisfying four properties generates a discrete choice model consistent with utility maximization (Train eq 4.8, p. 93):
```
P_i = Y_i · G_i / G     where G_i = ∂G/∂Y_i
```

The four properties of G (Train p. 93):
1. G ≥ 0 for all positive Y_j
2. G is homogeneous of degree one: G(ρY_1, ..., ρY_J) = ρ·G(Y_1, ..., Y_J)
3. G → ∞ as Y_j → ∞ for any j
4. Cross partial derivatives alternate in sign: G_i ≥ 0, G_ij ≤ 0, G_ijk ≥ 0, ...

### 4.2 Standard Logit as GEV

G = Σ_{j=1}^J Y_j. Then G_i = 1, and P_i = Y_i/G = e^{V_i}/Σ_j e^{V_j} — the logit formula. (Train p. 94)

### 4.3 Nested Logit as GEV

**The GEV generator for nested logit** (Train p. 94):
```
G = Σ_{ℓ=1}^{K} (Σ_{j∈B_ℓ} Y_j^{1/λ_ℓ})^{λ_ℓ}
```

In our notation:
```
G = Σ_{m=1}^{M} (Σ_{j∈m} exp(V_j/σ))^{σ}
```

Train verifies this satisfies all four GEV properties (pp. 94–95) and shows P_i = Y_i·G_i/G reduces to the nested logit formula (4.2).

### 4.4 Social Surplus and the Nested Logit Welfare Formula

**This is the key derivation for our project.**

From GEV theory, social surplus = ln(G) (up to a constant), converted to dollars by dividing by the marginal utility of income α_n.

For **standard logit**: SS = ln(Σ_j exp(V_j)), giving the Small & Rosen (1981) result.

For **nested logit**:
```
SS = ln(G) = ln[Σ_{m=1}^{M} (Σ_{j∈m} exp(V_j/σ))^{σ}]
```

Using the definition IV_m = ln Σ_{j∈m} exp(V_j/σ), we have:
```
(Σ_{j∈m} exp(V_j/σ))^{σ} = exp(σ · IV_m)
```

Therefore:

> **THE NESTED LOGIT WELFARE FORMULA**:
> ```
> W = (1/|β_d|) · ln[Σ_m exp(σ · IV_m)]
> ```
> where:
> - |β_d| = marginal utility of income (our α_n)
> - σ = nest dissimilarity parameter (Train's λ_k). Our model: σ = 0.50
> - IV_m = ln Σ_{j∈m} exp(V_j/σ) = inclusive value for nest m
> - The sum is over all M nests (our model: Chain, Supermarket, Small/Bodega)

**Change in welfare** from adding a new store:
```
ΔW = (1/|β_d|) · [ln(Σ_m exp(σ · IV_m^after)) - ln(Σ_m exp(σ · IV_m^before))]
```

**Derivation chain**: McFadden (1978) GEV Theorem → Social surplus = ln(G) → Train (2009) §4.6 nested logit G → Small & Rosen (1981) eq 5.9 for monetary conversion.

### 4.5 CRITICAL WARNING: Common Error

The formula `W = (1/|β_d|) · σ · ln(Σ_m exp(IV_m))` is **WRONG**.

The correct formula is `W = (1/|β_d|) · ln(Σ_m exp(σ · IV_m))`.

The σ multiplies each IV_m **inside** the exponential, not outside the logarithm. These two expressions are algebraically different when σ ≠ 1. They coincide only when σ = 1 (flat MNL), which is why the error can go undetected if only tested against flat logit.

**Verification**: At σ = 1, both reduce to `(1/|β_d|) · ln(Σ_m exp(IV_m))`. At σ = 0.5 with two nests having IV values of 2.0 and 3.0:
- Wrong: (1/|β_d|) · 0.5 · ln(exp(2) + exp(3)) = (1/|β_d|) · 0.5 · 3.3133 = (1/|β_d|) · 1.6566
- Correct: (1/|β_d|) · ln(exp(0.5·2) + exp(0.5·3)) = (1/|β_d|) · ln(exp(1) + exp(1.5)) = (1/|β_d|) · 1.9741

---

## 5. The Incremental Nested Logsum Trick

**Context**: When siting a new store, only one nest (Supermarket) is affected. We don't need to recompute all IVs from scratch.

### 5.1 Mathematical Derivation

Let the three nests be Chain (c), Supermarket (s), and Small/Bodega (b). Before adding a new store:
```
W_before = (1/|β_d|) · ln[exp(σ·IV_c) + exp(σ·IV_s) + exp(σ·IV_b)]
```

When we add a new store to the Supermarket nest with systematic utility V_new:
```
IV_s^new = ln[Σ_{j∈super} exp(V_j/σ) + exp(V_new/σ)]
         = ln[exp(IV_s^old) + exp(V_new/σ)]
```

This uses the identity: if IV_s = ln(Σ exp(V_j/σ)), then Σ exp(V_j/σ) = exp(IV_s), so adding one more term gives ln(exp(IV_s) + exp(V_new/σ)).

The new welfare is then:
```
W_after = (1/|β_d|) · ln[exp(σ·IV_c) + exp(σ·IV_s^new) + exp(σ·IV_b)]
```

**The welfare gain from the new store**:
```
ΔW = W_after - W_before
   = (1/|β_d|) · ln{ [exp(σ·IV_c) + exp(σ·IV_s^new) + exp(σ·IV_b)]
                     / [exp(σ·IV_c) + exp(σ·IV_s^old) + exp(σ·IV_b)] }
```

### 5.2 Why This Is Exact

This is NOT an approximation. It is algebraically identical to recomputing the full nested logsum from scratch. The only difference is computational efficiency: we update one nest's IV rather than recomputing all J alternatives' contributions.

**Proof**: Let S_old = Σ_{j∈super} exp(V_j/σ). Then IV_s^old = ln(S_old). After adding the new store: S_new = S_old + exp(V_new/σ), so IV_s^new = ln(S_new). The full formula with all alternatives gives the same result as our incremental formula because the Chain and Bodega nests are unchanged — their contributions factor out identically.

### 5.3 Computational Benefit

For greedy placement of K=5 stores across ~180 candidate locations, each candidate evaluation requires computing the welfare change. With the trick: update 1 nest IV (one log-sum-exp operation) instead of recomputing across all ~1,400+ stores. This is O(1) per candidate instead of O(J).

---

## 6. Our Model Specification

**Source**: PROJECT_REFERENCE v2.8, §3.2–3.3.

### 6.1 Utility Function

For individual in ZIP z choosing store j in format tier m:
```
V_zj = α_m + β_d · ln(t_zj + 1) + β_d_income · ln(t_zj + 1) · income_z
       + β_ebt · snap_z · ebt_j + β_del · inet_z · delivery_j
```

### 6.2 Parameters

| Parameter | Value | Source |
|---|---|---|
| β_d | CALIBRATED | step0b nested logit calibration |
| γ₁ (β_d_income) | Fixed = 0 | Dropped in v2.8 |
| γ₂ (β_ebt) | CALIBRATED | step0b |
| β_del | Fixed = 0.10 | Literature (Brinkman et al.) |
| α_chain | CALIBRATED | step0b |
| α_super | Fixed = 0.00 | Reference tier |
| α_bodega | CALIBRATED | step0b |
| σ | Fixed = 0.50 | Nest dissimilarity |

### 6.3 Nest Structure (Format Tiers)

| Tier | Formats |
|---|---|
| Chain | Trader Joe's, Whole Foods, large chain supermarkets |
| Supermarket | Independent supermarkets, medium grocers (NEW MUNICIPAL STORES GO HERE) |
| Small/Bodega | Bodegas, small grocers, convenience stores |

### 6.4 Welfare Computation

Per-capita welfare for individual in ZIP z:
```
W_z = (1/|β_d|) · ln[exp(σ · IV_chain,z) + exp(σ · IV_super,z) + exp(σ · IV_bodega,z)]
```

where:
```
IV_m,z = ln Σ_{j∈m} exp(V_zj / σ)
```

Aggregate welfare = Σ_z pop_z · W_z, weighted by ZIP population.

---

## 7. Empirical Bootstrap for Monte Carlo

Rather than assuming calibrated parameters follow Normal distributions, we resample from the 500 bootstrap parameter vectors produced by step0c. This:
- Respects parameter correlations (joint distribution)
- Handles non-normality (skewness, heavy tails)
- Uses the actual sampling distribution from our data

Each MC draw: sample one bootstrap vector with replacement → compute utilities → compute welfare → record.

---

## 8. Citation Chain (for RD)

The welfare formula we use derives from a well-established chain:

1. **McFadden (1978)**: Proved the GEV theorem — any function G satisfying four conditions generates a discrete choice model consistent with utility maximization. Social surplus = ln(G).
2. **Small & Rosen (1981)**: Showed that compensating variation for discrete choice = -(1/λ) × change in log-sum, where λ = marginal utility of income. Proved this for logit (eq 5.9) using the closed-form integral of the logit probability function.
3. **Train (2009) §3.5**: Presented the logit consumer surplus as E(CS) = (1/α_n) · ln(Σ exp(V_nj)) + C (eq 3.10).
4. **Train (2009) §4.6**: Extended to nested logit via the GEV generator G = Σ_ℓ (Σ_{j∈B_ℓ} Y_j^{1/λ_ℓ})^{λ_ℓ}. Social surplus = ln(G) = ln[Σ_m exp(σ·IV_m)].

**Our formula**: W = (1/|β_d|) · ln[Σ_m exp(σ·IV_m)], directly from this chain.

---

## 9. Source Inventory

### Small & Rosen (1981)
- **Full citation**: Small, Kenneth A. and Harvey S. Rosen. "Applied Welfare Economics with Discrete Choice Models." NBER Working Paper No. 319, February 1979. Published in Econometrica, 1981.
- **Tables**: Table 3.1 only (Factors for Computing Excess Burdens, p. 24)
- **Figures**: None
- **Key equations for our project**: (5.1) utility decomposition, (5.5) general welfare formula, (5.8) logit probability, **(5.9) logit consumer surplus**
- **Paper presents**: Formal theorem (Theorem 1, p. 12) proving CV = area under compensated demand even with discrete choice; Theorem 2 (p. 28) extending to quality changes; Section V applying to logit and probit.

### Train (2009) Chapter 3
- **Full citation**: Train, Kenneth E. *Discrete Choice Methods with Simulation*. 2nd ed. Cambridge University Press, 2009. Chapter 3: Logit, pp. 34–75.
- **Tables**: None in relevant sections
- **Figures**: Figure 3.1 (sigmoid logit curve, p. 38)
- **Key equations for our project**: (3.1)–(3.2) extreme value distribution, **(3.6) logit formula**, **(3.10) logit consumer surplus**

### Train (2009) Chapter 4
- **Full citation**: Train, Kenneth E. *Discrete Choice Methods with Simulation*. 2nd ed. Cambridge University Press, 2009. Chapter 4: GEV, pp. 76–96.
- **Tables**: None
- **Figures**: Figure 4.1 (two-level nested logit tree, p. 79), Figure 4.2 (three-level nested logit tree, p. 87)
- **Key equations for our project**: **(4.2) nested logit probability**, (4.3)–(4.5) two-logit decomposition, **(4.8) GEV choice probability P_i = Y_i·G_i/G**, **GEV generator for nested logit (p. 94)**
