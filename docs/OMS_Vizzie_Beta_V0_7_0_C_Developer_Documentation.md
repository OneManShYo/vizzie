# OMS Vizzie app [Beta V0.7.0] Developer Documentation

**Run date:** 2026-10-31  
**Current Unix Epoch:** 1793459152  
**Filename:** OMS_Vizzie_Beta_V0_7_0_C_Developer_Documentation.md  
**App Version:** Vizzie Beta V0.7.0  
**License:** GPL-3.0 (software); embed assets see ABOUT menu  
**Purpose:** The explanatory technical spec for OMS Vizzie: how each system works and why. Uses the shared OMS **Cortex / Node / Leaf** vocabulary (Dojo, Chippy), sized to Vizzie's scope.  

---

## CONTENTS

**1** Introduction  
&emsp;1.1 What is Vizzie?  
&emsp;1.2 Application development tiers  
**2** Cortex & the Critical Stack  
&emsp;2.1 The master music clock (CORTEX)  
&emsp;2.2 The uniform contract (critical: the one public interface)  
&emsp;2.3 The WGSL runtime (critical)  
&emsp;2.4 Message System: the feedback bar (CORTEX)  
**3** Node: Deck Audio, Tempo, Key Lock  
&emsp;3.1 Deck audio engine  
&emsp;3.2 Warp: steering the deck to the clock  
&emsp;3.3 TEMPO  
&emsp;3.4 KEY LOCK  
**4** Node: Controls & Solo  
&emsp;4.1 Lanes  
&emsp;4.2 Encoders  
&emsp;4.3 Solo  
&emsp;4.4 Piano roll  
**5** Node: Song Info, Audio Loading, Waveform  
&emsp;5.1 Loading audio  
&emsp;5.2 ID3 and the song info  
&emsp;5.3 Waveform  
&emsp;5.4 Scrub and double-tap loaders  
**6** Node: Viewer Surfaces  
&emsp;6.1 Code view  
&emsp;6.2 Drop or pick a `.wgsl`  
&emsp;6.3 Pop-out  
&emsp;6.4 Record  
&emsp;6.5 Orientation  
**7** Node: Surfaces and Modes  
&emsp;7.1 Host check and compact viewport  
&emsp;7.2 MODES: PUBLIC and AUTHORING  
&emsp;7.3 Pocket Rave  
&emsp;7.4 Compact authoring  
**8** Node: Authoring (the template the app carries)  
&emsp;8.1 The per-shader block  
&emsp;8.2 Renderer hooks: AUTH_GPU  
&emsp;8.3 Objects toggle and CRYPTOMATTE  
&emsp;8.4 Authoring overlay  
**9** Node: Tabs  
**10** Leaf Reference: Controls & Keyboard  
**11** Design System  
**12** Sources: AMU Data & Shaders  

---

# 1. Introduction

## 1.1 What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

## 1.2 Application development tiers
- **Cortex** = the small, load-bearing core. Everything traces back to it; a change cascades everywhere. The label is used **sparingly on purpose**: if everything is Cortex, the word means nothing. In Vizzie two systems carry it: **the master music clock** (timing) and **the Message System** (the single feedback channel), matching the OMS suite convention.
- **Node** = a feature system that depends on the Cortex but that the app's core function survives changes to. Most of the app is Nodes.
- **Leaf** = a small control or affordance hanging off a Node.

---

# 2. Cortex & the Critical Stack

The Cortex is the master music clock. Above it sit three layers that each depend on the one below: the uniform contract, the WGSL runtime, and the shader.

| Layer | What it does | Tier | If it breaks |
|---|---|---|---|
| 1. Master music clock (`CLOCK`, the warp map, the AMU reader `amu(t)`) | says where we are in the music, in beats, every frame | **CORTEX** | nothing is in time; the picture has no musical meaning |
| 2. Uniform contract (`pack()`) | turns musical position into the 36 floats a shader reads | critical | shaders receive garbage or stale values |
| 3. WGSL runtime (`main()`, `build()`, per-frame draw) | compiles the shader and draws it | critical | no picture at all |
| 4. The shader (default or user-loaded) | the actual look | rides on top | you lose *that look*, not the app; load another |

## 2.1 The master music clock (CORTEX)

**The one law: music time is the clock of record.** Position is counted in bars and beats, never in elapsed seconds, frame counts or audio energy. Seconds exist only at the edge, where the computer world needs them: the decoded audio buffer and the track's beat map. Conversions live there, not the other way round.

### 2.1.1 CLOCK
`CLOCK.beat` is the position in beats on the track's AMU beat grid: beat 0 is the first AMU beat, the fraction is the phase within the beat. `CLOCK.tempo` is the master tempo in BPM (set by TEMPO, 3.3). `CLOCK.advance(dt)` adds `dt × tempo / 60` beats: the master grid is evenly spaced at the TEMPO.

### 2.1.2 The warp map
Each track's AMU beats are its warp markers, set by the analysis instead of by hand. `CLOCK` builds a smoothed map once: each AMU beat time is replaced by a straight-line fit over the beats within ±8 (a 4-bar window), so analysis jitter averages out while real tempo drift is still followed (on Ain't No Trick the AMU marks sit 7.7 ms off a steady grid typically, 22.7 ms worst). `CLOCK.timeToBeat(t)` and `CLOCK.beatToTime(b)` convert through the map (linear between beats, extended past the first and last beat at their spacing); `CLOCK.beatLen(b)` is the track seconds per beat at beat `b`, the track's local tempo. `CLOCK.t` is a getter/setter through the map, for the places that need track seconds (the audio, the AMU reader).

### 2.1.3 Heartbeat and the loop
`hb()` is the clock's heartbeat: `audioCtx.currentTime` (the audio hardware clock) once a track is loaded, otherwise `performance.now()`. One rAF loop, `chrome()`, advances the clock by the heartbeat delta (clamped to 0.1 s) while playing, steers the deck (3.2), sizes the stage, writes the readout and draws the 2D chrome (knobs, waveform, piano roll). At the end of the track: LOOP off → stop and reset to 0; LOOP on → back to 0 and continue. `seekTo(sec)` sets `CLOCK.t` and moves the audio with it. A `visibilitychange` handler drops the stale delta when the tab returns.

### 2.1.4 The AMU reader
`amu(t)` reads the embedded timeline at track time `t` and returns the contract's fields: beat and bar phase (`phaseIn`), section / segment / phrase progress and index (`span`), key mode and tonic, momentary loudness, pace, and the four instrument activities (`sample`). The beat count for `vizzie.time` comes from `CLOCK.beat`, not from `amu()`.

### 2.1.5 The embedded data
The AMU sidecar is embedded as `const AMU={…}`: `len`, `bpm`, `beats` and `bars` (ascending times), `sec` / `seg` / `phr` (`[start,end]` pairs), `key` (`[start,end,mode,tonic]`), `pace` (`[start,end,value]`), `mom` (momentary LUFS as `{t0,dt,v}`) and `act` (`drum`, `bass`, `vocal`, `other`, each `{t0,dt,v}`). Names and values come from Apple's `MusicUnderstanding` framework as written by Sozo Sidecar V2; the embed is compacted (arrays, evenly sampled curves). `TRACK`, `BPM` and `SONG` (the track length) derive from it.

## 2.2 The uniform contract (critical: the one public interface)

Contract **V0.4.0D**: **9 × vec4 / 36 floats / 144 bytes**, frozen like a published API: new data goes only into reserved slots, never by renaming or reshuffling. `pack(a,beat,w,h)` builds all 36 floats each frame from the AMU reader's fields, the clock's beat and the canvas size. The full slot table is in Y 2.2.

### 2.2.1 Namespaces
- **WGSL/WebGPU standard**: types, attributes, built-ins. Untouched.
- **`amu.`**: Apple's value itself, sampled at the playhead (mode, momentary LUFS, pace, stem activity, tonic).
- **`vizzie.`**: anything Vizzie computed (gates, time, phases, progress, indices, key index, resolution).

### 2.2.2 Rules
- The contract carries **raw AMU values**. Scaling and shaping are the shader's own choice.
- Nothing enters the contract that is not AMU data or an explicit, requested Vizzie derivation (the removed `break` signal is the cautionary example).
- **`vizzie.time` (slot 13) is cumulative beats** on the master clock (V0.4.0D; it was song seconds up to V0.4.0C). There is no seconds slot and no tempo slot: subdivisions are maths on the beat value (one turn per bar = `t * TAU / 4.`). Because it is beats, motion driven by it follows TEMPO.
- Pulse is 1 − phase; a shader computes it if it wants one. `amu.mode` is 0 major / 1 minor.

### 2.2.3 Gates
Slots 0 to 12 carry, per lane, (soloed-in ? 1 : 0) × encoder intensity (`gk(id)`, looked up by slot with `gateOf(i)`), so a shader multiplies each element by its gate and the controls work on any shader.

## 2.3 The WGSL runtime (critical)

`main()` requests the adapter and device, configures a `webgpu` context on `#labGpu`, creates the 144-byte uniform buffer and calls `AUTH_GPU.init(device)`. `build(src)` compiles the shader (through `AUTH_GPU.patch`, 8.2), reads `getCompilationInfo()`, and only if it is clean builds a new pipeline and bind group and swaps them in: a bad shader never kills the running one; the error line shows in `#labGpuMsg`. `build` is exposed as `window.__applyWGSL`.

### 2.3.1 Why it runs like a game engine
Per frame: write 144 bytes, the authoring buffers when on, one render pass, `draw(6)` (a full-screen quad). No per-frame recompilation, no analysis, no cross-origin messaging. Keep it that way.

### 2.3.2 Full shaders only
`WGSL` is the default scene as a complete shader (`struct U`, binding, `vs`, `fs`). Apply, drop and pick compile the source as-is; a fragment-only paste is not wrapped any more.

### 2.3.3 One viewer
There is exactly one WebGPU canvas. `window.__placeGpu()` moves it, with its overlay canvas and error line, between the CREATE stage (`#labStage`) and Pocket Rave (`#prPlay`). Never create a second WebGPU canvas for another surface: move the one.

## 2.4 Message System: the feedback bar (CORTEX)

The **single channel for user feedback**, the bar at the bottom of the app (`#messageBar`). Every module speaks through `showMessage(text, type)`; no module rolls its own feedback.
- **`info` (cyan `#00d4ff`)**: the idle line (`mode().idle`) and live hover values: hovering a lane shows its slot, knob, solo state and current value; hovering a bus header lists its lanes.
- **`state` (orange `#ffa500`)**: what just changed (Playing, Tempo, KEY LOCK, Cue, Loaded …).
- **`error` (magenta `#ff006e`)**: failures (bad drop, decode failure, pop-out blocked, recording unsupported).

---

# 3. Node: Deck Audio, Tempo, Key Lock

## 3.1 Deck audio engine
`makeDeckAudio(ctx,buf,canStretch)` plays the decoded track through Web Audio: an `AudioBufferSourceNode` (or the KEY LOCK worklet) into a deck gain node, into the output. Position = the offset played from + AudioContext time since the start × rate (the audio hardware clock, sample-accurate). It keeps the interface the app used with an `<audio>` element (`currentTime`, `duration`, `paused`, `ended`, `play`, `pause`, `captureStream`) plus `rate` and `keyLock`. `audioContext()` creates the AudioContext inside the drop or pick gesture; any pointer or key event resumes it if the browser suspended it. Web Audio only, no browser-specific APIs.

## 3.2 Warp: steering the deck to the clock
`steerDeck()` runs every frame while playing. Target = the clock's track time (`CLOCK.t`). Speed = the warp map's local tempo × TEMPO (`CLOCK.beatLen(CLOCK.beat) × CLOCK.tempo / 60`), times a correction that closes the gap over about a second, capped at ±2 %. A gap over 250 ms (a seek, a stall) is jumped instead. Known limit: the KEY LOCK worklet's real read position is not reported back, so the gap is measured against the engine's own position model.

## 3.3 TEMPO
`setTempo(bpm)` sets `CLOCK.tempo`, clamped to half and one and a half times the track's BPM (64 to 192 on the example track). − / + step 1 BPM; typing sets it; double-click resets to `AMU.bpm` exactly. `tempoRatio()` = tempo / track BPM. `tempoUI()` shows the value and the % from the track's tempo.

## 3.4 KEY LOCK
On, the deck plays through the `vizzie-stretch` AudioWorklet: a WSOLA time-stretch (Hann-windowed frames, overlap-added) that holds pitch at any rate. The worklet source is `STRETCH_SRC`, loaded once per AudioContext by `loadStretch(ctx)` as a `data:` URL module (a `blob:` module is refused from `file://`; blob is the fallback). Transients: `findOnsets(buf)` finds the track's onsets once (high-passed level steps over twice the recent average, at least 50 ms apart) and the worklet places attacks so drum hits keep their snap. Off, the plain source's playback rate moves pitch with tempo, like a turntable. Off by default; the button is disabled where AudioWorklet is missing.

---

# 4. Node: Controls & Solo

## 4.1 Lanes
`LANES` holds the 12 AMU parameters (beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other), each with an id, bus, label, colour, draw kind, contract slot and data. The controls build six bus modules (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS); each lane is a cell with a chip and an encoder.

## 4.2 Encoders
Endless-encoder model: drag = intensity 0..1 (`knobVal`), press = solo, double-click = reset to 1. Bus header = group solo.

## 4.3 Solo
Owned by one module, `SOLO`: a set of lane ids and `grp:<bus>` keys. `SOLO.on(id)` is true when nothing is soloed, the lane is soloed, or its bus is. Solos are additive. The SOLO button lights when any solo is active and clears all on click. One canonical id per parameter (the lane id) is used by the chips, the encoders, the gates and `SOLO`.

## 4.4 Piano roll
`drawRoll(t)` draws each lane's AMU data through a fixed centre playhead. **Its axis is master-grid beats**: `rollView(t)` gives the window start beat and length; lanes are placed by `CLOCK.timeToBeat`, so bars stay bars at any TEMPO. Window: `ROLL_WIN` beats from `MODES` (16 = 4 bars in AUTHORING, 32 = 8 bars in PUBLIC) × `rollZoom`, up to twice the song (`rollMaxZoom()`); the zoom label is the share of the song in view (100 % = whole song). Orientation: vertical (lanes as columns) or horizontal (lanes as rows, `rollHoriz`). Interaction: drag = scrub in beats; click without dragging = cue to that block's start (`amuStart` / `amuCue`: beat, bar, section, segment, phrase, key span, pace step; loudness and the instruments are not cue targets); − / + buttons, ctrl + wheel and two-finger pinch zoom.

---

# 5. Node: Song Info, Audio Loading, Waveform

## 5.1 Loading audio
`loadAudioFromBlob(blob,name)` reads the ID3 tags, decodes the track, loads the KEY LOCK worklet in parallel, builds the deck engine at the current tempo, places it at the clock's position and computes the waveform peaks. Sources: the example MP3 auto-loaded on the hosted site (http / https only, from `./examples/`), a drop on the music row, or the hidden pickers (5.4). Under `file://` the app runs on the AMU clock alone until audio is loaded.

## 5.2 ID3 and the song info
`readID3()` is an inline ID3v2 parser (v2.2 to 2.4, UTF-8 / UTF-16, no library): cover (APIC), title, artist, label, year, copyright. `applyTagsToInfo()` writes them into the CREATE song info (`#coverArt`, `#trackName` …), the single source; Pocket Rave's card is rebuilt from it. Tapping the cover flips it and slides the song info out over the waveform, in every mode; tap elsewhere or Esc closes it. In AUTHORING the song info starts from the sidecar's file name.

## 5.3 Waveform
`computeLevels(buffer,600)` → normalised RMS peaks. One offscreen cache (`wfCache`) is rebuilt by `ensureWaveCache(W,H)` when its source or size changes; the CREATE strip (`drawLabWave`) and the Pocket Rave strip blit it and draw their own playhead. Before audio: in PUBLIC a dim placeholder envelope ("loading waveform…"), in AUTHORING the sidecar's momentary loudness. The waveform is a whole-song view.

## 5.4 Scrub and double-tap loaders
Both waveform strips seek on click and drag (pointer capture). In CREATE a double tap (two taps within 300 ms) on the cover or the waveform opens the hidden MP3 picker (`#labAudioIn`), and on the stage the hidden `.wgsl` picker (`#labShaderIn`, no `accept` filter because iOS greys out `.wgsl` when filtered; the name is checked instead). Single taps keep their own job. Drag and drop works as before.

---

# 6. Node: Viewer Surfaces

## 6.1 Code view
`</> Code` shows the current shader source; **Apply** compiles it as the preview (`window.__applyWGSL`); **Copy** copies it.

## 6.2 Drop or pick a `.wgsl`
Drop a `.wgsl` on the stage, or double-tap the stage to pick one: the code view fills and the same compile path runs.

## 6.3 Pop-out
`openPopOut()` opens a window with a `<video>` whose source is `#labGpu`'s capture stream: the same pixels, hot-swapped shaders included. Double-click for fullscreen.

## 6.4 Record
Capture stream of `#labGpu` at 60 fps + the deck engine's audio (`captureStream()` on its gain) → `MediaRecorder`, preferring H.264 / AAC MP4, falling back to VP9 / VP8 WebM; downloads as `VizzieWGSL_<WxH>_<time>`.

## 6.5 Orientation
Cycles 16:9 → 1:1 → 9:16 (`ASPECTS`); `fitStage()` keeps the stage 16:9 of its width and centres the narrower shapes in it.

---

# 7. Node: Surfaces and Modes

## 7.1 Host check and compact viewport
Two checks pick what opens; neither detects the device.
- **Host check** (`PUBLIC_HOST`, read once): onemanshyo.github.io, or onemanshyo.com and its subdomains = the public site; anywhere else (Claude preview, file://, localhost) = off-site (`AUTHOR_MODE`).
- **Compact viewport** (`compactMQ`, re-checked live): `(orientation:portrait), (max-height:500px)`.

| | Not compact | Compact |
|---|---|---|
| Public site | CREATE · PUBLIC (VISUAL header plain) | Pocket Rave, switching by itself with the viewport |
| Off-site | CREATE · AUTHORING; VISUAL cycles AUTHORING → PUBLIC → POCKET RAVE | compact AUTHORING; VISUAL cycles AUTHORING → POCKET RAVE |

Off-site the compact check only reshapes the authoring layout; only taps switch the surface (`setSurface`).

## 7.2 MODES: PUBLIC and AUTHORING
Every value that differs between the two modes lives in one table, `MODES`; app code reads `mode()` instead of testing the mode flag. A new feature that differs by mode adds a key there.

| Key | AUTHORING | PUBLIC |
|---|---|---|
| autoplay / loop | on / on | off / off |
| idle message | "Authoring mode · AMU is the clock" | "Ready · AMU is the clock" |
| roll height / window | 75 px / 16 beats | 150 px / 32 beats |
| readout line | yes | no |
| placeholder waveform before audio | no (sidecar loudness) | yes |
| song info from the sidecar | yes | no |

`LAYOUT.render()` / `LAYOUT.author()` move the same elements between the two arrangements (nothing is duplicated); `setMode(on)` switches mode, layout, roll and messages.

## 7.3 Pocket Rave
The public site's compact surface. Opens full frame (`.pr-expanded`); the ONEMANSHYO header toggles full frame and the normal view (off-site a further tap goes to compact authoring); the top strip (power light, jacks) returns off-site to AUTHORING. Normal view: MUSIC / ABOUT / LEARN tabs, the shader, the music row (cover beside the waveform), version line, Yobot, PLUR. Shader: tap = play / pause; double tap in full frame = normal view, in the normal view = `.wgsl` picker. Cover: tap = song info over the waveform; double tap = MP3 picker. Chrome redraws at about 22 fps only while Pocket Rave is on screen.

## 7.4 Compact authoring
Off-site on a compact viewport: Pocket Rave's frame and header with the authoring sections in one column (one row of 12 lanes, colour bars for chips, knobs up to 40 px). It can be forced on a wide viewport (Pocket Rave header, third tap), where it shows as a 430 px column.

---

# 8. Node: Authoring (the template the app carries)

The app is the shader authoring template: a copy of the app HTML at any build works on its own as the template, opening in AUTHORING off-site. There is no separate template version line; the app build is the template version. To author a shader, copy out the current app HTML; it becomes `OMS_Vizzie_Shader_<Name>_V<nn>.html` with its `.wgsl`.

## 8.1 The per-shader block
One contiguous block holds everything a shader fills: `RULES` (TECHNICAL, carried unchanged), `NOTES`, `BUILD`, `TEMPLATE` (the app build it was copied from), the `WGSL`, the embedded `AMU`, `SPECDOC` (scene, music understanding mapping, objects definitions, hierarchy), `CHANGELOG`, `RIG` (one entry per object), the objects-toggle and CRYPTOMATTE patches, and the overlay slots (`OV_PRELUDE`, `OV_V`, `OV_H`, `OV_AP`, `OV_FRAME_M`). App code sits outside it.

## 8.2 Renderer hooks: AUTH_GPU
Everything the preview adds to the WebGPU renderer lives in `AUTH_GPU`; the renderer calls `init`, `patch`, `entries`, `write`, `copy` and `read`. `patch(src)` adds the preview-only bindings (1 object mask, 2 overlay probe, 3 CRYPTOMATTE table) and patches; the shipped `.wgsl` is unchanged.

## 8.3 Objects toggle and CRYPTOMATTE
One tile per object (`RIG`) shows or hides it on the stage through a bit mask (binding 1). CRYPTOMATTE paints each object in its ID colour (binding 3, `cmTable()`), from `RIG` `cm` or a colour from the tile index.

## 8.4 Authoring overlay
GRID, GUIDES and POINTS draw on a 2D canvas over the stage, never in the shader (R5). Guides and anchor points are WGSL expressions of the shader's own constants (R6): the preview's shader evaluates them at one pixel (`ovProbeWGSL()`, binding 2), reads them back every sixth frame and `drawOverlay()` draws them. The probe is generic: a shader's `OV_PRELUDE` defines `ov_origin` (vec2) and `ov_m` (frame units per metre); guides are metres from `ov_origin`, anchor points are frame units.

---

# 9. Node: Tabs

CREATE / ABOUT / LEARN via `switchPanel()`. CREATE is the working surface. ABOUT carries the description, credits, licenses and technical notes. LEARN is not a panel: the tab calls `openLearn()`, which opens `https://onemanshyo.com/#learn` in a new tab.

---

# 10. Leaf Reference: Controls & Keyboard

- **Music:** cover (tap = song info, double tap = MP3 picker) · waveform (click / drag = seek, double tap = MP3 picker) · drop an audio file on the music row.
- **Transport:** PLAY / PAUSE · LOOP · TEMPO (− value +, %, double-click resets) · KEY LOCK.
- **Visual header:** VISUAL label (off-site: switch mode / surface) · `</> Code` · Pop Out · orientation · record · rec timer. Stage: drop or double tap = `.wgsl`.
- **Controls header:** − zoom % + · roll orientation · SOLO.
- **Encoders:** drag = intensity · press = solo · double-click = reset. Chips: click = solo. Bus headers: click = group solo.
- **Piano roll:** drag = scrub · click = cue to block start · pinch / ctrl + wheel = zoom.
- **Keyboard:** SPACE = play / pause (ignored while typing). Esc closes the song info.
- **Pocket Rave:** see 7.3.

---

# 11. Design System

## 11.1 Philosophy
Vizzie follows the OMS **Human Interface Guidelines** (Chippy section 10): a hardware mindset (once you settle and package, it must be right) and things look as good on the inside (CSS, class structure, markup) as on the outside.

## 11.2 What the Design System is
The shared OMS tokens and component language: the `.app` shell (wood-cheek / metal-rail frame), `.header` (gradient ONEMANSHYO brand + app tag + version + Yobot logo), `.tabbar` / `.tab`, `.sec-hdr` dividers, the `.btn` family, and the `.message-bar` footer. Exact values and classes live in Y.

## 11.3 What we DO
- Section headers are cyan `#00d4ff`; the authoring sections use orange `#ffa500` headers. New UI inherits `.sec-hdr` / `.btn`, never a parallel hand-rolled style.
- Header-strip buttons sit at the far right of the section header that owns them.
- Bus headers use a rainbow (RHYTHM red, STRUCTURE orange, KEY yellow, PACE green, LOUDNESS blue, INSTRUMENTS violet); lane colours are 11 pairwise-distinct hues + white for beat, one colour per parameter everywhere.
- Active state = border colour + tint + glow (LOOP cyan, SOLO pink, record pink pulse).
- All status and hover help goes to the message bar.
- Mode differences go in `MODES`, not in scattered checks.

## 11.4 The module hierarchy
**section → bus module → lane cell → chip + encoder** (`.amu-mod` → `.amu-cell` → `.lab-lane` + `.amu-knob`). The piano roll sits in its own module perimeter aligned with the bus modules above.

---

# 12. Sources: AMU Data & Shaders

## 12.1 AMU data
Apple's Music Understanding framework (Swift module `MusicUnderstanding`) analyses a track on-device; the OMS Sozo Sidecar writes it to JSON; Vizzie embeds it. Chain of trust: Apple → Sozo → JSON → `amu()` and `CLOCK` → `pack()` → shader. Apple is the authority.

## 12.2 Shaders
Vizzie runs any WGSL shader written to the uniform contract. Shaders are authored in the app itself (section 8), named `OMS_Vizzie_Shader_<Name>_V##.wgsl` / `.html`, and kept in `VIZZIE/App Folder/Library/Shaders/`, one folder per shader. Moving a shader onto V0.7.0 means restating any `vizzie.time` rates per beat (2.2.2).

---

**END OF DEVELOPER DOCUMENTATION**
