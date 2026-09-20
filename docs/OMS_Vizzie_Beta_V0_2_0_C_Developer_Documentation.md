# OMS VIZZIE [Beta V0.2.0] — DEVELOPER DOCUMENTATION

**Run date:** 2026-09-20
**Current Unix Epoch:** 1789927586
**App Version:** Vizzie Beta V0.2.0
**License:** GPL-3.0 (software)

**Purpose:** The "how it works" doc. Explains the app's architecture, the AMU musical clock, the vertical timeline, the canvas visual, the solo system, and the design system. Its companion, **Y (System Reference)**, is the "where is it" doc — it lists identifiers/shapes for lookup and points back here. They do not overlap: C teaches once; Y indexes once.

---

## 1. WHAT VIZZIE IS

A single-file, browser-native, MUSIC-driven visualizer. One HTML file with all code, the embedded AMU analysis, and all assets (cover art, logo, favicon) inline. It reads an Apple Music Understanding (AMU) sidecar — the JSON description of a track's music — and renders to the musical timeline. Generation of the *visual* is live; the musical structure is given, once, as data.

It sits in the OMS suite as a **consumer** of AMU sidecars (the OMS Sozo Sidecar tool produces them). It plays a sidecar back two ways at once: a circular **visual** and a vertical **session-view timeline**.

## 2. THE ONE LAW — AMU IS THE CLOCK

The single principle. Timing comes from the AMU musical timeline (bars/beats/sections), never from frame count, `requestAnimationFrame` deltas as a time source, or RMS/FFT audio energy. "Audio-driven" means audio-*played*, not audio-*timed*. Every visual element and every lane asks "where are we in the music right now" and draws accordingly. This is why the picture is musical rather than merely sound-reactive, and why it is scrubbable: any musical coordinate is directly addressable — set the clock to a timestamp and everything evaluates there, no playback required.

## 3. THE CLOCK (the cortex)

One scalar, `clock` (seconds into the track), advances one of two ways inside the single `frame()` loop:
- **audio-ridden:** when audio is loaded and playing, `clock = audioEl.currentTime`.
- **self-advanced:** with no audio, `clock += wall-delta` each frame, looping at `TRACK` (derived from the last bar plus a bar's tail).

Everything downstream reads `clock` and locates it in the AMU arrays. There is exactly one clock and one rAF loop; nothing else keeps time. At end-of-track the transport resets the playhead to 0 (LOOP off) or rewinds and continues (LOOP on), for both the audio-ridden and self-advanced paths.

**Musical-position helpers.** `idxPhase(arr, t)` returns `{i, p}` — the index at/just-before `t` in an ascending array (beats/bars) and 0..1 progress to the next. `secOf/segOf/phrOf(t)` return which section/segment/phrase contains `t` and progress through it. `isBreak(dur)` flags an off-length section (a breakdown/drop). `nearestBar(sec)` is the scrub snap target.

## 4. THE DATA (embedded AMU sidecar)

The V2 AMU sidecar (all six analysis types) is embedded as a JSON `<script>` block and parsed at load into: `bars`, `beats`, `BPM` (from `rhythm.bpm`), `sections`, `segments`, `phrases`, `KEY`, `LOUD` (with `LMOM`/`LSHORT` LUFS curves), `PACE`, `INSTR` (per-stem `{activity[], ranges[]}`), `STEMS`. Dense curves (loudness, per-stem activity) are downsampled at authoring time to keep the embed small. **Field-name note:** rhythm tempo is `rhythm.bpm` — reading `beatsPerMinute` yields `undefined` → `TRACK` NaN → every coordinate NaN → a blank timeline (this bug was hit and fixed; see §8).

## 5. THE VERTICAL TIMELINE (session view)

Drawn on the `#tl` canvas, DPR-scaled. A tracker/Session-View layout: **one column per AMU parameter**, grouped into buses. Time runs **down** the Y axis: `Y(sec) = HDR + (sec/TRACK) * plotH`. The top header band holds the group row (RHYTHM/STRUCTURE/KEY/PACE/LOUDNESS/INSTRUMENTS) and, beneath it, one label chip per column. The playhead is a horizontal line at `Y(clock)` sweeping down.

Each column draws by its lane **kind**: `ticks` (beat/bar dots), `blocks` (section/segment/phrase spans), `brk` (off-length sections), `keyspan` (the key range with a rotated tonic/mode label), `paceStep` (energy step bars), `curve` (loudness LUFS line), `stem` (per-instrument activity curve + active-range blocks). Lanes are colored at rest and flash a brighter (`hot()`) tint on their trigger via a small decaying `flash` value per lane, edge-triggered on index change.

**Scrub.** Pointer drag maps Y→time, snaps to the nearest bar, sets `clock`, and seeks audio if loaded. Because the clock is a musical coordinate, this seeks a *live* visual with no rendering.

## 6. THE VISUAL (rectangular fill)

Drawn on the `#c` canvas each frame from the current musical position. It is one coherent radial system scaled to **fill the box by width** (`fillR = W * 0.52`), so the circle overflows the short axis — a wheel seen through the viewport — rather than a small circle floating in a rectangle. Every AMU parameter is a concentric, color-matched layer on that one system:
- **beat** → a full-field ring pulse + a dot grid/burst; **bar** → rotating spokes + downbeat flash.
- **section** → base color + an outer arc that fills with section progress (+ a bottom progress bar).
- **phrase** → orbiting satellites; **segment** → an inner counter-rotating ring stepping per segment.
- **key** → an outer tint ring + the key label; **pace** → an outer energy ring whose speed/density track the pace value.
- **loudness** → drives the whole field's breathing radius (`baseR` scales with the sampled LUFS); **break** → complementary shift + field shake + a BREAK label.
- **drum / bass / vocal / other** → four concentric rings, each with arms/dots whose count, speed, and brightness track that stem's 0..1 activity.

Every one of the 13 parameters has its own bold, color-matched element (section arc+wedge, segment ring, phrase satellites, beat ring/dots, bar spokes, key wheel, pace gauge, loudness meter ring, four instrument rings, break shake) so soloing any parameter isolates a clearly visible colored thing. Colors come from one palette of 12 pairwise-distinct bright hues + white for beat, matched exactly between the timeline columns and the visual elements; the six bus headers use a separate rainbow (ROY-G-B-V, indigo skipped). The aesthetic is flat Canvas 2D — no gradients.

**Renderer note.** Canvas 2D is the current renderer (runs everywhere, including iPad Safari). WGSL/WebGPU is the intended primary renderer, deferred to desktop Chrome; the AMU→driver mapping sits above the renderer, so the renderer can be swapped without touching that join.

## 7. THE SOLO SYSTEM (single source of truth)

Solo is owned entirely by one module, `SOLO`, so behavior is routable and predictable. It holds a set of active keys — lane ids (e.g. `beats`, `ia:drum`) and/or group keys (`grp:<name>`) — and answers two questions everyone else asks:
- `SOLO.on(id)` — is this parameter currently colored? True when nothing is soloed, when this exact lane is soloed, or when its bus is soloed.
- `SOLO.muted(id)` — the inverse; used to swap an element's color to the mute gray.

Model: **additive** (multiple solos stack), each toggles independently, exclusive of nothing. **Monochrome mute** — non-soloed elements are not hidden; they draw in a dark-gray (`MUTE`) and keep moving, so the soloed element is the only thing in color. Every consumer routes through `SOLO`: the visual effects (each uses `muted(id)` to pick real-color-or-gray), the timeline column veil and chip/header highlights, the click hit-testing (chip → `toggleLane`, header → `toggleGroup`), and the transport master button (`SOLO.anyOn()` lights it; click → `SOLO.clear()`). Redraw is pushed on any change via `SOLO.sync()`.

**Critical:** there is exactly **one canonical id per parameter — the lane id** — used identically by the lanes, the visual, and `SOLO`. The predecessor bug (§8) was two id vocabularies drifting apart; the fix was collapsing them to one.

## 8. KNOWN FIXES / GOTCHAS (learned building it)

1. **`rhythm.bpm`, not `beatsPerMinute`.** The V2 sidecar's tempo field is `bpm`. Reading the wrong name made `BPM` undefined → `TRACK` NaN → every `X()/Y()` coordinate NaN → the whole timeline blank while the visual (separate clock path) still spun. One-field fix.
2. **The solo id-vocabulary split.** The visual called `muted('rhythm.beats')` while the solo authority keyed on the lane id `beats`; the lookup silently failed and mutes never applied. Fix: one `SOLO` module, one canonical id per parameter, all call-sites routed through it (§7).
3. **Collapsed canvas on layout change.** Fixed vertical layouts can squeeze a flex canvas to zero height; give the drawn canvases real minimum sizes and re-measure the first frames via `getBoundingClientRect`, DPR-scaling the backing store.
4. **HTML entities in static markup.** Use a literal "·"; the JS escape `\u00b7` only resolves inside JS strings, not in static HTML text.
5. **File input.** No `accept="audio/*"` filter (iOS Safari greys otherwise-valid MP3s).
6. **Waveform needs PCM.** AMU carries no samples, so the waveform only populates from uploaded audio (decoded via the Web Audio API); before load, a dimmed illustrative envelope + upload prompt stands in.

## 9. THE OMS DESIGN SYSTEM

Inherited from the shared OMS design system (the Chippy V1.16.0 bundle): the `.app` shell (wood-cheek/metal-rail frame), the `.header` (gradient ONEMANSHYO brand + app tag + version + the Yobot squint logo, favicon set), `.tabbar`/`.tab`, cyan `.sec-hdr` section dividers (bar + uppercase mono label + rule), the `.transport` + `.btn` strip, `#chartWrap`, the `.summary`/`.summary-grid` INFO layout, and the `.message-bar` footer (info=cyan / state=orange / error=magenta). Section-header cyan is `#00d4ff` and is reserved for chrome; the AMU "section" parameter uses a distinct brighter cyan so the two never collide. Do not hand-roll parallel styles — inherit the tokens so Vizzie reads as one product with the rest of the suite.

## 10. WHAT IT DELIBERATELY DOES NOT DO (yet)

- No contract/normalization layer — the visual currently reads AMU values semi-directly with per-element scaling; a frozen normalized uniform contract (the "any visual × any song" layer) is planned, not built.
- No WGSL renderer yet — Canvas 2D only.
- No user-facing mapping surface — which AMU parameter drives which visual property is fixed in code.
- No audio analysis — Vizzie reads a sidecar; it never runs AMU (that is the Sozo Sidecar's job, Apple-only).

---

**END OF DEVELOPER DOCUMENTATION**
