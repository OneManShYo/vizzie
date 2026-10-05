# OMS Vizzie app [Beta V0.5.0] Developer Documentation

**Run date:** 2026-10-05  
**Current Unix Epoch:** 1791240441  
**Filename:** OMS_Vizzie_Beta_V0_5_0_C_Developer_Documentation.md  
**App Version:** Vizzie Beta V0.5.0  
**License:** GPL-3.0 (software); embed assets see ABOUT menu  
**Purpose:** The explanatory technical spec for OMS Vizzie: how each system works and why. Uses the shared OMS **Cortex / Node / Leaf** vocabulary (Dojo, Chippy), sized to Vizzie's scope.  

---

## CONTENTS

**1** Introduction  
&emsp;1.1 What is Vizzie?  
&emsp;1.2 Application development tiers  
**2** Cortex & the Critical Stack  
&emsp;2.1 The AMU clock (CORTEX)  
&emsp;2.2 The uniform contract (critical: the one public interface)  
&emsp;2.3 The WGSL runtime (critical)  
&emsp;2.4 Message System: the feedback bar (CORTEX)  
**3** Node: Controls & Solo  
&emsp;3.1 Lanes  
&emsp;3.2 Encoders  
&emsp;3.3 Solo  
&emsp;3.4 Piano roll  
**4** Node: Song Info, Audio, Waveform  
&emsp;4.1 Audio  
&emsp;4.2 ID3  
&emsp;4.3 Waveform  
&emsp;4.4 Scrub  
**5** Node: Viewer Surfaces  
&emsp;5.1 Code editor  
&emsp;5.2 Drop a `.wgsl`  
&emsp;5.3 Pop-out  
&emsp;5.4 Record  
&emsp;5.5 Orientation  
**6** Node: Pocket Rave  
**7** Node: Tabs  
**8** Leaf Reference: Controls & Keyboard  
&emsp;8.1 Music column  
&emsp;8.2 Visual header  
&emsp;8.3 Controls header  
&emsp;8.4 Encoders  
&emsp;8.5 Keyboard  
&emsp;8.6 Pocket Rave  
**9** Design System  
&emsp;9.1 Philosophy  
&emsp;9.2 What the Design System is  
&emsp;9.3 What we DO  
&emsp;9.4 The module hierarchy  
**10** Sources: AMU Data & Shaders  
&emsp;10.1 AMU data  
&emsp;10.2 Shaders  

---

# 1. Introduction

## 1.1 What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

## 1.2 Application development tiers
- **Cortex** = the small, load-bearing core. Everything traces back to it; a change cascades everywhere. The label is used **sparingly on purpose**: if everything is Cortex, the word means nothing. In Vizzie two systems carry it: **the AMU clock** (timing) and **the Message System** (the single feedback channel), matching the OMS suite convention.
- **Node** = a feature system that depends on the Cortex but that the app's core function survives changes to. Most of the app is Nodes.
- **Leaf** = a small control or affordance hanging off a Node.

---

# 2. Cortex & the Critical Stack

The Cortex is the AMU clock. Above it sit three layers that each depend on the one below: the uniform contract, the WGSL runtime, and the shader. Only the clock is *Cortex*; the layers above are documented here (rather than with the ordinary Nodes) because they form the critical music-to-pixel spine, and you must understand what each sits on top of.

**The stack, bottom-up (each layer depends on the one beneath it):**

| Layer | What it does | Tier | If it breaks |
|---|---|---|---|
| 1. AMU clock (embedded analysis + `clock` + musical position) | says where we are in the music, every frame | **CORTEX** | nothing is in time; the picture has no musical meaning |
| 2. Uniform contract (`packUniforms`) | turns musical position into the 36 floats a shader reads | critical | shaders receive garbage or stale values |
| 3. WGSL runtime (device, pipeline, per-frame draw) | compiles the shader and draws it | critical | no picture at all |
| 4. The shader (default or user-loaded) | the actual look | rides on top | you lose *that look*, not the app; load another |

The tell for the ordering: **the shader sits on top of the runtime** (swap it and everything else keeps running); **the runtime sits on top of the contract** (a pipeline with no meaningful uniforms draws a still frame); **all of it sits on top of the clock** (no value means anything without musical position). The clock sits on the AMU data alone: that is why it, and only it in this stack, is Cortex.

## 2.1 The AMU clock (CORTEX)

**The one law: AMU is the clock.** Timing comes from the AMU musical timeline (bars/beats/sections), never from frame count, `requestAnimationFrame` deltas as a time source, or RMS/FFT audio energy. "Audio-driven" means audio-*played*, not audio-*timed*. This is why the visual locks to the real musical grid, and why the per-frame path is cheap: nothing is analysed at runtime.

### 2.1.1 One clock source
One scalar, `clock` (seconds into the track), advances in `frame()`:
- **audio-ridden:** when audio is loaded and playing, `clock = audioEl.currentTime`.
- **self-advanced:** with no audio, `clock += wall-delta` (clamped to 0.1 s), running to `TRACK` (last bar + one bar's tail).

At end of track: LOOP off → stop and reset to 0; LOOP on → rewind and continue. A `visibilitychange` handler drops the stale wall-delta and snaps to the audio position when the tab returns.

### 2.1.2 Musical position
`idxPhase(arr,t)` → `{i,p}`: the beat/bar at or before `t` and 0..1 progress to the next. Before the first element or after the last there is no interval to measure, so `p` holds 0: no guessing. `secOf/segOf/phrOf(t)` → index + progress through the containing section/segment/phrase.

### 2.1.3 Three loops, one clock
Three rAF loops read the same `clock`; none keeps its own time:
- `frame()`: advances `clock`; draws Pocket Rave chrome (info mirror, waveform) at ~22 fps when Pocket Rave is visible.
- `labTick()`: packs the uniforms from `clock` **every frame, wherever the viewer is**; draws the CREATE-tab chrome (knobs, piano roll, waveform) only when that panel is on screen.
- the GPU loop inside `initGpu()`: writes the uniform buffer and draws, **only while the viewer canvas is on screen** and the page is visible.

### 2.1.4 The data the clock reads
The AMU sidecar is embedded as a JSON `<script id="amu">` block and parsed at load into `bars`, `beats`, `BPM`, `sections`, `segments`, `phrases`, `KEY`, `LOUD` (+ `LMOM`/`LSHORT`), `PACE`, `INSTR` (per-stem `{activity[], ranges[]}`), `STEMS`, and derived `TRACK`.

#### 2.1.4.1 Provenance (verified V0.3.0: see the Shader Contract Normalization spec)

Names and shapes follow Apple's `MusicUnderstanding` framework as carried by Sozo Sidecar V2, with JSON-safe serialization: `CMTime` → seconds, `CMTimeRange` → `{start,end,duration}` (`end`/`duration` computed by Sozo), timed values → `{time,value}`.

#### 2.1.4.2 Current embed (differs from the verified shape)

the embedded copy predates the verification. It is decimated (loudness/activity ~900 points vs Apple's native 0.1 s / 0.05 s grids), rounded, uses `{t,v}` instead of `{time,value}`, and uses `rhythm.bpm`. Vizzie currently reads `{t,v}` and accepts `rhythm.bpm || rhythm.beatsPerMinute`.

## 2.2 The uniform contract (critical: the one public interface)

`packUniforms(t)` builds 32 floats each frame; the GPU loop writes the canvas resolution into slots 32 to 33; slots 34 to 35 are reserved. The buffer is **9 × vec4 / 36 floats / 144 bytes**, and the layout is frozen like a published API: new data goes only into reserved slots, never by renaming or reshuffling. The full slot table is in Y 5.

### 2.2.1 Namespaces

By who produced the number the shader receives:
- **WGSL/WebGPU standard**: types, attributes, built-ins. Untouched.
- **`amu.`**: Apple's value itself, only sampled at the playhead (mode, momentary LUFS, pace, stem activity, tonic).
- **`vizzie.`**: anything Vizzie computed or created (gates, time, phases, progress, indices, key index, resolution).

### 2.2.2 Rules (learned in V0.3.0)
- The contract carries **raw AMU values**. Any scaling (a LUFS window, a pace range) or shaping (pulses, flashes, decays) is the **shader's own choice**, written in the shader.
- Nothing enters the contract that is not AMU data or an explicit, requested Vizzie derivation. The removed `break` signal (an invented section-length heuristic that mis-flagged short sections) is the cautionary example.
- Pulse is 1 − phase; a shader computes it if it wants one.
- `amu.mode` is 0 major / 1 minor.

### 2.2.3 Gates

Slots 0 to 12 carry, per lane, (soloed-in ? 1 : 0) × encoder intensity (`gk(id)`), so a shader multiplies each element by its gate and the controls work on any shader.

## 2.3 The WGSL runtime (critical)

In-page (de-iframed in V0.2.08a, BLOG0037). `initGpu()` requests the adapter/device, configures a `webgpu` context on `#labGpu`, creates the 144-byte uniform buffer, and compiles the default shader. `compileWGSL(code)` compiles inside a validation error scope, reads `getCompilationInfo()`, builds a new pipeline + bind group, and swaps it in only if everything is clean: a bad shader never kills the running one; errors show on `#labGpuMsg`.

### 2.3.1 Why it runs like a game engine

the per-frame path is write 144 bytes, one render pass, `draw(6)` (a full-screen quad). No per-frame recompilation, no analysis, no cross-origin messaging, no per-frame DOM churn. Keep it that way.

### 2.3.2 Boilerplate

`WGSL_BOILER` supplies `struct U { v: array<vec4<f32>, 9> }`, the uniform binding, the vertex stage (aspect-correct `uv` from resolution), `f(i)` (slot reader), and helpers `hsl`, `ring`, `arcMask`, `PI`, `TAU`. `WGSL_FRAG` is the default fragment. A fragment-only shader uses the boilerplate; a full shader (with its own `struct U` / `@vertex`) compiles as-is.

### 2.3.3 One viewer

There is exactly one WebGPU canvas. `placeGpu()` moves it (and its error line) between the CREATE tab (`#labStage`) and Pocket Rave (`#prPlay`) on the same media query as the Pocket Rave CSS. Never create a second WebGPU canvas for another surface: move the one.

## 2.4 Message System: the feedback bar (CORTEX)

The **single channel for user feedback**, the bar at the bottom of the app (`#messageBar`), ported from Dojo/Chippy. Every module speaks through `showMessage(text, type)`; no module rolls its own feedback and there is no inline status in the interface.
- **`info` (cyan `#00d4ff`)**: hover hints, what a control is (`MSG.hint`, wired by `wireAllHints()` on `mouseenter` + `focus` from `data-hint`).
- **`state` (orange `#ffa500`)**: what just changed (Playing, Loop on, All solos cleared, Loaded …, Visual popped out …).
- **`error` (magenta `#ff006e`)**: failures (pop-out blocked, recording unsupported, bad drop, JSON error).

### 2.4.1 Why Cortex

every part of the UI depends on it for feedback; changing it cascades to all user communication.

---

# 3. Node: Controls & Solo

## 3.1 Lanes

`LANES` holds the 12 AMU parameters (beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other), each with an id, bus, label, colour, draw kind, and data accessor. The CREATE tab builds six bus modules (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS); each lane is a cell with a chip and an encoder.

## 3.2 Encoders

Endless-encoder model (turn = gain, push = solo): drag = intensity 0..1 (`knobVal`), press = solo, double-click = reset to 1. Bus header = group solo.

## 3.3 Solo

is owned by one module, `SOLO`: a set of lane ids and `grp:<bus>` keys. `SOLO.on(id)` is true when nothing is soloed, the lane is soloed, or its bus is. Solos are additive; each toggles independently. The SOLO button in the controls header lights when any solo is active and clears all on click. There is exactly **one canonical id per parameter (the lane id**) used by the chips, the encoders, the gates, and `SOLO`. (A pre-V0.1 bug came from two id vocabularies drifting apart; the fix was collapsing them to one.)

## 3.4 Piano roll

`drawRoll(t)` draws each lane's AMU data scrolling vertically through a fixed centred playhead, 16 s visible; soloed-out lanes dim.

---

# 4. Node: Song Info, Audio, Waveform

## 4.1 Audio

`loadAudioFromBlob(blob,name)` creates the audio element, reads ID3 tags, and decodes a copy for the waveform. Sources: the example MP3 auto-loaded on the hosted site (http/https only), or an audio file dropped on the song info box. Under `file://` the app stays analysis-only until audio is dropped.

## 4.2 ID3

`readID3()` is an inline ID3v2 parser (v2.2 to 2.4, UTF-8/UTF-16, no library): cover (APIC), title, artist, label, year, copyright. `applyTagsToInfo()` writes them into the CREATE info box: the single source of truth. Pocket Rave's info mirrors that box with ids stripped, so the ID3 writer only ever targets one copy. Default state: Yobot Squint cover + "Drag and Drop MP3 to load info". Catalog numbers, links, and exact release dates are not in ID3 and belong in the sidecar.

## 4.3 Waveform

`computeLevels(buffer,600)` → normalized RMS peaks. One offscreen cache (`wfCache`) is rebuilt by `ensureWaveCache(W,H)` when peaks or the requesting strip's size change; the CREATE strip and the Pocket Rave strip blit it and draw their own playhead. Before audio, a dim placeholder envelope ("loading waveform…"). The cache listens for 2D context loss and rebuilds.

## 4.4 Scrub

Both strips are seek surfaces: `wireWaveSeek(cv,pad)` binds pointer down/move/up (pointer capture, so a drag keeps tracking off the strip) on `#labWf` and `#prWf`, maps the x position to a fraction of the track, and calls `seekTo(sec)`. `seekTo` clamps to the track (and to the audio's duration when loaded), sets `clock`, resyncs the frame timer, and sets `audioEl.currentTime` when audio is loaded. Because the uniforms are packed from `clock`, the shader jumps with the playhead; with no audio, the AMU timeline moves on its own.

---

# 5. Node: Viewer Surfaces

## 5.1 Code editor

The `</> Code` button shows the current fragment; **Apply** runs `applyWGSLSource()`: source containing `struct U` or `@vertex` compiles as-is; anything else is treated as a fragment and gets the boilerplate. **Copy** copies it.

## 5.2 Drop a `.wgsl`

Drop a `.wgsl` file on the visual: same apply path; fills the editor so the two stay in sync.

## 5.3 Pop-out

`openPopOut()` opens a window with a `<video>` whose source is `#labGpu`'s capture stream: the same pixels, hot-swapped shaders included. It shows the viewer's own resolution, scaled, and freezes while the viewer is hidden (About tab, code view). Double-click for fullscreen.

## 5.4 Record

capture stream of `#labGpu` at 60 fps + the audio element's track → `MediaRecorder`, preferring real H.264/AAC MP4, falling back to VP9/VP8 WebM; 1 s timeslices; downloads as `VizzieWGSL_<dim>_<time>`.

## 5.5 Orientation

16:9 / 9:16 toggle letterboxes the viewer stage to 9:16 without changing the row height.

---

# 6. Node: Pocket Rave

Triggered by `@media (orientation:portrait), (max-height:500px)`: phones stay in Pocket Rave in both orientations; iPad/desktop keep the full app. Layout: header, MUSIC/ABOUT/LEARN tabs; MUSIC = song info mirror → the WGSL viewer (tap to play/pause; magenta border while playing) → waveform → version line → Yobot link (onemanshyo.com) → PLUR. ABOUT clones the desktop panel at runtime (single source of truth); LEARN opens the website via `openLearn()`. Code editor, pop-out, record, and the encoders are desktop-only.

---

# 7. Node: Tabs

Tabs CREATE / ABOUT / LEARN via `switchPanel()`. CREATE is the working surface (former Yo Lab). ABOUT carries the description, credits, software license, asset rights, technical notes, tools. LEARN is not a panel: the tab calls `openLearn()`, which opens `https://onemanshyo.com/#learn` in a new tab. The learning content lives on the website only.

---

# 8. Leaf Reference: Controls & Keyboard

## 8.1 Music column

Song info (drop audio; click cover → lightbox, click/Esc closes) · waveform (click/drag = seek) · PLAY/PAUSE · LOOP.

## 8.2 Visual header

`</> Code` · Pop Out · orientation · record · rec timer.

## 8.3 Controls header

SOLO (lit when any solo; click clears).

## 8.4 Encoders

Drag = intensity · press = solo · double-click = reset. Chips: click = solo. Bus headers: click = group solo.

## 8.5 Keyboard

SPACE = play/pause (ignored while typing in an input or the code editor). Esc closes the cover lightbox.

## 8.6 Pocket Rave

Tap the visual = play/pause; waveform click/drag = seek; tabs MUSIC / ABOUT, LEARN opens the website.

---

# 9. Design System

## 9.1 Philosophy
Vizzie follows the OMS **Human Interface Guidelines** (Chippy section 10): a hardware mindset (once you settle and package, it must be right, nothing left as hindsight) and things look as good on the inside (CSS, class structure, markup) as on the outside. We do not ship slop.

## 9.2 What the Design System is
The shared OMS tokens and component language: the `.app` shell (wood-cheek/metal-rail frame), `.header` (gradient ONEMANSHYO brand + app tag + version + Yobot logo, favicon), `.tabbar`/`.tab`, cyan `.sec-hdr` dividers, the `.btn` family, `.summary`/`.summary-grid`, and the `.message-bar` footer. Exact values and classes live in Y.

## 9.3 What we DO
- Section headers are always cyan `#00d4ff` (chrome only); new UI inherits `.sec-hdr` / `.btn`, never a parallel hand-rolled style.
- Header-strip buttons (Code, Pop Out, orientation, record, timer, SOLO) sit at the far right of the section header that owns them.
- Bus headers use a rainbow (RHYTHM red, STRUCTURE orange, KEY yellow, PACE green, LOUDNESS blue, INSTRUMENTS violet); lane colours are 11 pairwise-distinct hues + white for beat, one colour per parameter everywhere.
- Active state = border colour + tint + glow (LOOP cyan, SOLO pink, record pink pulse).
- All status and hover help goes to the message bar; no inline status.
- Write "·" (and similar) as the literal character in static HTML; `\u00b7` escapes only resolve inside JS strings.

## 9.4 The module hierarchy
Controls nest in a precise containment tree: **section → bus module → lane cell → chip + encoder.**
- **Bus module** (`.amu-mod`): bordered box sized to its lane count, headed by a solid bus pill (`.amu-bus`).
- **Lane cell** (`.amu-cell`): outlined sub-box holding one lane.
- **Chip + encoder** (`.lab-lane` + `.amu-knob`): the lane's name pill and its circular-surround encoder.
The piano roll sits in its own module perimeter aligned with the bus modules above.

---

# 10. Sources: AMU Data & Shaders

## 10.1 AMU data

Apple's Music Understanding framework (Swift module `MusicUnderstanding`, macOS 27) analyses a track on-device; the OMS Sozo Sidecar writes it to JSON; Vizzie embeds it. Chain of trust: Apple → Sozo → JSON → `packUniforms` → shader. Apple is the authority; names follow Apple unless there is a reason to deviate.

## 10.2 Shaders

Vizzie runs any WGSL shader written to the uniform contract; it does not care where the shader came from. Shaders are made with the Vizzie shader authoring workflow, `OMS_Vizzie_ShaderTemplate` (a paired `.html` + `.wgsl`): the HTML runs the shader on the real AMU sidecar timeline (drag to scrub), with a parts toggle and the SPECIFICATION (AMU mapping → scene → one block per object). The `.wgsl` drops into Vizzie unchanged. Shaders are named `OMS_Vizzie_Shader_<Name>_V##.wgsl`; the library lives in `VIZZIE/App Folder/Library/Shaders/`, one folder per shader.

---

**END OF DEVELOPER DOCUMENTATION**
