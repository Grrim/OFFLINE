"""Procedural audio generator for the Zaginiona game.

Generates 9 WAV files in `assets/audio/` using only numpy + wave (stdlib).
These are placeholders — quality is "good enough to be evocative", not
production-grade. Replace with real recordings when available.

Run from the project root:
    python tools/generate_audio.py
"""

from __future__ import annotations

import os
import wave
from pathlib import Path

import numpy as np

# ─── Constants ──────────────────────────────────────────────────────

SAMPLE_RATE = 44100
OUT_DIR = Path(__file__).parent.parent / "assets" / "audio"


# ─── Helpers ────────────────────────────────────────────────────────

def write_wav(filename: str, samples: np.ndarray) -> None:
    """Write a mono float32 array to a 16-bit PCM WAV file."""
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # Soft clip + normalise to prevent harsh clipping artefacts.
    samples = np.tanh(samples * 0.9)
    peak = float(np.max(np.abs(samples))) or 1.0
    samples = samples / peak * 0.95

    pcm = (samples * 32767).astype(np.int16)
    path = OUT_DIR / filename
    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(pcm.tobytes())
    size_kb = path.stat().st_size / 1024
    print(f"  ✓ {filename}  ({size_kb:.1f} KB)")


def t_array(duration: float) -> np.ndarray:
    """Return a time-axis array of the given duration in seconds."""
    return np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)


def fade(samples: np.ndarray, fade_in: float = 0.01, fade_out: float = 0.01) -> np.ndarray:
    """Apply exponential fade-in/out envelopes."""
    n = len(samples)
    in_n = int(SAMPLE_RATE * fade_in)
    out_n = int(SAMPLE_RATE * fade_out)
    env = np.ones(n)
    if in_n > 0:
        env[:in_n] = np.linspace(0, 1, in_n) ** 2
    if out_n > 0:
        env[-out_n:] = np.linspace(1, 0, out_n) ** 2
    return samples * env


def loop_safe(samples: np.ndarray, crossfade: float = 0.5) -> np.ndarray:
    """Cross-fade the end into the start so the loop is seamless."""
    n_xf = int(SAMPLE_RATE * crossfade)
    if n_xf >= len(samples) // 2:
        return samples
    head = samples[:n_xf].copy()
    tail = samples[-n_xf:].copy()
    fade_curve = np.linspace(0, 1, n_xf)
    blended = tail * (1 - fade_curve) + head * fade_curve
    out = samples.copy()
    out[-n_xf:] = blended
    out = out[:-n_xf]  # drop the cross-faded tail (already in the head)
    return out


# ─── Generators ─────────────────────────────────────────────────────

def gen_ambient_drone() -> None:
    """45-second low-frequency atmospheric drone with breathing modulation."""
    duration = 45.0
    t = t_array(duration)

    # Low fundamentals stacked with slight detuning for a "wide" feel.
    drone = (
        0.45 * np.sin(2 * np.pi * 55 * t)            # A1
        + 0.30 * np.sin(2 * np.pi * 55.3 * t)        # detuned
        + 0.25 * np.sin(2 * np.pi * 82.5 * t)        # E2 (perfect 5th)
        + 0.15 * np.sin(2 * np.pi * 110 * t)         # A2
    )

    # Slow LFO breathing modulation (~0.1 Hz).
    lfo = 0.5 + 0.4 * np.sin(2 * np.pi * 0.1 * t)
    drone *= lfo

    # Add quiet pink-ish noise for "wind through trees" texture.
    rng = np.random.default_rng(seed=42)
    noise = rng.normal(0, 0.05, len(t))
    # Simple low-pass via cumulative average (cheap, sounds OK at low freq).
    noise = np.convolve(noise, np.ones(50) / 50, mode="same") * 1.5

    drone += noise

    # Very slow breathing on overall amplitude.
    breath = 0.7 + 0.3 * np.sin(2 * np.pi * 0.07 * t)
    drone *= breath

    drone = loop_safe(drone, crossfade=2.0)
    drone = fade(drone, fade_in=2.0, fade_out=0.0)
    write_wav("ambient_drone.wav", drone * 0.6)


def gen_tension_loop() -> None:
    """25-second tension track: rising synth + clock tick + distorted bass."""
    duration = 25.0
    t = t_array(duration)

    # Pulsing bass at 110 Hz with sub-bass.
    bass = (
        0.5 * np.sin(2 * np.pi * 73 * t)
        + 0.3 * np.sin(2 * np.pi * 36.7 * t)
    )
    # Pulse envelope (heartbeat-like, ~70 BPM).
    bpm = 70
    pulse_freq = bpm / 60
    pulse = np.maximum(0, np.sin(2 * np.pi * pulse_freq * t)) ** 4
    bass *= pulse * 0.8

    # High-frequency dissonant drone for unease (minor 2nd interval).
    drone = (
        0.15 * np.sin(2 * np.pi * 440 * t)
        + 0.13 * np.sin(2 * np.pi * 466.16 * t)  # Bb4 — dissonant
    )
    # Tremolo on the high drone.
    drone *= 0.5 + 0.5 * np.sin(2 * np.pi * 4 * t)

    # Clock ticking — sharp click every second.
    ticks = np.zeros_like(t)
    for sec in range(int(duration)):
        idx = int(sec * SAMPLE_RATE)
        if idx + 200 < len(ticks):
            click = np.exp(-np.linspace(0, 8, 200))
            click *= np.sin(2 * np.pi * 3000 * np.linspace(0, 200 / SAMPLE_RATE, 200))
            ticks[idx:idx + 200] += click * 0.25

    signal = bass + drone + ticks

    # Soft distortion to add edge.
    signal = np.tanh(signal * 1.3)

    signal = loop_safe(signal, crossfade=1.5)
    signal = fade(signal, fade_in=1.0, fade_out=0.0)
    write_wav("tension_loop.wav", signal * 0.55)


def gen_sfx_notification() -> None:
    """Two-tone iOS-style chime."""
    duration = 0.7
    t = t_array(duration)

    # Two short notes: high then a perfect fifth above.
    note1_dur = 0.18
    note2_dur = 0.4
    note2_start = 0.15

    sig = np.zeros_like(t)

    # Note 1 — bell-like (sine + low-amp 2nd harmonic + fast decay).
    n1 = t[:int(note1_dur * SAMPLE_RATE)]
    bell1 = (np.sin(2 * np.pi * 880 * n1) + 0.3 * np.sin(2 * np.pi * 1760 * n1))
    bell1 *= np.exp(-n1 * 12)
    sig[:len(bell1)] += bell1

    # Note 2 — bell at 1318 Hz (E6).
    n2_start_idx = int(note2_start * SAMPLE_RATE)
    n2 = t[:int(note2_dur * SAMPLE_RATE)]
    bell2 = (np.sin(2 * np.pi * 1318 * n2) + 0.3 * np.sin(2 * np.pi * 2637 * n2))
    bell2 *= np.exp(-n2 * 6)
    end = min(n2_start_idx + len(bell2), len(sig))
    sig[n2_start_idx:end] += bell2[: end - n2_start_idx]

    write_wav("sfx_notification.wav", sig * 0.6)


def gen_sfx_keypad_tap() -> None:
    """Soft click for PIN digit entry."""
    duration = 0.08
    t = t_array(duration)

    # Mid-frequency burst with very fast decay.
    sig = np.sin(2 * np.pi * 1200 * t) * np.exp(-t * 80)
    # Add a touch of noise for "click" texture.
    rng = np.random.default_rng(seed=1)
    noise = rng.normal(0, 1, len(t)) * np.exp(-t * 120) * 0.3
    sig += noise

    write_wav("sfx_keypad_tap.wav", sig * 0.5)


def gen_sfx_keypad_error() -> None:
    """Low buzz for wrong PIN."""
    duration = 0.4
    t = t_array(duration)

    # Two low square-ish tones.
    sig = np.sign(np.sin(2 * np.pi * 165 * t)) * 0.3
    sig += np.sign(np.sin(2 * np.pi * 110 * t)) * 0.2
    # Buzzy amplitude modulation.
    sig *= 0.5 + 0.5 * np.sin(2 * np.pi * 18 * t)
    # Decay.
    sig *= np.exp(-t * 4)

    sig = fade(sig, fade_in=0.005, fade_out=0.05)
    write_wav("sfx_keypad_error.wav", sig * 0.55)


def gen_sfx_unlock() -> None:
    """Whoosh + soft chime for successful unlock."""
    duration = 0.6
    t = t_array(duration)

    # Rising whoosh — frequency sweep.
    sweep_freq = np.linspace(200, 1500, len(t))
    phase = np.cumsum(2 * np.pi * sweep_freq / SAMPLE_RATE)
    whoosh = np.sin(phase) * np.exp(-t * 3) * 0.4

    # Confirming bell.
    bell_start = int(0.15 * SAMPLE_RATE)
    bell_t = t[:len(t) - bell_start]
    bell = np.sin(2 * np.pi * 1046 * bell_t) * np.exp(-bell_t * 5) * 0.5
    bell += np.sin(2 * np.pi * 2093 * bell_t) * np.exp(-bell_t * 8) * 0.2

    sig = np.zeros_like(t)
    sig += whoosh
    sig[bell_start:] += bell[: len(sig) - bell_start]

    write_wav("sfx_unlock.wav", sig * 0.6)


def gen_sfx_glitch() -> None:
    """Bit-crushed digital interference burst."""
    duration = 0.25
    t = t_array(duration)

    rng = np.random.default_rng(seed=7)

    # Harsh white noise burst.
    noise = rng.normal(0, 1, len(t))

    # Bit-crush by quantising.
    bit_depth = 4
    levels = 2 ** bit_depth
    noise = np.round(noise * levels) / levels

    # Modulate with a high-frequency square wave for "digital" feel.
    sq = np.sign(np.sin(2 * np.pi * 200 * t))
    noise *= 0.5 + 0.5 * sq

    # Random amplitude stutter.
    n_stutter = 8
    stutter_env = np.repeat(rng.uniform(0.2, 1.0, n_stutter),
                             len(t) // n_stutter + 1)[:len(t)]
    noise *= stutter_env

    # Fast decay.
    noise *= np.exp(-t * 4)

    sig = fade(noise, fade_in=0.001, fade_out=0.02)
    write_wav("sfx_glitch.wav", sig * 0.5)


def gen_sfx_message() -> None:
    """Soft pop/blip for incoming chat message."""
    duration = 0.15
    t = t_array(duration)

    # Quick rising pitch — "blip".
    sweep_freq = np.linspace(600, 900, len(t))
    phase = np.cumsum(2 * np.pi * sweep_freq / SAMPLE_RATE)
    sig = np.sin(phase) * np.exp(-t * 18) * 0.6
    # Add a soft sub-pulse.
    sig += np.sin(2 * np.pi * 300 * t) * np.exp(-t * 25) * 0.2

    write_wav("sfx_message.wav", sig * 0.55)


def gen_sfx_ending() -> None:
    """Dramatic low impact + reverb tail for ending reveal."""
    duration = 2.5
    t = t_array(duration)

    # Sub-bass impact at the start.
    impact_t = t[:int(0.5 * SAMPLE_RATE)]
    impact = np.sin(2 * np.pi * 50 * impact_t) * np.exp(-impact_t * 5)
    impact += np.sin(2 * np.pi * 100 * impact_t) * np.exp(-impact_t * 8) * 0.5

    # Mid-range stab.
    stab = np.sin(2 * np.pi * 220 * impact_t) * np.exp(-impact_t * 10) * 0.4

    # Long reverb tail — filtered noise that fades over the full duration.
    rng = np.random.default_rng(seed=99)
    tail = rng.normal(0, 1, len(t)) * np.exp(-t * 1.2) * 0.15
    tail = np.convolve(tail, np.ones(80) / 80, mode="same")

    # High dissonant shimmer.
    shimmer = (
        np.sin(2 * np.pi * 880 * t) * np.exp(-t * 0.8) * 0.08
        + np.sin(2 * np.pi * 932 * t) * np.exp(-t * 0.8) * 0.06
    )

    sig = np.zeros_like(t)
    sig[:len(impact)] += impact
    sig[:len(stab)] += stab
    sig += tail
    sig += shimmer

    sig = fade(sig, fade_in=0.005, fade_out=0.3)
    write_wav("sfx_ending.wav", sig * 0.7)


# ─── Main ───────────────────────────────────────────────────────────

def main() -> None:
    print(f"Generating audio assets into: {OUT_DIR}")
    print()

    print("Loops:")
    gen_ambient_drone()
    gen_tension_loop()

    print("\nSFX:")
    gen_sfx_notification()
    gen_sfx_keypad_tap()
    gen_sfx_keypad_error()
    gen_sfx_unlock()
    gen_sfx_glitch()
    gen_sfx_message()
    gen_sfx_ending()

    print("\nDone. 9 files generated.")


if __name__ == "__main__":
    main()
