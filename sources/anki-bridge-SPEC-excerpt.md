# Anki ↔ Knowledge Bridge — Specification

> Hand this to Claude Code. The bridge connects Noah's Anki desktop deck
> (~2,700 notes, ~5,300 cards across 70 HSK 1–3 decks) to the
> methodology vault at `~/Documents/Knowledge/Chinese/` so that cowork
> tutoring sessions can read what's due and push field updates / new
> notes / tags back into Anki.
>
> Build target: production-ready Mac install with two scheduled
> launchd jobs (morning pull + evening push), Python 3.11+ standard
> library only (no PyPI deps).

---

## 1. Why this exists

Cowork bash runs in a sandbox VM — it cannot reach `localhost:8765` on
the user's Mac. So the Knowledge folder is the **message bus** between
the two environments:

```
┌────────────────┐  AnkiConnect      ┌─────────────────────┐  files     ┌──────────────┐
│  Anki Desktop  │ ───────────────►  │  anki_bridge.py     │ ─────────► │   Cowork     │
│  + AnkiConnect │ ◄───────────────  │  (this codebase)    │ ◄───────── │   (chat)     │
└────────────────┘  HTTP/JSON        └─────────────────────┘            └──────────────┘
                                       writes inbox.md
                                       reads outbox.md
```

The bridge runs **only on Noah's Mac**, talks to AnkiConnect, and
read/writes markdown files in the shared Knowledge folder. Cowork only
ever touches those files.

---

## 2. Prerequisites

### On Noah's Mac (one-time)

1. **Anki desktop** installed and signed in to his AnkiWeb account.
2. **AnkiConnect** addon installed:
   - Anki → Tools → Add-ons → Get Add-ons → code `2055492159`
   - Restart Anki. By default it listens on `http://127.0.0.1:8765`.
3. **Python 3.11+** available as `/usr/bin/python3` or `python3` on
   PATH. (No `pip install` needed — stdlib only.)
4. **Anki must be running** for the bridge to work. The launchd jobs
   are a noop when Anki is closed (graceful fail, logged).

### One-time Anki schema change (manual)

The current note type `HSK Chinese++` has fields:

    Chinese | Pinyin | English | ChineseAudio | Etymology | ExampleSentence | PatternName

Add one field:

- **Tools → Manage Note Types → `HSK Chinese++` → Fields → Add → `PersonalSentence`**

Rationale: ExampleSentence is already 84.5% filled with curated content
— don't overwrite it. Personal interview-prep sentences (the ones Noah
