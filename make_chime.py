#!/usr/bin/env python3
"""Synthesize an airline-seatbelt 'bing-bong' chime (descending two tones)."""
import math
import os
import struct
import wave

SR = 44100
AMP = 0.5
TONE_DUR = 0.45
GAP = 0.06
ATTACK = 0.005
out_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        "sounds", "seatbelt-chime.wav")


def tone(freq, dur):
    n = int(SR * dur)
    samples = []
    for i in range(n):
        t = i / SR
        # smooth short attack to avoid click, exponential decay like a real chime
        if t < ATTACK:
            env = t / ATTACK
        else:
            env = math.exp(-3.0 * (t - ATTACK))
        # fundamental + subtle second harmonic for warmth
        s = math.sin(2 * math.pi * freq * t)
        s += 0.25 * math.sin(2 * math.pi * 2 * freq * t)
        samples.append(AMP * env * s / 1.25)
    return samples


def gap(dur):
    return [0.0] * int(SR * dur)


# Descending: higher "bing" then lower "bong"
data = tone(660.0, TONE_DUR) + gap(GAP) + tone(520.0, TONE_DUR)

os.makedirs(os.path.dirname(out_path), exist_ok=True)
with wave.open(out_path, "w") as w:
    w.setnchannels(1)
    w.setsampwidth(2)  # 16-bit
    w.setframerate(SR)
    frames = b"".join(
        struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in data
    )
    w.writeframes(frames)

print("wrote", out_path)
