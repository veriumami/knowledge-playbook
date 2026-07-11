# How other skills consume the brain

The brain is a **data layer**. Other Claude Code skills can read from
it without depending on each other.

## Read interfaces

### 1. Bash subprocess (recommended for skill scripts)

```bash
# Find matches as JSON
matches=$(bash ~/.claude/skills/brain/scripts/brain.sh query --json "anti-bot")
echo "$matches" | jq '.matches[].path'

# Get repo pulse (with git state)
bash ~/.claude/skills/brain/scripts/brain.sh repo tinytreads
```

### 2. Direct file Read (for Claude session reasoning)

When Claude is reasoning in a session and needs context, it can Read
vault files directly:

```
Read ~/Documents/Knowledge/repos/<repo>/pulse.md
Read ~/Documents/Knowledge/anti-bot/google-signed-chrome-profile.md
```

### 3. Pointer in `~/.claude/CLAUDE.md`

Add a single line so any Claude session knows where the brain lives:

```
Brain (cross-project second brain): ~/Documents/Knowledge/
```

When the user asks "what's the pattern for X", Claude greps the vault
directly without needing to invoke the skill.

## Skills that should consume

| Skill | What it reads | Why |
|---|---|---|
| `project-progress` | `repos/<repo>/plan.yaml` | Hour-weighted progress bars |
| `council-simulation` | `decisions/`, `councils/` (phase 2) | Prior deliberations as substrate |
| `debugging-council` | recent `attempts.md` for prior fixes | Don't re-derive solved problems |
| `agent-watchdog` | `agents/` for stall-recovery patterns | Pattern-based recovery decisions |

## Read-only contract

Other skills should **NEVER** write to the brain. Brain manages its own
writes via `/brain note`, `/brain log`, `/brain commit-checkpoint`.

If another skill needs to record something, it should call `/brain
note` or `/brain log` as a subprocess:

```bash
bash ~/.claude/skills/brain/scripts/brain.sh note \
  "council deliberation: chose Option C-plus for brain architecture" \
  --domain decisions
```

## Privacy boundary

The brain never exposes secrets in markdown (env-files-by-path-only,
token-stripping in extractors). Skills that consume the brain inherit
this contract — if a skill ingests something from a repo and writes
back to the brain, it must strip token-shaped strings first.

## Adding new consumer skills

Pattern:

1. Skill's own `SKILL.md` notes "consumes from brain at $BRAIN_VAULT"
2. Skill scripts use the bash subprocess interface above
3. If frequency is high, cache results — don't re-grep the vault on
   every operation
4. Document the consumer relationship in this file

The brain doesn't know about consumer skills. Consumers know to look
at the brain. **One-way dependency** — clean.
