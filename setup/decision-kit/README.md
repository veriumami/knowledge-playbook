# Decision kit - choosing a CUDA focus area

A small, reusable way to pick *where to point deep expertise* without guessing. Built
for the question "which CUDA optimization area should I work on," but the shape works for
any "N good options, which one" call.

The order matters. Agents launched with no context return four generic literature
reviews. So: **capture the person's context first, then brief the agents with it**, then
score, then let real data break the tie.

## How to run it

1. **Fill `INTAKE.md`.** Ten minutes. These are the private inputs (goal, hardware, how
   low-level, which DSP subdomain) that actually swing the answer. Nothing here is
   guessable from outside.
2. **Open Claude Code in the vault and paste `SPAWN-AGENTS.md`.** It launches four
   read-only, no-inference research agents, one per option, each briefed with the intake.
   Each returns: the concrete gap, difficulty, existing tools, a first "hello-world"
   target, and expected payoff, with sources.
3. **Score with `RUBRIC.md`.** Weight the agents' findings by the intake. Optionally run
   `/council-simulation` over the top two to stress-test the call.
4. **Break the tie with data.** Pick one real workload, profile it (Nsight Systems +
   Compute, roofline), and confirm the bottleneck actually lives where the chosen option
   operates. Do not skip this: it is the no-inference move applied to the decision itself.

## The four options being weighed

- **A - Fusion at the seams.** Custom kernels that fuse a DSP pipeline the libraries
  leave as separate calls (pulse compression, beamforming, polyphase filterbanks, STAP),
  killing the global-memory round-trips between stages.
- **B - Small / batched / structured transforms.** The regime the big libraries
  under-serve: small or odd-size FFTs/GEMMs, batched tiny problems, Toeplitz/Hankel
  structure, real-valued transforms.
- **C - Memory / workspace + precision, embedded/real-time.** Workspace/scratch
  reduction, in-place transforms, out-of-core streaming, precision reduction, and
  latency-deterministic behavior on Jetson / embedded aerospace targets.
- **D - Open-source GPU-DSP libraries.** Extend or optimize an OSS library where the bar
  is lower than NVIDIA's closed libs and gaps are real (cuSignal/RAPIDS; VkFFT as the
  proof one focused expert can rival cuFFT).

## To use it for dad

Copy this `decision-kit/` folder into his vault (e.g. `~/Documents/Knowledge/cuda/`),
have him fill `INTAKE.md`, then run step 2 there so the auto-logger records the whole
decision as it happens.
