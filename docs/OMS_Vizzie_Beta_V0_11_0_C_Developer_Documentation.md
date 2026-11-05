# OMS Vizzie app [Beta V0.11.0] Developer Documentation

**Run date:** 2026-11-05  
**Current Unix Epoch:** 1793912480  
**Document purpose:** The explanatory technical spec for OMS Vizzie: how each system works and why. Uses the shared OMS **Cortex / Node / Leaf** vocabulary (Dojo, Chippy), sized to Vizzie's scope.  
**Filename:** OMS_Vizzie_Beta_V0_11_0_C_Developer_Documentation.md  

## About this document

Vizzie Beta V0.11.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## CONTENTS

**1** Introduction  
&emsp;1.1 What is Vizzie?  
&emsp;1.2 Application development tiers  
**2** Cortex and the Critical Stack  
&emsp;2.1 The master music clock (CORTEX)  
&emsp;2.2 The uniform contract (critical: the one public interface)  
&emsp;2.3 The WGSL runtime (critical)  
&emsp;2.4 Message System: the feedback bar (CORTEX)  
**3** Node: Deck Audio, Tempo, Key Lock  
&emsp;3.1 Deck audio engine  
&emsp;3.2 Warp: steering the deck to the clock  
&emsp;3.3 TEMPO and the tempo master  
&emsp;3.4 KEY LOCK  
**4** Node: Deck Controls (one code for every deck)  
&emsp;4.1 The control strip  
&emsp;4.2 Lanes, buses and encoders  
&emsp;4.3 Solo  
&emsp;4.4 Piano roll  
&emsp;4.5 Drops and double-tap loaders  
**5** Node: Song Info, Audio Loading, Waveform  
&emsp;5.1 Loading audio  
&emsp;5.2 ID3, cover art and the song info  
&emsp;5.3 Waveform  
&emsp;5.4 Loading a track's AMU JSON  
**6** Node: Viewer Surfaces  
&emsp;6.1 Code view  
&emsp;6.2 Drop or pick a `.wgsl`  
&emsp;6.3 Pop-out  
&emsp;6.4 REC  
&emsp;6.5 Orientation  
&emsp;6.6 Arrangement position  
**7** Node: Surfaces and Modes  
&emsp;7.1 Host check and compact viewport  
&emsp;7.2 MODES and LAYOUT: CREATE and AUTHORING  
&emsp;7.3 Global strips  
&emsp;7.4 Pocket Rave  
&emsp;7.5 Compact authoring  
&emsp;7.6 CREATE: LIBRARY, FX and the playlist controls  
&emsp;7.7 The Moogerfooger strip and the header rename  
**8** Node: PERFORM  
&emsp;8.1 Two decks on one clock  
&emsp;8.2 The deck view  
&emsp;8.3 QUANT  
&emsp;8.4 Master position  
&emsp;8.5 Mixer, OUT and encoders  
&emsp;8.6 Layout fit  
&emsp;8.7 Panel strip: MODE · FX · EQ  
&emsp;8.8 FX  
&emsp;8.9 LIBRARY  
&emsp;8.10 Playlist QUEUE  
&emsp;8.11 Demo playlists (the website set)  
**9** Node: Authoring (the template the app carries)  
**10** Node: Tabs  
**11** Leaf Reference: Controls and Keyboard  
**12** Design System (Human Interface Guidelines)  
&emsp;12.1 Philosophy  
&emsp;12.2 What the Design System is  
&emsp;12.3 Buttons  
&emsp;12.4 Fields  
&emsp;12.5 Spacing  
&emsp;12.6 Lines and modules  
&emsp;12.7 Colour semantics  
&emsp;12.8 Interaction pattern matrix  
&emsp;12.9 The module hierarchy  
&emsp;12.10 Known design debt  
**13** User Media: AMU Data and Shaders  

---

# 1. Introduction

## 1.1 What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

## 1.2 Application development tiers
- **Cortex** = the small, load-bearing core. Everything traces back to it; a change cascades everywhere. The label is used **sparingly on purpose**: if everything is Cortex, the word means nothing. In Vizzie two systems carry it: **the master music clock** (timing) and **the Message System** (the single feedback channel), matching the OMS suite convention.
- **Node** = a feature system that depends on the Cortex but that the app's core function survives changes to. Most of the app is Nodes.
- **Leaf** = a small control or affordance hanging off a Node.

---

# 2. Cortex and the Critical Stack

The Cortex is the master music clock. Above it sit three layers that each depend on the one below: the uniform contract, the WGSL runtime, and the shader.

| Layer | What it does | Tier | If it breaks |
|---|---|---|---|
| 1. Master music clock (`MASTER`, each deck's warp map, the AMU reader `readAMU(d,t)`) | says where we are in the music, in beats, every frame | **CORTEX** | nothing is in time; the picture has no musical meaning |
| 2. Uniform contract (`pack()`) | turns musical position into the 36 floats a shader reads | critical | shaders receive garbage or stale values |
| 3. WGSL runtime (`main()`, `build()`, per-frame draw) | compiles the shader and draws it | critical | no picture at all |
| 4. The shader (default or user-loaded) | the actual look | rides on top | you lose *that look*, not the app; load another |

## 2.1 The master music clock (CORTEX)

**The one law: music time is the clock of record.** Position is counted in bars and beats, never in elapsed seconds, frame counts or audio energy. Seconds exist only at the edge, where the computer world needs them: the decoded audio buffer and the track's beat map. Conversions live there, not the other way round.

### 2.1.1 MASTER and the decks
`MASTER` is the one master music clock for the app: `MASTER.beat` and `MASTER.tempo` (BPM, set by TEMPO, 3.3). It owns no track and no audio. `MASTER.advance(dt)` adds `dt × tempo / 60` beats and returns them: the master grid is evenly spaced at the TEMPO.

A deck (`makeDeck(id,amu)`) is one track on the master clock. Its position is `d.beat`, in its own track's beats: beat 0 is the track's first AMU beat, the fraction is the phase within the beat. Every frame each playing deck moves by the beats the master moved. `DECKS` holds the decks; `DK` is deck A, the deck CREATE shows and drives. PERFORM adds deck B (8.1); deck A on PERFORM is the same deck object as CREATE's, by design. A deck carries its AMU, warp map, lane data, knobs and solos, play / KEY LOCK state, a pending QUANT action (`d.pend`, 8.3) and its audio engine; `d.setTrack(amu)` replaces its track (5.4).

### 2.1.2 The warp map
Each track's AMU beats are its warp markers, set by the analysis instead of by hand. `warpMap(beats)` builds each track's smoothed map once: each AMU beat time is replaced by a straight-line fit over the beats within ±8 (a 4-bar window), so analysis jitter averages out while real tempo drift is still followed (on Ain't No Trick the AMU marks sit 7.7 ms off a steady grid typically, 22.7 ms worst). `d.timeToBeat(t)` and `d.beatToTime(b)` convert through the deck's map (linear between beats, extended past the first and last beat at their spacing); `d.beatLen(b)` is the track seconds per beat at beat `b`, the track's local tempo. `d.t` is a getter / setter through the map, for the places that need track seconds (the audio, the AMU reader).

### 2.1.3 Heartbeat and the loop
`hb()` is the clock's heartbeat: `audioCtx.currentTime` (the audio hardware clock) once a track is loaded, otherwise `performance.now()`. One rAF loop, `chrome()`, does, in order, every frame:
1. advances `MASTER` by the heartbeat delta (clamped to 0.1 s);
2. moves each playing deck by the same number of beats and steers it (3.2), or handles its track end;
3. `quantTick()`: fires due QUANT starts and cues; a deck playing alone leads the master grid (8.3);
4. advances the master position (8.4);
5. `masterTick()`: hands the tempo master to a playing deck when needed (3.3);
6. sizes the stage, writes the readout and the arrangement position, draws the CREATE chrome (knobs, waveform, piano roll, song info line), then calls PERFORM's draw (`window.__perfDraw`), which also runs `fxTick()` (8.8).

**LOOP** (`d.loop`, `d.loopSpan`), per deck. `d.loopSpan` is null (the whole track) or a chip's span `{li,start,end}` (`amuSpan()`; a ticks lane's chip runs to the next tick). With LOOP on and a span, the deck wraps from the span's end to its start every frame, keeping the beat's fraction (the end is a musical boundary; no extra wait).

**Track end**, per deck: with LOOP on the deck wraps to 0 and plays on; with LOOP off it stops and its playhead returns to the start. While REC records on CREATE: LOOP off, the track end stops the recording; LOOP on, the recording runs across the wrap. A picked chip being rendered (`REC.span`) stops the recording and the deck at the chip's end (6.4). `seekTo(sec,d)` sets `d.t` and moves that deck's audio with it. A `visibilitychange` handler drops the stale delta when the tab returns.

Every deck opens paused (`MODES.autoplay` is false in both modes since V0.8.08a).

### 2.1.4 The AMU reader
`readAMU(d,t)` reads deck `d`'s AMU at track time `t` and returns the contract's fields: beat and bar phase (`phaseIn`), section / segment / phrase progress and index (`span`), key mode and tonic, momentary loudness, pace, and the four instrument activities (`sample`). The beat count for `vizzie.time` comes from `d.beat`, not from `readAMU()`.

### 2.1.5 The embedded data
The AMU sidecar is embedded as `const AMU={…}`: `len`, `bpm`, `beats` and `bars` (ascending times), `sec` / `seg` / `phr` (`[start,end]` pairs), `key` (`[start,end,mode,tonic]`), `pace` (`[start,end,value]`), `mom` (momentary LUFS as `{t0,dt,v}`) and `act` (`drum`, `bass`, `vocal`, `other`, each `{t0,dt,v}`). Names and values come from Apple's `MusicUnderstanding` framework as written by Sozo Sidecar V2; the embed is compacted (arrays, evenly sampled curves). `TRACK`, `BPM` and `SONG` (the track length) derive from it. This embedded AMU is the default track for every deck (the authoring pack, 9); a deck can load another track's AMU (5.4).

## 2.2 The uniform contract (critical: the one public interface)

Contract **V0.4.0D**, unchanged in this release: **9 × vec4 / 36 floats / 144 bytes**, frozen like a published API: new data goes only into reserved slots, never by renaming or reshuffling. `pack(dk,a,w,h)` builds all 36 floats each frame for deck `dk` from the AMU reader's fields (`a = readAMU(dk, dk.t)`), the deck's gates and beat, and the canvas size. Each PERFORM deck packs its own uniforms for its own shader. The full slot table is in Y 2.2.

### 2.2.1 Namespaces
- **WGSL/WebGPU standard**: types, attributes, built-ins. Untouched.
- **`amu.`**: Apple's value itself, sampled at the playhead (mode, momentary LUFS, pace, stem activity, tonic).
- **`vizzie.`**: anything Vizzie computed (gates, time, phases, progress, indices, key index, resolution).

### 2.2.2 Rules
- The contract carries **raw AMU values**. Scaling and shaping are the shader's own choice.
- Nothing enters the contract that is not AMU data or an explicit, requested Vizzie derivation (the removed `break` signal is the cautionary example).
- **`vizzie.time` (slot 13) is the deck's cumulative beats** (beat 0 = its track's first AMU beat), advancing on the master clock. There is no seconds slot and no tempo slot: subdivisions are maths on the beat value (one turn per bar = `t * TAU / 4.`). Because it is beats, motion driven by it follows TEMPO.
- Pulse is 1 − phase; a shader computes it if it wants one. `amu.mode` is 0 major / 1 minor.

### 2.2.3 Gates
Slots 0 to 12 carry, per lane, (soloed-in ? 1 : 0) × encoder intensity (`d.gate(id)`, looked up by slot with `d.gateOf(i)`), so a shader multiplies each element by its gate and the controls work on any shader.

## 2.3 The WGSL runtime (critical)

`main()` requests the adapter and device, configures a `webgpu` context on `#labGpu`, creates the 144-byte uniform buffer and calls `AUTH_GPU.init(device)`. `build(src)` compiles the shader (through `AUTH_GPU.patch`, 9.2), reads `getCompilationInfo()`, and only if it is clean builds a new pipeline and bind group and swaps them in: a bad shader never kills the running one; the error line shows in `#labGpuMsg`. `build` is exposed as `window.__applyWGSL`.

### 2.3.1 Why it runs like a game engine
Per frame: write 144 bytes, the authoring buffers when on, one render pass, `draw(6)` (a full-screen quad). No per-frame recompilation, no analysis, no cross-origin messaging. Keep it that way.

### 2.3.2 Full shaders only
`WGSL` is the default scene as a complete shader (`struct U`, binding, `vs`, `fs`). Apply, drop and pick compile the source as-is.

### 2.3.3 One CREATE viewer, deck textures on PERFORM
CREATE has exactly one WebGPU canvas. `window.__placeGpu()` moves it, with its overlay canvas and error line, between the CREATE stage (`#labStage`) and Pocket Rave (`#prPlay`). Never create a second WebGPU canvas for another CREATE surface: move the one.

PERFORM is the exception by design: each PERFORM deck renders its own shader into its own texture (`window.__deckGpu`), shown on that deck's stage (the deck's "headphones"), and OUT (`window.__outGpu`) blends the two textures (8.5).

## 2.4 Message System: the feedback bar (CORTEX)

Built and working on CREATE and PERFORM. Every message and its wording is listed in E 9 (Message index).

**Troubleshooting note (V0.9.24a).** Hover help stopped after any click in one Chrome profile: after the click Chrome sent no more mouse movement to the page (the page kept running, `document.hasFocus()` true); switching apps and back restored it. Safari and a clean Chrome profile worked. The cause was a Chrome extension in that profile; with extensions removed and Chrome restarted, hover works. Vizzie's hover code was not the cause and was not changed.

### 2.4.1 The contract (as Dojo, OMS App V5.9.0)
The **single channel for transient user feedback** is the bar at the bottom of the app (`#messageBar`). Every module speaks through `showMessage(text, type, onClick)`; no module rolls its own feedback, and browser tooltips are not used (`bindHelp` moves every `title` into the bar's help and removes it).
- **`info` (cyan `#00d4ff`)**: help on hover or focus, "Name (keys)". Leaving a control clears the bar.
- **`state` (orange `#ffa500`)**: the value or confirmation after a change (Playing, TEMPO 129.01 BPM, QUANT 1 Bar, Cue …).
- **`error` (Red Hots `#ff006e`)**: failures (bad drop, decode failure, pop-out blocked, recording unsupported).
- An empty `info` never overwrites a `state` message (Dojo V5_0_17), so action feedback survives the pointer moving off.
- `onClick` makes a message clickable (pointer cursor).
- Idle = an empty bar, as Dojo.

### 2.4.2 Help text and binding
Help lives in one table, `HELP` (selector → text or function), plus the shared components (control strip, lanes, buses, encoders, FX cells, LIBRARY entries and filters), so every deck gets the same help; PERFORM deck controls prefix "Deck A:" / "Deck B:". `bindHelp()` binds each control's own `mouseenter` (show), `mouseleave` (clear, or return to the help of the control it sits in) and `focusin`, as Dojo binds it. Help text says what a control is and only its non-obvious keys (double-click, drag, arrows); it never says "(click)". Toggles say their state. Live help: lanes show their live values, buses their lanes' levels, encoders their value.

---

# 3. Node: Deck Audio, Tempo, Key Lock

## 3.1 Deck audio engine
`makeDeckAudio(ctx,buf,canStretch,keyLock)` plays the decoded track through Web Audio: an `AudioBufferSourceNode` (or the KEY LOCK worklet) into a `pre` node, then the deck gain node, into the output. The FX rack sits between them where the deck's FX are live (`FX_LIVE`, 8.8): PERFORM, and deck A on CREATE: `pre` → AFX1 → AFX2 → gain; in AUTHORING and Pocket Rave `pre` connects straight to the gain. Position = the offset played from + AudioContext time since the start × rate (the audio hardware clock, sample-accurate). It keeps the interface the app used with an `<audio>` element (`currentTime`, `duration`, `paused`, `ended`, `play`, `pause`, `captureStream`) plus `rate` and `keyLock`. One engine per deck (`d.audio`), all on the app's one AudioContext. `audioContext()` creates the AudioContext inside the drop or pick gesture; any pointer, key, touchend or click event resumes it if the browser suspended it. Web Audio only, no browser-specific APIs, with two iOS / iPadOS Safari provisions (V0.10.07d): `navigator.audioSession.type = 'playback'` where the browser has it, so silent mode does not mute the music, and the first touchend or click plays one silent sample (`audioUnlocked`), which unlocks the AudioContext for the session.

Deck volume: on PERFORM each deck's gain follows its AUD encoder (8.5); on CREATE deck A plays at full.

## 3.2 Warp: steering the deck to the clock
`steerDeck(d)` runs every frame for each playing deck. Target = the deck's track time (`d.t`). Speed = its warp map's local tempo × TEMPO (`d.beatLen(d.beat) × MASTER.tempo / 60`), times a correction that closes the gap over about a second, capped at ±2 %. A gap over 250 ms (a seek, a stall) is jumped instead. Known limit: the KEY LOCK worklet's real read position is not reported back, so the gap is measured against the engine's own position model.

A seek, PLAY or load on one deck does not reset the master clock's last tick (V0.8.09b), so scrubbing one deck never stalls another.

## 3.3 TEMPO and the tempo master
**The tempo master** (`tempoMaster`) is the deck that sets the tempo, as Traktor AUTO and the CDJ master. The deck started first is master. When the master stops and another deck is playing, `masterTick()` hands mastership to that deck. With nothing playing, the master stays. An incoming deck never sets the tempo, and the tempo never changes on a start, a stop or a handover. On CREATE alone the master is deck A. Deck B keeps playing when you switch tabs, so if deck A stops while deck B plays, deck B becomes master and CREATE's TEMPO double-click then goes to deck B's BPM. On PERFORM the master deck's MASTER indicator is lit.

**TEMPO** is one field in the global strip (7.3), the same field on CREATE and PERFORM (`bindTempoField(tv)`): click in, ↑ / ↓ = ±1 BPM, ← / → = ±0.01 BPM, type a value and Enter, Escape leaves the field, double-click = the master deck's track BPM exactly. These keys act only in that field; there are no app-wide tempo keys. `setTempo(bpm,exact)` sets `MASTER.tempo`, rounded to 0.01, clamped to half and one and a half times the **master deck's** track BPM, and every loaded deck's rate. `d.ratio()` = master tempo / the deck's track BPM. The change message is "TEMPO 129.01 BPM" (orange). There is no tempo % any more.

## 3.4 KEY LOCK
On, the deck plays through the `vizzie-stretch` AudioWorklet: a WSOLA time-stretch (Hann-windowed frames, overlap-added) that holds pitch at any rate. The worklet source is `STRETCH_SRC`, loaded once per AudioContext by `loadStretch(ctx)` as a `data:` URL module (a `blob:` module is refused from `file://`; blob is the fallback). Transients: `findOnsets(buf)` finds the track's onsets once (high-passed level steps over twice the recent average, at least 50 ms apart) and the worklet places attacks so drum hits keep their snap. Off, the plain source's playback rate moves pitch with tempo, like a turntable.

Per deck (`d.keyLock`), **on by default** on every deck since V0.8.28a. Where the browser has no AudioWorklet, KEY LOCK shows off and disabled.

---

# 4. Node: Deck Controls (one code for every deck)

Since V0.8.07a every deck control is one shared component, used by CREATE's deck, both PERFORM decks and, for the pickers, Pocket Rave. A deck view places the components; it owns no control of its own. A fix to a component reaches every deck.

## 4.1 The control strip
`STRIP` is the one definition of a deck's transport buttons: **PLAY** (`.btn primary`), **LOOP** and **KEY LOCK** (`.btn loop`). `buildStrip(holder,o)` builds them into a deck view (`o.ids` keeps CREATE's element ids, `o.ctx.mix` says whether decks are mixed); `bindDeckButtons(d,b)` binds them and SOLO; `deckButtonsUI(d,b)` shows their state each frame (PLAY / PAUSE text, `armed` while a QUANT start waits, LOOP lit, KEY LOCK lit, SOLO lit). CUE was removed in V0.8.21a (it did nothing); LOOP, removed in V0.8.41a, came back in V0.9.06a as the musical loop (2.1.3).

PLAY goes through `deckPlayPress(d)`: a start waits for QUANT when another deck is playing, on either tab (8.3); a second press while armed cancels it. A deck's own PLAY clears the master PLAY's memory (8.4).

## 4.2 Lanes, buses and encoders
`LANES` holds the 12 AMU parameters (beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other), each with an id, bus, label, colour, draw kind, contract slot and data. `buildLanes(d,box,o)` builds a deck's six bus modules (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS), each lane a cell with a chip and an encoder. `o.buses` adds the bus headers; `o.labels` gives short chip labels (`LANE_SHORT`); `o.chips` builds chips only, no encoder (the mini players).

Encoders: endless-encoder model. Drag up / down = intensity 0 to 1 (`d.knob`, per deck), a press without dragging = solo, double-click = back to 1. Bus header click = group solo.

**Mini players** (PERFORM decks and CREATE's `#labMini`, V0.9.17a): each lane is a chip (click = solo), no encoder; the bus headers are thin colour bars without text; the solo shows on the chip. The lane gain (`d.knob`) stays at its value (1) in the deck model, so shaders get the same gates. AUTHORING keeps the full section: chips, encoders and named bus headers. On CREATE the large section is hidden and not painted (`paintLanes` runs on it in AUTHORING only).

## 4.3 Solo
Owned per deck by `makeSolo()` (`d.solo`): a set of lane ids and `grp:<bus>` keys. `d.solo.on(id)` is true when nothing is soloed, the lane is soloed, or its bus is. Solos are additive. The deck's SOLO button lights when any solo is active and clears all on click. One canonical id per parameter (the lane id) is used by the chips, the encoders, the gates and SOLO.

## 4.4 Piano roll
`deckRoll(cv,d,o)` is one roll component for every deck: draw, scrub, cue, zoom and orientation. **Its axis is master-grid beats**: the window starts at `R.view(t).b0` and is `R.win()` beats long; lanes come from the deck and are placed by `d.timeToBeat`, so bars stay bars at any TEMPO. The playhead is fixed at the centre (`ROLL_PH` = 0.5) at every zoom; the content scrolls under it.

- **Window:** `o.base()` beats at zoom 1 × `R.zoom`, up to twice the song (`R.maxZoom()`), so the whole song is in view from the centre playhead wherever it is. Base: AUTHORING's roll `ROLL_WIN` from `MODES` (16 beats = 4 bars); CREATE's mini roll and PERFORM 16 beats.
- **Zoom field:** one data field (`ui.field`), the standard field (12.4). Click in, ↑ / ↓ move through five steps, 0, 25, 50, 75, 100. `R.step()` maps the zoom to that scale: 0 = the closest view (zoom 1), 100 = the whole song, evenly spaced between. Ctrl + wheel and two-finger pinch on the roll still zoom freely; the field shows where that lands on the same scale.
- **Opening view:** `o.step` and `o.horiz`. PERFORM rolls and CREATE's mini roll open at 25 %, horizontal. AUTHORING's roll opens vertical at 0 %.
- **Two rolls on the CREATE panel** (`o.active`): the full roll is active in AUTHORING, the mini on CREATE (the full roll is hidden there, V0.10.05a); each keeps its own zoom and orientation, and `R.syncUI()` puts the active roll's values on the shared zoom field and orientation button at every switch. The zoom field sits in AUTHORING's controls row and on CREATE's Music Understanding header (7.2).
- **Orientation:** vertical (lanes as columns) or horizontal (lanes as rows), toggled by the deck's orientation button.
- **Input** (`rollInput`): drag = scrub in beats; click without dragging = cue to that block's start (`amuStart` / `amuCue`: beat, bar, section, segment, phrase, key span, pace step; loudness and the instruments are not cue targets). A cue goes through `deckCue(d,sec,landed)` and waits for QUANT whenever the deck is playing and QUANT is not None (8.3). With LOOP on the cued chip becomes the loop span; clicking the lit chip again releases it to the whole track. On a stopped deck the chip is **picked** (`d.pick`): the playhead goes to its start and REC renders it (6.4); any other playhead move, or PLAY, clears it. The looped or picked chip is lit solid cyan (Dojo 'selected').

## 4.5 Drops and double-tap loaders
**One drop zone per deck, the whole deck** (`bindDrop(el,d)`), on CREATE and both PERFORM decks. `readDrop()` reads files and folders (File System Access handles first, which work on `file://`; then the older entries; then plain files) and records each file's path inside the drop (`f._rel`). The deck takes the **first file of each type** in drop order: `.wgsl`, AMU `.json`, audio, square cover image (`isImage`, `coverSize`); every other file is ignored and counted in the message. They load shader, AMU, audio, then the cover (after the track, so its message is last). While dragging, a layer covers the deck: dashed cyan edge, translucent blur, and one hint built by `dropHint(main,types)`: "Drop files" with the types one per line (the same standard on every drop zone). CREATE's LIBRARY module (`#labLibSec`, class `lib-drop`) sits inside the deck's drop zone but is the LIBRARY's own: `bindDrop` leaves drags over it alone, and a drop there goes to the LIBRARY (7.6), not the deck (V0.10.10e).

**Double-tap loaders** (`bindLoaders`, `bindCover`): two taps within 300 ms. Cover = MP3 / AMU picker, waveform = MP3 / AMU picker, stage = `.wgsl` picker (not inside CREATE's Code view). The `.wgsl` picker has no `accept` filter because iOS greys out `.wgsl` when filtered; the name is checked instead. Single taps keep their own job.

---

# 5. Node: Song Info, Audio Loading, Waveform

## 5.1 Loading audio
`loadAudioFromBlob(blob,name,d)` reads the ID3 tags, decodes the track, loads the KEY LOCK worklet in parallel, builds the deck engine at the current tempo, places it at the clock's position and computes the waveform peaks. Sources: a packed MP3 (`TRACK_MP3`, 9.1), the example MP3 auto-loaded on the hosted site when none is packed (http / https only, from `./examples/`), a drop on the deck, or the hidden pickers (4.5). Under `file://` the app runs on the AMU clock alone until audio is loaded.

## 5.2 ID3, cover art and the song info
`readID3()` is an inline ID3v2 parser (v2.2 to 2.4, UTF-8 / UTF-16, no library): cover (APIC), title, artist, label, year, copyright. **The picture is copied (`slice()`) before decoding**: `decodeAudioData` takes over (detaches) the file's buffer, and a view into it would read empty afterwards (fixed in V0.8.32a; PERFORM decks showed no cover art before). `deckCover(d)` gives a deck's cover: the authoring pack's `TRACK_COVER` on deck A when packed, else the MP3's art, else the default. `deckInfo(d)` gives title and artist from the tags, the file name or the embedded track's info.

**The song info line** (`infoLine(box,d)`) is one shared function for PERFORM's decks and CREATE in both modes: one line, "title · artist · BPM · key", one style (11px Courier New, `#cfd6dd`, on `rgba(10,10,10,.85)`). It always scrolls (`.pf-tick.run`, V0.9.05a) right to left at about 40 px a second, repeating after a gap so it loops without a jump. It is measured again only on a new song or a resize.

A cover tap shows or hides the info over the waveform (`bindCover`: single tap = toggle, double tap = picker); it stays until the cover is tapped again: no click-elsewhere or Esc close, mode switches and track loads leave it as set. The info lets the pointer through (`pointer-events:none`), so the waveform keeps working under it.

CREATE uses the same line since V0.9.03a (the static panel is retired there and the cover no longer flips; the flip stays in AUTHORING). The panel's fields stay in the page, hidden: Pocket Rave reads them.

**Dropped cover** (V0.9.16a): a square image dropped on a deck (`setDeckCover`) sets `d.coverURL`, which wins in `deckCover(d)` over `TRACK_COVER` and the ID3 art; loading another track clears it (`clearDeckCover`).

## 5.3 Waveform
`computeLevels(buffer,600)` → normalised RMS peaks per deck (`d.peaks`). `waveView(cv,d,hold)` draws a deck's whole-song waveform with its own cache, rebuilt when the audio, the track or the size changes, and its own playhead. A click without drag is a cue through `deckCue()` (on QUANT while playing, message 'Cue · bar x.y · QUANT n'); a drag of 4 px or more scrubs (V0.9.04a). Before audio: on CREATE a dim placeholder envelope, in AUTHORING the sidecar's momentary loudness. The waveform is a whole-song view.

## 5.4 Loading a track's AMU JSON
A Sozo Sidecar v2 `.json` dropped on a deck, or picked with the MP3 picker (CREATE, PERFORM decks and Pocket Rave), is recognised by its file type (`isAMU`). `amuFromSozo(j)` converts it to the compact AMU (`rhythm`, `structure`, `key`, `pace`, `loudness.momentary`, `instrumentActivity`; tonic names to 0 to 11 via `TONICS`; the instruments' ranges are not carried, as in the embedded AMU) and refuses a file that does not match, naming the missing field. `loadAMUFromFile(f,d)` puts it on the deck with `d.setTrack()`: new warp map and lanes, playhead to the start, the song title from the JSON's `file` field until ID3 tags fill it. Audio and AMU load in either order; `checkPair(d)` reports a loaded MP3 more than 2 s longer or shorter than the AMU. The key name comes from the track (`TONIC_NAMES`).

---

# 6. Node: Viewer Surfaces

These are on the CREATE panel (CREATE and AUTHORING). PERFORM has no Code, REC or Pop Out (8.2). On CREATE the stage shows deck A's visual FX when a VFX slot is live (7.6), so Pop Out and REC carry them too.

## 6.1 Code view
`</> Code` shows the current shader source; **Apply** compiles it as the preview (`window.__applyWGSL`); **Copy** copies it.

## 6.2 Drop or pick a `.wgsl`
Drop a `.wgsl` on the deck, or double-tap the stage to pick one: the code view fills and the same compile path runs.

## 6.3 Pop-out
`openPopOut()` opens a window with a `<video>` whose source is `#labGpu`'s capture stream: the same pixels, hot-swapped shaders included. Double-click for fullscreen.

## 6.4 REC
REC records from the playhead (`startRec()`, no jump to 0; V0.9.07a). On a stopped deck with a picked chip (4.4): LOOP off = one pass, `REC.span`, and `chrome()` stops the recording and the deck at the chip's end ('Chip rendered · recording saved'); LOOP on = the chip loops and the recording runs until REC is pressed again. With no pick: from the playhead to the track end (LOOP off) or across the wraps until REC is pressed (LOOP on). On a playing deck it records from where it is. Capture stream of `#labGpu` at 60 fps + the deck engine's audio (`captureStream()` on its gain) → `MediaRecorder`, preferring H.264 / AAC MP4, falling back to VP9 / VP8 WebM; downloads as `VizzieWGSL_<WxH>_<time>`. The arrangement position box turns red while recording.

## 6.5 Orientation
Cycles 16:9 → 1:1 → 9:16 (`ASPECTS`); `fitStage()` keeps the stage 16:9 of its width and centres the narrower shapes in it.

## 6.6 Arrangement position
`arrPos(a)` formats a deck's position as Ableton's arrangement position: bars.beats.sixteenths, the bar right-aligned in four places (1.1.1 to 9999.4.4), so the box has a fixed width and never moves as the bar count grows. One formatter and one box style (`#labRecTime`, `.pf-pos`) serve CREATE and every PERFORM deck. CREATE's box sits in its global strip (7.3): CREATE has one deck, so its position is the master position.

---

# 7. Node: Surfaces and Modes

## 7.1 Host check and compact viewport
Two checks pick what opens; neither detects the device.
- **Host check** (`PUBLIC_HOST`, read once): onemanshyo.github.io, or onemanshyo.com and its subdomains = the website; anywhere else (Claude preview, file://, localhost) = off-site (`AUTHOR_MODE`).
- **Compact viewport** (`compactMQ`, re-checked live): `(orientation:portrait), (max-height:500px)`.

| | Not compact | Compact |
|---|---|---|
| Website | Tabs CREATE · HELP · ABOUT · LEARN; opens on CREATE | Pocket Rave, switching by itself with the viewport |
| Off-site | Tabs CREATE · PERFORM · AUTHORING · HELP · ABOUT · LEARN; opens on AUTHORING | compact authoring; its header goes to Pocket Rave |

**PERFORM and AUTHORING are off-site only**: on the website their tabs (and PERFORM's panel) are removed from the page. Off-site on a wide viewport, Pocket Rave is reached through compact authoring (a compact viewport, 7.5); the section headers switch nothing since V0.10.08a.

## 7.2 MODES and LAYOUT: CREATE and AUTHORING
CREATE and AUTHORING are two tabs over one panel, `#panelLab`, in two modes (V0.10.08a). `switchPanel('author')` shows `#panelLab` and calls `setMode(true)`; `switchPanel('lab')` shows it and calls `setMode(false)`. Every value that differs between the two modes lives in one table, `MODES` (keys `authoring` and `public`; `public` is CREATE); app code reads `mode()` instead of testing the mode flag (`authorOn`, html class `author-on`). A new feature that differs by mode adds a key there.

| Key | AUTHORING | CREATE (`public`) |
|---|---|---|
| autoplay / loop | off / off | off / off |
| roll height / window | 75 px / 16 beats | (the large roll is hidden) |
| readout line | yes | no |
| placeholder waveform before audio | no (sidecar loudness) | yes |
| song info from the sidecar | yes | no |

`LAYOUT.render()` / `LAYOUT.author()` move the same elements between the two arrangements; nothing is duplicated. The Visual header row is found by its label (`#labVisTxt`), not by position.

**CREATE** (`LAYOUT.render()`), top to bottom:
1. **GLOBAL** section header (`#labModeHdr`, text `Global`) over the global strip (7.3).
2. A row of two columns. Left, under a **Music** header (`#labVisTxt` reads Music): `#labLeftCol` holding the music row (`#labMusic`, 40 px: cover 40 × 40 and the waveform), the controls row (`#labTransportHold`) and the LIBRARY module (`#labLibSec`, 7.6) down to the stage's bottom. Right, under a **Visuals** header holding Code, Pop Out, orientation and REC: the stage.
3. **Music Understanding** (`#labMuSec`), full width: the mini (`#labMini`: `buildLanes` with chips and bus bars, and its own `deckRoll` on deck A). Its header carries the roll zoom field and SOLO at the far right (V0.10.10d), at the header buttons' height. `LAYOUT.fitMu()` sizes the mini down to the bottom of the page (at least 160 px), trimming any overflow so the page does not scroll; it runs on render, on window resize and from a ResizeObserver on the left column and `.body`.

The large Music Understanding (`#labAMU`, its header) and the large roll (`#labRollWrap`) are hidden on CREATE. Because the controls row is off the page while the layouts swap, `LAYOUT` holds SOLO and the zoom field as references (`soloEl`, `zoomEl`) and moves them back in `author()`.

CREATE controls row: **PLAY | LOOP | KEY LOCK | roll orientation | PLAY NEXT | CONTINUOUS PLAY | SHUFFLE ........ FX** (FX pushed to the far right).

**AUTHORING** (`LAYOUT.author()`): the GLOBAL header and strip, the Visual header (`Visual : Authoring`) over the stage, the music, the controls row **PLAY | LOOP | KEY LOCK | zoom | roll orientation ........ SOLO**, the large Music Understanding (chips, encoders, named bus headers), the large roll and the authoring sections. FX, PLAY NEXT, CONTINUOUS PLAY and SHUFFLE are hidden; the deck plays dry.

`setMode(on)` switches mode, layout, roll and messages, and closes the FX drawer.

## 7.3 Global strips
A thin strip across the top of the tab, as Ableton's top bar: global settings you set and leave. One look on both panels (`.pf-global`; the CREATE panel adds `.cr-global` for its margins). On the CREATE panel it sits under a **GLOBAL** section header, which switches nothing (V0.10.08a). A global setting belongs here; a deck setting belongs on the deck.

| Tab | Strip |
|---|---|
| CREATE, AUTHORING | TEMPO · QUANT · arrangement position (one deck = the master) |
| PERFORM | TEMPO · QUANT · PLAY · master position |

QUANT is one value on every tab: `bindQuantField()` binds every QUANT field (`QUANT_FIELDS`), and a change updates all of them (V0.9.04a).

## 7.4 Pocket Rave
The website's compact surface. Opens full frame (`.pr-expanded`); the ONEMANSHYO header toggles full frame and the normal view (off-site a further tap goes to compact authoring); the top strip (power light, jacks) returns off-site to AUTHORING. Normal view: MUSIC / ABOUT / LEARN tabs, the shader, the music row (cover beside the waveform), version line, PLUR. Shader: tap = play / pause; double tap in full frame = normal view, in the normal view = `.wgsl` picker. Cover: tap = song info over the waveform, on / off (the card follows the 5.2 rule); double tap = MP3 picker. Chrome redraws at about 22 fps only while Pocket Rave is on screen. Pocket Rave draws without FX.

## 7.5 Compact authoring
Off-site on a compact viewport: Pocket Rave's frame and header with the authoring sections in one column (one row of 12 lanes, colour bars for chips, knobs up to 40 px). Its header goes to Pocket Rave. It can be forced on a wide viewport (Pocket Rave header, third tap), where it shows as a 430 px column. The arrangement position box, Pop Out and REC are hidden there.

## 7.6 CREATE: LIBRARY, FX and the playlist controls
Built once when the app opens (V0.10.03a to 10e). CREATE only: AUTHORING hides FX and the three icons (`html.author-on`), and a mode or surface switch closes the FX drawer (`window.__crFx.show(false)`).

- **LIBRARY module** (`#labLibSec`, `.pf-mod.pf-libmod.lib-drop`): a `Library` section header, the filter row and the list (`.cr-libin` > `.pf-list`), the same LIBRARY as PERFORM's (8.9) through a second view (`crView = libView(box,{decks:[DK]})`). It is placed in the left column under the controls row and fills it to the stage's bottom; its surround is the page gradient (V0.10.10b). It is the LIBRARY's own drop zone (4.5): files and folders dropped on it go through `readDrop` → `libImport`. A one-deck view: ← and → both load deck A; a **double-click or double tap** on a row (the same row twice within 400 ms, timed by the list: `box._tapId`, `box._tapT`, because the first click redraws the row and iOS reports no second click) loads a track and plays it from the top, or loads a shader. LIBRARY lists take `touch-action:manipulation` (no double-tap zoom).
- **FX** (`#labFxBtn`, `.btn.loop`): opens a drawer (`#labFxPanel`, `.pf-fxpanel` > `.pf-fxslide` > `.pf-fxin`) that slides down out of the controls row over the LIBRARY module: the row's width, from its bottom to the column's bottom (`place()`, re-run on resize and from a ResizeObserver on the left column). The drawer's grid (`.cr-fxgrid`) is AFX1 over AFX2, VFX1 over VFX2 to the right: deck A's slots, the same as PERFORM's deck A (`fxCell(DK,dom,i,true)`, no deck name). Its hover help is bound when it is first placed.
- **Music and visual FX on CREATE**: deck A's rack is live on CREATE (`FX_LIVE`: deck A, CREATE mode, not Pocket Rave, the CREATE panel shown). With a live VFX slot the renderer draws the shader into a texture (`ctex`), runs the shared visual FX chain (`vfxRun`, state `cvst`) and blits the result to the stage, so Pop Out and REC carry it.
- **PLAY NEXT** (`#labNextBtn`, `.bgtoggle.cr-pnext`, a press), **CONTINUOUS PLAY** (`#labContBtn`) and **SHUFFLE** (`#labShufBtn`) (both `.bgtoggle.cr-ptog`, toggles lit cyan as LOOP): icons, no text, after the roll orientation button (V0.10.06a, 06b). State `CP {cont, shuf}`. `window.__crNext(now)` takes the next track in the LIBRARY list as shown (`crView.rows`; an empty list falls back to every track by name), after the one on the deck, wrapping: `now` (PLAY NEXT) stops the playing track and plays the next from the top; at a track's end (LOOP off) the end-of-track handler calls it, and it acts only while CONTINUOUS PLAY is on. SHUFFLE gives each track in CREATE's view a random sort key (`crView.shuf`), the track on the deck first, kept until SHUFFLE is off: the list is put in a random order and play follows it, as streaming players do.

## 7.7 The Moogerfooger strip and the header rename
The strip (`#prSafeTop`: red power light `.pr-pwr` and five jacks) shows on the main app on every tab, on the website and off it, inside the wood frame above the header (`html:not(.pr-on) #prSafeTop`; `.app` padding-top 26 px under the safe area), as on Pocket Rave (V0.10.11a). A tap on the strip acts only on Pocket Rave and compact authoring (off-site: back to AUTHORING); on the main app it does nothing.

**Header rename** (V0.10.11c): on the main app a tap on the power light makes the header text (`#brandTxt`) editable, selected, with a dashed cyan outline. Enter or a blur keeps it, Esc restores it, empty restores ONEMANSHYO; whitespace is collapsed and the text cut to 24 characters; pasted text is plain. Keys typed there stop at the header (Space does not play). It lasts for the session: nothing is saved.

---
# 8. Node: PERFORM

Two decks and a mixer, for playing visuals live to music. Shown off-site only (7.1). The ADD / SCREEN / CUT mix modes and EQ are shown but inactive.

## 8.1 Two decks on one clock
Deck A is `DK`, the same deck object CREATE shows: its track, solos, knobs and position are shared between the tabs. Deck B is a second `makeDeck('B',AMU)` on the same master clock, starting on the embedded track and default shader. Both decks follow `MASTER`, the tempo master (3.3) and QUANT (8.3).

## 8.2 The deck view
`deckView(d,root)` places the shared deck controls (4) in a deck's column. It owns nothing of its own. Top to bottom:
1. **Header:** DECK A / B · KEY LOCK · MASTER (right-aligned). MASTER (`.pf-master`) is an indicator in the standard toggle style: lit while the deck is the tempo master; plain arrow cursor.
2. **Stage:** the deck's shader, 16:9, in the standard line.
3. **Music row, 40 px:** cover 40 × 40 and the waveform beside it; the song info line opens over the waveform.
4. **Row:** PLAY | LOOP | zoom | orientation | position ........ SOLO.
5. **Music Understanding:** the lane chips and bus bars (mini player, 4.2) and the roll, which takes the remaining height.

No Code, REC or Pop Out on PERFORM: it is for performing, not authoring. The stage shows the deck's picture after its visual FX (8.8).

## 8.3 QUANT
One master value in music time, in the PERFORM global strip: **None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars** (`QUANT_STEPS`); default 1/4 (`QUANT_DEF`). Triplets and the steps below 1/4 were removed in V0.8.13a: they have no use for starting and cueing a track, and triplet timing in a visual is the shader's job.

The step size is the master's; each deck lands its own AMU point on that step. That alignment is the sync: there is no separate DJ-style SYNC button. The QUANT field is on both tabs' global strips (7.3).
- **PLAY on a stopped deck** (`deckPlayPress`) waits for the master's next step when another deck is playing (`othersPlaying(d)`), on either tab; the deck starts from its own nearest step line on its AMU grid (bar 1 = its first AMU bar). PLAY blinks (`armed`) while it waits; a second press cancels.
- **A cue on a playing deck** (`deckCue`: roll blocks, waveform clicks) waits for the master's next point at the cue's place within the step, whenever QUANT is not None (V0.9.04a), one deck or two. A cue on a paused deck is at once.
- **FX kills and restores** wait for the next step while any deck plays (`fxLater`, 8.8).
- **Forward only** (OMS canon). None = at once.
- A deck playing alone, on either tab, leads the master grid: `quantTick()` sets the master's phase to the deck's position in an 8-bar cycle from its bar 1 (`QCYCLE` = 32 beats), so every step size lines up with its phrases.

## 8.4 Master position
**Master PLAY** (`#pfMasterPlay`, `window.__masterPlay()`, V0.9.13a), in the PERFORM strip between QUANT and the position, as Ableton's Space: with any deck playing it pauses every playing deck at once and remembers them and the master grid's beat (`__mpHeld`); pressed again it resumes the remembered decks at once from where they stopped and puts the grid back, so QUANT stays on the beat. With nothing remembered it starts every deck from its playhead. No QUANT wait, no snapping. Space on PERFORM calls it; a deck's own PLAY clears the memory. Its label is PLAY or PAUSE by whether any deck plays.

The PERFORM global strip's position box (`#pfMasterPos`) is the session on the master clock, not a deck position, in bars.beats.sixteenths. It starts at 1.1.1 and counts at the master tempo while any deck plays, from the first PLAY. When every deck stops it holds, and carries on when a deck plays again. Double-click = back to 1.1.1. The count is kept in `window.__mpB` (beats) and advanced in `chrome()` from `performance.now()`. The deck positions stay on the decks.

## 8.5 Mixer, OUT and encoders
- **OUT** (`#pfOut`): the mix of the two deck pictures (after their visual FX) at their VID strengths, MIX = weighted blend. ADD, SCREEN and CUT are shown, inactive, in the MODE panel (8.7).
- **Encoders**, in a row: A VID, A AUD, B AUD, B VID. VID = the deck's strength in OUT (`d.outGain`); AUD = the deck's volume (`d.audGain`). Drag up / down, double-click = 0. VID encoders open at 12 o'clock (0.5), so OUT shows both decks on open; AUD encoders open at 0. VID encoders take the visual-domain Purple People Eater `#B24DFF`, AUD the audio-domain cyan `#00d4ff`.

## 8.6 Layout fit
PERFORM is three columns side by side, DECK A | MIXER column | DECK B (`.pf`, grid `1fr / 0.563fr / 1fr`, 24 px apart), under the global strip. Each deck is a module in the standard line (12.6). The MIXER column has no line of its own: it holds three modules of the same width, each in the standard line, 6 px apart: the MIXER (`.pf-mixmod`: header, OUT and encoders), the panel strip (`.pf-pwrap`, 8.7) and the LIBRARY (`.pf-libmod`, 8.9), which takes the remaining height. The page fits the window without scrolling. Per deck, `fit(v)` sizes the stage 16:9 from the column width, smaller on short windows, after reserving the fixed rows, the gaps, the lanes and 40 px of roll, so the Music Understanding panel always keeps room for chips and roll.

## 8.7 Panel strip: MODE · FX · EQ (PERFORM)
`.pf-panelrow`: three equal buttons in the toggle style, MODE, FX and EQ (EQ is a placeholder, `.ph`). MODE and FX open a **drawer** (`.pf-fxslide`, V0.9.22d to 22g) that slides out of the strip's bottom edge, `transform: translateY(-100%)` → 0 in 0.26 s, inside a clipping window (`.pf-fxpanel`, `overflow:hidden`). The window is the strip's width, tucked 6 px under it, and reaches the bottom of the LIBRARY module (`fxPlace()`, re-run on resize); it covers the LIBRARY, which is left as it is underneath. One panel at a time (`fxShow`); the open button is lit; clicking it again slides the drawer back up. MODE holds the video mode row (`.pf-modes`: MIX on; ADD, SCREEN, CUT placeholders). FX holds the deck effects (8.8).

## 8.8 FX
One FX engine for PERFORM and CREATE (V0.10.01a): `fxInit(d)` gives a deck `d.fx = {a:[2 slots], v:[2 slots]}`, slot `{name, amt, killed, node}`; session only. Deck A's slots are shared by PERFORM's deck A and CREATE (7.6). PERFORM's FX panel is a 4 × 2 grid: DECK A VFX | DECK A AFX | DECK B AFX | DECK B VFX, rows 1 and 2. Each cell (`fxCell`) is a knob (`.pf-enc.pf-fxk`, drag = amount; click or Enter = kill / restore; a second click within 300 ms = reset to the effect's default, unmuted, dropping a kill the first click armed (`s.gen`, V0.10.07c); ↑ / ↓ ±0.01, ← / → ±0.05) and an effect box under it (`.pf-fxsel`: click, then the arrows step the bank; a new effect starts at its neutral value). AFX cells are cyan `#00d4ff`, VFX Purple People Eater `#B24DFF`.

**Music FX** (`AFX`), where `FX_LIVE` says the deck's rack plays (PERFORM; deck A on CREATE). `fxWire(d)` rewires when the slots or that answer change: live = `pre` → AFX1 → AFX2 → gain (killed slots bypassed); otherwise `pre` → gain. Each effect is a `mixer()` (dry / wet). Filter (bipolar, neutral at 0.5: left low-pass 20 kHz → 150 Hz, right high-pass 20 Hz → 6 kHz, Q 1.1), Washout (high-pass 20 Hz → 2 kHz), Dubby (band-passed feedback echo, dotted 1/8), Delay (the QUANT division, None = 1/4), Reverb (2.8 s noise impulse), Flanger and Phaser (LFO = 1 / (4 × QUANT division)), Bitcrush (16 → 3 bits, curve of 65 536 points). Defaults AFX1 Filter, AFX2 Dubby. Tempo-timed effects follow TEMPO and QUANT every frame (`tick`).

**Visual FX** (`VFX`, V0.9.22h; one shared chain `vfxRun` since V0.10.02a). One WGSL post pass, `PERF_VFX`, with a uniform of kind, amount, deck beat, beat phase, size, QUANT division, time, Feedback decay, QUANT step, beat kick and bar phase. `makeDeckGpu` (PERFORM) and CREATE's renderer render the shader into a texture, then `vfxRun` runs each live slot (`vfxLive(d)`: not killed, not at its neutral value) as a pass ping-ponging two textures (`fxA` / `fxB`, in the chain's state `vfxState`), Feedback reading `prev` (a copy of the last final picture). On PERFORM the final picture is the deck's stage view and what OUT mixes; on CREATE it is the stage. Bank: RGB Split, Feedback, Glitch, Pixelate, Scanlines, Mirror, Kaleidoscope, VHS, Shake (Dojo's nine), Tone (bipolar: left darker / softer, right brighter / sharper), Tile (1 to 8), Rotate (at tempo; a mirrored repeat at the edges), Zoom (pulses on the beat). Defaults VFX1 RGB Split, VFX2 Feedback.

**Kills on QUANT:** `fxLater(run,armed)` queues the kill or restore in `FXQ` for the master's next step (`nextMaster`) while any deck plays, else at once; `fxTick()` fires due entries every frame (called from `chrome()` through `window.__fxTick`).

## 8.9 LIBRARY
One LIBRARY (`LIB`, shared since V0.10.03a) shown in any number of views (`libView(box,o)`, `LIB.views`): PERFORM's MIXER column and CREATE's LIBRARY module (7.6). Every view has the same filter row and list, and a change in one redraws all. On PERFORM the whole MIXER column is a drop zone for files and folders, subfolders included (`readDrop()`, 4.5); on CREATE the LIBRARY module is. `libImport()` sorts by type and reports one message:
- **Tracks:** each audio file paired with its AMU `.json` by the JSON's `file` field, or its name minus `_sozo_v2_AMU`; audio without its JSON and a JSON without its audio are left out and counted. The JSON is attached data, never an entry. A square image with the track's name is its cover (`entry.cover`).
- **Shaders:** grouped by name stem without `_V##`, the highest `_V##` kept; names without a version fall back to the newest file date.
- A re-drop of the same name replaces its entry.

The list (`.pf-lib`) is sorted by name; filters ALL · QUEUE · MUSIC · SHADERS, then the demo playlists (8.11) (`.pf-libfrow`, their own row). Entry = name + dot (audio cyan, shader Purple People Eater). Click = select (cyan border) and keyboard focus on the list (Dojo focus ring): ↑ / ↓ move the selection, ← loads it on Deck A, → on Deck B (`__libLoad`), Delete or Backspace removes it (a deck keeps what it has). Drag an entry onto a deck = load it (track: its AMU, audio and cover; shader: the `.wgsl`). An entry on a deck is tinted Yellow Man (Dojo 'loaded'); `window.__libTick` redraws the views when a deck's track or shader changes. The LIBRARY is session only: Vizzie saves nothing (13).

## 8.10 Playlist QUEUE
An `.m3u8` dropped on the MIXER column or CREATE's LIBRARY module, before or after the music (V0.9.23a), is held in memory (`LIB.queue`). Its paths are tail-matched against each library file's path inside the drop (`f._rel`), with a file-name fallback (`queueResolve()`). QUEUE is a toggle that combines with the ALL / MUSIC / SHADERS filters; on, the list shows the matched tracks in the playlist's order. A second playlist replaces the first; a library drop re-matches. The message counts queued, no AMU and not found. An `.m3u8` typed `audio/x-mpegurl` (macOS) is not taken as audio (`isAudio`, V0.9.23b). Vizzie writes no playlist.

## 8.11 Demo playlists (the website set)
On http / https, `libWebSet()` reads `./examples/library.json` on open: `{"files":[file names in ./examples/], "playlists":[{"name","file"}]}` (V0.10.04a). Audio files and AMU `.json` files are listed as stand-ins: an audio entry keeps its URL (`_url`) and is fetched when its track is loaded; an AMU entry (`_lazy`, its `text()` fetches) pairs with its MP3 by name and is fetched when its track loads (V0.10.07g), so opening the page fetches no music or analysis. Other files are fetched on open. They are imported quietly (no message). Each playlist (`LIB.lists`) becomes a filter button after SHADERS, its name in capitals (`.pf-libpl`), listing its tracks in its order; its `#EXTINF:sec, Artist - Title` lines name those tracks 'Title · Artist' (V0.10.05b). Tracks match by path, then file name. The LIBRARY opens on the first playlist. Loading a website track fetches its MP3 and AMU, with the message 'Loading NAME …'.

---

# 9. Node: Authoring (the template the app carries)

The app is the shader authoring template: a copy of the app HTML at any build works on its own as the template, opening in AUTHORING off-site. There is no separate template version line; the app build is the template version. To author a shader, copy out the current app HTML; it becomes `OMS_Vizzie_Shader_<Name>_V<nn>.html` with its `.wgsl`.

## 9.1 The per-shader block
One contiguous block holds everything a shader fills: `RULES` (TECHNICAL, carried unchanged; R11 music time is listed first), `NOTES`, `BUILD`, `TEMPLATE` (the app build it was copied from), the `WGSL`, the embedded `AMU`, the authoring pack (`TRACK_INFO`, `TRACK_MP3`, `TRACK_COVER`), `SPECDOC` (scene, music understanding mapping, objects definitions, hierarchy), `CHANGELOG`, `RIG` (one entry per object), the objects-toggle and CRYPTOMATTE patches, and the overlay slots (`OV_PRELUDE`, `OV_V`, `OV_H`, `OV_AP`, `OV_FRAME_M`). App code sits outside it.

**Music time (R11).** Every position, length and cue in authoring is bars and beats, never seconds: 62.1 = bar 62, beat 1; bar.beat B.N = beat (B − 1) × 4 + (N − 1) in `vizzie.time`.

**Authoring pack (R12).** The shader HTML can pack the song it is authored against: its AMU (compact) in the AMU slot, its info in `TRACK_INFO`, its MP3 and cover as data URIs in `TRACK_MP3` / `TRACK_COVER`. A packed MP3 and cover load on open from anywhere (`dataBlob`), so the song survives every iteration and the file can be sent as one; the `.wgsl` stays lean. Empty = the default, Ain't No Trick. App code is never changed for it.

**Default scene.** The AMU test tunnel with Yobot Squint on top, Squint sized as in HalloweenBounceFeatSquint V60 at 16:9 (`SUBJECT_HEIGHT` 0.765, the Yobot 43.7 % of the frame height; V0.8.02a).

## 9.2 Renderer hooks: AUTH_GPU
Everything the preview adds to the WebGPU renderer lives in `AUTH_GPU`; the renderer calls `init`, `patch`, `entries`, `write`, `copy` and `read`. `patch(src)` adds the preview-only bindings (1 object mask, 2 overlay probe, 3 CRYPTOMATTE table) and patches; the shipped `.wgsl` is unchanged.

## 9.3 Objects toggle and CRYPTOMATTE
One tile per object (`RIG`) shows or hides it on the stage through a bit mask (binding 1). CRYPTOMATTE paints each object in its ID colour (binding 3, `cmTable()`), from `RIG` `cm` or a colour from the tile index.

## 9.4 Authoring overlay
GRID, GUIDES and POINTS draw on a 2D canvas over the stage, never in the shader (R5). Guides and anchor points are WGSL expressions of the shader's own constants (R6): the preview's shader evaluates them at one pixel (`ovProbeWGSL()`, binding 2), reads them back every sixth frame and `drawOverlay()` draws them. A shader's `OV_PRELUDE` defines `ov_origin` (vec2) and `ov_m` (frame units per metre); guides are metres from `ov_origin`, anchor points are frame units.

**Camera and grid (R10).** World units are always metres; framing belongs to the camera, as in Blender. A shader with its own camera declares it in `OV_PRELUDE`; the GRID steps with the camera: major = the largest power of ten not above the frame height in metres, minor = a tenth (2 m frame: 1 m / 10 cm; 20 cm: 10 cm / 1 cm; 2 cm: 1 cm / 1 mm); labels in metres and a corner label naming the step. A shader with no camera uses `OV_FRAME_M` (template: 2 m).

---

# 10. Node: Tabs

**CREATE · PERFORM · AUTHORING · HELP · ABOUT · LEARN**, in that order (V0.10.10a), via `switchPanel()`. On the website: CREATE · HELP · ABOUT · LEARN, opening on CREATE. Off-site it opens on AUTHORING. PERFORM and AUTHORING are off-site only (7.1). CREATE and AUTHORING share `#panelLab` in two modes (7.2). HELP (`#panelHelp`) holds LET'S DO THIS: a section header and two outlined modules of four lines each (`#labLetsDo` > `ul.cr-tips`, 15px Courier New, `#0a0a0a`, 1px `#2a2a2a`, radius 6px). ABOUT carries the description, credits, licenses and technical notes. LEARN is not a panel: the tab calls `openLearn()`, which opens `https://onemanshyo.com/#learn` in a new tab.

---

# 11. Leaf Reference: Controls and Keyboard

The full keyboard table is E 10 (Keyboard index); every control's help, with its pointer actions, is E 9 (Message index).

- **Global strip (CREATE, AUTHORING):** TEMPO field · QUANT field · arrangement position, under the GLOBAL header.
- **Global strip (PERFORM):** TEMPO field · QUANT field (click in, ↑ / ↓, scroll; double-click = 1/4) · master PLAY / PAUSE · master position (double-click = 1.1.1).
- **TEMPO field:** ↑ / ↓ ±1 BPM · ← / → ±0.01 BPM · type + Enter · Escape leaves · double-click = the master deck's BPM.
- **Music (every deck):** cover (tap = song info on / off, double tap = MP3 / AMU picker) · waveform (click = cue on QUANT, drag = scrub, double tap = MP3 / AMU picker) · drop files or folders anywhere on the deck (first MP3, AMU `.json`, `.wgsl`, square cover image).
- **CREATE controls row:** PLAY / PAUSE · LOOP · KEY LOCK · roll orientation · PLAY NEXT · CONTINUOUS PLAY · SHUFFLE ........ FX. **Music Understanding header (CREATE):** zoom field · SOLO, far right.
- **AUTHORING controls row:** PLAY / PAUSE · LOOP · KEY LOCK · zoom field · roll orientation ........ SOLO.
- **PERFORM deck:** header KEY LOCK · MASTER (indicator); row PLAY / PAUSE · LOOP · zoom field · orientation · position ........ SOLO.
- **FX (PERFORM panel, CREATE drawer):** knob drag = amount · ↑ / ↓ ±1 % · ← / → ±5 % · click / Enter = kill / restore on QUANT · double-click = reset to the default; effect box: click, then the arrows = previous / next effect.
- **LIBRARY:** click = select · ↑ / ↓ select · ← = Deck A · → = Deck B (CREATE: both = deck A) · Delete = remove · drag onto a deck = load · CREATE: double-click or double tap = load and play; filters ALL · QUEUE · MUSIC · SHADERS · demo playlists.
- **Visuals header (CREATE) / Visual header (AUTHORING):** `</> Code` · Pop Out · orientation · REC. Stage: drop or double tap = `.wgsl`.
- **Power light (main app):** tap = retype the header for the session (Enter = keep · Esc = cancel · empty = ONEMANSHYO).
- **Zoom field:** click in, ↑ / ↓ = 0 / 25 / 50 / 75 / 100.
- **Encoders (AUTHORING):** drag = intensity · press = solo · double-click = reset to full. Chips: click = solo. Bus headers and bars: click = group solo.
- **Mixer encoders:** drag = level · double-click = 0.
- **Piano roll:** drag = scrub · click = cue to block start (on QUANT while playing; LOOP on = loop it; stopped = pick it) · pinch / ctrl + wheel = zoom.
- **Keyboard:** SPACE = play / pause deck A on CREATE and AUTHORING, the master PLAY / PAUSE on PERFORM (ignored while typing). Esc no longer closes the song info (V0.9.05a).
- **Pocket Rave:** see 7.4.

---

# 12. Design System (Human Interface Guidelines)

## 12.1 Philosophy
Vizzie follows the OMS **Human Interface Guidelines** (Dojo, Chippy): a hardware mindset (once you settle and package, it must be right, as with manufacturing physical goods) and things look as good on the inside (CSS, class structure, markup) as on the outside.

## 12.2 What the Design System is
The shared OMS tokens and component language: the `.app` shell, `.header` (gradient ONEMANSHYO brand + app tag + version; the Yobot logo was removed in V0.9.24a), `.tabbar` / `.tab`, `.sec-hdr` dividers, the `.btn` family, the field, the standard line, and the `.message-bar` footer. Exact values and classes live in Y 11.

## 12.3 Buttons
- **One small-button standard:** 11px Courier New, padding 3px 10px, 1px border, radius 4px. SOLO and Pop Out set it; PLAY, KEY LOCK and MASTER follow it on PERFORM and CREATE.
- **A button hugs its label.** It never stretches to fill a row (`flex:0 0 auto`). A row aligns its buttons; it does not size them.
- **A button never changes size with its state.** PLAY / PAUSE is fixed at the width of its longest word (PAUSE, 5 characters of the mono font) in both states, text centred, so the row never shifts.
- **Toggle** (`.btn.loop`): grey off (`#7a7a7a` on `#3a3a3a`), cyan on (`#00d4ff` border and text, cyan glow). LOOP, KEY LOCK, MASTER, the LIBRARY filters, MODE / FX / EQ, CREATE's FX.
- **SOLO** on the CREATE panel (`.btn.solo`): grey off, Barbie Pink on (`#E0218A`, glow). PERFORM's SOLO uses the toggle style (cyan on); see 12.10.
- **Primary** (`.btn.primary`): cyan (PLAY). While a QUANT start waits, PLAY blinks (`.btn.armed`).
- **Indicator in button form** (MASTER): the toggle style with the plain arrow cursor.
- **Icon toggle** (`.bgtoggle`, roll orientation): 26 × 24. CREATE's CONTINUOUS PLAY and SHUFFLE are icon toggles lit as LOOP (`.cr-ptog.on`); PLAY NEXT is an icon press styled as PERFORM's orientation button (`.cr-pnext`: cyan on a `#1e4a55` border).
- **Disabled:** opacity 0.4 on PERFORM; CREATE's KEY LOCK 0.35 (12.10).

## 12.4 Fields
**One standard field** (`.pf-gf`) for every data field: TEMPO and QUANT on both tabs and the roll zoom fields. 72 × 24 px, 13px Courier New, line height 18px, text centred, cyan `#00d4ff` on `#060606`, 1px `#333` border, radius 4px. Hover = border `#4a4a4a`; focus = cyan border and glow. No label, no − / + buttons, no unit text beside it: the hover help says what it is and its keys. Click in, then the arrow keys.

**Position box** (`#labRecTime`, `.pf-pos`): 11px Courier New 600, `#888`, 1px `#333` border, radius 4px, fixed width (8 characters + padding), so it never moves. Barbie Pink while REC records.

## 12.5 Spacing
**One gap between neighbouring controls everywhere: 8 px** (buttons, fields, toggles, mixer mode chips), set by the row's or strip's `gap`, never by per-control margins. A control pushed to the end of a row (SOLO) uses `margin-left:auto`. The Music Understanding grid has its own tighter spacing: lane cells 4 px apart on CREATE and 2 px on PERFORM, bus modules 6 px apart on CREATE.

## 12.6 Lines and modules
**The standard line:** 1px `#2a2a2a`, radius 6px. Modules (DECK A, MIXER, DECK B), stages, the waveform, the cover, the AMU box and the global strip use it. A module is a line only: no fill (`#0a0a0a` belongs to the inner boxes that had it), 8 px inside so content does not touch the line. Section headers keep `.sec-hdr` (3 × 13 bar, 11px uppercase label, 1px `#262626` rule).

## 12.7 Colour semantics

**Key colours.** Wes's own colours: Purple People Eater `#B24DFF`, Barbie Pink `#E0218A`, Green Slime `#65FF00`, Yellow Man `#FFF000`, Orange Julius `#FFA500` (brand), Goblin White `#FFFFFF` and Red Hots `#FF006E` (key). Where the UI needs a colour these fill the role first. **One shade of each colour in the app:** any purple, pink, green or yellow is the key colour; a dim form is the same colour at lower opacity, never a second shade (V0.10.12a, 12b). Shader WGSL colours are the shader's own and are not part of the design system.

- **Domain colours:** visual Purple People Eater `#B24DFF`, audio cyan `#00d4ff`. The mixer's VID and AUD encoders, the FX knobs and boxes and the LIBRARY dots carry them.
- Chrome and section headers cyan `#00d4ff`; authoring sections Orange Julius `#ffa500`.
- Messages: info cyan `#00d4ff`, state Orange Julius `#ffa500`, error Red Hots `#ff006e`. Red Hots also: the danger button (`.btn.mag`), GPU errors on a stage, the ONEMANSHYO gradient (cyan to Red Hots) and Pocket Rave's stage border while playing.
- Active and recording: Barbie Pink `#E0218A` (SOLO on the CREATE panel, the roll and waveform playheads, all of REC).
- Picked or rendered chip on the roll: Yellow Man; LIBRARY entry loaded on a deck: Yellow Man tint.
- Bus colours: RHYTHM Red Hots, STRUCTURE Orange Julius, KEY Yellow Man, PACE Green Slime, LOUDNESS blue `#00a8ff`, INSTRUMENTS Purple People Eater. **Every lane takes its bus colour**; beat is Goblin White.
- Credits and PLUR (ABOUT, Pocket Rave) and the authoring overlay's anchor points: Purple People Eater.
- Active state = border colour + tint + glow (toggle cyan, SOLO Barbie Pink, REC Barbie Pink pulse).

## 12.8 Interaction pattern matrix
Same gesture = same result everywhere (Dojo's matrix, with Vizzie's values).

**Encoders (lane knobs):**

| Gesture | Result | Feedback |
|---|---|---|
| Hover | Help in the message bar; lanes show live values | cyan message |
| Drag vertical | Intensity, 0.005 per px | knob arc |
| Press without dragging | Solo the lane | the lane shows soloed, others dim; SOLO lit |
| Double-click | Back to full (1.0) | knob arc |

**Mixer encoders:**

| Gesture | Result | Feedback |
|---|---|---|
| Hover | Help with the current value | cyan message |
| Drag vertical | Level, full range over 150 px | orange value |
| Double-click | 0 | orange value |

**Buttons:**

| Gesture | Result |
|---|---|
| Hover | Help in the message bar |
| Click | Act or toggle; orange confirmation |

**Fields (TEMPO, QUANT, zoom):**

| Gesture | Result |
|---|---|
| Hover | Help with the keys |
| Click | Focus (cyan border and glow) |
| ↑ / ↓ | Coarse step (TEMPO ±1 BPM; QUANT and zoom: next value) |
| ← / → | Fine step (TEMPO ±0.01 BPM only) |
| Type + Enter | Set (TEMPO) |
| Double-click | Default (TEMPO = master deck's BPM; QUANT = 1/4; master position = 1.1.1) |
| Escape | Leave the field |

**Music row and stage:**

| Gesture | Result |
|---|---|
| Tap cover | Song info on / off |
| Double-tap cover or waveform | MP3 / AMU picker |
| Click waveform | Cue (on QUANT while playing) |
| Drag waveform | Scrub |
| Double-tap stage | `.wgsl` picker |
| Drop on a deck | Load by file type |
| Drop on a LIBRARY | Add to the LIBRARY |

**Piano roll:** drag = scrub · click a block = cue to its start · pinch / ctrl + wheel = zoom.

**FX knobs:**

| Gesture | Result | Feedback |
|---|---|---|
| Hover | Help with the slot, effect and amount | cyan message |
| Drag vertical | Amount | orange value |
| ↑ / ↓, ← / → | Amount ±1 % / ±5 % | orange value |
| Click or Enter | Kill / restore on QUANT | orange message |
| Double-click | Reset to the effect's default, unmuted | orange value |

**Drop zones:** one hint everywhere, "Drop files" and the types one per line (`dropHint`); files and folders on every drop zone.

**LIBRARY list:** click = select · double-click or double tap = load and play (CREATE) · drag onto a deck = load.

Keys act only in the focused field, knob, box or list; the only app-wide key is SPACE (CREATE and AUTHORING: deck A; PERFORM: master PLAY).

## 12.9 The module hierarchy
**section → bus module → lane cell → chip + encoder** (`.amu-mod` → `.amu-cell` → `.lab-lane` + `.amu-knob`); mini players: chip only. The piano roll sits in its own module perimeter aligned with the bus modules above. PERFORM: **tab → global strip + DECK A | MIXER column | DECK B → deck view rows** (8.2); the MIXER column → MIXER, panel strip, LIBRARY modules, the drawer over the LIBRARY (8.6, 8.7). CREATE: **tab → GLOBAL + MUSIC column | VISUALS stage → Music Understanding**; the MUSIC column → music row, controls row, LIBRARY module, the FX drawer over the LIBRARY (7.2, 7.6). Module per function.

## 12.10 Known design debt
Where the build does not follow the standard.
- The small-button standard is applied per container (`.pf-trans .btn`, `#labTransportHold > .btn`, `.pf-sm`, inline styles in the Visual header), not by one class; the base `.btn` still declares 12px / padding 6px 12px.
- Disabled opacity differs: 0.4 on PERFORM buttons, 0.35 on CREATE's KEY LOCK.
- SOLO lights pink on CREATE (`.btn.solo`) and cyan on PERFORM (`.btn.loop`): two looks for one function.
- The Dojo button spec (34 px high, 600 weight, uppercase, 0.5 letter spacing, no border) and Vizzie's small button differ; Vizzie's is the one in use.
- Some code comments describe earlier layouts (CREATE "render" mode stacking PLAY / LOOP, PERFORM placeholders, CREATE's LIBRARY as a drawer opened by a LIBRARY button, "CREATE PUBLIC"); `MODES.idle` and `IDLE_MSG` are set but no longer shown (idle = empty bar).
- The mode key for CREATE is still `public` in `MODES` and `mode()`; the word PUBLIC is gone from the UI.
- HELP's line "Press LIBRARY to see more music and visuals" names a button CREATE no longer has (the LIBRARY is always open since V0.10.09a); the wording is Wes's, kept as is.

---

# 13. User Media: AMU Data and Shaders

Everything the performer provides: music, its AMU, shaders, cover images and playlists. Vizzie saves none of it: the gig folder is the set.

## 13.1 AMU data
Apple's Music Understanding framework (Swift module `MusicUnderstanding`) analyses a track on-device; the OMS Sozo Sidecar writes it to JSON; Vizzie embeds it. Chain of trust: Apple → Sozo → JSON → `readAMU()` and `MASTER` → `pack()` → shader. Apple is the authority.

## 13.2 Shaders
Vizzie runs any WGSL shader written to the uniform contract. Shaders are authored in the app itself (9), named `OMS_Vizzie_Shader_<Name>_V##.wgsl` / `.html`, and kept in `VIZZIE/App Folder/Library/Shaders/`, one folder per shader. Moving a shader onto V0.7.0 or later means restating any `vizzie.time` rates per beat (2.2.2).

---

**END OF DEVELOPER DOCUMENTATION**
