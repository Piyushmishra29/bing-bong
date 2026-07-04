#!/usr/bin/env bash
# bing-bong installer — chime when Claude Code finishes a prompt.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOUNDS_DIR="$HOME/.claude/sounds"
SETTINGS="$HOME/.claude/settings.json"
PLAYER="$SOUNDS_DIR/bing-bong"
WAV="$SOUNDS_DIR/seatbelt-chime.wav"

echo "bing-bong ✈️  installing…"

# 1. sound file
mkdir -p "$SOUNDS_DIR"
cp "$REPO_DIR/sounds/seatbelt-chime.wav" "$WAV"

# 2. player script (auto-detects available audio player)
cat > "$PLAYER" <<'EOF'
#!/usr/bin/env bash
# bing-bong player — plays the chime with whatever audio player exists.
WAV="$HOME/.claude/sounds/seatbelt-chime.wav"
[ -f "$WAV" ] || exit 0
if command -v pw-play >/dev/null 2>&1; then exec pw-play "$WAV" >/dev/null 2>&1
elif command -v paplay >/dev/null 2>&1; then exec paplay "$WAV" >/dev/null 2>&1
elif command -v afplay >/dev/null 2>&1; then exec afplay "$WAV" >/dev/null 2>&1
elif command -v aplay >/dev/null 2>&1; then exec aplay -q "$WAV" >/dev/null 2>&1
elif command -v ffplay >/dev/null 2>&1; then exec ffplay -nodisp -autoexit -loglevel quiet "$WAV" >/dev/null 2>&1
fi
exit 0
EOF
chmod +x "$PLAYER"

# 3. register the Stop hook (idempotent; upgrades older chime hooks)
python3 - "$SETTINGS" "$PLAYER" <<'EOF'
import json, os, sys

settings_path, player = sys.argv[1], sys.argv[2]
hook_cmd = player + " &"

data = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        data = json.load(f)

hooks = data.setdefault("hooks", {})
stop = hooks.setdefault("Stop", [])

# drop any previous bing-bong / seatbelt-chime hooks (upgrade path)
for group in stop:
    group["hooks"] = [
        h for h in group.get("hooks", [])
        if not ("seatbelt-chime" in h.get("command", "")
                or "bing-bong" in h.get("command", ""))
    ]
stop[:] = [g for g in stop if g.get("hooks")]

stop.append({"hooks": [{"type": "command", "command": hook_cmd}]})

os.makedirs(os.path.dirname(settings_path), exist_ok=True)
with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print(f"hook registered in {settings_path}")
EOF

# 4. test flight
echo "test flight:"
"$PLAYER" || true
echo "installed. bing… bong. you are now free to move about the cabin. 🛬"
