# Audio assets

Drop your audio files into this folder. The game works without them
(silent fail on missing files), but they dramatically improve immersion.

## Expected files

### Loops (background)

- `ambient_drone.mp3` — Subtle, low-frequency atmospheric loop.
  Think: distant wind, faint electrical hum, barely-there heartbeat.
  Should loop seamlessly. ~30-60s, quiet and unobtrusive.

- `tension_loop.mp3` — Higher-intensity loop for the Sheriff sequence.
  Think: rising synth drone, distorted bass pulse, ticking clock.
  Fades in/out programmatically. ~20-30s loop.

### SFX (one-shots)

- `sfx_notification.mp3` — iOS-style notification chime. Short, clean.
  ~0.5-1s. Plays when a push banner slides in.

- `sfx_keypad_tap.mp3` — Soft click/tap for PIN entry digits.
  ~0.1s. Subtle, not annoying on repeat.

- `sfx_keypad_error.mp3` — Low buzz/thud for wrong PIN.
  ~0.3-0.5s. Feels like rejection.

- `sfx_unlock.mp3` — Satisfying click/whoosh for successful unlock.
  ~0.5s. Brief moment of relief.

- `sfx_glitch.mp3` — Digital interference burst. Static crackle,
  bit-crushed noise, or corrupted signal. ~0.2-0.4s.

- `sfx_message.mp3` — Soft "pop" or "blip" when an NPC message
  appears in the chat. ~0.2s. Distinct from notification.

- `sfx_ending.mp3` — Dramatic reveal sting for the ending screen.
  ~1-2s. Low impact hit + reverb tail.

## Sources for free audio

- freesound.org (CC0 / CC-BY)
- pixabay.com/sound-effects (free license)
- zapsplat.com (free with attribution)
- Generate with AI: ElevenLabs Sound Effects, Stable Audio

## Format

MP3, 44.1kHz, mono or stereo. Keep files small (<500KB each for SFX,
<2MB for loops). The audioplayers package handles all common formats.
