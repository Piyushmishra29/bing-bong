#!/usr/bin/env bash
# bing-bong uninstaller. --purge also removes the sound files.
set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
SOUNDS_DIR="$HOME/.claude/sounds"

python3 - "$SETTINGS" <<'EOF'
import json, os, sys

settings_path = sys.argv[1]
if not os.path.exists(settings_path):
    print("no settings file, nothing to do")
    sys.exit(0)

with open(settings_path) as f:
    data = json.load(f)

stop = data.get("hooks", {}).get("Stop", [])
for group in stop:
    group["hooks"] = [
        h for h in group.get("hooks", [])
        if not ("seatbelt-chime" in h.get("command", "")
                or "bing-bong" in h.get("command", ""))
    ]
stop[:] = [g for g in stop if g.get("hooks")]
if not stop and "Stop" in data.get("hooks", {}):
    del data["hooks"]["Stop"]
if not data.get("hooks") and "hooks" in data:
    del data["hooks"]

with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print("hook removed")
EOF

if [ "${1:-}" = "--purge" ]; then
  rm -f "$SOUNDS_DIR/seatbelt-chime.wav" "$SOUNDS_DIR/bing-bong"
  echo "sound files removed"
fi

echo "bing-bong uninstalled. cabin has gone quiet. 🔇"
