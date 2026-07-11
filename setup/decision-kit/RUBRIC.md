# Rubric - scoring the options

Score each option 1-5 on every dimension, multiply by the weight, sum. The weights
encode "maximize efficiency for this person," so adjust them from the intake before
scoring (a "learn" goal weights Feedback-loop and Fit up; an "impact" goal weights
Impact and Load-bearing up).

| Dimension | What it measures | Default weight |
|---|---|---|
| **Fit** | Match to the intake's DSP expertise + preferred abstraction level | 3 |
| **Impact** | Size of the real-world win if it works | 2 |
| **Load-bearing** | How many downstream uses depend on this being faster | 2 |
| **Tractability** | Can a first result land in 1-2 weeks with current tools | 3 |
| **Feedback speed** | How fast profile-tweak-reprofile loops are | 2 |
| **Learning value** | How much durable CUDA skill it builds | weight by goal |
| **Durability** | Does the win survive the next GPU generation | 1 |

Score = Σ (rating × weight). Rank the options; keep the top two.

## Then, before committing

- Run `/council-simulation` on the top two if they are close: name the strongest case for
  each and the strongest objection.
- **Empirical tiebreak (required):** take the intake's canary workload (question 8),
  profile it with Nsight Systems + Compute, and place it on a roofline. Confirm the
  bottleneck (memory-bound vs compute-bound) is the one the chosen option attacks. If the
  data disagrees with the score, the data wins - re-pick.

The output is one chosen option, a one-line reason, and the first target from
`SPAWN-AGENTS.md` step 4.
