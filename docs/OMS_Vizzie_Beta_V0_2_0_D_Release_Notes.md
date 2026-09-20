# OMS Vizzie [Beta V0.2.0] — RELEASE NOTES

**Run date:** 2026-09-20
**Unix Epoch:** 1789927586
**App Version:** Vizzie Beta V0.2.0
**License:** GPL-3.0 (software)
**Purpose:** The human "what shipped" for this build.

---

## Vizzie V0.2.0 — second release

This release adds a mobile view and a hidden experimental lab. On phones in portrait, Vizzie now shows a compact "Pocket Rave" surface. In the LEARN tab there's a new door into the Yo Lab — an experimental WebGPU/WGSL version of the visual you can watch, solo, dial with knobs, and even edit the shader code live. The main app is smoother too (no more stutter when you move the mouse or switch tabs), and the example track now loads itself on the site.

## Vizzie V0.1.0 — first release

Vizzie is live. This is the first published version — the full app: a music-driven visual and a vertical Apple Music Understanding timeline, with solo, a distinct color system, waveform, loop, and a pop-out. The LEARN tab now points you to the learn section on onemanshyo.com.

## Vizzie V0.2.0 — the music makes the picture

Vizzie is the visual side of the OMS suite. Load a track's Apple Music Understanding analysis, press play, and the picture moves in real musical time — because it's reading the actual bars, sections, and instruments of the song, not guessing from a spectrum. This build brings the visual, the timeline, and full solo control together into something that reads like an instrument.

### New in this build

- **Loop.** A LOOP button in the controls — turn it on and playback returns to the start and keeps going instead of stopping at the end. When it's off, the track finishes and the playhead resets to the top so you can hit play again.
- **A clearer color system.** Every AMU parameter now has its own distinct, bright color — the six buses (rhythm, structure, key, pace, loudness, instruments) read as a rainbow across the top, and each lane below is a clean, distinguishable hue. And every parameter now draws its own element in the visual, so when you solo one, you see exactly that one thing lit up in its color while everything else greys out.
- **A tidier pop-out.** The pop-out is now a small icon in the corner of the visual instead of a button sitting on top of it.

### It's driven by music, not sound

The clock is the AMU musical timeline. Beats, bars, sections, phrases, key, loudness, pace, and each instrument drive their own part of the picture. This is the thing FFT/RMS visualizers could never do — lock to the real musical grid. Press play with no audio and the timeline runs on its own; upload the track and the audio rides the same clock.

### The visual fills the frame

A single circular field that fills the whole canvas — a wheel seen through the viewport — with every AMU parameter mapped to its own layer: the beat pulses the field, bars spin the spokes, sections sweep the outer arc and shift the color, phrases orbit, the four instruments each get a ring that reacts to when that stem is playing, loudness makes the whole thing breathe, and pace drives the outer energy ring. Flat, clean, futuristic — no gradients.

### A timeline you can read like a tracker

Below the visual, the AMU analysis is laid out vertically — one column per parameter, grouped into buses (rhythm, structure, key, pace, loudness, instruments), time running top to bottom, the playhead sweeping down. Drag it to scrub anywhere; it snaps to the bar. Each column is color-matched to its element in the visual, on a palette picked so no two colors read alike.

### Solo anything

Click a column to solo that one parameter, or a group header to solo a whole bus. Solos stack — click several to build up exactly the set you want to watch. Soloed elements keep their color; everything else goes gray but keeps moving, so what you soloed is the only thing lit. A SOLO button in the transport glows whenever anything is soloed; one click clears them all.

### Waveform

Upload a track and its real waveform draws in above the timeline, bar-aligned, with the playhead in sync. Before you load audio, a placeholder shows where it'll go.

### It's one file

Everything is inline — the visual, the embedded analysis, the cover art, the logo. No install, no account, no network. The current renderer is Canvas 2D so it runs everywhere, including iPad. A higher-end WGSL renderer (desktop) is planned.

### What's next

- Re-analyze more tracks with the full AMU palette so Vizzie plays real per-instrument data beyond the reference track.
- The WGSL renderer path.
- A user-facing surface to map any AMU parameter to any visual property.

---

**END OF RELEASE NOTES**
