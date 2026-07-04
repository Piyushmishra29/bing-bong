# bing-bong ✈️

> *bing… bong.* Your prompt has landed. You are now free to move about the cabin.

**bing-bong** plays the airline seatbelt-sign chime every time Claude Code finishes
responding — so you can alt-tab away, and your ears tell you when it's done.

The chime is a warm two-tone descending "bing-bong" (660 Hz → 520 Hz), synthesized
from scratch in [`make_chime.py`](make_chime.py). No copyrighted airline audio,
just math that sounds like a Boeing.

## Install

```bash
git clone https://github.com/Piyushmishra29/bing-bong.git
cd bing-bong
./install.sh
```

That's it. The installer:

1. copies the chime to `~/.claude/sounds/`
2. drops a tiny player script (`~/.claude/sounds/bing-bong`) that auto-detects
   your audio player — PipeWire (`pw-play`), PulseAudio (`paplay`), ALSA
   (`aplay`), macOS (`afplay`), or `ffplay` as a last resort
3. registers a **Stop hook** in `~/.claude/settings.json` so the chime fires
   whenever Claude Code finishes a turn
4. plays it once so you know it worked

Idempotent — safe to re-run. It also upgrades any older hard-coded chime hook
to the portable player script.

## Uninstall

```bash
./uninstall.sh          # removes the hook, keeps the sound files
./uninstall.sh --purge  # removes everything
```

## Bring your own sound

Any 16-bit WAV works. Replace `~/.claude/sounds/seatbelt-chime.wav` with your
own file and keep the name — or edit the hook in `~/.claude/settings.json` to
point somewhere else.

Want to tweak the chime itself? Edit the frequencies/decay in `make_chime.py`
and regenerate:

```bash
python3 make_chime.py
./install.sh
```

## How it works

Claude Code runs [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks)
at lifecycle events. `Stop` fires when the agent finishes responding. The hook
is one line:

```json
{ "hooks": { "Stop": [ { "hooks": [ { "type": "command",
  "command": "$HOME/.claude/sounds/bing-bong &" } ] } ] } }
```

The player script backgrounds itself and swallows all output, so it can never
slow down or break a session — worst case on a machine with no audio player,
it exits silently.

---

*Cabin crew, doors to manual and cross-check.* 🛬
