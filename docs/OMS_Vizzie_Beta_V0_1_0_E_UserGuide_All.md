# OMS Vizzie [Beta V0.1.0] — USER GUIDE

**Run date:** 2026-09-20
**Unix Epoch:** 1789910858
**App Version:** Vizzie Beta V0.1.0
**License:** GPL-3.0 (software)
**Purpose:** How to use Vizzie.

---

## 1. WHAT IT IS

Vizzie is a browser visualizer. Open the one HTML file, press play, and the picture moves to the music. It reads a track's Apple Music Understanding (AMU) analysis — the bars, sections, key, loudness, pace, and instruments of a song — and draws to that musical clock. It reacts to *music*, not just *sound*. No install, no account.

## 2. OPEN IT

Open `OMS_Vizzie_Beta_V0.1.0.html` in any modern browser (desktop Chrome recommended; it also runs on iPad Safari). It loads with a reference track's analysis already embedded, so it works immediately.

## 3. THE TABS

- **MUSIC** — the visualizer, transport, waveform, and AMU timeline.
- **ABOUT** — what Vizzie is, who made it, and the license.

## 4. TRANSPORT

- **PLAY / pause** — start/stop. With no audio loaded, the AMU timeline advances on its own; upload audio and it plays in sync. **Spacebar** also toggles play/pause. When a track finishes, the playhead returns to the start.
- **LOOP** — when on (lit cyan), playback returns to the start and keeps going instead of stopping at the end.
- **SOLO** — lights up whenever anything is soloed (see §7); click it to clear all solos at once.

## 5. THE VISUAL (top-right INFO box)

A small expand icon sits in the top-right corner of the visual — click it to pop the visual out into its own window (double-click that window for fullscreen; good for a second screen). The pop-out renders at the window's own resolution, so it stays crisp when enlarged.


A circular field that fills the box and reacts to the music:
- **beat** pulses the whole field; **bar** spins the spokes and flashes on the downbeat.
- **section** sweeps the outer arc as the section progresses and sets the color; **phrase** sends satellites orbiting; **segment** turns an inner ring.
- **key** shows as an outer tint ring with the key labelled (e.g. "E minor").
- **pace** drives an outer energy ring; **loudness** makes the whole field breathe (bigger = louder).
- **drum / bass / vocal / other** each get a ring that reacts to when that instrument is active.

## 6. THE WAVEFORM

Above the timeline. Before you load audio it shows a dimmed placeholder with an "upload audio to view waveform" box — **click it to pick a local audio file**. Once loaded, the real waveform draws, bar-aligned, and the playhead sweeps it in sync with the music.

## 7. THE AMU TIMELINE (solo)

Below the transport: one **column per AMU parameter**, grouped under rainbow-colored bus headers (RHYTHM red, STRUCTURE orange, KEY yellow, PACE green, LOUDNESS blue, INSTRUMENTS violet). Time runs top to bottom; the playhead is the horizontal line sweeping down. Each column has its own distinct bright color, matched to that parameter's element in the visual — so soloing a lane lights exactly that element in the visual.

- **Scrub** — drag anywhere on the timeline to move through the track (snaps to the nearest bar; seeks the audio if loaded).
- **Solo one parameter** — click its **column chip** (e.g. "drum"). It stays in color; everything else — timeline and visual — goes gray.
- **Solo a whole bus** — click a **group header** (e.g. "INSTRUMENTS") to solo all its columns at once.
- **Stack solos** — click more; they add. Click a soloed one again to remove just it.
- **Clear all** — click the **SOLO** button in the transport.

## 8. NOTES

- The AMU analysis is embedded; only audio is uploaded, and only when you want to hear the track against the visual.
- Some parameters carry more visible motion than others depending on the track's data.
- The current renderer is Canvas 2D (runs everywhere). A WGSL renderer for desktop is planned.

---

**END OF USER GUIDE**
