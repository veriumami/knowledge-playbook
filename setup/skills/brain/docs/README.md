# brain skill — quickstart

## Install (assumes you have a vault at `~/Documents/Knowledge/`)

```bash
chmod +x ~/.claude/skills/brain/scripts/*.sh
chmod +x ~/.claude/skills/brain/scripts/lib/*.sh
chmod +x ~/.claude/skills/brain/hooks/*.sh
```

If you don't have a vault yet, run `/brain init` (v1.5).

## Wire the SessionEnd hook (optional but recommended)

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/skills/brain/hooks/session_end_hook.sh"
          }
        ]
      }
    ]
  }
}
```

Note: we use `SessionEnd` (fires once per session) not `Stop` (fires
per turn — too noisy).

To disable temporarily without removing config: `export BRAIN_HOOK_ENABLED=0`.

## First commands

- `/brain` — see the heat-map (one bucket per tracked repo)
- `/brain repo <name>` — see the rendered pulse + live git state
- `/brain query "<topic>"` — search vault
- `/brain note "<text>" --domain <name>` — capture an explanation
- `/brain log <repo> attempt "<text>"` — manual log entry
- `/brain checkpoint review` — see SessionEnd captures awaiting approval

## Architecture

See [`architecture.md`](./architecture.md) for the full design
(auto-capture flow, bubble-up mechanics, brain-as-data-layer
interface, v1/v2/v3 phasing).

## Customization

See [`customization.md`](./customization.md) for extending the skill.

## Integration

See [`integration.md`](./integration.md) for how other skills can
consume the brain.
