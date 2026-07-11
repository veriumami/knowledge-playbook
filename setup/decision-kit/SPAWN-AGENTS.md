# Spawn the research agents (paste into Claude Code, in the vault)

Prerequisite: `INTAKE.md` in this folder is filled in. This prompt briefs four read-only
agents with those answers so they research *your* situation, not CUDA in general.

---

Read `INTAKE.md` in this folder. Then spawn **four parallel read-only agents**
(general-purpose), one per option below. Give every agent this shared brief:

> READ-ONLY, no-inference. Do not modify anything. Follow `NO-INFERENCE.md`: every claim
> needs a citable source (link or doc); if you cannot verify, say NOT VERIFIED. No
> em-dashes. You are advising an engineer whose intake is: {paste the filled INTAKE
> answers}. Assess THIS option against that intake, not the general case.

Return from each agent, in ~250-400 words:
1. **The concrete gap** this option targets, and whether it is real given the intake's
   hardware/subdomain (cite: benchmarks, library docs, issue trackers, papers).
2. **Difficulty** for this person (skills required vs the intake's low-level appetite).
3. **Existing tools / prior art** to build on or extend (name them, with links).
4. **A first "hello-world" target** they could finish in ~1-2 weeks.
5. **Expected payoff** and how it would be measured (roofline / speedup / memory saved /
   merged PR).
6. **Honest risks** and the fastest way this option disappoints.

The four options (one agent each):
- **A - Fusion at the seams**: fused kernels for a DSP pipeline (pulse compression,
  beamforming, polyphase filterbanks, STAP) that libraries leave as separate calls.
- **B - Small / batched / structured transforms**: small/odd-size or batched FFT/GEMM,
  Toeplitz/Hankel structure, real-valued transforms.
- **C - Memory / workspace + precision, embedded/real-time**: workspace reduction,
  in-place transforms, out-of-core streaming, precision reduction, Jetson/latency.
- **D - Open-source GPU-DSP libraries**: extend/optimize an OSS lib (cuSignal/RAPIDS,
  VkFFT, CuPy custom kernels) where gaps are documented.

After the agents return: I will verify their key claims against the cited sources before
trusting them, then score all four with `RUBRIC.md` and recommend one, plus the single
profiling probe that would confirm or kill the choice.
