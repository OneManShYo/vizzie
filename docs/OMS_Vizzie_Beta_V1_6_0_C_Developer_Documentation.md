# OMS Vizzie app [Beta V1.6.0] Developer Documentation

**Run date:** 2026-11-22  
**Current Unix Epoch:** 1795349176  
**Document purpose:** The explanatory technical spec for OMS Vizzie: how each system works and why. Uses the shared OMS **Cortex / Node / Leaf** vocabulary (Dojo, Chippy), sized to Vizzie's scope.  
**Filename:** OMS_Vizzie_Beta_V1_6_0_C_Developer_Documentation.md  

## About this document

Vizzie Beta V1.6.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## CONTENTS

**1** Introduction  
&emsp;1.1 What is Vizzie?  
&emsp;1.2 Application development tiers  
**2** Cortex and the Critical Stack  
&emsp;2.1 The master music clock (CORTEX)  
&emsp;&emsp;2.1.3a AUTO MIX and the clock  
&emsp;2.2 The uniform contract (critical: the one public interface)  
&emsp;&emsp;2.2.1 Namespaces  
&emsp;&emsp;2.2.2 Rules  
&emsp;&emsp;2.2.3 Gates  
&emsp;&emsp;2.2.4 The settings block (binding 1)  
&emsp;&emsp;2.2.5 Authoring preview bindings (@group(3))  
&emsp;&emsp;2.2.6 The AMU span tables (binding 2)  
&emsp;2.3 The WGSL runtime (critical)  
&emsp;2.4 Message System: the feedback bar (CORTEX)  
**3** Node: Deck Audio, Tempo, Key Lock  
&emsp;3.1 Deck audio engine  
&emsp;3.2 Warp: steering the deck to the clock  
&emsp;3.3 TEMPO and the tempo master  
&emsp;3.4 KEY LOCK  
&emsp;3.5 The master bus: ISOLATOR, MASTER, DSP  
&emsp;3.6 Audio calibration tests  
**4** Node: Deck Controls (one code for every deck)  
&emsp;4.1 The control strip  
&emsp;4.2 Lanes, buses and encoders  
&emsp;4.3 Solo  
&emsp;4.4 Piano roll  
&emsp;4.5 The drop zone and double-tap loaders  
**5** Node: Song Info, Audio Loading, Waveform  
&emsp;5.1 Loading audio  
&emsp;5.2 ID3, track names, cover art and the song info  
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
&emsp;7.2 MODES and LAYOUT: PLAY and CREATE  
&emsp;7.3 Global strips  
&emsp;7.4 Pocket Rave  
&emsp;7.5 Compact authoring  
&emsp;7.6 PLAY: LIBRARY, FX and the playlist controls  
&emsp;7.7 The Moogerfooger strip and the header rename  
&emsp;7.8 The Settings drawer  
&emsp;7.9 SHOUT OUT  
&emsp;7.10 AUTO MIX and SELECTA  
&emsp;7.11 PLAY: FOLLOW and the visual list  
**8** Node: PERFORM  
&emsp;8.1 Two decks on one clock  
&emsp;8.2 The deck view  
&emsp;8.3 QUANT  
&emsp;8.4 Master position  
&emsp;8.5 Mixer, OUT, encoders and LINK  
&emsp;8.6 Layout fit  
&emsp;8.7 Panel strip: ISO · EQ · FX · MODE · gear  
&emsp;8.8 FX  
&emsp;8.9 LIBRARY  
&emsp;8.10 SETS (playlists)  
&emsp;8.11 Demo playlists (the website set) and Yodega  
&emsp;&emsp;8.11.1 Yodega  
&emsp;8.12 EQ and RGB  
&emsp;8.13 MODE: visual mix modes (OUT)  
&emsp;8.14 Keyboard: one flow for the whole UI  
&emsp;8.15 Hardware: two Midi Fighter Twisters  
**9** Node: Authoring (the template the app carries)  
&emsp;9.1 The per-shader block  
&emsp;9.2 Renderer hooks: AUTH_GPU  
&emsp;9.3 Objects toggle and CRYPTOMATTE  
&emsp;9.4 Authoring overlay  
&emsp;9.5 Standard settings (R13)  
&emsp;9.6 Assets and the pipeline (R14 to R24)  
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
&emsp;12.11 Control rules  
**13** User Media: AMU Data and Shaders  

---

# 1. Introduction

## 1.1 What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

## 1.2 Application development tiers
- **Cortex** = the small, load-bearing core. Everything traces back to it; a change cascades everywhere. The label is used **sparingly on purpose**: if everything is Cortex, the word means nothing. In Vizzie two systems carry it: **the master music clock** (timing) and **the Message System** (the single feedback channel), matching the OMS suite convention. Since V1.5.01d (BLOG0368) the **AUTO MIX audio core** is locked under the master music clock (2.1.3a): the AMU grid, Steering in normal play, the AUTO MIX Lock, the hidden deck, preload and the no-gap handover.
- **Node** = a feature system that depends on the Cortex but that the app's core function survives changes to. Most of the app is Nodes.
- **Leaf** = a small control or affordance hanging off a Node.

---

# 2. Cortex and the Critical Stack

The Cortex is the master music clock. Above it sit three layers that each depend on the one below: the uniform contract, the WGSL runtime, and the shader.

| Layer | What it does | Tier | If it breaks |
|---|---|---|---|
| 1. Master music clock (`MASTER`, each deck's warp map, the AMU reader `readAMU(d,t)`) | says where we are in the music, in beats, every frame | **CORTEX** | nothing is in time; the picture has no musical meaning |
| 2. Uniform contract (`pack()`, `deckSettings(d)`) | turns musical position into the 36 floats a shader reads (binding 0) and carries the shader's own 64 settings floats (binding 1) | critical | shaders receive garbage or stale values |
| 3. WGSL runtime (`main()`, `build()`, per-frame draw) | compiles the shader and draws it | critical | no picture at all |
| 4. The shader (default or user-loaded) | the actual look | rides on top | you lose *that look*, not the app; load another |

## 2.1 The master music clock (CORTEX)

**The one law: music time is the clock of record.** Position is counted in bars and beats, never in elapsed seconds, frame counts or audio energy. Seconds exist only at the edge, where the computer world needs them: the decoded audio buffer and the track's beat map. Conversions live there, not the other way round.

### 2.1.1 MASTER and the decks
`MASTER` is the one master music clock for the app: `MASTER.beat` and `MASTER.tempo` (BPM, set by TEMPO, 3.3). It owns no track and no audio. `MASTER.advance(dt)` adds `dt × tempo / 60` beats and returns them: the master grid is evenly spaced at the TEMPO.

A deck (`makeDeck(id,amu)`) is one track on the master clock. Its position is `d.beat`, in its own track's beats: beat 0 is the track's first AMU beat, the fraction is the phase within the beat. Every frame each playing deck moves by the beats the master moved. `DECKS` holds the decks, `DECKS=[DK,DA,DB]`. `DK` is PLAY's deck (`perf=false`), the one PLAY, CREATE and Pocket Rave show and drive. PERFORM makes its own two, `DA` and `DB` (`perf=true`, 8.1). Since V1.0.30i (BLOG0219 CREATE and PERFORM: separate play controls) the surfaces share no deck; before, PLAY's deck was PERFORM's Deck A. `surfDecks()` gives the open surface's decks. The model is three channels and one global part: the tempo, the master clock, QUANT and the master bus (3.5) are the app's, one value each. A deck carries its AMU, warp map, lane data, knobs and solos, play / KEY LOCK state, a pending QUANT action (`d.pend`, 8.3), a pending shader load (`d.shPend`, 6.2) and its audio engine; `d.setTrack(amu)` replaces its track (5.4).

### 2.1.2 The warp map
Each track's AMU beats are its warp markers, set by the analysis instead of by hand. `warpMap(beats)` builds each track's smoothed map once: each AMU beat time is replaced by a straight-line fit over the beats within ±8 (a 4-bar window), so analysis jitter averages out while real tempo drift is still followed (on Ain't No Trick the AMU marks sit 7.7 ms off a steady grid typically, 22.7 ms worst). `d.timeToBeat(t)` and `d.beatToTime(b)` convert through the deck's map (linear between beats, extended past the first and last beat at their spacing); `d.beatLen(b)` is the track seconds per beat at beat `b`, the track's local tempo. `d.t` is a getter / setter through the map, for the places that need track seconds (the audio, the AMU reader).

### 2.1.3 Heartbeat and the loop
`hb()` is the clock's heartbeat: `audioCtx.currentTime` (the audio hardware clock) once a track is loaded, otherwise `performance.now()`. One rAF loop, `chrome()`, calls `chromeStep()`, which does, in order, every frame (split into a step in V1.4.16a, BLOG0348, so a pop-out window's timer can run it, 6.3):
1. advances `MASTER` by the heartbeat delta (clamped to 0.1 s);
2. moves each playing deck by the same number of beats and steers it (3.2), or handles its track end; then `window.__amTick(db)` runs AUTO MIX (7.10);
3. `quantTick()`: fires due QUANT starts, cues, song switches and shader loads; a deck playing alone leads the master grid (8.3);
4. advances the master position (8.4);
5. `masterTick()`: hands the tempo master to a playing deck when needed (3.3);
6. sizes the stage, writes the readout and the arrangement position, draws the PLAY chrome (knobs, waveform, piano roll, song info line), then calls PERFORM's draw (`window.__perfDraw`), which also runs `fxTick()` (8.8).

**LOOP** (`d.loop`, `d.loopSpan`), per deck. `d.loopSpan` is null (the whole track) or a chip's span `{li,start,end}` (`amuSpan()`; a ticks lane's chip runs to the next tick). With LOOP on and a span, the deck wraps from the span's end to its start every frame, keeping the beat's fraction (the end is a musical boundary; no extra wait).

**Track end**, per deck: with LOOP on the deck wraps to 0 and plays on; with LOOP off it stops and its playhead returns to the start. While REC records on PLAY: LOOP off, the track end stops the recording; LOOP on, the recording runs across the wrap. A picked chip being rendered (`REC.span`) stops the recording and the deck at the chip's end (6.4). `seekTo(sec,d)` sets `d.t` and moves that deck's audio with it. A `visibilitychange` handler drops the stale delta when the tab returns.

Every deck opens paused (`MODES.autoplay` is false in both modes since V0.8.08a).

### 2.1.3a AUTO MIX and the clock (who follows whom)
AUTO MIX (7.10) is the one place where a second song plays on PLAY's clock. It does not only use the Cortex: these were added to the Cortex and the deck audio engine to make it work:

| Added | Where | Build | What it does |
|---|---|---|---|
| The AUTO MIX hook | `chromeStep` → `window.__amTick(db)` | V1.4.20a | runs after the decks move each frame: the hidden deck's beat, the SELECTA's post-mix tempo change, preload, mix start, fade, handover |
| The hidden deck | `AX = makeDeck('X',AMU)`, outside `DECKS` | V1.4.20a | a fourth deck on the master clock, for the incoming song |
| The SELECTA's tempo (group 4) | `mix.hold`, `mix.t0`, `mix.t1`, `mix.cap`, `gl`, `TS.c.hand` | V1.4.23c; V1.5.01a, 01b, 01e | 4.1 = 0: the master tempo held through the mix; after the handover it moves to 4.4's target over 4.2's bars (`gl`), at most 4.3 when set (7.10) |
| The visual of the hidden deck | `VB`, `buildB(txt)`, `window.__amVis()`, `vtail` | V1.5.01c | the incoming song's paired shader drawn on `AX`'s data to its own texture and mixed with PLAY's picture in `frameStep` through PERFORM's mix shader (`PERF_MIX`) |
| Start at an exact audio time | `makeDeckAudio(...).lockAt(when, offset, rate)` | V1.4.26a | a deck starts on a given audio-clock instant at a fixed speed; a playing source hands over with a 6 ms crossfade |
| A gain per audio source | `sg` in `makeDeckAudio` | V1.4.26a | lets the crossfade above happen inside one deck |
| Timed play in the stretch worklet | `pend` in `vizzie-stretch` | V1.4.26a | a play message for a later time waits for it (KEY LOCK path) |
| The lock in Steering | `AMLOCK` in `steerDeck(d)` | V1.4.26a, 26b | Steering leaves a locked deck's audio alone; its beat is pulled toward the audio instead |
| The decoded audio exposed | `makeDeckAudio(...).buffer` | V1.4.24a | read by the AMU Nudge (removed in V1.4.28b); the getter stays |

Its clock rules:

| Case | Leads | Follows | How |
|---|---|---|---|
| Normal play, every tab | the Beat Clock (`MASTER`, on the audio clock, 0.1 s step cap) | each playing deck's audio | Steering (`steerDeck`, 3.2): speed pulled 2 % at most; a gap over 250 ms is jumped |
| AUTO MIX, during the mix | the audio: A and B start on one audio-clock instant and play at fixed AMU speeds (AUTO MIX Lock) | each deck's beat, so the visuals, the fade and the handover | `AMLOCK`: Steering off for both; each beat pulled 15 % a frame toward its audio; a gap over 1 beat is jumped |
| AUTO MIX, after the handover | the Beat Clock again | the new song's audio | Steering back on; the tempo moves as the SELECTA's group 4 says (SELECTA ID 1: to the new song's BPM over 16 bars, `gl`) |
| A pop-out in full screen | the pop-out's timer | the clock step | `chromeStep` runs from the pop-out when the main timer has not run for 60 ms (6.3) |

- **The hidden deck.** `AX` is a fourth deck on the master clock, outside `DECKS`: it moves by the same beats each frame (`AX.beat += db` in `__amTick`) and never counts for the tempo master, QUANT or `surfDecks()`. At the handover PLAY's deck (`DK`) takes over its audio and position; `AX` is empty again.
- **The tempo during a mix.** With the SELECTA's 4.1 at 0 (the only value built) `MASTER.tempo` is held at the playing tempo (`mix.t0`) for the whole mix and B is matched to it, however far that is from B's own tempo: every transition mixes (V1.5.01a, BLOG0365: V1.5.0's 'no beat mix past 5 %' was one SELECTA setting built as a refusal for every mix; removed). A TEMPO typed by hand (`TS.c.hand === true`) is left alone; a tempo held by a 4.3 cap (`TS.c.hand === 'selecta'`) is not treated as by hand (V1.5.01e).
- **The start.** B's position comes from A's beat at the start instant through both AMU grids (A's beat to B's bar 1 plus the same distance into the zone), so the two songs meet on their AMU beats; no audio analysis is used (the AMU Nudge, a kick measurement, was removed in V1.4.28b).
- **Locked (Cortex, V1.5.01d, BLOG0368).** The AMU grid (`readAMU`, `timeToBeat`, `beatToTime`), Steering in normal play (`steerDeck`), the AUTO MIX Lock (`lockAt`, `AMLOCK`), no AMU Nudge, the hidden deck, preload and the no-gap handover (`AX`, `PRE`, `endMix`) change only on the product owner's explicit go on a written spec, and a change passes the regression baseline first: the handover (no reload, the new song playing, no errors), sync (in-app recording alignment), tempo (Rezzonate into Rave Ya: 127 held in the mix, 127 to 128 over 16 bars after) and load errors. Not locked: the SELECTA parameters (7.10).
- **Known limit.** Outside a mix the 0.1 s step cap and Steering stand: a frame over 100 ms can bend the music by up to 2 % (BLOG0324, parked). A fix that removed the cap and pulled the music only past 8 ms (V1.4.27a) passed headless and was pulled on the hardware (the visuals suffered); a clock change is tested on the real machine before it is kept.

### 2.1.4 The AMU reader
`readAMU(d,t)` reads deck `d`'s AMU at track time `t` and returns the contract's fields: beat and bar phase (`phaseIn`), section / segment / phrase progress and index (`span`), key mode and tonic, momentary loudness, pace, and the four instrument activities (`sample`). The beat count for `vizzie.time` comes from `d.beat`, not from `readAMU()`.

### 2.1.5 The embedded data
The AMU sidecar is embedded as `const AMU={…}`: `len`, `bpm`, `beats` and `bars` (ascending times), `sec` / `seg` / `phr` (`[start,end]` pairs), `key` (`[start,end,mode,tonic]`), `pace` (`[start,end,value]`), `mom` (momentary LUFS as `{t0,dt,v}`) and `act` (`drum`, `bass`, `vocal`, `other`, each `{t0,dt,v}`). Names and values come from Apple's `MusicUnderstanding` framework as written by Sozo Sidecar V2; the embed is compacted (arrays, evenly sampled curves). `TRACK`, `BPM` and `SONG` (the track length) derive from it. This embedded AMU is the default track for every deck (the authoring pack, 9); a deck can load another track's AMU (5.4).

## 2.2 The uniform contract (critical: the one public interface)

Contract **V0.5.0A** (V0.11.02a; was V0.4.0D), with binding 2 added in V1.3.28a (BLOG0203, additive). Three bindings in `@group(0)`:
- **Binding 0, the AMU block:** unchanged from V0.4.0D, **9 × vec4 / 36 floats / 144 bytes**, frozen like a published API: new data goes only into reserved slots, never by renaming or reshuffling. `pack(dk,a,w,h)` builds all 36 floats each frame for deck `dk` from the AMU reader's fields (`a = readAMU(dk, dk.t)`), the deck's gates and beat, and the canvas size.
- **Binding 1, the settings block:** new, **16 × vec4 / 64 floats** (`SET_VEC4` = 16, `SET_BYTES` = 256), the shader's own values (2.2.4).
- **Binding 2, the AMU span tables:** read-only storage, worked out by the app from the loaded AMU, one table per lane (2.2.6).

A shader may use any of the three; shaders written for V0.4.0D run unchanged. Each PERFORM deck packs its own uniforms and writes its own settings block for its own shader. The full slot table is in Y 2.2.

A new section is more than V0.4.0D's letter steps (a letter was a unit change in one slot): the minor rolls and the letter starts at A.

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
Slots 0 to 12 carry, per lane, (soloed-in ? 1 : 0) × the lane's knob (`d.gate(id)`, looked up by slot with `d.gateOf(i)`), so a shader multiplies each element by its gate and the controls work on any shader. Since V0.11.10a no surface has lane encoders: every lane's knob stays at full, so a gate is its lane's solo state, the same on every surface.

### 2.2.4 The settings block (binding 1)
In WGSL, declared once after the AMU block:

```
@group(0) @binding(1) var<uniform> settings: array<vec4<f32>, 16>;
```

A plain uniform array of vec4, no struct: `settings[0].x` reads as written.

**One block per deck.** `deckSettings(d)` gives deck `d`'s 64 floats (`d.settings`, a `Float32Array`), zero until something writes them. PLAY's renderer (`DK`) and each PERFORM deck write their deck's block every frame beside the AMU block.

**The declaration** (part of the contract). A shader declares its settings in comment lines anywhere in the `.wgsl`, so the shader compiles as it is:

```
// @setting NAME settings[N].c min max step default | help      a number (N 0 to 15, c one of x y z w)
// @setting NAME settings[N].xyz color r g b | help              a colour (.xyz or .yzw, 0 to 1)
```

The place is written as the shader reads it, so the line and the code match; the help after `|` is optional. Example: `// @setting HUE settings[1].z 0 1 0.01 0.5 | Hue/Saturation/Value node: hue (0.5 = none)`, read in the shader as `settings[1].z`.

**Reading it.** `readSettings(src)` parses the lines into `{list, errs}`: each entry `{name, type, idx, min, max, step, def, help}` (`type` 'number' or 'color'; `idx` the float indices in the block). A line that does not fit is skipped with its reason: name; settings[N].c; N is 0 to 15; a number is .x, .y, .z or .w; a colour is .xyz or .yzw; min max step default; color r g b; min below max; step above 0; default from min to max; name used twice; place used twice. The reasons show in red in the message bar, e.g. `Settings: line 1 · Q: N is 0 to 15` ("Deck B: " in front on PERFORM).

**On a compile.** `settingsFrom(d,src)` runs when a shader compiles cleanly on a deck (PLAY's `main()` build and `makeDeckGpu`'s build). It reads the declaration from the shader as written, not from the authoring preview's patched copy, and keeps it on the deck as `d.setDecl` `{src, list}`. A setting with the same name, type and place as before keeps its value; a new or moved setting takes its default; floats no setting declares are 0. The same source again changes nothing, so a second compile of the running shader keeps its values. Every change of declaration calls the functions in `SET_ON` (the Settings drawers rebuild, 7.8).

**Export: keeping a look.** `settingsBake(src,d)` returns `src` with each declared setting's default replaced by deck `d`'s current value, matched by name; only the default numbers change, and a number whose value has not changed stays exactly as written. `shaderNextName(d)` gives the next version's name: the deck's shader name with `_V##` stepped up by one, the digits kept, or `_V01` added to a name without a version; a shader with no name is `OMS_Vizzie_Shader_V01`. `saveShader(d,src)` downloads `settingsBake(src,d)` as `NAME.wgsl` (the original file is never touched); the deck then holds that version: its name (`d.shaderName`), and, when `src` is the deck's running shader, its defaults (a double-tap goes to the exported values) and its source; any Code view showing that code shows the exported text. Message 'Exported NAME_V12.wgsl to Downloads' ("Deck B: " in front on PERFORM). Export sits in the Code views (6.1). The internal names keep "save" (`saveShader`, `#labSave`, `.pf-csave`); what shows is Export.

**The bind group layout.** `contractLayout(device)` is one explicit group 0 layout with bindings 0 and 1 (uniform, vertex and fragment) and, since V1.3.28a, binding 2 (read-only storage), cached on the device. The automatic layout lists only the bindings a shader uses, so one bind group could not serve shaders with and without binding 1; the explicit layout always has all three, and a shader may use any of them. PERFORM's FX and OUT pipelines are separate and keep their own layouts.

### 2.2.6 The AMU span tables (binding 2)
V1.3.28a (BLOG0203, the product owner 2026-11-14). A shader sees one frame at a time, so on its own it cannot compare spans across the song or look ahead ("the busiest sections", "the section before the biggest one", "a ball count that follows each section"). `amuTables(M, toBeat)` works that out once, when a deck takes a track (`setTrack`), from whatever AMU is loaded: one table per lane, one row per span, so the row count is the song's. Nothing is written to the AMU JSON. The result is kept on the deck (`d.tab`, a `Float32Array`) and each renderer writes it to its deck's binding 2 buffer (`TAB_BYTES` 1 MB) when it changes.

- **Lanes, in this order:** 0 section, 1 segment, 2 phrase, 3 bar, 4 pace.
- **Head (16 floats):** [0] section first row, rows, segment first row, rows · [1] phrase first row, rows, bar first row, rows · [2] pace first row, rows · [3] song length in beats, BPM.
- **Row (24 floats, `AmuRow` = 6 × vec4):** `pos` start (beats), length (beats), index, rows in lane · `avg` drums, bass, vocal, other averaged over the span (0 to 1) · `norm` the same scaled to this song's range in the lane · `loud` LUFS, LUFS norm, pace, pace norm · `rank` drums, bass, vocal, other within the lane (1 = highest; values within a tolerance share a rank) · `lvl` LUFS rank, pace level (1 = highest; pace values within 1 % are one level), pace levels in the song, 0.
- **Current index per lane:** section slot 20, phrase slot 21, segment slot 22, bar slot 5, pace slot 15 (slots 5, 15 and 22 were reserved and always 0 before V1.3.28a).
- **In WGSL:** the template declares `AmuRow`, `AmuTable` and `amuRow(lane, i)` (index clamped to the lane), with a commented example: a count from the current section's drums norm, a look-ahead to the next section, and song progress (`vizzie.time` / head[3].x). Rule R23 (9.6).

A shader that does not declare binding 2 is unaffected. Mezcla must build the same table, binding and slots.

### 2.2.5 Authoring preview bindings (@group(3))
The authoring preview's three bindings sit in `@group(3)`, keeping their binding numbers: 1 object mask (`partMask`), 2 overlay probe (`gprobe`), 3 CRYPTOMATTE (`cm`). They are patched into the preview's copy of the WGSL only (9.2); the shipped `.wgsl` is unchanged and group 0 is the contract's alone. Group 3 rather than 1: the contract roadmap keeps group 1 for assets, and 3 is the last group WebGPU allows by default. When the preview has objects, `bindP` holds bind groups 1 to 3 (1 and 2 empty, as WebGPU expects every group in the layout to be set; 3 the preview's buffers, with an explicit layout from `AUTH_GPU.entries()`), and each frame sets them after group 0. PERFORM's deck renderer never had the preview bindings.

## 2.3 The WGSL runtime (critical)

`main()` requests the adapter and device, configures a `webgpu` context on `#labGpu`, creates the 144-byte uniform buffer and the settings buffer (`SET_BYTES`), and calls `AUTH_GPU.init(device)`. `build(src)` compiles the shader (through `AUTH_GPU.patch`, 9.2), reads `getCompilationInfo()`, and only if it is clean reads the settings declaration (`settingsFrom`), builds a new pipeline on `contractLayout(device)` and a bind group, and swaps them in: a bad shader never kills the running one; the error line shows in `#labGpuMsg`. `build` is exposed as `window.__applyWGSL`.

### 2.3.1 Why it runs like a game engine
Per frame: write 144 bytes (AMU block) and 256 bytes (settings block), the authoring buffers when on, one render pass, `draw(6)` (a full-screen quad). No per-frame recompilation, no analysis, no cross-origin messaging. A settings change is a buffer write, not a recompile. Keep it that way.

### 2.3.2 Full shaders only
`WGSL` is the default scene as a complete shader (`struct U`, binding, `vs`, `fs`). Apply, drop and pick compile the source as-is.

### 2.3.3 One PLAY viewer, deck textures on PERFORM
PLAY has exactly one WebGPU canvas. `window.__placeGpu()` moves it, with its overlay canvas and error line, between the PLAY stage (`#labStage`) and Pocket Rave (`#prPlay`). Never create a second WebGPU canvas for another PLAY surface: move the one.

PERFORM is the exception by design: each PERFORM deck renders its own shader into its own texture (`window.__deckGpu`), shown on that deck's stage (the deck's "headphones"), and OUT (`window.__outGpu`) blends the two textures (8.5).

## 2.4 Message System: the feedback bar (CORTEX)

Built and working on PLAY and PERFORM. Every message and its wording is listed in E 9 (Message index).

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

**Keys win over a resting mouse** (V1.0.24c, BLOG0206): a key press puts `.kbd-nav` on the body, and until the mouse moves `bindHelp` shows no hover help (focus help still shows) and the LIBRARY shows no hover tint. Before, a list redrawn under a still mouse fired the hovered row's help over the keyed row's. It lives in the one hover handler, so it applies to every control.

---

# 3. Node: Deck Audio, Tempo, Key Lock

## 3.1 Deck audio engine
`makeDeckAudio(ctx,buf,canStretch,keyLock)` plays the decoded track through Web Audio: an `AudioBufferSourceNode` (or the KEY LOCK worklet) into a `pre` node, then the deck gain node, into the master bus (`masterIn(ctx)`, 3.5). The FX rack sits between them where the deck's FX are live (`FX_LIVE`, 8.8): PERFORM's decks, and PLAY's deck on PLAY: `pre` → AFX1 → AFX2 → gain; on PERFORM the deck's TRIM and EQ come first, `pre` → TRIM → LOW → MID → HIGH → AFX1 → AFX2 → gain (8.12); in CREATE and Pocket Rave `pre` connects straight to the gain. Position = the offset played from + AudioContext time since the start × rate (the audio hardware clock, sample-accurate). It keeps the interface the app used with an `<audio>` element (`currentTime`, `duration`, `paused`, `ended`, `play`, `pause`, `captureStream`) plus `rate`, `keyLock`, `buffer` (the decoded audio) and `lockAt(when, offset, rate)` (V1.4.26a: start at an exact audio-clock time at a fixed speed; a playing source hands over with a 6 ms crossfade; each source goes through its own gain for it; with KEY LOCK the worklet holds a play message set for a later time until that time, 7.10). One engine per deck (`d.audio`), all on the app's one AudioContext. `audioContext()` creates the AudioContext inside the drop or pick gesture; any pointer, key, touchend or click event resumes it if the browser suspended it. Web Audio only, no browser-specific APIs, with two iOS / iPadOS Safari provisions (V0.10.07d): `navigator.audioSession.type = 'playback'` where the browser has it, so silent mode does not mute the music, and the first touchend or click plays one silent sample (`audioUnlocked`), which unlocks the AudioContext for the session.

Deck volume: on PERFORM each deck's gain follows its MUSIC encoder with an audio taper, gain = position² (8.5); on PLAY its deck plays at full. One function gives that value, `deckVol(d)` (PERFORM: MUSIC², 0 when killed; PLAY: 1), and a new audio path starts at it: `makeDeckAudio(ctx,buf,canStretch,keyLock,vol)` builds the gain node at the deck's volume, so a track loaded onto a deck with its MUSIC down or killed makes no sound, also when it starts at once on a playing deck (V1.1.02, BLOG0227 Load thump). Before, every load built the path at full and the MUSIC value came a frame later.

## 3.2 Warp: steering the deck to the clock
`steerDeck(d)` runs every frame for each playing deck. Target = the deck's track time (`d.t`). Speed = its warp map's local tempo × TEMPO (`d.beatLen(d.beat) × MASTER.tempo / 60`), times a correction that closes the gap over about a second, capped at ±2 %. A gap over 250 ms (a seek, a stall) is jumped instead.

With KEY LOCK on, the gap is measured against where the time-stretch really is (V1.1.01, BLOG0226 KEY LOCK: decks drift apart over time). The worklet posts its read position, the nominal track position of the block being played, every 8 render blocks (about 23 ms): `{type:'at', id, t, pos}`, with `t` the AudioContext time of that block. The deck's audio position is the last report carried forward at the rate, so the pull above closes the real gap. The play message carries its start time (`{type:'play', pos, rate, id, at}`): a start that reaches the worklet late begins in place instead of late. Before V1.1.01 the position was the engine's own prediction (start + elapsed × rate), so the pull never saw the worklet fall behind and KEY LOCK decks drifted. KEY LOCK off is unchanged: the buffer source plays at the exact rate set.

A seek, PLAY or load on one deck does not reset the master clock's last tick (V0.8.09b), so scrubbing one deck never stalls another.

**Steering** is the name used for `steerDeck` (BLOG0084, V0.6.20a). It is off for the two decks of an AUTO MIX while the mix plays (AUTO MIX Lock, V1.4.26a, 7.10): their audio runs untouched on the audio clock and their beats follow it. The 0.1 s step cap (2.1.3) stands; BLOG0324 (a slow frame bends the music) stays parked, a fix tried in V1.4.27a having been pulled.

## 3.3 TEMPO and the tempo master
**The tempo master** (`tempoMaster`) is the deck that sets the tempo, as Traktor AUTO and the CDJ master. `masterTick()` runs every frame over the open surface's decks (`surfDecks()`) (V1.0.30a, 30e; BLOG0215 Tempo master):
- The deck started first is master. It keeps mastership while it plays; on PERFORM, while it plays and its MUSIC is up (above 0, not killed).
- When the master stops, a playing deck takes over: on PERFORM one whose MUSIC is up first. When the master's MUSIC goes down while it plays (PERFORM), a playing deck whose MUSIC is up takes over, as on a pause; with none, the master stays.
- With nothing playing on PERFORM, a master whose MUSIC is down hands mastership to a deck whose MUSIC is up. With nothing playing on PLAY, the master stays.
- Bringing the old master's MUSIC back up does not take mastership back.
- **By hand:** a click on a deck's MASTER (or Enter from the keyboard) calls `setMasterByHand(d)`: the deck becomes master and is pinned (`masterPin`). The next start or stop of any deck, or any deck's MUSIC going up or down (`masterSig`), ends the pin and hands it back to AUTO.
- The tempo never changes on a start, a stop or a handover.

On PLAY the master is its one deck. A surface switch (`window.__surf`, 8.1) gives mastership to the open surface: PLAY's deck on PLAY; back on PERFORM, PERFORM's last master. On PERFORM the master deck's MASTER is lit.

**A load and the tempo** (`tempoOnLoad(d)`): a track load sets the tempo to the new track's BPM only when no other deck on its surface is playing and the deck is the master (PLAY's deck always is). A playing deck is never retempoed by another deck's load (V1.0.30a; before, any load on deck A set the tempo, so a playing deck B was retempoed).

**TEMPO** is one field in the global strip (7.3), the same field on PLAY and PERFORM (`bindTempoField(tv)`). It is a keyboard stop (8.14): W A S D and the plain arrows move on from it; Shift+↑ / ↓ = ±1 BPM, Shift+← / → = ±0.01 BPM (V1.0.29b); type a value and Enter, Escape leaves the field, double-click = the master deck's track BPM exactly. These keys act only in that field; there are no app-wide tempo keys. `setTempo(bpm,exact)` sets `MASTER.tempo`, rounded to 0.01, clamped to half and one and a half times the **master deck's** track BPM, and every loaded deck's rate. `d.ratio()` = master tempo / the deck's track BPM. The change message is "TEMPO 129.01 BPM" (orange). There is no tempo % any more.

**TEMPO follows the song until set by hand** (V1.3.16a, BLOG0303). On PLAY (with CREATE and Pocket Rave) the TEMPO follows the song's own tempo at the playhead, from its AMU beats, so a song with a tempo change plays as recorded and the readout moves with it. On PERFORM it follows the tempo changes of the MASTER deck's song in proportion; a change of MASTER deck does not make it jump. Set by hand (keys, typing, the Twister's push and turn) it holds; a double-click on TEMPO (or the Twister's 1 s hold) goes back to following. Each tab keeps its own TEMPO. A tempo-change song starts at its main tempo (the tempo most of its bars play at), which the LIBRARY's BPM column and the 'Loaded AMU' message show.

## 3.4 KEY LOCK
**Removed from the interface in V1.3.04a (BLOG0293):** KEY LOCK does not work well enough in the HTML app, so its button is gone from PLAY, CREATE and the PERFORM decks; every deck plays with KEY LOCK off and the pitch follows the tempo. The time-stretch code below stays in the app, unused. Mezcla carries key lock natively.

On, the deck plays through the `vizzie-stretch` AudioWorklet: a WSOLA time-stretch (Hann-windowed frames, overlap-added) that holds pitch at any rate. The worklet source is `STRETCH_SRC`, loaded once per AudioContext by `loadStretch(ctx)` as a `data:` URL module (a `blob:` module is refused from `file://`; blob is the fallback). **The splice match** (V1.1.03, BLOG0228 KEY LOCK sound: echo and muddy kicks): each new frame is placed where it best continues the last one, rated by normalised cross-correlation over 1024 samples, so the match does not depend on loudness; the search runs ±512 samples, every 4th offset first, then ±3 around the best. Before, the rating was raw signal strength over a shorter stretch: a louder spot won over a matching one, so frames landed in the wrong place and parts played twice a few ms apart (an echo, muddy kicks), even at an unchanged tempo. The rate always carries the clock's pull (3.2), so it is never exactly 1 and the worklet never plays the track straight. Transients: `findOnsets(buf)` finds the track's onsets once (high-passed level steps over twice the recent average, at least 50 ms apart) and the worklet places attacks so drum hits keep their snap. Off, the plain source's playback rate moves pitch with tempo, like a turntable.

Per deck (`d.keyLock`), **off by default** on every deck since V1.2.09a (BLOG0254, the product owner; on by default from V0.8.28a). Where the browser has no AudioWorklet, KEY LOCK shows off and disabled.

## 3.5 The master bus: ISOLATOR, MASTER, DSP
V1.0.20a (BLOG0180 Master gain for PERFORM audio, BLOG0181 Isolator in the mixer (3-band, full kill), BLOG0197 DSP: master compressor / limiter). Every deck's gain node feeds one bus, built once per AudioContext by `masterIn(ctx)`: ISOLATOR → MASTER gain → DSP compressor (a `DynamicsCompressorNode`) → DSP OUTPUT gain → the speakers. Before, each deck went straight to the speakers. The state is `MSTR`; `masterApply()` sets the nodes.
- **ISOLATOR:** three bands split at 250 Hz and 2.5 kHz by Linkwitz-Riley crossovers (two Butterworth filters on each side; an allpass at 2.5 kHz keeps LOW in phase with MID + HIGH), so the bands sum flat at 0 dB. Each band (`MSTR.iso`, a linear gain) runs from full kill (left) through 0 dB (centre, the default) to +6 dB (right); a killed band (`MSTR.isoK`) is silent.
- **MASTER** (`MSTR.db`): the output level after the isolator, before DSP. −60 dB = off (−∞), default 0 dB, top +6 dB.
- **DSP** (`DSP_PRESETS`, Dojo V5.9.0's values from its code): Off 0 dB 1:1; Gentle −12 dB 2:1; Medium −18 dB 4:1, OUTPUT +1.58 dB; Aggressive −24 dB 8:1, OUTPUT +2.92 dB; Limiter −3 dB 20:1. It starts on Limiter. THRESH −48 to 0 dB, RATIO 1:1 to 20:1, OUTPUT −12 to +12 dB; turning a knob makes the preset CUSTOM.
- **PERFORM only**, as the EQ and TRIM: a check every 200 ms (`mixOn()`) sets `MSTR.perf`; off PERFORM every stage is neutral (bands at 1, MASTER 0 dB, compressor at 0 dB threshold and 1:1, OUTPUT 0 dB). The nodes stay in the path on every tab.

The controls are on PERFORM: the isolator in the ISOLATOR drawer (8.7; in the MIXER header until V1.3.02a), MASTER and DSP at the global strip's right end (7.3).

## 3.6 Audio calibration tests
BLOG0229 Audio calibration tests. How an audio change is checked before a build is handed over, written so the tests can be rebuilt. The tests are not part of the app: they run the build headless in Chromium (Web Audio, the real worklet) and read the decks from the page. Every build that touches deck audio, the clock or KEY LOCK reports the five, in this order and these units, in its build notes.

**Click track:** 44.1 kHz stereo, 200 s, a kick every 0.5 s: a sine sweeping 50 + 120·e^(−30t) Hz, decay e^(−12t), 0.25 s long, amplitude 0.9. **Tap:** the final output, before the device. An onset is the first sample above 0.15 after at least 0.15 s below; its time is the block's playback time plus its offset. The deck's grid position is logged every 16 ms and read at each onset; error = grid position − heard kick time (a constant offset is the tap latency; only change over time counts).
1. **Drift** (ms, first to last window): the error's median per 10-second window. Cases: steady at ×1.06 for 2 minutes; the tempo jumping ×0.94 / ×1.08 every 1.7 s for 90 s. Pass: the last window within 5 ms of the first.
2. **Two-deck phase** (beats): both decks on the click track, the tempo jumps as above, the app hidden 3 s and shown; once a second the fractional beat difference between the two deck clocks. Pass: constant within 0.001 beat.
3. **Load thump** (output peak, 6 cases): a deck at volume 0 gets a track loaded while it plays, while it is paused and while the other deck plays, each with KEY LOCK on and off. Pass: peak below 0.0001 in every case.
4. **KEY LOCK kick fidelity** (offline): the stretcher rendered on a 30 s mix at 124 BPM (kick, off-beat noise hat, bass, pad) at ×1.0003, 0.97, 1.03, 0.94, 1.06, 0.90 and 1.12; each kick from −5 to +120 ms against the source at the best lag within ±15 ms, as normalised correlation (1 = identical).
5. **CPU** (ms/s): the stretcher's offline render time per second of audio, 20 s at ×1.06 and ×0.94.

---

# 4. Node: Deck Controls (one code for every deck)

Since V0.8.07a every deck control is one shared component, used by PLAY's deck, both PERFORM decks and, for the pickers, Pocket Rave. A deck view places the components; it owns no control of its own. A fix to a component reaches every deck.

## 4.1 The control strip
`STRIP` is the one definition of a deck's transport buttons: **PLAY** (`.btn primary`), **CUE**, **LOOP** and **Music Visual Pair** (`.btn loop`, `mvp`; KEY LOCK's item until V1.3.04a, 3.4). `buildStrip(holder,o)` builds them into a deck view (`o.ids` keeps PLAY's element ids, `o.ctx.mix` says whether decks are mixed); `bindDeckButtons(d,b)` binds them and SOLO; `deckButtonsUI(d,b)` shows their state each frame (PLAY / PAUSE text, `armed` while a QUANT start waits, LOOP lit, Music Visual Pair lit, SOLO lit). CUE was removed in V0.8.21a (it did nothing); LOOP, removed in V0.8.41a, came back in V0.9.06a as the musical loop (2.1.3).

**CUE** came back in V1.0.30h (BLOG0218 CUE button right of PLAY / PAUSE), right of PLAY: back to the start of the track (0 s) through `deckCue(d,0,…)`, the waveform click's path. Playing, it lands on QUANT and the deck plays on, as a chip click; paused, at once. A chip loop is released on landing. One strip definition, so PLAY (both modes) and both PERFORM decks have it. A press, never lit.

PLAY goes through `deckPlayPress(d)`: a start waits for QUANT when another deck on its surface is playing (`othersPlaying(d)`, 8.3), so PLAY's one deck starts at once; a second press while armed cancels it, and a press while a song switch waits cancels the switch ('Switch cancelled · the song plays on'; the switch is unused since V1.2.33a, 5.1). A deck's own PLAY clears the master PLAY's memory (8.4).

## 4.2 Lanes, buses and encoders
`LANES` holds the 12 AMU parameters (beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other), each with an id, bus, label, colour, draw kind, contract slot and data. `buildLanes(d,box,o)` builds a deck's six bus modules (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS), each lane a cell with a chip and an encoder. `o.buses` adds the bus headers; `o.labels` gives short chip labels (`LANE_SHORT`); `o.chips` builds chips only, no encoder (the mini players); `o.only` builds a subset of the lanes (Pocket Rave, 7.4).

**Chips on every surface** (V0.11.10a, BLOG0172 AUTHORING: Music Understanding encoders become the standard chips): every `buildLanes` call passes `o.chips`, so each lane is a chip (click = solo) with its short label, no encoder; the bus headers are thin colour bars without text (click = group solo); the solo shows on the chip. PERFORM decks, PLAY's `#labMini` and CREATE's `#labAMU` (`CREATE_LANES`) are the same. The lane gain (`d.knob`) stays at its value (1) in the deck model, so shaders get the same gates on every surface. On PLAY the large section is hidden and not painted (`paintLanes` runs on it in CREATE only). `buildLanes` can still build encoders without `o.chips`; no surface uses them.

## 4.3 Solo
Owned per deck by `makeSolo()` (`d.solo`): a set of lane ids and `grp:<bus>` keys. `d.solo.on(id)` is true when nothing is soloed, the lane is soloed, or its bus is. Solos are additive. The deck's SOLO button lights when any solo is active and clears all on click. One canonical id per parameter (the lane id) is used by the chips, the encoders, the gates and SOLO.

## 4.4 Piano roll
`deckRoll(cv,d,o)` is one roll component for every deck: draw, scrub, cue, zoom and orientation. **Its axis is master-grid beats**: the window starts at `R.view(t).b0` and is `R.win()` beats long; lanes come from the deck and are placed by `d.timeToBeat`, so bars stay bars at any TEMPO. The playhead is fixed at the centre (`ROLL_PH` = 0.5) at every zoom; the content scrolls under it. `o.only` draws a subset of the lanes and `o.wt` their relative sizes (`laneGeo`; tap-to-cue uses the same sizes), for Pocket Rave (7.4); every other roll passes neither and draws the twelve lanes, equal.

- **Window:** `o.base()` beats at zoom 1 × `R.zoom`, up to twice the song (`R.maxZoom()`), so the whole song is in view from the centre playhead wherever it is. Base: CREATE's roll `ROLL_WIN` from `MODES` (16 beats = 4 bars); PLAY's mini roll and PERFORM 16 beats.
- **Zoom field:** one data field (`ui.field`), the standard field (12.4). Click in, ↑ / ↓ move through five steps, 0, 25, 50, 75, 100. `R.step()` maps the zoom to that scale: 0 = the closest view (zoom 1), 100 = the whole song, evenly spaced between. Ctrl + wheel and two-finger pinch on the roll still zoom freely; the field shows where that lands on the same scale.
- **Opening view:** `o.step` and `o.horiz`. PERFORM rolls, PLAY's mini roll and Pocket Rave's roll open at 25 %, horizontal. CREATE's roll opens horizontal at 100 %, the whole song (V1.3.30a, BLOG0316; 0 % before), and keeps its place on the scale when a track loads or the mode changes (`R.at`, `R.keep()`), 120 px high (`o.hh`, the fixed horizontal height; V0.11.16a, BLOG0183 AUTHORING music row and roll as CREATE's); vertical it is 75 px high (`MODES` rollH).
- **Two rolls on the PLAY panel** (`o.active`): the full roll is active in CREATE, the mini on PLAY (the full roll is hidden there, V0.10.05a); each keeps its own zoom and orientation, and `R.syncUI()` puts the active roll's values on the shared zoom field and orientation button at every switch. The zoom field sits in CREATE's controls row and on PLAY's Music Understanding header (7.2).
- **Orientation:** vertical (lanes as columns) or horizontal (lanes as rows), toggled by the deck's orientation button. PLAY and CREATE share one button (`#labRollBtn`): on PLAY it sits on the Music Understanding header, left of the zoom field (V1.5.01d; `LAYOUT` moves it there and back to its place in CREATE's controls row, a comment marker); its icon is `ROLL_ORI` (V1.5.13a, 15a): three lanes of 1, 2 and 4 bars, drawn horizontal or turned for vertical as the roll runs, through `deckRoll`'s `ui.orientIco`. PERFORM's roll buttons keep their icon.
- **Input** (`rollInput`): drag = scrub in beats; click without dragging = cue to that block's start (`amuStart` / `amuCue`: beat, bar, section, segment, phrase, key span, pace step; loudness and the instruments are not cue targets). A cue goes through `deckCue(d,sec,landed)` and waits for QUANT whenever the deck is playing and QUANT is not None (8.3). With LOOP on the cued chip becomes the loop span; clicking the lit chip again releases it to the whole track. On a stopped deck the chip is **picked** (`d.pick`): the playhead goes to its start and REC renders it (6.4); any other playhead move, or PLAY, clears it. The looped or picked chip is lit solid cyan (Dojo 'selected'). A cued chip waiting for QUANT is filled Orange Julius `#FFA500` until the jump lands (`d.armed`, V1.1.09j; a cyan outline before). The Twister's cue cursor (8.15) is an Orange Julius outline on its chip.

**Chip ranges** (V1.3.20a, BLOG0308; lasting on PLAY since V1.3.24a, BLOG0311). Click a structure chip (section, segment or phrase), then Shift+click another, in the same or another structure lane, either order: the span from the earlier start to the later end is picked (REC renders it once; LOOP on loops it) or, playing with LOOP on, looped live. Mouse only; every deck roll; the range lights section, segment and phrase over its whole span (`box()`). On PLAY the range is a lasting selection (`DK.range`): it stays through scrubbing, play and LOOP changes; LOOP off keeps it lit; REC jumps to its start and renders it once (LOOP off) or loops it (LOOP on); Esc or a plain chip click clears it.

## 4.5 The drop zone and double-tap loaders
**One drop zone for the whole app** (`appDrop`, V1.0.01a to 12a, BLOG0191 One drop zone for the whole app). Files and folders dragged anywhere over the window, on any tab, show one layer over the whole window (`.drop-hint.app-drop`) with one hint built by `dropHint(main,types)`: "Drop files" with MP3, AMU .json, .wgsl, cover image, .m3u8 playlist, .omsset, .zip, one per line. `readDrop()` reads files and folders (File System Access handles first, which work on `file://`; then the older entries; then plain files) and records each file's path inside the drop (`f._rel`). **Every drop goes into the LIBRARY** (`libImport`, 8.9); the LIBRARY's summary is the last message. What else happens:
- **PERFORM:** nothing loads onto a deck; load from the LIBRARY (8.9).
- **A one-deck tab** (PLAY, CREATE, HELP, ABOUT, LEARN, Pocket Rave) **with its song playing:** the LIBRARY only; the song and its shader carry on (V1.0.04a).
- **A one-deck tab, nothing playing:** `deckDrop(fs,DK)` also loads PLAY's deck, in the LIBRARY's order, not the drop order (V1.0.10a): the first song by title (its MP3 tag, else its file name; `ALNUM`) among those with their AMU in the drop, else the first song; the AMU and cover with its name (a lone AMU or cover dropped with it goes with it); the first shader by name, at its newest `_V##`. They load shader, AMU, audio, then the cover (after the track, so its message comes before the LIBRARY's).
- **The rule** (V1.4.07a, BLOG0336): something playing, on any tab = the LIBRARY only, nothing on any deck changes, music or visual; nothing playing = PLAY's deck loads as above, PERFORM the LIBRARY only. Tried and taken out in the same line: a drop loading PLAY's deck while it played (V1.4.04a) and a per-deck drop on PERFORM (V1.4.05a, 06a: it depended on where the pointer was, which the one drop zone does not show).
- **Zips** (V1.4.08a, BLOG0340): a zip is opened in the browser (`dropZips`, `unzipFile`, `zipMsg`; `DecompressionStream`, no library; stored or deflated, not encrypted, not zip64) and its files go through the same intake as a dropped folder, at any depth: songs with their AMU, covers, the newest `_V` of each shader, each `.omsset` and `.m3u8` inside as a set (several allowed), the `.omsset`'s pairs, and the playing rule above. Skipped: `__MACOSX/`, `._` files, `.DS_Store`, zips in the zip, unknown files. A zip with no `.omsset` or `.m3u8` is a set named after the zip. The message is one line of counts, usable / found ('NAME: songs 2/2 · shaders 1/1 · covers 1/2 · sets 1/1 · pairs 1/2'); not a zip: 'Could not read NAME (not a zip)'.
- **The LIBRARY's view** (V1.0.12a): a drop with nothing playing sets it to ALL, its default (any filter and any applied set cleared); a drop with a song playing leaves it as it is. "Playing" is either deck on PERFORM, the deck on a one-deck tab. A drop applies no set (8.10).

The deck drop zones for files, PLAY's LIBRARY module drop zone and PERFORM's MIXER column drop zone are gone. `bindDrop(el,d)` is now only the target for a LIBRARY row dragged onto a deck (PLAY's `#labWrap`, each PERFORM deck): the deck shows "Drop to load" while the row is over it, and the drop loads the row there (`__libLoad`). The MIXER column gets its positioning frame (`position: relative`) where the drawers are made, because the EQ, FX and MODE drawers are placed in its coordinates (V1.0.14a: the removed drop zone code had given the column that frame).

**One intake** (V1.5.14a, BLOG0374): the drop's body is `intake(files)`, exposed as `window.__appIntake`; the drop calls `intake(readDrop(...))`, and PLAY's add-files picker (7.6) passes its files to the same function, so a picked zip, `.omsset`, song, AMU, shader, cover or playlist is taken in exactly as dropped.

**Double-tap loaders** (`bindLoaders`, `bindCover`): two taps within 300 ms. Cover = MP3 / AMU picker, waveform = MP3 / AMU picker, stage = `.wgsl` picker (not inside PLAY's Code view). The `.wgsl` picker has no `accept` filter because iOS greys out `.wgsl` when filtered; the name is checked instead. Single taps keep their own job.

---

# 5. Node: Song Info, Audio Loading, Waveform

## 5.1 Loading audio
`loadAudioFromBlob(blob,name,d)` reads the ID3 tags, decodes the track, loads the KEY LOCK worklet in parallel, builds the deck engine at the current tempo, places it at the clock's position and computes the waveform peaks. Sources: a packed MP3 (`TRACK_MP3`, 9.1), the example MP3 auto-loaded on the hosted site when none is packed (http / https only, from `./examples/`), a drop on the app (4.5), a LIBRARY entry (8.9), or the hidden pickers (4.5). Under `file://` the app runs on the AMU clock alone until audio is loaded.

**A load onto a playing deck** (V1.2.33a, BLOG0277): `__libLoad` presses the deck's PLAY (pause) first, then loads the track as onto a stopped deck; when the AMU and the audio are both in (`Promise.all`) the deck is put at 0 (`seekTo(0,d)`), so the track sits at 1.1.1, stopped. This holds for every source: a LIBRARY row (PLAY: double-click, Enter, ← / →; PERFORM: ← / →), a row dragged onto the deck, and the Twister Library push (8.15). DECK LOCK (8.2) refuses the load on a locked playing deck instead. The song switch on QUANT (`deckSwitch(d,e)`, V1.0.21a, BLOG0198) is no longer called: hot loading a playing deck could not be made reliable in the HTML app, while Mezcla does it natively (BLOG0198 and BLOG0278 dropped, the product owner 2026-11-12). The function is left in the code, unused.

## 5.2 ID3, track names, cover art and the song info
`readID3()` is an inline ID3v2 parser (v2.2 to 2.4, UTF-8 / UTF-16, no library): cover (APIC), title, artist, label, year, copyright. **The picture is copied (`slice()`) before decoding**: `decodeAudioData` takes over (detaches) the file's buffer, and a view into it would read empty afterwards (fixed in V0.8.32a; PERFORM decks showed no cover art before). `deckCover(d)` gives a deck's cover: the authoring pack's `TRACK_COVER` on PLAY's deck (`DK`) when packed, else the MP3's art, else the default. One rule for every deck (V1.4.03a, BLOG0335): every load on PLAY's deck sets the cover from that song (a dropped cover, then the MP3's art, else the Yobot Squint placeholder) through `deckCover`, as PERFORM's decks do; before, a song without art kept the previous song's. `deckInfo(d)` gives title and artist from the tags, the file name or the embedded track's info.

**Track names, one rule everywhere** (V1.0.24a, BLOG0206 LIBRARY: track names from the MP3 tags, one rule everywhere): the MP3's ID3 title · artist; no title = the file name without its extension; no artist = the title alone; other formats (WAV, M4A, AAC, FLAC, OGG) = the file name. The LIBRARY reads them with `tagsOf(f)`: the tag's bytes only, ID3v2 at the start of the file (its header gives its size) or ID3v1 in the last 128 bytes; a website track (`_url`) is read from its first 64 KB (a Range request). Each file is read once (`TAGS`), in the background after an import (`libMeta`), and the views redraw when the tags are in. The same names show in the LIBRARY, the song info and the message bar ('Loaded …', 'Loading …', 'Playing …', the row's hint; `tagLabel`, `trackLabel`). Pairing a song with its AMU and cover, and a set finding its tracks, stay on file names.

**The song info line** (`infoLine(box,d)`) is one shared function for PERFORM's decks and PLAY in both modes: one line, "title · artist · BPM · key", one style (11px Courier New, `#cfd6dd`, on `rgba(10,10,10,.85)`). It always scrolls (`.pf-tick.run`, V0.9.05a) right to left at about 40 px a second, repeating after a gap so it loops without a jump. It is measured again only on a new song or a resize.

A cover tap shows or hides the info over the waveform (`bindCover`: single tap = toggle, double tap = picker); it stays until the cover is tapped again: no click-elsewhere or Esc close, mode switches and track loads leave it as set. The info lets the pointer through (`pointer-events:none`), so the waveform keeps working under it.

PLAY uses the same line since V0.9.03a (the static panel is retired there and the cover no longer flips; the flip stays in CREATE). The panel's fields stay in the page, hidden: Pocket Rave reads them.

**Dropped cover** (V0.9.16a): a square image dropped with its track (4.5), or a LIBRARY track's cover (8.9), goes through `setDeckCover` and sets `d.coverURL`, which wins in `deckCover(d)` over `TRACK_COVER` and the ID3 art; loading another track clears it (`clearDeckCover`).

## 5.3 Waveform
`computeLevels(buffer,600)` → normalised RMS peaks per deck (`d.peaks`). `waveView(cv,d,hold)` draws a deck's whole-song waveform with its own cache, rebuilt when the audio, the track or the size changes, and its own playhead. The cache keeps its source (`w.src`: `d.peaks`, else `d.amu`), so a new track repaints every view of the deck, PLAY, PERFORM and Pocket Rave (V1.0.30f, BLOG0216; before, only PLAY's was reset and PERFORM's decks kept the first track's waveform). A click without drag is a cue through `deckCue()` (on QUANT while playing, message 'Cue · bar x.y · QUANT n'); a drag of 4 px or more scrubs (V0.9.04a). Before audio: on PLAY a dim placeholder envelope, in CREATE the sidecar's momentary loudness. The waveform is a whole-song view.

## 5.4 Loading a track's AMU JSON
A Sozo Sidecar v2 `.json` dropped on the app with its song (4.5), loaded with its track from the LIBRARY (8.9), or picked with the MP3 picker (PLAY, PERFORM decks and Pocket Rave), is recognised by its file type (`isAMU`). `amuFromSozo(j)` converts it to the compact AMU (`rhythm`, `structure`, `key`, `pace`, `loudness.momentary`, `instrumentActivity`; tonic names to 0 to 11 via `TONICS`; the instruments' ranges are not carried, as in the embedded AMU) and refuses a file that does not match, naming the missing field. `loadAMUFromFile(f,d)` puts it on the deck with `d.setTrack()` (from V1.2.30a to V1.3.14a a `//` note swallowed this call for LIBRARY loads, so the deck kept the previous AMU; fixed in V1.3.15a, BLOG0304): new warp map and lanes, playhead to the start, the song title from the JSON's `file` field until ID3 tags fill it. Audio and AMU load in either order; `checkPair(d)` reports a loaded MP3 more than 2 s longer or shorter than the AMU. The key name comes from the track (`TONIC_NAMES`).

---

# 6. Node: Viewer Surfaces

These are on the PLAY panel (PLAY and CREATE). Each PERFORM deck has a Code view too (6.1); PERFORM has no REC, and no Pop Out on its decks; the MIXER header's Pop Out opens OUT (8.5). On PLAY the stage shows its deck's visual FX when a VFX slot is live (7.6), so Pop Out and REC carry them too.

## 6.1 Code view
`</> Code` (`#labCodeBtn`) shows the current shader source over the stage (`#labCodeView`, editor `#labCode`), with three buttons and a status line beside them (`#labCodeMsg`):
- **Apply** (`#labApply`) compiles the editor text as the preview (`window.__applyWGSL`): "applied (preview only)" or "error, see stage".
- **Copy** (`#labCopy`) copies the editor text, as written: "copied".
- **Export** (`#labSave`) exports the editor text as the next version with the deck's current settings as its defaults (`saveShader`, 2.2.4); the editor then shows the exported text: "exported".

**PERFORM decks** (V0.11.09a, BLOG0175 Code on PERFORM decks; Export in every Code view): each deck header has `</> Code` (`.pf-code`), left of Settings. It opens the same Code view (`.pf-codeview`: the same markup, styles and button order, Apply · Copy · Export, editor `.pf-codeta`) over that deck's stage, with that deck's shader; Code lights while open. Apply sets the deck's shader (`d.wgsl`, `d.wgslVer`) and its stage compiles it ("applied", or "error, see stage" when the stage shows a WGSL error), on either deck; before V1.0.30i deck A's Apply went through PLAY's renderer, since the two shared the deck. A new shader loaded on the deck shows in its open Code view unless the editor has focus (`v.codeSync`). Clicks inside the Code view do not reach the stage, so a double-click in the code does not open the shader picker.

Editing a setting's default in the code and pressing Apply keeps the setting's current value (same name, type and place, 2.2.4); the new default applies on a fresh load or a double-tap reset. Export writes the current value as the default.

## 6.2 Drop or pick a `.wgsl`
Drop a `.wgsl` on the app (it loads on a one-deck tab with nothing playing, 4.5), load one from the LIBRARY (8.9), or double-tap the stage to pick one: the code view fills and the same compile path runs.

**Shader loads wait for QUANT** (`loadDeckShader(d,txt,name)`, V1.0.13a, BLOG0194 Shader loads wait for QUANT): a load from the LIBRARY, the picker or a drop follows the song-start rule. With any deck playing it swaps on the master's next QUANT step (`d.shPend`, fired by `quantTick()`); with nothing playing, or QUANT None, at once (`shaderNow`). While it waits the message bar shows 'NAME on the next 1/4' ("Deck B: " in front on PERFORM); a second load replaces it. The shader compiles at the step, not before. Apply in a Code view stays immediate. Deck messages name the shader by its title (`shNameOf`, 13.2): 'Loaded …', '… on the next 1/4', 'WGSL error in …'.

## 6.3 Pop-out
`openPopOut()` opens a window with a `<video>` whose source is `#labGpu`'s capture stream: the same pixels, hot-swapped shaders included. Double-click for fullscreen. **The pop-out keeps the clock running** (V1.4.16a, BLOG0348): a pop-out in full screen on the same display hides the main window, and the browser stops the main window's animation timer, which runs the music clock and the drawing. While a pop-out is open (PLAY's Pop Out, PERFORM's OUT pop-out), its own timer runs the same steps (`__chromeStep`, `__frameStep`) whenever the main timer has not run for 60 ms (`__mainT`), never twice in a frame. **Sharp at any window size** (V1.3.26a, BLOG0313): while the pop-out is open, `popSize(cv)` renders the canvas at the pop-out picture's size (the window fitted to the picture's shape × its pixel density up to 2, never below the preview, long side up to 3840); before, a big window showed a stretched small picture. SHOUT OUT and the tagline sit on the picture itself, not the window (7.9).

## 6.4 REC
REC records from the playhead (`startRec()`, no jump to 0; V0.9.07a). On a stopped deck with a picked chip (4.4): LOOP off = one pass, `REC.span`, and `chrome()` stops the recording and the deck at the chip's end ('Chip rendered · recording saved'); LOOP on = the chip loops and the recording runs until REC is pressed again. With no pick: from the playhead to the track end (LOOP off) or across the wraps until REC is pressed (LOOP on). On a playing deck it records from where it is. **Export size** (V1.3.19a, BLOG0307): while recording, the canvas's backing store is held at the orientation preset's export size (`ASPECTS[aspI].rec`, `REC.size`: 1920 × 1080, 1080 × 1080 or 1080 × 1920); the preview keeps its size through CSS. Before, a file came out at the preview's size.

**The recorded picture** (V1.3.25a, BLOG0312): REC captures a 2D canvas at the export size (`window.__recComp`): each frame the shader's picture, then, with SHOUT OUT on, `recShout(g, cv, W, H)` draws the SHOUT OUT scrim and text as they show on the stage (positions, scrolling and fades read from the page, scaled, drawn at full size). Each credit line is one run of text (`runLine`, V1.3.37a, BLOG0325): it starts where the label starts and each piece follows the measured width of the one before, so "Title · Artist" keeps single spaces at any export size; only a line that scrolls is clipped to its room. SHOUT OUT off = the picture only. With a PLAY chip range (4.4) REC jumps to its start.

Capture stream of that canvas + the deck engine's audio (`captureStream()` on its gain) → `MediaRecorder` at 16 Mbps, preferring H.264 / AAC MP4, falling back to VP9 / VP8 WebM; downloads as `VizzieWGSL_<WxH>_<time>` (the real size). The arrangement position box turns red while recording.

**REC is live capture.** A frame that takes longer to draw than the frame time is not in the file; a heavy shader at 1080p drops frames. The authoring overlay's GPU read-back never runs while recording (V1.3.36a, BLOG0322). Shader-side performance is the first fix (the StarshipGo findings: story values worked out once per pixel, binary search over span-table rows, stages and pieces bounded); an offline render (BLOG0323) and the clock's step cap (BLOG0324, a frame over 100 ms bends the music up to 2 %) are parked as findings.

## 6.5 Orientation
Cycles 16:9 → 1:1 → 9:16 (`ASPECTS`); `fitStage()` keeps the stage 16:9 of its width and centres the narrower shapes in it. Compact CREATE does the same since V1.0.23a (BLOG0204 Compact AUTHORING: stage keeps its 16:9 height in every orientation): its stage box is 16:9 of its width, capped at 60 % of the window height, in every orientation (`fw*9/16`; before, the box took the orientation's shape and everything under it jumped).

## 6.6 Arrangement position
`arrPos(a)` formats a deck's position as Ableton's arrangement position: bars.beats.sixteenths, the bar right-aligned in four places (1.1.1 to 9999.4.4), so the box has a fixed width and never moves as the bar count grows. One formatter and one box style (`#labRecTime`, `.pf-pos`) serve PLAY and every PERFORM deck. PLAY's box sits in its global strip (7.3): PLAY has one deck, so its position is the master position.

---

# 7. Node: Surfaces and Modes

## 7.1 Host check and compact viewport
Two checks pick what opens; neither detects the device.
- **Host check** (`PUBLIC_HOST`, read once): onemanshyo.github.io, or onemanshyo.com and its subdomains = the website; anywhere else (Claude preview, file://, localhost) = off-site (`AUTHOR_MODE`).
- **Compact viewport** (`compactMQ`, re-checked live): `(orientation:portrait), (max-height:500px)`.

| | Not compact | Compact |
|---|---|---|
| Website | Tabs PLAY · HELP · ABOUT · LEARN; opens on PLAY | Pocket Rave, switching by itself with the viewport |
| Off-site | Tabs PLAY · CREATE · PERFORM · HELP · ABOUT · LEARN; opens on CREATE | compact authoring; its header goes to Pocket Rave |

**PERFORM and CREATE are off-site only**: on the website their tabs (and PERFORM's panel) are removed from the page. Off-site on a wide viewport, Pocket Rave is reached through compact authoring (a compact viewport, 7.5); the section headers switch nothing since V0.10.08a.

## 7.2 MODES and LAYOUT: PLAY and CREATE
**Names** (V1.4.22a, BLOG0355): the tab that plays music with visuals is PLAY (was CREATE); the tab that authors a shader to its music is CREATE (was AUTHORING), whose one mode is AUTHOR (the idle message 'CREATE · AUTHOR · AMU is the clock', the header 'Visual : Author'). Code names stay as they were (`lab`, `author`, `public`, `authoring`, `authorOn`, `#labWrap`, `cr-` classes), and code comments written before V1.4.22a say CREATE for PLAY and AUTHORING for CREATE.

PLAY and CREATE are two tabs over one panel, `#panelLab`, in two modes (V0.10.08a). `switchPanel('author')` shows `#panelLab` and calls `setMode(true)`; `switchPanel('lab')` shows it and calls `setMode(false)`. Every value that differs between the two modes lives in one table, `MODES` (keys `authoring` and `public`; `public` is PLAY); app code reads `mode()` instead of testing the mode flag (`authorOn`, html class `author-on`). A new feature that differs by mode adds a key there.

| Key | CREATE | PLAY (`public`) |
|---|---|---|
| autoplay / loop | off / off | off / off |
| roll height (vertical) / window | 75 px / 16 beats (horizontal: 120 px, 4.4) | (the large roll is hidden) |
| readout line | yes | no |
| placeholder waveform before audio | no (sidecar loudness) | yes |
| song info from the sidecar | yes | no |

`LAYOUT.render()` / `LAYOUT.author()` move the same elements between the two arrangements; nothing is duplicated. The Visual header row is found by its label (`#labVisTxt`), not by position.

**PLAY** (`LAYOUT.render()`), top to bottom:
1. **GLOBAL** section header (`#labModeHdr`, text `Global`) over the global strip (7.3).
2. A row of two columns. Left, under a **Music** header (`#labVisTxt` reads Music): `#labLeftCol` holding the music row (`#labMusic`, 40 px: cover 40 × 40 and the waveform), the controls row (`#labTransportHold`) and the LIBRARY module (`#labLibSec`, 7.6) down to the stage's bottom. The **Music** header carries what plays next: PLAY NEXT · CONTINUOUS · SHUFFLE · AUTO MIX · SELECTA (V1.5.08a, BLOG0371). Right, under a **Visuals** header holding FOLLOW · visual PLAY NEXT · visual CONTINUOUS · visual SHUFFLE (7.11), then Code, Pop Out, orientation and REC: the stage.
3. **Music Understanding** (`#labMuSec`), full width: the mini (`#labMini`: `buildLanes` with chips and bus bars, and its own `deckRoll` on PLAY's deck). Its header carries the roll zoom field and SOLO at the far right (V0.10.10d), at the header buttons' height. `LAYOUT.fitMu()` makes the MUSIC | VISUALS row exactly the stage's 16:9 height and gives the mini everything below it, down to the bottom of the page, at least 160 px, with no maximum (V1.5.20a, BLOG0380; from V1.3.01a, BLOG0289, the mini stopped at `MU_H`, 251 px, and the row took what was left, which opened a gap under the stage in a window tall for its width, such as a 4:3 iPad; `MU_H` remains declared, unused); a short window trims the mini to 160 px, then lets the page scroll. Then `libSnap()` caps the LIBRARY list (`max-height`) so it ends on a whole row; the few pixels left sit under it in the module, and the expanded LIBRARY (7.6) is not capped. It runs on render, on window resize and from a ResizeObserver on the left column and `.body`.

The large Music Understanding (`#labAMU`, its header) and the large roll (`#labRollWrap`) are hidden on PLAY. Because the controls row is off the page while the layouts swap, `LAYOUT` holds SOLO and the zoom field as references (`soloEl`, `zoomEl`) and moves them back in `author()`.

PLAY controls row (under the waveform): **PLAY | CUE | LOOP ........ EQ | FX | gear** (V1.5.08a, BLOG0371; EQ leads the right group, pushed right). `LAYOUT.render()` moves PLAY NEXT, CONTINUOUS, SHUFFLE, AUTO MIX and SELECTA (`labNextBtn`, `labContBtn`, `labShufBtn`, `labAutoMixBtn`, `labSelectaBtn`) to the Music header (`MHDR`, `.cr-mhdr` spacing), Music Visual Pair to the LIBRARY filter row (V1.5.01f, 10a, BLOG0370) and the roll orientation to the Music Understanding header (V1.5.01d); each is found inside the controls row while that row is off the page, and `author()` puts each back before its comment marker (`rollMark`, `mvMark`, `mhMark`). Until V1.5.08a the row was PLAY | CUE | LOOP | Music Visual Pair | roll orientation | PLAY NEXT | CONTINUOUS PLAY | SHUFFLE | AUTO MIX ........ SELECTA | EQ | FX | gear.

**CREATE** (`LAYOUT.author()`): the GLOBAL header and strip, the Visual header (`Visual : Author`, holding Code, Settings, Pop Out, orientation and REC) over the stage, the music row (cover 40 × 40 and the waveform box 40 px high, as PLAY's; V0.11.16a), the controls row **PLAY | CUE | LOOP | Music Visual Pair | zoom | roll orientation ........ SOLO**, the large Music Understanding (`#labAMU`: the lane chips and bus bars, as PLAY's and PERFORM's; V0.11.10a), the large roll (horizontal, 120 px, 4.4) and the authoring sections. FX, EQ, the gear, PLAY NEXT, CONTINUOUS PLAY, SHUFFLE, AUTO MIX, SELECTA, the LIBRARY's expand and add files, and the VISUALS header's FOLLOW group are hidden; the deck plays dry. CREATE keeps its Settings in the Visual header after Code.

**Scroll lock** (V1.3.33a, 33b, BLOG0319; CREATE only). A padlock button (`#labLockBtn`) on the Visual : Author row, left of orientation, lit and on at every load (nothing saved). On, the rows from GLOBAL through the picture stay in place while MUSIC and everything below scrolls under them: `#labWrap` becomes `display: contents` and each locked row is `position: sticky` at its own offset, its side margins and the gaps between rows filled with the page background so nothing shows through. Off, the page scrolls as before. A window too short to leave a quarter of its height below the locked block behaves as off. Hidden outside CREATE; `window.__lock()` re-applies it on a mode change, a resize and a change of the picture box.

`setMode(on)` switches mode, layout, roll and messages, and closes the FX drawer and the Settings drawer.

## 7.3 Global strips
A thin strip across the top of the tab, as Ableton's top bar: global settings you set and leave. One look on both panels (`.pf-global`; the PLAY panel adds `.cr-global` for its margins). On the PLAY panel it sits under a **GLOBAL** section header, which switches nothing (V0.10.08a). A global setting belongs here; a deck setting belongs on the deck.

| Tab | Strip |
|---|---|
| PLAY, CREATE | TEMPO · QUANT · arrangement position · Shaka (one deck = the master) |
| PERFORM | TEMPO · QUANT · PLAY · master position · Shaka ........ MASTER · DSP |

QUANT is one value on every tab: `bindQuantField()` binds every QUANT field (`QUANT_FIELDS`), and a change updates all of them (V0.9.04a).

**MASTER and DSP** (PERFORM, V1.0.20a; the bus is 3.5), at the strip's right end. **MASTER** (`#pfMasterGain`) is a standard field (12.4), as TEMPO and QUANT: Shift+↑ / ↓ ±1 dB, Shift+← / → ±0.1 dB (8.14), scroll, double-click = 0 dB; message 'MASTER −2.0 dB'. **DSP** (`#pfDspBtn`, the toggle style, sized as master PLAY, lit while open) opens a panel (`.pf-dspwin`, 280 px wide) that slides down out of the strip's right end, the drawers' slide, over the top of Deck B: a DSP header with the preset box (`.pf-dsppre`; click, then Shift+↑ / ↓ steps Off · Gentle · Medium · Aggressive · Limiter, then CUSTOM once a knob turns), the THRESH, RATIO and OUTPUT knobs with value boxes (`mkKnob`, the drawers' knob without a kill), and a GR bar (`.pf-dspgr`: the compressor's gain reduction, Orange Julius, 0 to 12 dB, drawn while the panel is open). Opening focuses the preset box; DSP again or Escape closes it. The strip has a positioning frame (`position: relative`) for the panel.

## 7.4 Pocket Rave
The website's compact surface, on PLAY's deck. Opens full frame (`.pr-expanded`); the ONEMANSHYO header toggles full frame and the normal view (off-site a further tap goes to compact authoring); the top strip (power light, jacks) returns off-site to CREATE. Shader: tap = play / pause; double tap in full frame = normal view, in the normal view = `.wgsl` picker. Cover: tap = song info over the waveform, on / off (the card follows the 5.2 rule); double tap = MP3 picker. The chrome (song card, waveform) redraws at about 22 fps only while Pocket Rave is on screen. Since V1.4.19a (BLOG0351) the deck's EQ, RGB and FX play on Pocket Rave (`FX_LIVE` includes it); before, it played dry. It is touch only: the keyboard flow (8.14) does not run there.

**Normal view** (V1.0.22a to 22h, BLOG0199 Pocket Rave normal view), modelled on compact CREATE, under the MUSIC / ABOUT / LEARN tabs, full width (8 px from the frame); the view scrolls. Top to bottom (`#prMusic`): **VISUAL** header (orientation, REC; V1.4.19a) · the canvas (`#prPlay`), 16:9, framed as CREATE's stage in the standard line (1px `#2a2a2a`, radius 6px; no glow, no colour while playing) · **MUSIC** header (PLAY NEXT · CONTINUOUS · SHUFFLE · EQ · FX · gear, V1.4.19a) · the 40 px music row (cover 40 × 40, waveform beside it; the song info on the cover's back) · **MUSIC UNDERSTANDING** header · the lane buttons · the roll · the status line (section · bar · BPM · key, as CREATE's) · vizzie app [version] · PLUR.
- The controls are the app's components: the lane buttons are `buildLanes` (chips and bus bars, click = solo) and the roll is `deckRoll`, both with `o.only` = STRUCTURE (section, segment, phrase) and INSTRUMENTS (drums, bass, vocals, other); beat, bar, key, pace and loudness are left out. The roll is horizontal, opens at 4 bars, 25 %; drag = scrub, tap a block = cue to its start, pinch = zoom; the instrument lanes are 0.75 of a structure lane's height (`o.wt`). It draws every frame.
- **The headers** (V1.4.19a, BLOG0351). VISUAL: orientation (16:9 · 1:1 · 9:16) and REC; each press runs PLAY's own button (one setting, one state). MUSIC: PLAY NEXT · CONTINUOUS · SHUFFLE · EQ · FX · gear, PLAY's order and icons, with their dots and Shift+click resets; each press runs PLAY's control, so the state is one. EQ, FX and Settings open one at a time in PLAY's drawer window, placed over Music Understanding from its header to the bottom of the roll (`place()`); pressing the lit button closes it; full frame closes it. Pocket Rave's own Settings button and drawer (`#prSetBtn`) are hidden; the gear opens PLAY's docked Settings (7.8). The canvas follows PLAY's orientation (1:1 and 9:16 at most 60 % of the screen tall). The waveform shows AUTO MIX's zone and envelopes as PLAY's does (7.10); AUTO MIX itself is turned on in PLAY.
- Left out: GLOBAL (TEMPO and QUANT still apply), the transport row (tap the canvas to play; pinch to zoom the roll), Code, Pop Out, the objects toggle and the authoring sections.

## 7.5 Compact authoring
Off-site on a compact viewport: Pocket Rave's frame and header with the authoring sections in one column (one row of 12 lanes, colour bars for chips). Its header goes to Pocket Rave. It can be forced on a wide viewport (Pocket Rave header, third tap), where it shows as a 430 px column. The arrangement position box, Pop Out and REC are hidden there. Its stage box keeps its 16:9 height in every orientation (6.5).

## 7.6 PLAY: LIBRARY, FX and the playlist controls
Built once when the app opens (V0.10.03a to 10e). PLAY only: CREATE hides the drawers' buttons and the list icons (`html.author-on`), and a mode or surface switch closes the drawer window (`window.__crFx.show(false)`).

- **LIBRARY module** (`#labLibSec`, `.pf-mod.pf-libmod`): a `Library` section header, the filter row and the list (`.cr-libin` > `.pf-list`), the same LIBRARY as PERFORM's (8.9) through a second view (`crView = libView(box,{decks:[DK]})`). It is placed in the left column under the controls row and fills it to the stage's bottom; its surround is the page gradient (V0.10.10b). Files reach it through the app's one drop zone (4.5), or the add-files picker below; it has no drop zone of its own since V1.0.01a. **Filter row** (V1.5.16a): ALL · MUSIC · VISUALS · SETS · expand · add files ........ Music Visual Pair · save · clear; `libListButtons` keeps that order when the sets change (expand right after SETS, add after it, Music Visual Pair anchored before save). Below 1100 px (not compact) the row's gap is 4 px and Music Visual Pair's padding 5 px. The list ends on a whole row (`libSnap`, 7.2). A one-deck view: A / ← and D / → both load PLAY's deck; Enter on a row does what its double-click does (V1.0.30b); a **double-click or double tap** on a row (the same row twice within 400 ms, timed by the list: `box._tapId`, `box._tapT`, because the first click redraws the row and iOS reports no second click) loads a track and plays it from the top (on a playing deck: the deck stops and the track loads stopped at 1.1.1, 5.1), or loads a shader (on QUANT while playing, 6.2). LIBRARY lists take `touch-action:manipulation` (no double-tap zoom).
- **LIBRARY expand** (V1.5.12a, 13a, BLOG0373; desktop PLAY only): `#labLibXBtn` (`.bgtoggle.mu-ctl`, a bulleted-list icon, lit while expanded) right of SETS. Pressed, the list box (`crView.box`) moves into a drawer window (`mkWin('labLibXPanel')`, in `#panelLab`) that slides down from the filter row's bottom over the left half of Music Understanding to its bottom, the LIBRARY's width (`xPlace()`); the filter row stays put. Press again, Escape, or EQ / FX / gear / SELECTA (`show()` collapses it first) = back after the slide up; a resize re-places it. Messages 'LIBRARY expanded' / 'LIBRARY back'; hover 'LIBRARY: expand down over Music Understanding (more rows, e.g. for pairing)'. No button on compact, Pocket Rave or CREATE.
- **Add files** (V1.5.14a, 16a, BLOG0374): `#labLibAdd` (`.bgtoggle.mu-ctl.pf-libadd`, a folder with a plus) beside expand clicks a hidden `<input type=file multiple>` with no type filter (iOS greys out `.wgsl` when filtered); the chosen files go to `window.__appIntake` (4.5), the drop's own intake, so the iPad (Safari, also as a home-screen app) loads packs where nothing can be dropped. Hover 'Add files: MP3, AMU .json, .wgsl, cover image, .m3u8 playlist, .omsset, .zip (the same as a drop)'. Expand and add take only the row's gap (mu-ctl's 6 px margin removed).
- **Music Visual Pair** (V1.5.01f, 10a, BLOG0370): in the filter row beside save (`#mvPairBtn`, `margin-left:auto`), where a set's pairs are saved; back in CREATE's controls row in CREATE (a comment marker).
- **FX** (`#labFxBtn`, `.btn.loop`): opens a drawer (`#labFxPanel`, `.pf-fxpanel` > `.pf-fxslide` > `.pf-fxin`) that slides down out of the controls row over the LIBRARY module: the row's width, from its bottom to the column's bottom (`place()`, re-run on resize and from a ResizeObserver on the left column). The drawer holds two knob modules (`.cr-eqgrid.cr-fxcols` > `.pf-eqcol`, 8px 4px inside; V1.5.19a, BLOG0379; a bare 72 px grid, `.cr-fxgrid`, before): AFX1 over AFX2, then VFX1 over VFX2: PLAY's deck's own slots (`fxCell(DK,dom,i,true)`, no deck name), not PERFORM's since V1.0.30i. Its hover help is bound when it is first placed. **Dot and reset** (V1.3.03a, BLOG0292): one dot left of FX, lit cyan while any effect is off neutral and not killed; Shift+click (or Shift+Enter) puts every effect back to neutral and clears kills, the picked effects and the drawer as they were ('FX reset: every effect to neutral').
- **EQ · FX · gear** (V1.4.17a, BLOG0349; EQ leads the right group since V1.5.08a): three buttons at the row's right end, PERFORM's order, one drawer window (`#labFxPanel`): EQ (`eqPan`) holds PLAY's deck's RGB (TRIM · BLUE · GREEN · RED) and EQ (TRIM · HIGH · MID · LOW) columns, two knob modules (`.cr-eqgrid`, 96 px columns), PERFORM's controls for one deck; FX the two modules above; the gear (`setPan`) the deck's Settings, docked (7.8); SELECTA's knobs (`selPan`, 7.10) share the same window. Every pane is a knob module per column, 6 px apart (V1.5.19a, BLOG0379), and none shows a scrollbar (V1.5.11a: `#labFxPanel` `scrollbar-width:none`, `::-webkit-scrollbar` hidden; the wheel, trackpad and W A S D / arrows scroll). One open at a time (`show('eq'|'fx'|'set'|'sel')`); a second click closes. Dots and Shift+click resets as FX: EQ lit when a band, TRIM or colour is off default or killed; the gear (purple) when a setting is off its default. The VISUALS header's Settings button is hidden on PLAY.
- **Music and visual FX on PLAY**: PLAY's deck's rack is live on PLAY and on Pocket Rave (`FX_LIVE`: `DK`, PLAY mode or Pocket Rave, the PLAY panel shown); the EQ plays there too (V1.4.17a, 19a): `pre` → TRIM → LOW → MID → HIGH → AFX1 → AFX2 → gain, as PERFORM's (8.12), and the RGB is applied to the picture. With a live VFX slot the renderer draws the shader into a texture (`ctex`), runs the shared visual FX chain (`vfxRun`, state `cvst`) and blits the result to the stage, so Pop Out and REC carry it.
- **PLAY NEXT** (`#labNextBtn`, `.bgtoggle.cr-pnext`, a press), **CONTINUOUS PLAY** (`#labContBtn`) and **SHUFFLE** (`#labShufBtn`) (both `.bgtoggle.cr-ptog`, toggles lit cyan as LOOP): icons, no text, on the Music header since V1.5.08a (after the roll orientation button in the controls row before; V0.10.06a, 06b); their states also show, dimmed, on the VISUALS header's visual buttons while FOLLOW is on (7.11). State `CP {cont, shuf}`; CONTINUOUS PLAY is on when the app opens (V1.3.09a, BLOG0298), SHUFFLE off. `window.__crNext(now)` takes the next track in the LIBRARY list as shown (`crView.rows`; an empty list falls back to every track in the LIBRARY's order, `libCmp`), after the one on the deck, wrapping: `now` (PLAY NEXT) stops the playing track and plays the next from the top; at a track's end (LOOP off) the end-of-track handler calls it, and it acts only while CONTINUOUS PLAY is on. SHUFFLE gives each track in PLAY's view a random sort key (`crView.shuf`), the track on the deck first, kept until SHUFFLE is off: the list is put in a random order and play follows it, as streaming players do.
- **Sets on PLAY** (V1.4.01a, BLOG0333): a double-click, double tap or Enter on a set row applies the set, loads its first song with its Music Visual Pair shader and plays it from the top, CONTINUOUS PLAY on ('Set NAME: playing from its first track · continuous play on'); a song playing stops first; on the set already applied it plays it again from its first song and the set stays applied. PERFORM unchanged (8.10).
- **Set link** (V1.4.02a, BLOG0334; V1.4.18a, BLOG0350): on the website an address with `?set=Name` (or `#set=Name`) applies that set once the website and Yodega sets have loaded, loads its first song with its pair, CONTINUOUS PLAY on; the browser holds the sound until the first tap ('Set NAME ready · tap to play'). The name matches without case, spaces or punctuation, and a set named 'Yodega: Name' matches Name; no such set: 'Link: no set named NAME on this site'. With a link the demo song does not load at open. Code: `webLinkSet()` reads the name, `window.__webLink()` applies it after the website sets load. A pack page (`yodega/YoPacks/<Pack>/index.html`, written by the drop script) forwards to `?set=` and names its set (`<meta name=vizzie-set>`), title and description; the app, opened from it, reads the pack pages (`window.__packPages`) and takes the pack page's title and description into its own `<title>` and description (bookmarks, history, shared links); without a link the app's title is unchanged.

## 7.7 The Moogerfooger strip and the header rename
The strip (`#prSafeTop`: red power light `.pr-pwr` and five jacks) shows on the main app on every tab, on the website and off it, inside the wood frame above the header (`html:not(.pr-on) #prSafeTop`; `.app` padding-top 26 px under the safe area), as on Pocket Rave (V0.10.11a). A tap on the strip acts only on Pocket Rave and compact authoring (off-site: back to CREATE); on the main app it does nothing.

**Metal inserts** (V0.11.06a, BLOG0173 Metal inserts run to the top through the Moogerfooger strip): the two metal inserts on the inner edge of the wood panels (`.app::before`, `.app::after`) sit above the strip (z-index 121; the strip is 120), so they run from the top of the window to the bottom, as in Mezcla.

**Header rename and tagline** (V0.10.11c; V1.1.04, BLOG0224 Header rename; V1.1.05, BLOG0231 Tagline): on the main app a tap on the power light makes both the header name (`#brandTxt`) and the tagline at the header's right (`#descTxt`) editable, each with a dashed cyan outline; the name gets the cursor, a click puts it in the tagline. Each takes up to 75 characters (`MAXN`): typing stops there, a paste is trimmed to what fits, and Enter keeps exactly what is shown (the old 24-character cut is gone). While typing, the message bar counts: "Header: 31/75 (Enter = keep · Esc = cancel · empty = ONEMANSHYO)". Each ends on its own: Enter or a blur keeps it, Esc restores it, empty restores its default (ONEMANSHYO; the tagline "Music makes magic!"); whitespace is collapsed; pasted text is plain. Keys typed there stop at the field (Space does not play). It lasts for the session: nothing is saved.

## 7.8 The Settings drawer
One component, `settingsDrawer(d,btn,anchor,limit,side)`, for every WGSL stage (BLOG0164 SETTINGS drawer, BLOG0176 Settings drawer: a fixed rack of 32 slots). It is built from the deck's declaration (`d.setDecl.list`, 2.2.4), rebuilt through `SET_ON` whenever the deck's shader changes, and writes straight into the deck's settings block (`deckSettings(d)`): no recompile, the picture follows the next frame. Values last for the session.

**Docked** (V1.4.09a, BLOG0341; V1.4.17a, BLOG0349): on PERFORM each deck's Settings opens from the mixer strip's gear, Deck A's column left and Deck B's right, two across, at least four rows in view, more scrolling (8.7); on PLAY from the controls row's gear, in the drawer window over the LIBRARY (7.6). The same component, placed in the drawer (`dock.pane`); the colour wheel is 92 px there. **PLAY: 8 across** (V1.5.09a, 11a, BLOG0372): PLAY passes `dock.cols` 8, so the rack is the drawer's full width in rows of 8 (`.cr-setcol .set-pnl`), the shader's own settings following the standard ones with no empty slots, and only the rows in use (V1.5.19a: full rows of 8, at least one); PERFORM's dock has no `cols`: two across, a shader's own settings on a fresh row of two, at least four rows. **PLAY's columns are knob modules** (V1.5.19a, BLOG0379): `.pf-eqcol.cr-setcol` loses its outline and each of the 8 columns is drawn as one module by its cells' borders (side borders on every cell, the top on the first row, the bottom on the last; the colour wheel, the panel's last child, excluded), 6 px between columns, 3px 4px inside each cell (8 px at the module's top and bottom). PERFORM's deck headers and PLAY's VISUALS header no longer carry Settings; CREATE keeps its button in the Visual header, and Pocket Rave uses PLAY's gear (7.4).

**The button.** **Settings** shows only while the deck's shader declares settings; a shader without settings hides it and closes the drawer. CREATE: in the Visual header after Code (`#labSetBtn`); PLAY: in the VISUALS header with Code, Pop Out, orientation and REC; each PERFORM deck: in its header right of `</> Code` (`.pf-set`); Pocket Rave: in its VISUAL header (`#prSetBtn`, 7.4). It lights while the drawer is open; click again to close. A mode or surface switch closes PLAY's drawer (`window.__setDrawer`), as the FX drawer.

**Changed dot and reset** (V1.1.08a, BLOG0237 Settings button): every Settings button but Pocket Rave's (`.set-btn`, 24 px padding each side) carries one purple dot at its left, as the EQ and FX buttons' dots (8.7): dim while every setting is at the shader's default (the declaration's defaults, `s.def`), a steady glow while any is changed; no blinking. Shift+click resets every setting to the shader default and leaves the drawer as it is; Shift+Enter does the same where the button is a keyboard stop (PLAY). Pocket Rave's button (`#prSetBtn`, touch only) has neither.

**Where it opens.**
- **PLAY:** sideways (class `set-left`), out of the stage box's left edge over the MUSIC column (`#labLeftCol`: cover, waveform, controls row, LIBRARY), the stage's height, from the column's left edge to 6 px behind the stage's left edge, the stage on top. Music Understanding below stays uncovered, and Space still plays. The side is set before the drawer is placed, so the first open also comes from the side (V0.11.09e).
- **CREATE:** slides down out of the Visual module's bottom edge, tucked 6 px behind it, at the module's width, as the PERFORM FX drawer.
- **Pocket Rave:** slides down out of the canvas, on PLAY's deck's values; full frame closes it.
- **PERFORM deck:** slides down out of the stage box's bottom edge, at the stage's width, over the rows below. The deck column clips what passes its bottom edge, so the drawer stays inside the column, 8 px above its bottom, and its panel scrolls when the settings do not fit. Each deck has its own drawer and block; PERFORM's Deck A is not PLAY's deck (V1.0.30i), so their values are separate.

**The rack** (`.set-pnl`, `SLOTS` = 32): 32 slots in 4 rows of 8, always drawn on CREATE and the undocked stages (PLAY: only the rows in use, above), as Ableton's macros: a slot not used shows an empty encoder (dashed, dim) and an empty value box (`.set-empty`). Settings in the standard area (`settings[0]` to `settings[3]`) fill the rack first, in declaration order; a shader's own settings start on a fresh row. A shader with no standard settings fills from slot 1. More than 32: the first 32 show and the bar says "Settings: N beyond the 32 slots not shown" in red. Each slot: the 36 px encoder, the name (10px, cut with "…" when it does not fit; the full name in the hover help), the value box (`.set-val`, 10px, 16 px high, up to 64 px wide, as wide as its column allows). A colour takes one slot.

**A slot.**
- **Number:** encoder drag up / down = its range in 150 px, snapped to its step; double-tap = its default. Field: click, then ↑ / ↓ = ± step, or type + Enter; double-click = default; Escape leaves.
- **Colour:** the encoder shows the colour, its pointer the hue; drag up / down = hue; tap = the colour wheel at the foot of the drawer (hue around, saturation from the centre out, a value bar beside it); double-tap = default. Field: a hex + Enter; double-click = default.

**Keys** (V1.1.07a, BLOG0236 Settings drawer keyboard): every encoder in the rack is a keyboard stop (`tabindex=0`). W A S D and the arrows move between them as in the EQ and FX drawers and stay inside the open drawer; W off its top row leaves (8.14). With the drawer open, the next W A S D or arrow from its Settings button goes to the drawer's first knob (`btn._setWin`), also on PERFORM, where the deck header's buttons are not stops. Shift+↑ / ↓ = one step, Shift+← / → = five steps (the setting's own step). A colour encoder: Shift+↑ / ↓ turn the hue 5°, Shift+← / → 30°; Enter opens and closes its colour wheel, as a tap.

Purple People Eater `#B24DFF` throughout (visual domain): arcs, names, value boxes and the selected ring. The drawer holds no Export: Export is in the Code views (6.1; V0.11.09f).

## 7.9 SHOUT OUT
BLOG0251 SHOUT OUT (V1.2.06a to 06d) and BLOG0260 (V1.2.14a). The Shaka button (`.shout-btn`: `#shoutBtnLab` in PLAY's and CREATE's global strip after the position, `#shoutBtnPf` in PERFORM's after the master position) turns the credits on and off. One state for the app (`window.__shout`, `{on}`), on when the app opens since V1.3.01b (BLOG0285; off before), not saved; lit (primary) while on. Messages: 'SHOUT OUT on: music and visual credits' / 'SHOUT OUT off'; hover 'SHOUT OUT: music and visual credits (on / off)'. No MIDI (MIDI is for frequent performance actions).

While on, a `.shout` box sits bottom left over the stage (3.2 % from the sides, 4.5 % from the bottom), two lines: "Music: title · artist" and "Visual: title · author" (the LIBRARY's names, 5.2 and 13.2; no tags = the file name). One font, one size and one colour, solid white with no shadow since V1.3.27a (BLOG0314; white at 70 % with a soft shadow before), no box; the size follows the stage (about 1.8 % of its height); a line past the stage edge ends with an ellipsis. Turning it on fades in over one beat; a new song or shader fades out and in over one beat. It is hidden while the Code view covers the stage.

**The scrim** (V1.3.27a, BLOG0314). Behind the credits, a soft dark gradient over the bottom 30 % of the picture (`_scrimB`: stops .62, .42, .25, .09, 0) and, while the tagline shows, one over the top 18 % (`_scrimT`: .5, .34, .2, .07, 0), under the text (z 2; the text z 3). They fade in and out with SHOUT OUT and the tagline over one beat (`scrimPass()`, run with `tick()` every 200 ms), on every host, and REC draws them too (6.4). SHOUT OUT off: no scrim.

**The tagline line** (V1.3.01c to 07a, BLOG0288; off by default since V1.3.17a, BLOG0305). The header's tagline ("Music makes magic!", editable from the red power light) is a third line, scrolling right to left across the top of the picture, one pass about 16 s, starting 4.5 % of the picture's height below its top, as the credits end 4.5 % above its bottom: the PLAY stage, PLAY's pop-out, the mixer OUT and its pop-out, never the deck canvases. It starts off on every load (`TAG.on`); a double-click on the header tagline turns it on or off for the session (V1.3.14a, BLOG0302): the header text is Orange Julius while on, grey while off ('Tagline on' / 'Tagline off'). While editing, a double-click selects a word instead.

**Square and vertical** (V1.3.08a, BLOG0297): on the PLAY stage a line wider than its room keeps its label (Music: / Visual:) fixed and scrolls the rest right to left, disappearing at the label; a line that fits stays still.

**OUT on and off** (V1.4.12a, BLOG0344): a Shaka (`#pfMixShout`) in the MIXER header, left of the pop-out button, on at open, turns SHOUT OUT off and on for OUT and the PERFORM pop-out only (credits and tagline); the deck stages keep theirs. The GLOBAL Shaka overrides: on turns the MIXER's on, off turns SHOUT OUT off everywhere ('SHOUT OUT is off (GLOBAL Shaka)').

**The mixer OUT and the pop-outs** (V1.3.01e to 01j, BLOG0286): one strip at the bottom scrolling right to left: "Deck A" and its Music and Visual lines, then "Deck B" and its two; a deck with MUSIC and VISUAL both at 0 is left out. The deck canvases keep their own two lines. In the pop-outs the lines sit on the picture, not the window, and follow it when the window is resized.

In CREATE the overlay draws above the scrim and the text (9.4).

Where: the PLAY and CREATE stage (it moves into Pocket Rave with the viewer), the pop-out (`shoutPop`), each PERFORM deck canvas (`.pf-dshout`: that deck's song and shader) and OUT (`shoutPf`, the scrolling strip below); a killed knob counts as 0.

## 7.10 AUTO MIX and SELECTA
BLOG0354 (V1.4.20a, 21a), BLOG0356 (V1.4.23a, 23b), BLOG0360 (V1.4.23c), BLOG0362 (V1.4.25a, 25b), BLOG0357 (V1.4.26a, 26b, 28b); V2: BLOG0365 (V1.5.01a), BLOG0366 (V1.5.01b, 01c, 01e), BLOG0368 (V1.5.01d), BLOG0369 (V1.5.17a, 18a, 19a). A PLAY feature (a party feature): with AUTO MIX on, each song in the list mixes into the next, from the AMU's structure. Nothing of PERFORM's decks, mixer or master section is used.

**The split** (V1.5.01b, BLOG0366, the product owner: AUTOMIX & Selecta V2). **AUTO MIX runs the mix and makes no mixing choices of its own**: the button, the preload, the AUTO MIX Lock, the handover, what ends a mix and the waveform shading. **The SELECTA decides the mix**: every number about where it sits, how long it is, how the music and the visuals move and what the tempo does is a SELECTA parameter. The engine holds no mixing values of its own: no refusal, no gap rule, no default bars.

**The button** (`#labAutoMixBtn`, a blender icon, `.bgtoggle.cr-ptog`), on the Music header after SHUFFLE (V1.5.08a); off when the app opens (`AM.on`). With it on the list plays on at a track's end even with CONTINUOUS off (the fallback when no mix was made). Turning it off during a mix ends the mix.

### 7.10.1 SELECTAs and parameter IDs
A SELECTA is keyed by its **numeric ID** (`SELECTAS = {1: {...}}`); its name and style are labels only. **SELECTA ID 1** always exists, sets every parameter, is the one selected when the app opens (`SELECTA = SEL1`), and supplies any parameter another SELECTA does not set: `sp(group, key)` reads the selected SELECTA's value, else SELECTA ID 1's. Parameter IDs are numbers with a fixed meaning: a new parameter takes a new ID; an ID is never reused for something else.

| ID | Group · parameter | Key | Built | SELECTA ID 1 (house club) |
|---|---|---|---|---|
| 1.1 | Zone · last full section, minimum bars | `zone.fullBars` | V1.5.01b | 8 |
| 1.2 | Zone · sections in the mix | `zone.sections` | V1.5.01b | 2 |
| 1.3 | Zone · bars per section, maximum | `zone.maxBars` | V1.5.01b | 16 |
| 1.4 | Zone · mix point: sections before the last full section | `zone.point` | V1.5.17a | 0 (the last full section) |
| 2.1 | Music Mix · volume | `music.curve` → `vol` | V1.5.01b | incoming 0 to full (`u²`) across section 1, full after; outgoing full |
| 2.2 | Music Mix · EQ low (100 Hz shelf) | `music.curve` → `eqLow` | V1.5.01b | incoming −30 dB in section 1, −30 to 0 dB across section 2; outgoing 0, then 0 to −30 dB across section 2 |
| 2.3 | Music Mix · EQ mid | | not built | |
| 2.4 | Music Mix · EQ high | | not built | |
| 2.5 | Music Mix · isolator LOW · MID · HIGH | `music.curve` → `iso` | V1.5.01b | incoming flat; outgoing flat, then out across the mix's last bar |
| 2.6 | Music Mix · filter | | not built | |
| 2.7 | Music Mix · AFX | | not built | |
| 2.8 | Music Mix · TRIM | | not built | |
| 3.1 | Visual Mix · mode (PERFORM's MODE list, `VMIX_MODES`) | `visual.mode` | V1.5.01c | MIX |
| 3.2 | Visual Mix · strength | `visual.curve` → `str` | V1.5.01c | outgoing full, then full to 0 across the last section; incoming 0, then 0 to full |
| 3.3 | Visual Mix · VFX | | not built | |
| 3.4 | Visual Mix · RGB | | not built | |
| 3.5 | Visual Mix · visual TRIM | | not built | |
| 3.6 | Visual Mix · shader settings | | not built | |
| 4.1 | Tempo · in-mix tempo change, % | `tempo.inMixChange` | V1.5.01e (only 0 built) | 0: the playing tempo holds; the incoming song is matched to it |
| 4.2 | Tempo · post-mix adjustment duration, bars | `tempo.postBars` | V1.5.01e | 16 |
| 4.3 | Tempo · post-mix maximum change, % | `tempo.postMax` | V1.5.01e | not set (no maximum) |
| 4.4 | Tempo · post-mix tempo target | `tempo.postTarget` | V1.5.01e (only `'track'`) | the playing track's BPM |

The curves take `m = {s: the section (0 = first), u: 0 to 1 through it, n: sections, last: 0 to 1 through the mix's last bar}` and return each song's values (`a` outgoing, `b` incoming). SELECTA ID 1 was set by the product owner: the zone values in V1.5.01b, the visual 'just the basics so we have values and it works' in V1.5.01c, the tempo after the IWSY The Album test in V1.5.01e (until then 4.3 was 5 %, from V1.5.01a; before V1.5.01a the 5 % was a refusal, BLOG0365). A test SELECTA with only 1.3 set mixes with every other value from SELECTA ID 1.

**The API** (`window.__selecta`): `list()` (ID, name, style), `get()` / `set(id)` (numeric), `param(group, key)` (= `sp`), `setp(group, key, value)` (writes the selected SELECTA's parameter, bumps `SVER`), `modes` (`VMIX_MODES`). Parked: an OMS set carrying SELECTA values (BLOG0376), the API as a control surface for MIDI and scripts (BLOG0377), AUTO MIX taking its timing from a set's mix points (BLOG0378).

### 7.10.2 The plan, the preload and the start
**The hidden deck.** `AX = makeDeck('X',AMU)`, AUTO MIX's own deck, not in `DECKS`: the incoming song (B) plays on it. Each deck's audio goes through its own mix strip, `chain(au)`: gain → low shelf at 100 Hz (`eq`, 2.2) → `vol` (2.1) → an LR4 isolator (250 Hz / 2.5 kHz, `g[0..2]`, 2.5) → the master bus. PLAY's EQ knobs are not used for the mix. `put(strip, values)` sets a strip's volume, EQ low and isolator.

**The plan** (`planFor(d)`). From PLAY's song (A) and its AMU: the last full section (the last with at least 1.1 bars), moved 1.4 sections earlier (the mix point; the anchor is never before the first section), then the sections before it up to 1.2, each mixed over at most 1.3 bars (the anchor section's first bars; an earlier one's last bars, ending where the next starts). It gives the mix zone in A's beats (`sB`, `eB`), the section bounds (`secs`), the bar it starts at, the length in bars and the time to preload (`ts`); a zone that would run past the track ends 0.5 s before it. At a mix point earlier than the last full section the handover comes earlier and A's bars after it are not played. `SVER` is in the zone's and the plan's cache keys, so a knob change plans again.

**Preload.** 30 s before the zone (`PRE`) the next song in the list (as PLAY NEXT picks it, SHUFFLE's order included, `nextId()`) loads onto `AX` through the LIBRARY loader (`__libLoad(id,AX)`), with its paired shader's text when there is one (and, with FOLLOW off and visual CONTINUOUS on, the visual list's next instead, `prep.vzNext`, 7.11); the message bar says 'AUTO MIX (SELECTA 1): NAME comes in at bar N'. Not ready by the zone's first bar: no mix, and the next song plays at the end, as CONTINUOUS.

**AUTO MIX Lock** (V1.4.26a, 26b, BLOG0357; Cortex since V1.5.01d). At the mix start both decks start on one audio-clock instant, 60 ms ahead (`when`): from A's audio position, A's beat at that instant (`bA`) and B's matching beat (B's AMU bar 1 plus the same distance into the zone, `bB`). A restarts in place and B starts, both with `lockAt(when, offset, rate)` (3.1): sample-exact on the audio clock, A crossfading 6 ms from its old source. Each plays at one fixed speed for the whole mix: its AMU's average beat length over the zone at the held tempo (`rA`, `rB`). While `AMLOCK` holds the two audio engines, Steering does not touch them (3.2): each deck's beat (visuals, fade, handover) keeps its smooth step and is pulled 15 % of the way to its audio each frame (a gap over one beat is jumped). At the handover, or when the mix ends, `AMLOCK` is cleared and Steering returns for the deck that plays on. The AMU Nudge (V1.4.24a) was removed in V1.4.28b: B lands on its AMU grid only.

### 7.10.3 The mix: music, visuals, tempo
**Music Mix.** Every frame of the mix `put` sets both strips from `music.curve(m)` (2.1, 2.2, 2.5). SELECTA ID 1: section 1, B up from silent with its bass out; section 2, both at full, the bass swapped on the EQ; the last bar, A's isolator takes A out.

**Visual Mix** (V1.5.01c, BLOG0366). When B has a paired shader that differs from the one on the stage, `mix.vis` holds its text: `frameStep` draws it on `AX`'s music data into its own texture (`VB`, built by `buildB(txt)`) and mixes it with PLAY's picture (after PLAY's VFX and RGB) through PERFORM's mix shader (`PERF_MIX`) in the SELECTA's mode (3.1, index in `VMIX_MODES`, OUT_MODE's order) at the curve's strengths (3.2, `mix.vv`); `window.__amVis()` hands the stage `{d, txt, ga, gb, mode}`. No pair (or the same shader) = no visual mix. At the handover PLAY's deck takes B's shader (`DK.shaderName`, `__applyWGSL`); until the deck's own pipeline is built the mixed picture with B at full stays (`vtail`), so there is no blank frame.

**Tempo** (group 4; V1.5.01a, 01b, 01e). At the start `mix.t0` = the playing tempo, `mix.t1` = 4.4's target (the new song's main BPM, `mainBpm(AX.amu)`), `mix.hand` = TEMPO typed by hand (`TS.c.hand === true` only). With 4.1 = 0 and no hand, `mix.hold`: `MASTER.tempo` stays at `t0` through the mix. With 4.3 set, `t1` is capped to `t0` ± 4.3 and `mix.cap` marks it. After the handover `gl` moves the tempo from `t0` to `t1` over 4.2 bars of the new song; at its end a capped tempo holds as `TS.c.hand = 'selecta'` (the TEMPO hover says 'held by the SELECTA (Post-mix maximum change), until a track loads or the next mix'), which the next mix does not treat as by hand, so later mixes keep moving (V1.5.01e: V1.5.01a's cap set TEMPO by hand and froze every later mix at 121.6 BPM in the IWSY test); otherwise the track leads again. A TEMPO typed by hand is left alone throughout.

**The handover** (`endMix(true)`, at the zone's end). PLAY's deck takes B over where it is, with no reload and no gap: `DK.audio = AX.audio`, its AMU (`setTrack`), beat, name, tags, cover, waveform peaks, lanes and LIBRARY selection; its shader as above (with FOLLOW on and no visual mix, the pair switches on QUANT, `mvPairLoad`). A stops. Pause, seek, a load, PLAY NEXT, leaving PLAY or turning AUTO MIX off during a mix ends it (`endMix(false)`): B stops, A's strip back to flat, A plays on as it was.

**The zone on the waveform** (V1.4.23a, 23b, BLOG0356). `window.__amZone()` returns `{secs, env}` for PLAY's song while AUTO MIX is on (cached by song, AMU length, SELECTA and `SVER`): the sections in seconds and 161 points of the SELECTA's music curve. `amShade(g,x0,W,H,len)` draws it on PLAY's waveform (`waveView`) and on Pocket Rave's: an Orange Julius zone (34 % over the earlier sections, 50 % over the last), an Orange Julius line at each section start, and the envelopes: incoming Green Slime, outgoing Goblin White, solid = volume × isolator, dashed = EQ low (0 dB at the top, −30 dB at the bottom), 0.9 px, no labels. It shows as soon as AUTO MIX is on, follows each new song and redraws at once when a SELECTA knob turns.

**Clock hook.** `chromeStep` calls `window.__amTick(db)` after the decks have moved (2.1.3a): it runs the post-mix tempo change, the preload, the mix start, the fade (`put` from the curve every frame) and the handover. `window.__am.state()` reports it (tests).

### 7.10.4 The SELECTA knobs
The SELECTA button (`#labSelectaBtn`, a record icon) sits on the Music header after AUTO MIX (V1.5.08a) and opens the SELECTA drawer (`selPan`, `.cr-selpan`) in the drawer window, one at a time with EQ, FX and Settings; it lights while open. Since V1.5.17a (BLOG0369) the drawer is a knob panel, no heading or list (the V1.4.25a picker rows, `.cr-selrow` / `.cr-selmore`, are gone): each knob sets the selected SELECTA's parameter for the session through `setp`, from the next mix (a mix already running keeps its values); the zone redraws at once.

| Knob (label) | Full name (message bar) | Parameter | Steps |
|---|---|---|---|
| POINT | MIX POINT | 1.4 | last · 2nd to last · 3rd to last |
| LENGTH | MIX LENGTH | 1.3 | 4 · 8 · 16 · 32 bars (2, 4, 8, 16 bars each side of the section line; shorter where a section is shorter) |
| TEMPO | TEMPO AFTER MIX | 4.2 | 1 · 4 · 16 bars |
| MODE | MODE | 3.1 | PERFORM's visual mix modes, MIX to COLOR |

TEMPO IN MIX (4.1) was shown inactive ('held') in V1.5.17a and left off the panel in V1.5.19a (the product owner: not built; it stays 0, its ID unchanged; a knob comes back if it is ever built). Labels are short (V1.5.19a: 'TEMPO AFTER MIX' wrapped); the full name and what it does are in the hover help. The minimums give a hot, radio-style mix, the maximums a long house blend.

Each knob is a knob module (`.cr-eqgrid.cr-skgrid` 4 × 96 px, a `.pf-eqcol` per knob; V1.5.19a, BLOG0379): the drawers' 36 px knob (`SVG(col)`, arc and pointer as the FX knob), the name (`.pf-encl`) and the value box (`.pf-fxsel`), cyan, MODE purple (visual). The knob wrapper (`.pf-encw.cr-skc`) is a keyboard stop: drag up / down (or a finger, 24 px a step), click or tap = next (wraps), Shift+click = back, wheel and ↑ → / ↓ ← step, double-click or double-tap = SELECTA ID 1's value; the ring is on the knob. Message 'SELECTA · MIX LENGTH: 16 bars (from the next mix)'.

## 7.11 PLAY: FOLLOW and the visual list
BLOG0367 (V1.5.01d, 07a). PLAY's VISUALS header, left of Code: **FOLLOW · visual PLAY NEXT · visual CONTINUOUS · visual SHUFFLE** (`#vzBox`: `vzFollow`, `vzNext`, `vzCont`, `vzShuf`, icon buttons as the music ones; placed left of `#labCodeBtn` after every layout swap, hidden in CREATE, PLAY only). State `VZ = {follow, cont, shuf, order}`; `vzOwn()` = FOLLOW off on PLAY.
- **FOLLOW on** (at open; a dot and an arrow, lit): the visuals follow the music: each song's paired shader (Music Visual Pair), mixed in an audio AUTO MIX by the SELECTA's Visual Mix (7.10.3). The visual buttons show the music's CONTINUOUS and SHUFFLE, dimmed (`.mir`).
- **A visual button pressed:** FOLLOW off; the visual buttons take the music's states, then the press. The visuals use their own list: the LIBRARY's shaders in its VISUALS order, or their own random order (SHUFFLE). CONTINUOUS off = the visual stays; CONTINUOUS on = at a song change the list's next shader (`__vzSong`, on QUANT), or during an audio AUTO MIX the list's next mixes in (`prep.vzNext`); ▶| = the next shader now (on QUANT while music plays).
- **FOLLOW again:** the visuals follow the song pairs from the next song ('Visuals FOLLOW the song pairs from the next song').
- Messages: 'Visuals on their own list (LIBRARY order)', 'Visual PLAY NEXT: NAME', 'Visual CONTINUOUS on / off', 'Visual SHUFFLE on / off', each prefixed 'Visuals on their own list · ' when the press turned FOLLOW off. `window.__vz = {list, next, txt, change, state}` (tests).
- Named FOLLOW in V1.5.07a (LINK in V1.5.01d): it couples nothing; it follows the pairs or not. PERFORM's mixer LINK keeps its name (8.5).

---
# 8. Node: PERFORM

Two decks and a mixer, for playing visuals live to music. Shown off-site only (7.1). Every control on it is live: the sixteen visual mix modes (8.13), the EQ and RGB (8.12) and the FX (8.8).

## 8.1 Two decks on one clock
PERFORM makes its own two decks, `DA` and `DB` (`makeDeck('A',AMU)`, `makeDeck('B',AMU)`, `perf=true`), pushed onto `DECKS` after PLAY's `DK`. Both start on the embedded track and the default shader. Since V1.0.30i (BLOG0219 CREATE and PERFORM: separate play controls) PLAY and PERFORM share no deck: a load, PLAY, CUE, shader, Code Apply or FX on one surface never touches the other. Before, Deck A was `DK`, PLAY's deck, and PLAY on Deck A played PLAY too. The tempo, the master clock, QUANT and the master bus stay one for the app: three channels, one global part (2.1.1). Both decks follow `MASTER`, the tempo master (3.3) and QUANT (8.3).

**One surface plays.** `switchPanel()` calls `window.__surf()`: a switch between PLAY and PERFORM pauses the decks of the surface left, drops their pending QUANT actions and master PLAY's memory, so only one surface plays. MASTER, QUANT waits and the LIBRARY's on-deck marks use the open surface's decks (`surfDecks()`, `othersPlaying(d)`); on PLAY its deck is master, back on PERFORM, PERFORM's last master (3.3).

## 8.2 The deck view
`deckView(d,root)` places the shared deck controls (4) in a deck's column. It owns nothing of its own. Top to bottom:
1. **Header:** DECK A / B · lock · MASTER · `</> Code` (right-aligned; KEY LOCK removed in V1.3.04a, 3.4; Settings moved to the mixer strip's gear in V1.4.09a, 8.7). MASTER (`.pf-master`) is in the standard toggle style, lit while the deck is the tempo master; since V1.0.30a it is also a button: a click (pointer cursor) makes the deck master by hand (3.3). `</> Code` opens the deck's Code view over its stage (6.1); Settings, shown while the deck's shader declares settings, opens its Settings drawer (7.8). The header's controls are mouse only: Tab, W A S D and the arrows pass them by (V1.0.30c, 8.14).
   **DECK LOCK** (V1.2.31a, BLOG0275): a lock icon (`.pf-lock`, the Shaka's button style) right of the deck title, open shackle off, closed on (`d.lock`, off on open, kept until clicked again; message 'Deck A LOCK on: no track loads while it plays (click = on / off)'). On, while the deck plays, every song route refuses a song, AMU or cover: the LIBRARY (double-click, row drag, arrow keys), the Twister push and the deck's song pickers ('Deck A is LOCKED while it plays: unlock it (lock icon) to load a song (shaders load any time)'). Off, a playing deck stops and the song loads at 1.1.1, stopped (5.1). Shaders load any time, locked or not (V1.4.05a to 07a, BLOG0336).
2. **Stage:** the deck's shader, 16:9, in the standard line.
3. **Music row, 40 px:** cover 40 × 40 and the waveform beside it; the song info line opens over the waveform.
4. **Row:** PLAY | CUE | LOOP | Music Visual Pair | zoom | orientation | position ........ SOLO.
5. **Music Understanding:** the lane chips and bus bars (mini player, 4.2) and the roll, which takes the remaining height.

No REC or Pop Out on a PERFORM deck: it is for performing, not authoring (OUT has its own Pop Out in the MIXER header, 8.5). Code and Settings are there so a deck's shader can be read, tuned and exported where it plays. The stage shows the deck's picture after its visual FX and its RGB (8.8, 8.12).

## 8.3 QUANT
One master value in music time, in the PERFORM global strip: **None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars** (`QUANT_STEPS`); default 1/4 (`QUANT_DEF`). Triplets and the steps below 1/4 were removed in V0.8.13a: they have no use for starting and cueing a track, and triplet timing in a visual is the shader's job.

The step size is the master's; each deck lands its own AMU point on that step. That alignment is the sync: there is no separate DJ-style SYNC button. The QUANT field is on both tabs' global strips (7.3).
- **PLAY on a stopped deck** (`deckPlayPress`) waits for the master's next step when the other deck on its surface is playing (`othersPlaying(d)`); the deck starts from its own nearest step line on its AMU grid (bar 1 = its first AMU bar). PLAY blinks (`armed`) while it waits; a second press cancels.
- **A cue on a playing deck** (`deckCue`: roll blocks, waveform clicks, CUE) waits for the master's next point at the cue's place within the step, whenever QUANT is not None (V0.9.04a), one deck or two. A cue on a paused deck is at once.
- **A track loaded onto a playing deck** stops the deck and loads stopped at 1.1.1 (5.1, V1.2.33a); no QUANT wait. The song switch on QUANT is no longer used.
- **A shader load** (`loadDeckShader`, 6.2) waits for the master's next step while any deck plays (`d.shPend`).
- **FX kills and restores** wait for the next step while any deck plays (`fxLater`, 8.8). EQ, RGB and mixer kills are at once (8.5, 8.12).
- **Forward only** (OMS canon). None = at once.
- A deck playing alone leads the master grid: `quantTick()` sets the master's phase to the deck's position in an 8-bar cycle from its bar 1 (`QCYCLE` = 32 beats), so every step size lines up with its phrases.

## 8.4 Master position
**Master PLAY** (`#pfMasterPlay`, `window.__masterPlay()`, V0.9.13a), in the PERFORM strip between QUANT and the position, as Ableton's Space, on PERFORM's decks (`PD`): with any deck playing it pauses every playing deck at once and remembers them and the master grid's beat (`__mpHeld`); pressed again it resumes the remembered decks at once from where they stopped and puts the grid back, so QUANT stays on the beat. With nothing remembered it starts every deck from its playhead. No QUANT wait, no snapping. Space on PERFORM calls it; a deck's own PLAY clears the memory. Its label is PLAY or PAUSE by whether any deck plays.

The PERFORM global strip's position box (`#pfMasterPos`) is the session on the master clock, not a deck position, in bars.beats.sixteenths. It starts at 1.1.1 and counts at the master tempo while any deck plays, from the first PLAY. When every deck stops it holds, and carries on when a deck plays again. Double-click = back to 1.1.1. The count is kept in `window.__mpB` (beats) and advanced in `chrome()` from `performance.now()`. The deck positions stay on the decks.

## 8.5 Mixer, OUT, encoders and LINK
- **OUT** (`#pfOut`): the two deck pictures (after their visual FX and RGB) combined at their VISUAL strengths in the visual mix mode picked in the MODE drawer (`OUT_MODE`, 8.13); MIX, the weighted blend, on open.
- **Encoders** (`.pf-encs`), in a row: A VISUAL, A MUSIC, B MUSIC, B VISUAL (named VISUAL and MUSIC in the app, messages, help and the Twister map since V1.3.12a, BLOG0301; VID and AUD before: Vizzie has no video). VISUAL = the deck's strength in OUT (`d.outGain`); MUSIC = the deck's volume (`d.audGain`). They are 36 px knobs alone: no outline, no label and no value under them (V0.11.21e; the outlined modules and value boxes of V0.11.19a were tried and removed in V0.11.21b to 21e to give the drawer below its room). The encoder's place and colour say which it is: VISUAL Purple People Eater `#B24DFF` outside, MUSIC cyan `#00d4ff` inside; deck A left, deck B right. The level shows in the message bar on hover, drag and Shift+arrows: VISUAL in %, MUSIC in dB.
- **MUSIC in dB, audio taper:** the deck gain is the knob position squared (gain = p²), so the turn spreads evenly by ear: full left −∞ dB (silence), 9 o'clock −24 dB, 12 o'clock −12 dB, full right 0 dB. MUSIC tops out at 0 dB; the output level after the mix is MASTER's (3.5).
- **Behaviour** (the drawers' rule, BLOG0186 Mixer encoders: values, dB, kill rule, compact): drag up / down = level (full range over 150 px); Shift+↑ / ↓ ±0.01, Shift+← / → ±0.05 of the turn (8.14); click = select (the ring in the encoder's domain colour), no change; Enter = kill / restore the selected encoder (MUSIC: silence; VISUAL: the deck out of OUT), killed dims and the level is kept (`d.mixK` `{audGain, outGain}`); double-click = the default, 0, and restored (VISUAL 0 %, MUSIC silence, as on open). VISUAL and MUSIC open at 0 (V1.0.15a, BLOG0195 Mixer: VISUAL starts at 0): OUT is black and the speakers silent on open.
- **LINK** (V1.0.29a, BLOG0178 Mixer: LINK per deck; on by default since V1.0.30g, BLOG0217; the glide V1.2.11a, BLOG0256): a horizontal chain icon (`.pf-link`) between each deck's two encoders, A VISUAL and A MUSIC, B MUSIC and B VISUAL. Click, or Enter with it selected, links or unlinks; white = linked, grey = off. State `d.link` `{on, caught}`. Linked, MUSIC leads and VISUAL follows MUSIC exactly. Turning LINK on with VISUAL away from MUSIC glides VISUAL to MUSIC on the next QUANT step (at once when nothing plays or QUANT is None), over one beat; MUSIC never moves, so the volume never jumps ('Deck A LINK on · VISUAL glides to MUSIC n% on the next 1/4, over one beat'). Before V1.2.11a VISUAL waited until MUSIC was swept past it (pick-up). Moving VISUAL unlinks, so the visual can go its own way mid mix ('LINK off (VISUAL moved)'). Both decks open linked with MUSIC and VISUAL at 0. Each encoder keeps its own kill. Session only.
- **Meters** (V1.2.20a, BLOG0264): two thin vertical meters (`.pf-meters`, 6 px each, 4 px apart) centred between the two MUSIC encoders, Deck A left, Deck B right, no labels. Each reads its deck after MUSIC and its kill (an AnalyserNode on `d.audio.gain`): mono peak, −48 dB to 0 dB, green (Green Slime), yellow above −6 dB, red at 0 dB (Red Hots `#FF006E`, the design system's one red, since V1.3.11a, BLOG0282; `#FF2D2D` before); fast up, slow fall. A stopped deck, MUSIC at 0 or a killed MUSIC reads empty. Screen only: Vizzie has no headphones or cue, so the meters show a deck is sending audio.
- **Pop Out** (V1.3.01c to 01h, BLOG0284): an 18 px square at the MIXER header's far right, marked only by its top-right corner, opens OUT (the mix) in its own window, as PLAY's (6.3); double-click it for fullscreen. The window carries OUT's SHOUT OUT strip and the tagline (7.9).
- **ISOLATOR** (V1.0.20a; the bus is 3.5; in its own drawer since V1.3.02a, BLOG0291, 8.7): LOW · MID · HIGH in one outlined box, the drawers' 36 px knobs; until V1.3.02a they sat at the MIXER header's right end (`.pf-iso`), each its name then a 20 px knob. Full kill (left), 0 dB (centre), +6 dB (right); the drawers' knob behaviour: drag, Shift+arrows, click = select, Enter = kill / restore (true silence), double-click = 0 dB. Cyan (audio).

## 8.6 Layout fit
PERFORM is three columns side by side, DECK A | MIXER column | DECK B (`.pf`, grid `1fr / 0.563fr / 1fr`, gap 24 px), under the global strip. The MIXER column reaches 12 px into each gap (`.pf-col.pf-mix` margin `0 -12px`), so the gaps either side are 12 px and the decks keep their width (V0.11.18a). PERFORM sits 9 px from the app's frame at each side (`#panelPerform.active` margin `0 -9px`; the other tabs keep the page's 18 px; V0.11.18b) (BLOG0185 PERFORM spacing: centre column and outer gaps). Each deck is a module in the standard line (12.6). The MIXER column has no line of its own: it holds three modules of the same width, each in the standard line, 6 px apart: the MIXER (`.pf-mixmod`: header with the isolator, OUT, encoders and LINK), the panel strip (`.pf-pwrap`, 8.7) and the LIBRARY (`.pf-libmod`, 8.9), which takes the remaining height. The page fits the window without scrolling. Per deck, `fit(v)` sizes the stage 16:9 from the column width, smaller on short windows, after reserving the fixed rows, the gaps, the lanes and 40 px of roll, so the Music Understanding panel always keeps room for chips and roll.

## 8.7 Panel strip: ISO · EQ · FX · MODE · gear (PERFORM)
`.pf-panelrow`: since V1.4.09a (BLOG0341) five equal buttons, **ISO · EQ · FX · MODE · gear**: ISO (the isolator's three bands crossing at the two crossovers) and the gear are icons drawn to one standard (the DECK LOCK's: 1.5 stroke, the button's own colour, 12 px tall); ISO carries the audio (cyan) dots, both lit when the master isolator is off default; the gear the visual (purple) dots, left Deck A and right Deck B. The gear opens the decks' Settings over the LIBRARY (7.8; Twister A4 / D4 as before, the drawer scrolling to the cursor; Shift+click resets as EQ and FX). **ISO drawer** (V1.4.11a, 11b, BLOG0343): LOW · MID · HIGH at 72 px (the drawers' knobs are 36 px), the three bands' curves drawn behind them in the knob track's colour, and ISOLATOR centred over the curves in the section headers' type. Before V1.4.09a: four equal buttons in the toggle style (`.btn.loop.pf-fxbtn`, 22 px high, 10px with 1px letter spacing), **ISOLATOR · EQ · FX · MODE** (ISOLATOR added in V1.3.02a, BLOG0291; it opens the master isolator's drawer the same way; in a narrow window the four tighten their lettering), left to right by priority (V0.11.14b, BLOG0182 Panel strip order: EQ · FX · MODE; was MODE · FX · EQ). Each opens a **drawer** (`.pf-fxslide`, V0.9.22d to 22g) that slides out of the strip's bottom edge, `transform: translateY(-100%)` → 0 in 0.26 s, inside a clipping window (`.pf-fxpanel`, `overflow:hidden`). The window is the strip's width, tucked 6 px under it, and reaches the bottom of the LIBRARY module (`fxPlace()`, re-run on resize); it covers the whole LIBRARY, which is left as it is underneath, so its height follows the window. One panel at a time (`fxShow`, `fxOpen` = 'iso' | 'eq' | 'fx' | 'mode' | null); the open button is lit; clicking it again slides the drawer back up. EQ holds the deck EQs and RGB (8.12), FX the deck effects (8.8), MODE the visual mix modes (8.13). The drawer comes right after the strip in the page order, so Tab goes strip, drawer, LIBRARY (8.14).

**Changed dots** (V1.1.06a, BLOG0232 EQ and FX buttons show which columns are off their defaults): EQ and FX carry four dots each (`.pf-dots`), two left and two right, in the drawer's column order: A visual (purple), A audio (cyan) | B audio (cyan), B visual (purple). A dot is dim (22 %) while every control in its column is at its default, and glows steadily otherwise; no blinking. EQ: a band, TRIM or colour channel off 0 dB / ×1.00, or killed. FX: an effect's amount off its neutral and not killed (picking another effect alone does not light it). `window.__pfDots()` checks every frame. MODE has none.

**Shift+click reset** (V1.1.06b, BLOG0234 Shift+click on EQ / FX resets to defaults): Shift+click on EQ or FX resets by where it lands: the left third Deck A, the centre both decks, the right third Deck B, audio and visual alike. EQ: every band and audio TRIM to 0 dB, every colour channel and visual TRIM to ×1.00, kills cleared. FX: every amount to its neutral, kills cleared, a pending QUANT kill dropped; the picked effects stay. The drawer stays as it is. Shift+Enter on the selected button resets both decks. With Shift held over the button the bar names what a click resets; after it, "EQ reset: Deck A to default".

**Drawer layout** (EQ and FX, V0.11.14a to 14e): four columns, as the mixer above (`.pf-eqgrid`, each column a `.pf-eqcol` module: 1px `#2a2a2a`, radius 6px, `#0a0a0a`), visual outside, audio inside: deck A's two on the left, deck B's on the right. No DECK A / DECK B header and no deck letter on the labels (V0.11.15b): the column's place names the deck; the message bar names it in full. The columns sit 9 px from the strip, the sides and (EQ) the drawer's bottom (`.pf-eqpan` padding 15px 8px 8px: the drawer starts 6 px under the strip), 6 px apart, 8 px inside each column.

## 8.8 FX
One FX engine for PERFORM and PLAY (V0.10.01a): `fxInit(d)` gives a deck `d.fx = {a:[2 slots], v:[2 slots]}`, slot `{name, amt, killed, node}`; session only. PERFORM's two decks and PLAY's deck each have their own slots (7.6; V1.0.30i). PERFORM's FX drawer (V0.11.14e, BLOG0135 PERFORM FX panel) is four outlined columns, as the EQ drawer (8.7): A VFX · A AFX | B AFX · B VFX (`.pf-eqgrid.pf-fxcols`), slot 1 above slot 2 in each; the columns keep their height (two rows) and the space is below them; 4 px inside at the sides (`.pf-fxcols .pf-eqcol` padding 8px 4px) so the effect names fit. Each cell (`fxCell`) is a knob (`.pf-enc.pf-fxk`, labelled AFX1, AFX2, VFX1, VFX2) and an effect box under it (`.pf-fxsel`, spanning its column at 9px; a name too long ends in "…", the message bar shows it in full: click, then the arrows step the bank; a new effect starts at its neutral value). AFX cells are cyan `#00d4ff`, VFX Purple People Eater `#B24DFF`.

**The knob** (the one kill rule, V0.11.15a, the same on PLAY's FX drawer): drag = amount; Shift+↑ / ↓ ±0.01, Shift+← / → ±0.05; click = select (the ring in the knob's domain colour), it no longer kills; Enter = kill / restore on QUANT (`fxLater`; the ring shows while it waits, purple on a VFX knob, cyan on AFX); a killed knob dims and keeps its amount; double-click (a second click within 300 ms) = reset to the effect's default, unmuted, dropping a kill already armed (`s.gen`); Tab / Shift+Tab = the next / previous control.

**Music FX** (`AFX`), where `FX_LIVE` says the deck's rack plays (PERFORM's decks; PLAY's deck on PLAY). `fxWire(d)` rewires when the slots, the EQ's place or that answer change: live = `pre` → AFX1 → AFX2 → gain (killed slots bypassed), with the deck's TRIM and EQ before AFX1 on PERFORM (8.12); otherwise `pre` → gain. Each effect is a `mixer()` (dry / wet). Filter (bipolar, neutral at 0.5: left low-pass 20 kHz → 150 Hz, right high-pass 20 Hz → 6 kHz, Q 1.1), Washout (high-pass 20 Hz → 2 kHz), Dubby (band-passed feedback echo, dotted 1/8), Delay (the QUANT division, None = 1/4), Reverb (2.8 s noise impulse), Flanger and Phaser (LFO = 1 / (4 × QUANT division)), Bitcrush (16 → 3 bits, curve of 65 536 points). Defaults AFX1 Filter, AFX2 Dubby. Tempo-timed effects follow TEMPO and QUANT every frame (`tick`).

**Visual FX** (`VFX`, V0.9.22h; one shared chain `vfxRun` since V0.10.02a). One WGSL post pass, `PERF_VFX`, with a uniform of kind, amount, deck beat, beat phase, size, QUANT division, time, Feedback decay, QUANT step, beat kick and bar phase. `makeDeckGpu` (PERFORM) and PLAY's renderer render the shader into a texture, then `vfxRun` runs each live slot (`vfxLive(d)`: not killed, not at its neutral value) as a pass ping-ponging two textures (`fxA` / `fxB`, in the chain's state `vfxState`), Feedback reading `prev` (a copy of the last final picture). On PERFORM the deck's RGB pass follows (8.12) and its result is the deck's stage view and what OUT mixes; on PLAY the final picture is the stage. Bank: RGB Split, Feedback, Glitch, Pixelate, Scanlines, Mirror, Kaleidoscope, VHS, Shake (Dojo's nine), Tone (bipolar: left darker / softer, right brighter / sharper), Tile (1 to 8), Rotate (at tempo; a mirrored repeat at the edges), Zoom (pulses on the beat). Defaults VFX1 RGB Split, VFX2 Feedback.

**Switching a VFX** (V1.4.10a, BLOG0342): the amount stays; while music plays with QUANT on, the new effect comes in on the next QUANT step (the knob armed, the box showing the effect coming, the last switch winning); otherwise at once; a killed effect stays killed. AFX unchanged: the amount goes to the new effect's neutral, at once.

**Kills on QUANT:** `fxLater(run,armed)` queues the kill or restore in `FXQ` for the master's next step (`nextMaster`) while any deck plays, else at once; `fxTick()` fires due entries every frame (called from `chrome()` through `window.__fxTick`).

## 8.9 LIBRARY
One LIBRARY (`LIB`, shared since V0.10.03a) shown in any number of views (`libView(box,o)`, `LIB.views`): PERFORM's MIXER column and PLAY's LIBRARY module (7.6). Every view has the same header and list, and a change in one redraws all. Files and folders, subfolders included, reach it through the app's one drop zone (`appDrop`, `readDrop()`, 4.5). `libImport()` sorts by type and reports one message:
- **Tracks:** each audio file paired with its AMU `.json` by the JSON's `file` field, or its name minus `_sozo_v2_AMU`; audio without its JSON and a JSON without its audio are left out and counted. The JSON is attached data, never an entry. A square image with the track's name is its cover (`entry.cover`).
- **Shaders:** grouped by name stem without `_V##`, the highest `_V##` kept; names without a version fall back to the newest file date. Each kept shader's `@title @author @type @desc` lines are read on import (`shMeta`, 13.2).
- **Sets:** each `.m3u8` becomes a set (8.10).
- **Zips:** opened and taken through the same intake (4.5, V1.4.08a).
- A re-drop of the same name replaces its entry.

**The header** (`.pf-libfrow`), one line: **ALL · MUSIC · VISUALS · SETS ........ save · X** (V1.0.16a; save, the OMS set, V1.3.06a, 8.10; VISUALS was SHADERS, and QUEUE and the playlist buttons are gone, 8.10). ALL clears an applied set; MUSIC and VISUALS keep it; SETS is greyed with no sets. **X** (`.pf-libclr`, the controls row's icon-button style, at the far right; `libClear`, V1.0.02a, 05a, 08a) empties the LIBRARY: tracks and their covers, shaders, the tracks without AMU and every set; the filter returns to ALL; the decks keep what they have ('Library cleared · the decks keep what they have').

**The list** (`.pf-lib`) has a sticky sort header (`.pf-libhd`, V1.0.24a, BLOG0206) that covers the list's top edge: **TITLE · ARTIST · BPM · KEY**, and on VISUALS **TITLE · AUTHOR · VER · TYPE** (V1.0.26a, BLOG0208). Click a heading to sort by it (`LIB.sort`, `libCmp`), again to reverse; the default is TITLE, A to Z, alphanumeric (`ALNUM`: 2 before 10, case ignored). A row without the sorted value goes last; VER sorts by number. BPM and KEY come from the track's AMU (`keyShort`: the key the song spends longest in, short: Em, F#m, C). On ALL a shader shows its title and author beside the tracks. An applied set and PLAY's SHUFFLE keep their own order, and the header shows no arrow (`.fixed`). Entry = title, artist (a track) or author (a shader), BPM · KEY or VER · TYPE, and a dot (audio cyan, shader Purple People Eater). A row's hint in the message bar: title · artist (a track), title · author — description (a shader), then its keys.

**Keys and pointer:** click = select (cyan border) and keyboard focus on the list, with no outline or glow on the list itself (V1.4.14a, BLOG0337; the rows' own highlights unchanged); ↑ / ↓ or W / S move the selection and show the row's hint in the message bar, as a click (V1.0.24b); A / ← loads it on Deck A, D / → on Deck B (`__libLoad`; PLAY: either loads its deck); Delete or Backspace removes it (a deck keeps what it has). W (or ↑) on the first row goes up to the header's lit filter; on the header A / D (or ← / →) move along the buttons and S (or ↓) goes down into the list; S on the last row stays (`libNav`, one code for every view, V1.0.25a, BLOG0207). Drag an entry onto a deck = load it (track: its AMU, audio and cover; shader: the `.wgsl`). A track loaded onto a playing deck stops it and loads stopped at 1.1.1 (5.1), unless DECK LOCK refuses it (8.2); a shader load waits for QUANT (6.2). An entry on a deck of the open surface is tinted Yellow Man (Dojo 'loaded'; `onDeck`, `surfDecks()`); `window.__libTick` redraws the views when a deck's track or shader changes. The LIBRARY is session only: Vizzie saves nothing (13).

## 8.10 SETS (playlists)
An `.m3u8` in a drop (4.5), before or after the music, becomes a set (V1.0.03a to 19a, BLOG0193 LIBRARY: playlists in the header): its non-`#` lines in order (`file://` URLs decoded), named by its `#PLAYLIST:` line, else its file name with underscores as spaces. `LIB.lists` holds the sets `{name, paths}` in alphabetical order (`plSort`: case-blind, 2 before 10); a set with the same name replaces it. Its paths are tail-matched against each library file's path inside the drop (`f._rel`), with a file-name fallback (`queueResolve(list)`); a library drop re-matches.

**SETS** is a filter like the others (V1.0.16a): it lights and shows the sets as LIBRARY rows (`.pf-plrow`): the set's name, its tracks in the library of its total in grey (e.g. 12/14), and a cyan name and dot on the applied set. Double-click (double tap) or Enter on a set applies it (`setApply`, `LIB.set`; on PLAY it also plays it, 7.6, V1.4.01a): the list goes to MUSIC with that set's tracks in its order, and MUSIC and SETS are lit. The same on the applied set turns it off (the list stays on SETS); on another set, it switches. A set stays applied through MUSIC and VISUALS (VISUALS shows the shaders, SETS stays lit) and through loading a track or shader; ALL clears it, and so does a drop with nothing playing (4.5). ← → and Delete do nothing on a set row. SETS' hint names the set applied: 'Library: Set NAME · N sets · click to show'.

A drop applies no set; an applied set stays applied after another drop. The drop's message names the sets it added (V1.0.19a): 'Library: set Night Set added · 2 of 2 found', or 'Library: 2 sets added · Afternoon 1/1 · Day 1/2' (alphabetical, found / total), after the usual summary when tracks or shaders came too. An `.m3u8` typed `audio/x-mpegurl` (macOS) is not taken as audio (`isAudio`, V0.9.23b). QUEUE (V0.9.23a) and the PLAYLIST drop-down and drawer (V1.0.05a, 06a) are removed: SETS does their job.

**Sorting a set** (V1.3.13a, BLOG0223): with a set applied, TITLE, ARTIST, BPM and KEY sort its tracks (again = reverse); a cyan dot at the right end of the headings, shown while the set is sorted, puts the playlist order back, as picking the set again does.

**Folder drop** (V1.3.10a, BLOG0299): a dropped folder holding tracks (audio with its AMU) and no `.m3u8` or `.omsset` becomes a set named after the folder, its tracks A to Z by file name (subfolders included; audio without an AMU left out and counted). Several folders: one set each.

**Music Visual Pairs** (V1.3.05a, BLOG0294, 0295). A button in each deck's controls row, right of LOOP (`MVPAIR`, icon only: cyan speaker, link, purple camera; lit when the deck's song and shader are paired). Click pairs the deck's song with its shader (one shader per song; a shader may pair with any number of songs); click the lit button unpairs; a new shader over a paired song dims it until clicked. Loading a paired song from the LIBRARY (row, drag, arrow keys, Twister) onto any deck also loads its shader, at once or on the next QUANT step as any shader load. Pairs are shared by PLAY and PERFORM and last for the session.

**OMS sets** (V1.3.06a, BLOG0296). The LIBRARY header's save button (down arrow onto a line, left of CLEAR) writes an `.omsset` to Downloads (`omsWrite`): the applied set, named after its `.m3u8`, or with none applied the paired songs, named in a box (default `OMS_Vizzie_Set_<date>`). JSON: `{"oms": 1, "type": "set", "app", "version", "saved", "vizzie": {"set": {"name", "tracks": [{"file", "length", "label"}]}, "pairs": [{"song", "shader"}]}}`, file names only. Dropping an `.omsset` (alone or with the library) adds the set as an `.m3u8` would and adds its pairs to the session's (the file wins for a song it names; a pair whose shader is not in the LIBRARY is skipped and counted). An `.m3u8` keeps each `#EXTINF` so the set can carry it. This is the one file Vizzie writes for the LIBRARY.

## 8.11 Demo playlists (the website set) and Yodega
On http / https, `libWebSet(base)` reads `./examples/library.json` on open (and, since V1.3.38a, `./yodega/library.json`, 8.11.1): `{"files":[file names in ./examples/], "playlists":[{"name","file"}]}` (V0.10.04a). Audio files and AMU `.json` files are listed as stand-ins: an audio entry keeps its URL (`_url`) and is fetched when its track is loaded; an AMU entry (`_lazy`, its `text()` fetches) pairs with its MP3 by name and is fetched when its track loads (V0.10.07g), so opening the page fetches no music or analysis. Other files are fetched on open. They are imported quietly (no message). Each playlist becomes a set (`LIB.lists`, 8.10), in alphabetical order. Its tracks' names come from their MP3 tags, read from each file's first 64 KB (5.2), like every other track; its `#EXTINF` lines no longer rename them (V1.0.24a), and it keeps its order. Tracks match by path, then file name. The LIBRARY opens with the first set applied (MUSIC). Loading a website track fetches its MP3 and AMU, with the message 'Loading NAME …'. `.wgsl` and `.omsset` entries are fetched on open and imported as a drop would (shaders into VISUALS, OMS sets as sets with their pairs).

### 8.11.1 Yodega
V1.3.38a (BLOG0326, 0327). Yodega is the product owner's own music and shaders, paired into sets, published to the site's `./yodega/` folder by a Yodega push: content only, never an app build. The same loader runs for both folders (`['./examples/','./yodega/']`); `./yodega/library.json` lists every drop's files with the drop's subfolder in the path (`YoBombs/song.mp3`), each part URL-encoded (`webUrl`). A drop holds its MP3s with their AMU sidecars, its shaders and its `.omsset` (tracks plus Music Visual Pairs), so on the site it shows in LIBRARY as if the folder had been dropped in: the set, its pairs, and CONTINUOUS PLAY through it. `./examples/` is unchanged. A drop and `library.json` are made by a script outside the app (BLOG0328); the push flow is BLOG0329. Opening the HTML as a local file reads neither folder.

**YoPacks** (BLOG0347, drop script v4 to v6, outside the app): the Yodega folder mirrors the site's `yodega/`: `library.json` and `YoPacks/<Pack>/`, every pack rebuilt each run, each pack page (`index.html`) forwarding to the app's set link with the set's title and description (7.6). Since 2026-11-21 (BLOG0361) `./examples/` holds ANT only, with an empty `library.json`; the LIBRARY shows the Yodega packs, and ANT with its default shader is the only default.

## 8.12 EQ and RGB
The EQ drawer (BLOG0137 EQ per deck (3-band) and RGB; TRIM since V1.0.18a): four outlined columns (8.7), four rows, visual outside under the VISUAL encoders, audio inside under the MUSIC encoders:

| Row | A RGB | A EQ | B EQ | B RGB |
|---|---|---|---|---|
| 1 | TRIM | TRIM | TRIM | TRIM |
| 2 | BLUE | HIGH | HIGH | BLUE |
| 3 | GREEN | MID | MID | GREEN |
| 4 | RED | LOW | LOW | RED |

Red sits with LOW, green with MID, blue with HIGH (the DVS waveform colours). Each cell (`eqCell(d,i,vis)`; `i` 3 = TRIM) is a 36 px knob, its name and its value box (`.pf-eqval`), spanning its column. The rows spread evenly over the column's height and close up to 6 px in a short window. PERFORM only; levels are kept for the session.

**TRIM** (V1.0.18a, BLOG0196 Mixer: TRIM at the top of the EQ drawer, after the Ecler mixer): index 3 of `d.eq` and `d.rgb`. Audio TRIM is the deck's input gain before the EQ (`R.trim`, a gain node): −15 dB (left), 0 dB (centre, the default), +15 dB (right); killed = −15 dB, its left end. Visual TRIM is one gain on the whole picture, R, G and B together, before the RGB knobs, on RGB's scale: off (left), ×1.00 (centre, the default), ×1.33 (right); killed = off. Each TRIM plays where the EQ plays (PERFORM). Messages: 'Deck A audio TRIM …', 'Deck A visual TRIM …'.

**EQ, audio** (V0.11.13a). `d.eq` = `[low, mid, high, trim]` in dB, per deck (`fxInit`). Three biquad filters (`createBiquadFilter`): LOW `lowshelf` 70 Hz, MID `peaking` 1 kHz Q 0.7, HIGH `highshelf` 13 kHz, the DJ channel EQ (as Pioneer's DJM). Each band runs from −26 dB (left) through 0 dB (centre) to +6 dB (right); near the centre it snaps to 0 dB. `eqApply(d)` sets the gains. The chain is `pre` → TRIM → LOW → MID → HIGH → the FX rack → gain (the MUSIC encoder). It plays on PERFORM only: `fxWire` routes through it when `window.__eqOn(d)` says so; on PLAY its deck plays without it (PLAY has no EQ control). Cyan knobs, the value in dB ("+6.0 dB", "0 dB"). A shelf at −26 dB cuts the sub and most of the kick, not all of it; a full kill is the isolator's job (3.5, 8.5).

**RGB, visual** (V0.11.14a, Dojo's visual EQ). `d.rgb` = `[r, g, b, trim]` gains on the deck's picture, each channel times the visual TRIM: left = channel off (×0.00), centre = ×1.00, right = ×1.33 (Dojo's top). It runs as one more `PERF_VFX` pass, kind 14, after the deck's visual FX and before OUT (`vfxRun(…, rgb)`, PERFORM decks only), so the deck stage and OUT both show it. The pass is drawn only when a channel is off ×1.00, so a deck at ×1.00 costs nothing. Feedback keeps its trail from the picture before RGB, so a channel change does not build up in the trail. Purple knobs, the value as a gain ("×1.00").

**The knob** (the one kill rule, V0.11.15a): drag = level; Shift+↑ / ↓ fine, Shift+← / → coarse; click = select; Enter = kill / restore, at once (EQ: the band at −26 dB, `d.eqK`; RGB: the channel at 0, `d.rgbK`; TRIM: its left end); killed dims and the level is kept; double-click = 0 dB / ×1.00, restored. Message: "Deck B RGB BLUE ×1.00", "Deck A EQ HIGH +6.0 dB".

## 8.13 MODE: visual mix modes (OUT)
The MODE drawer (BLOG0184 Video mix modes (OUT)): sixteen buttons (`.pf-modes` > `.pf-mode`), four rows of four, each with a short label; the message bar gives the full name and what it does. Click or Enter picks a mode; it changes at once; the mode in use is purple (visual domain). `OUT_MODE` (session) goes to `PERF_MIX` as `m.mode`. With `a` = deck A × VISUAL A, `b` = deck B × VISUAL B, `A` / `B` the decks' pictures, `ga` / `gb` the VIDs:

| # | Label | Mode | OUT |
|---:|---|---|---|
| 0 | MIX | MIX | the crossfade, `(a + b) / max(1, ga + gb)` |
| 1 | NAM | NAM | non-additive mix: the brighter pixel, `max(a, b)` |
| 2 | ADD | ADD | `min(a + b, 1)` |
| 3 | SCRN | SCREEN | `1 − (1 − a)(1 − b)` |
| 4 | MULT | MULTIPLY | `mix(a, a × B, gb)`: B only where A is bright |
| 5 | OVER | OVERLAY | overlay of B on a, mixed by `gb` |
| 6 | DIFF | DIFFERENCE | `abs(a − b)` |
| 7 | LUMA | LUMA | `b × mix(1, l, ga)`, `l` = A's luma: A is the matte |
| 8 | DARK | DARKEN | `min(a, b)` (a deck at 0: the other alone) |
| 9 | SOFT | SOFT LIGHT | a gentle OVERLAY, B tints a, mixed by `gb` |
| 10 | EXCL | EXCLUSION | `a + b − 2ab` |
| 11 | INVL | INV LUMA | `b × mix(1, 1 − l, ga)` |
| 12 | SUB | SUBTRACT | `max(a − b, 0)` |
| 13 | DODGE | DODGE | `a / (1 − B × gb)` |
| 14 | BURN | BURN | `1 − (1 − a) / mix(1, B, gb)` |
| 15 | COLOR | COLOR | B's colour at a's luma, mixed by `gb` |

In the modes with a base (MULTIPLY, OVERLAY, SOFT LIGHT, DODGE, BURN, COLOR) deck A is the base at VISUAL A and VISUAL B is how much of B goes over it; with VISUAL A at 0, B alone. In LUMA and INV LUMA, VISUAL B is B's strength and VISUAL A how much matte. A VISUAL at 0 takes its deck out in every mode, so there is no CUT: pulling a VISUAL to 0 is the cut (dropped in V0.11.17a). MIX and ADD look the same while the two VIDs add up to 100 % or less.

The mode buttons are styled as the strip buttons (22 px, 10px Courier New, 1px letter spacing, radius 3px).

## 8.14 Keyboard: one flow for the whole UI
BLOG0210 Keyboard: W A S D and Tab across the whole UI; Enter on / off; Shift+A / Shift+B / Shift+M on PERFORM (V1.0.28a to 30d). One document-level `keydown` handler (capture phase) serves PLAY, PERFORM and CREATE, on a local file and on the website. Pocket Rave is touch only (`prActive()`). It replaces PERFORM's MIXER column grid (BLOG0187) and PLAY's own LIBRARY handler.
- **The stops** (`kbdItems`, `KBD_SEL`): on the open tab, buttons, selects, links, the TEMPO field and anything with a tab index, plus the tab bar; lane chips, bus bars and lane knobs are stops. Not a stop: `tabindex="-1"`, a control clipped out of view (the buttons of a closed drawer) or under an open drawer or panel (`kbdShown`), and PERFORM's deck-header controls (KEY LOCK, MASTER, Code, Settings), which are mouse only (V1.0.30c; PLAY keeps its headers in the flow).
- **W A S D = arrows** (V1.0.29b): the nearest stop that way. W / S go to the next row close to straight ahead (a wider cone when nothing is), then the nearest in it; A / D move along the same row first. **Tab / Shift+Tab** move in page order over the same stops. With nothing selected, the first press goes to the tab's first control (`kbdFirst`: its top row's leftmost; controls a few px apart in height count as one row).
- **The tab bar:** W (or ↑) into it lands on the open tab; S (or ↓) from it goes to the tab's first control (TEMPO), as Tab does; Enter opens a tab.
- **Enter = on / off:** presses a button, opens a tab, solos a lane chip or bus bar (`_enter`), kills / restores a knob or encoder, opens / closes a drawer from its strip button, applies a set, makes a deck MASTER.
- **Shift+arrows = the selected control's value:** encoders, knobs, the TEMPO, QUANT, zoom and MASTER fields, the effect and preset boxes. The plain arrows only move, so ↓ on TEMPO no longer lowers the tempo. TEMPO: digits type a tempo, Shift+↑ / ↓ ±1 BPM, Shift+← / → ±0.01. Text fields and the Code views keep their keys.
- **The LIBRARY** keeps its rules (`libNav`, 8.9): in the list W / S step the rows and A / D (← / →) load; on the header A / D move along and S goes down into the list. W on the header goes on by the general rule (PERFORM: up into the mixer).
- **Jump keys**, each to a section's first control, from anywhere (also from the TEMPO field), with no exit first: **Shift+L** into the LIBRARY (ALL), on PLAY and PERFORM, website included; with an EQ, FX or MODE drawer over the LIBRARY the bar says to close it first. On PERFORM (`window.__pfKeys`): **Shift+A** / **Shift+B** into Deck A / Deck B (their PLAY), **Shift+M** into the mixer (A VISUAL), with the message "Mixer: W A S D, arrows or Tab move · Shift+arrows = level · Enter = kill / open · Escape = out of a drawer". Plain M is retired. PLAY has no other section keys.
- **Drawers (PERFORM):** Tab from a strip button with a drawer open goes straight to the drawer's first control (EQ: A's visual TRIM; FX: VFX1; MODE: MIX), then steps on through the drawer. W A S D and the arrows stay in the open drawer's grid (`.pf-fxin`): only W from its top row leaves, to the strip (V1.0.31b, BLOG0222). W / S take a stop straight below / above first (overlapping it side to side), the nearest row first, then that row's leftmost: PLAY → the RHYTHM bus bar → beat (V1.0.31c, 31d); with none straight that way, the nearest in a cone as before. **Escape** anywhere in a drawer goes to its lit strip button. The Settings drawers follow the same rule: the keys stay in the open rack (7.8; V1.1.07a, BLOG0236).
- **One focus look:** the app's cyan ring (`box-shadow: 0 0 0 2px #00d4ff`) on every stop picked from the keyboard (`.kbd-nav … :focus-visible`); the visual mix modes keep their purple ring.
- Nothing acts while typing in a field or the Code view (TEMPO excepted, as above), or with Ctrl / Cmd / Alt held.

## 8.15 Hardware: two Midi Fighter Twisters
BLOG0238 Hardware: two Midi Fighter Twisters drive the PERFORM mixer (V1.1.09a to 09k, remapped and finished in V1.2.02a to 33a, signed off on the hardware 2026-11-12). Two DJ TechTools Midi Fighter Twisters, on their factory settings (no configuration tool, no scripting on the unit), play PERFORM, one per deck, by the Hardware Perform Map (blueprint sheet 12). Web MIDI (`navigator.requestMIDIAccess`, no SysEx): Chrome and other browsers that have it. The MIDI layer starts only off the website (`AUTHOR_MODE`, V1.2.01a, BLOG0245): the website has no PERFORM and never asks for MIDI. PLAY ignores the units.

**What the units send and take** (factory settings): a turn sends channel 1, CC 0 to 15 (bank 1, row by row, left to right: 0 = A1, 3 = D1, 12 = A4, 15 = D4), an absolute value 0 to 127; a push sends channel 2, the same CC, 127 pressed and 0 released (knob switches must be CC Hold; a unit on CC Toggle needs two pushes per action). The app sets each ring with a CC on channel 1, which also sets the knob's own value, so the next turn carries on from the app's value. Ring colour is set on channel 2 (cyan 31 on unit A, 34 on unit B; purple 108; blue 1 for the navigation knobs). Side buttons and banks are channel 4: top and bottom buttons CC 8 to 13, the middle ones the unit's Previous / Next Bank.

**Which ports** (V1.4.15a, BLOG0339): before the units are paired, only a port whose name contains 'Twister' can bind as Deck A or Deck B (`MIDI_DEVICE` at the top of the MIDI section holds the name and its rule; binding asks only it). Every other port (Ableton, IAC buses, other controllers) is ignored. **Pairing.** Every Twister input is read, not by name: Chrome sees the port name the unit reports ("Midi Fighter Twister" or "USB MIDI Device"), not a name given in macOS or the Utility, so two units cannot be told apart by name. On PERFORM the first unit whose knob is pushed binds to Deck A (MFA, the LEFT unit), the next to Deck B (MFB); the message bar asks for each ('MIDI: press a knob on the LEFT Twister (Deck A)'). Binding lasts the session; a replugged unit keeps its deck and gets its colours and rings again. Each unit's output is the connected output of the same name at the same place among same-named ports (`outFor`, disconnected ports left out, V1.2.32a).

**Crossed outputs** (V1.2.32a, BLOG0276): with two units of the same port name, Chrome's input and output lists can come in different orders, so each unit got the other's output: rings and recentres landed on the wrong unit and knobs jumped. `tx(s,b)` keeps the last value sent to each output (`LT`); a knob always moves on from the value its unit last received, so a turn far from its own output's value and close to the other's means the outputs are crossed. The app swaps them, resends colours and rings and says 'MIDI: the two Twisters' outputs were crossed (same port name) · fixed, turn again'. That first touch does nothing.

**Bank guard** (V1.2.13a, BLOG0258): a unit slipped to bank 2, 3 or 4 (a middle side button pressed) is sent back to bank 1 (channel 4, CC 0, value 127) with its colours and rings ('MIDI: MFB slipped to bank 2 · back on bank 1'). **Side buttons** do nothing (V1.2.24a, BLOG0268): the units sit side by side, the buttons are stiff and the unit moves when pressed.

**The map** (`MAP`, rows top to bottom; MFB is the column mirror of MFA, `role(s,cc)`, so each deck's controls sit outside and the gains meet in the middle):

| Row | MFA (Deck A): A | B | C | D | MFB (Deck B): A | B | C | D |
|---|---|---|---|---|---|---|---|---|
| 1 | Library | WF Cue | Visual Gain | Music Gain | Music Gain | Visual Gain | WF Cue | Library |
| 2 | VFX1 | AFX1 | VEQ B | AEQ Hi | AEQ Hi | VEQ B | AFX1 | VFX1 |
| 3 | VFX2 | AFX2 | VEQ G | AEQ Mid | AEQ Mid | VEQ G | AFX2 | VFX2 |
| 4 | Settings | AMU | VEQ R | AEQ Low | AEQ Low | VEQ R | AMU | Settings |

The EQ rows follow the EQ drawer's rows, top to bottom.

**The registry.** Each PERFORM control offers itself through `window.__mkReg(deck, name, {get, set, push, play, ...})`, kept in `MK` by deck and map name: the mixer encoders, the EQ and RGB knobs, the FX knobs, the Library, WF Cue, AMU and Settings knobs register where they are built (one code with the mouse and keys), so a turn calls the same `set` a drag does and a push the same action as a click or Enter.

**Rings.** Every 50 ms each bound unit gets the value of each mapped control that changed since it was sent, so a mouse, key or reset move shows on the ring. A value from the unit is recorded as sent, so the app never answers a turning knob. The app also keeps each knob's real position (`u.kv`) from every channel 1 message and every ring it sends (V1.2.23a, BLOG0267), and the last value sent per CC (`u.lr`, V1.2.27a, BLOG0271): a stepping knob counts its turn from where the knob really is, and a value sent before the knob received a recentre is counted from that value, not from 64.

**Stepping knobs** (`rel`: Library, WF Cue, AMU, the Settings cursor): the change between one value and the last moves a cursor, one stop per 8 counts (`REL_STEP`; the remainder is kept). The app recentres the knob to 64 as soon as it passes 112 or 16, and after 250 ms at rest, so a turn never runs out (V1.2.16a). The double push window is 400 ms.

**Knob actions.**

| Knob | Turn | Push | Double push | Push and turn | Hold 1 s |
|---|---|---|---|---|---|
| Library (MFA A1, MFB D1) | cursor over the LIBRARY list rows (the list showing: ALL, MUSIC, VISUALS, or the applied set); closes an open EQ, FX or MODE drawer | loads the row stopped (a playing deck stops first; DECK LOCK refuses on a locked playing deck); a shader row loads, play untouched; a set row applies or turns it off | stopped deck: loads and plays on the QUANT grid once the AMU and audio are both in (`deckPlayPress`); playing deck: stops, loads stopped at 1.1.1 | master tempo, 0.1 BPM per stop, endless | tempo back to the master deck's BPM |
| WF Cue (MFA B1, MFB C1) | cue cursor over the current structure lane; the first turn starts at the playhead's block | jump there on QUANT, as a chip click (on release); the cursor stays as a cue point | none | switch lane: sect, seg, phr (stops at the ends) | none |
| Visual Gain (MFA C1, MFB B1) | VISUAL | kill / restore | LINK on (the glide, 8.5) | none | none |
| Music Gain (MFA D1, MFB A1) | MUSIC | kill / restore | none | none | none |
| VFX1, VFX2, AFX1, AFX2 | opens the FX drawer, sets the amount | drawer closed: opens only; open: kill / restore (on QUANT while playing) | none (a dropout on the first push) | none | none |
| VEQ R, G, B, AEQ Hi, Mid, Low | opens the EQ drawer, sets the band | drawer closed: opens only; open: kill / restore | none | none | none |
| Settings (MFA A4, MFB D4) | opens the deck's Settings drawer; cursor over the Settings button, then each setting; armed: changes the value in its steps (a colour: its hue, 5°) | closed: opens with the cursor only; on a setting: arm / disarm; on the Settings button: close | on a setting: reset it (drawer stays open); on the Settings button: reset all | none | none |
| AMU (MFA B4, MFB C4) | cursor over the deck's buses and lanes, left to right | solo / unsolo; closes that deck's Settings drawer | none | none | none |

- **Library.** One cursor for both knobs, over the list rows only (V1.2.28a, BLOG0272): the filter buttons and CLEAR are not stops (`stops()` = `v.rows`). Push and double push call `push(d)` and `play(d)`; `play` waits for `__libLoad`'s promise (AMU and audio, V1.2.30a, BLOG0274) before `deckPlayPress`, so a late AMU no longer resets the grid mid play. Held and turned, it rides the master tempo (V1.2.12a, BLOG0257); letting go after a turn loads nothing; a plain push fires on release.
- **WF Cue.** The cursor (`d.cueCur`, an Orange Julius outline on the block, 4.4) belongs to the track it was picked on (`L`, the lane data): a load drops it, and a push with a stale cursor does nothing (V1.2.29a, BLOG0273). Message: 'Deck A cue · section 2 of 26 · bar 9.1 (push = jump on QUANT)'.
- **EQ and FX** (V1.2.22a, BLOG0266): the first push on a closed drawer opens it ('EQ open · push again to kill / restore'); the knob's kill is untouched.
- **Settings** (V1.2.03a to 26a): the knob plays the deck's Settings drawer (7.8). Turning back past the first setting lands on the Settings button. A shader without settings: 'no settings in this shader'. The `op` flag that marks a push-opened drawer is cleared by any turn and by the close push (V1.2.26a, BLOG0270).
- **Drawers.** Only the Library knob closes an open EQ, FX or MODE drawer (it sits under them); the other knobs leave them alone (V1.2.04a, BLOG0248). AMU and WF Cue close that deck's Settings drawer, which covers the deck's chips (V1.2.10a, BLOG0255).

---

# 9. Node: Authoring (the template the app carries)

The app is the shader authoring template: a copy of the app HTML at any build works on its own as the template, opening in CREATE off-site. There is no separate template version line; the app build is the template version. To author a shader, copy out the current app HTML; it becomes `OMS_Vizzie_Shader_<Name>_V<nn>.html` with its `.wgsl`.

## 9.1 The per-shader block
One contiguous block holds everything a shader fills: `RULES` (TECHNICAL, carried unchanged; in the order R11 music time, R12 authoring pack, R13 settings, R14, R15, R17 to R22 assets and the pipeline (9.6), then R1 to R10, then R16 shader metadata), `NOTES`, `BUILD`, `TEMPLATE` (the app build it was copied from), the `WGSL`, the embedded `AMU`, the authoring pack (`TRACK_INFO`, `TRACK_MP3`, `TRACK_COVER`), `SPECDOC` (scene, music understanding mapping, objects definitions, hierarchy), `CHANGELOG`, `RIG` (one entry per object), the objects-toggle and CRYPTOMATTE patches, and the overlay slots (`OV_PRELUDE`, `OV_V`, `OV_H`, `OV_AP`, `OV_FRAME_M`). App code sits outside it.

**The default scene's Yobot** (V1.3.18a to 22a, BLOG0306, 0309): the centre of the circle the Yobot's head was made from sits 0.12 frame units below the frame centre (`SUBJECT_Y` 0.1069: the product owner's `YOBOT_Y` −0.12 set on V1.3.18b's 0.2269, folded in by V1.3.21a; `YOBOT_X` and `YOBOT_Y` stay as settings, default 0, moving only the Yobot), and the Yobot is drawn over the scene and blended back at 75 % as one layer (`YB_OPACITY` 0.75), so the whole shader shows through it.

**Music time (R11).** Every position, length and cue in authoring is bars and beats, never seconds: 62.1 = bar 62, beat 1; bar.beat B.N = beat (B − 1) × 4 + (N − 1) in `vizzie.time`.

**Authoring pack (R12).** The shader HTML can pack the song it is authored against: its AMU (compact) in the AMU slot, its info in `TRACK_INFO`, its MP3 and cover as data URIs in `TRACK_MP3` / `TRACK_COVER`. A packed MP3 and cover load on open from anywhere (`dataBlob`), so the song survives every iteration and the file can be sent as one; the `.wgsl` stays lean. Empty = the default, Ain't No Trick. App code is never changed for it.

**Default scene.** The AMU test tunnel with Yobot Squint on top, Squint sized as in HalloweenBounceFeatSquint V60 at 16:9 (`SUBJECT_HEIGHT` 0.765, the Yobot 43.7 % of the frame height; V0.8.02a). It declares and uses the template's standard fourteen settings (9.5), so on open the Settings button shows with the template's own picture. Its WGSL carries the four metadata lines under line 1 (V1.0.27a, BLOG0209 Template: new shaders start named right): `// @title Template Default Scene`, `// @author Wes Smith`, `// @type scene`, `// @desc the AMU test tunnel background (every AMU lane) with Yobot Squint`. A new shader replaces them with its own.

**Settings (R13).** The values an author exposes to tune the look are settings, not consts: declare the block once and each setting as a `// @setting` line (2.2.4); read it where the const was used, with a `let` at the top of each function that uses it (`let CAM_DIST = settings[0].w;`). A WGSL const cannot be built from a setting: a value made from one is a `let` inside the function. Settings are static: to make one move with the music, write that in the shader from the AMU slots and expose the amount as its own setting. Nothing checks the declaration against the code: a setting never read does nothing, a wrong `settings[N]` reads another value. Export in a Code view exports the shader to Downloads as the next version, the tuned values as its defaults. Its check: the drawer lists every declared setting at its default, each one changes the picture, no Settings line in red, no const left that a setting replaces.

**Shader metadata (R16)** (V1.0.26a, 27a; BLOG0208 Shader metadata, BLOG0209): under line 1 of the `.wgsl`, one line each: `// @title` (the name the app shows), `// @author` (one or more, comma-separated, as a track's artists: the source first, e.g. Ducky3D, Wes Smith), `// @type` (asset, visualizer, scene or story; another type shows in red, V1.2.05g), `// @desc` (one line, optional). The version stays in the file name (`_V##`). Write them when the shader is made, never after the fact. File name: `OMS_Vizzie_Shader_<Name>_V##`, underscores and no spaces, the same for the `.wgsl` and its `.html`, `<Name>` the title in CamelCase. Its check: @title, @author and @type present (not the default scene's), @type one of the four, @desc one line, the file name as above. The app reads them as 13.2 says.

## 9.2 Renderer hooks: AUTH_GPU
Everything the preview adds to the WebGPU renderer lives in `AUTH_GPU`; the renderer calls `init`, `patch`, `entries`, `write`, `copy` and `read`. `patch(src)` adds the preview-only bindings in `@group(3)` (1 object mask `partMask`, 2 overlay probe `gprobe`, 3 CRYPTOMATTE table `cm`; 2.2.5) and patches; the shipped `.wgsl` is unchanged.

## 9.3 Objects toggle and CRYPTOMATTE
One tile per object (`RIG`) shows or hides it on the stage through a bit mask (`@group(3)` binding 1). The tiles are half the size since V1.3.31a (BLOG0317): 24 across on a desktop, 12 in the compact layout (`.bgrid`), name text 9 px; the full name shows in the message bar. CRYPTOMATTE paints each object in its ID colour (`@group(3)` binding 3, `cmTable()`), from `RIG` `cm` or a colour from the tile index. CRYPTOMATTE shows its ID colours at the standard HUE 0.5 and VALUE 1; with other values the default scene's HSV node shifts them too.

## 9.4 Authoring overlay
GRID, GUIDES and POINTS draw on a 2D canvas over the stage (`#labOverlay`), never in the shader (R5). GRID is on when the app opens (V1.3.35a, BLOG0321). The overlay draws only in CREATE (`drawOverlay` returns when `authorOn` is false; the stage is shared with PLAY), above the SHOUT OUT scrim and text (z 5, V1.3.34a, BLOG0320). Its GPU read-back (`AUTH_GPU.copy`) runs only in CREATE and never while REC is on (V1.3.36a, BLOG0322). Guides and anchor points are WGSL expressions of the shader's own constants (R6): the preview's shader evaluates them at one pixel (`ovProbeWGSL()`, binding 2), reads them back every sixth frame and `drawOverlay()` draws them. A shader's `OV_PRELUDE` defines `ov_origin` (vec2) and `ov_m` (frame units per metre); guides are metres from `ov_origin`, anchor points are frame units.

**Camera and grid (R10).** World units are always metres; framing belongs to the camera, as in Blender. A shader with its own camera declares it in `OV_PRELUDE`; the GRID steps with the camera: major = the largest power of ten not above the frame height in metres, minor = a tenth (2 m frame: 1 m / 10 cm; 20 cm: 10 cm / 1 cm; 2 cm: 1 cm / 1 mm); labels in metres and a corner label naming the step. A shader with no camera uses `OV_FRAME_M` (template: 2 m). An asset reports its camera through the probe, so the GRID, the axis lines and REF follow it (9.6).

## 9.5 Standard settings (R13)
The template's standard fourteen (BLOG0177 Template standard settings: the first two rows of the rack), for any shader: "give me the defaults" means these, declared and used as the default scene does. `settings[0]` to `settings[3]` are the standard area; a shader's own settings start at `settings[4]` and show from row 3 of the rack (7.8).

| Rack | Setting | Place | Range, step, default | Acts on |
|---|---|---|---|---|
| row 1 | SCALE | settings[0].x | 0.25 to 4, 0.05, 1 | the frame: zoom |
| row 1 | ROTATION | settings[0].y | −180 to 180, 1, 0 | the frame: turn, degrees |
| row 1 | OFFSET_X | settings[0].z | −1 to 1, 0.01, 0 | the frame: left / right, half-heights |
| row 1 | OFFSET_Y | settings[0].w | −1 to 1, 0.01, 0 | the frame: up / down, half-heights |
| row 1 | PIVOT_X | settings[2].x | −1 to 1, 0.01, 0 | centre of ROTATION and SCALE, left / right |
| row 1 | PIVOT_Y | settings[2].y | −1 to 1, 0.01, 0 | centre of ROTATION and SCALE, up / down |
| row 1 | TILE | settings[2].z | 1 to 8, 1, 1 | repeats the frame; each tile shows the whole frame |
| row 1 | TIME_OFFSET | settings[2].w | 0 to 32 beats, 0.25, 0 | slides the motion along the music clock |
| row 2 | SPEED | settings[1].x | 0 to 4, 0.05, 1 | `vizzie.time` × SPEED |
| row 2 | REACT | settings[1].y | 0 to 1, 0.05, 1 | every lane gate × REACT |
| row 2 | HUE | settings[1].z | 0 to 1, 0.01, 0.5 | Blender's Hue/Saturation/Value node, hue (0.5 = none) |
| row 2 | SATURATION | settings[3].x | 0 to 2, 0.05, 1 | the same node, saturation (0 = grey) |
| row 2 | VALUE | settings[1].w | 0 to 2, 0.05, 1 | the same node, value |
| row 2 | CONTRAST | settings[3].y | 0 to 2, 0.05, 1 | contrast around mid grey, after the node |

Row 2 ends with two empty slots. In the default scene:
- `stdFrame(p, asp)` acts on the frame before anything is drawn (tunnel and Yobot alike): TILE first, then rotate and zoom around PIVOT, then OFFSET (`p = rotate(-ROTATION) * (p - OFFSET - PIVOT) / SCALE + PIVOT`). PIVOT alone does nothing: at ROTATION 0 and SCALE 1 the picture does not change. TILE is whole numbers, and the pixel size for the edges follows it, so the Yobot stays sharp when tiled.
- The tunnel's clock: `vizzie.time` × SPEED + TIME_OFFSET; its lane gates × REACT. SPEED multiplies the clock, so turning it moves the motion to the matching place on the scaled clock (a jump while turning).
- Last on the picture: `stdHSV(col)` (hue, saturation, value), then CONTRAST around 0.5.

## 9.6 Assets and the pipeline (R14 to R24)
BLOG0249 Asset shader standard (V1.2.05a to 05f) and BLOG0250 Pipeline (V1.2.05g to 05j), signed off by the product owner. The template rules carry the full text (`RULES`); this is how they fit together.

**The pipeline (R16, R19 to R22).** Four types, each built from the one below: **assets** (one thing: a prop, character or vehicle; everything starts here), **visualizers** (looping animations from assets, `// Loop: N bars`, seamless, driven by the AMU lanes), **scenes** (a timeline from assets, placed in metres on the ground, on `vizzie.time` and the section index) and **stories** (scenes strung together; the story owns the clock and each scene starts at scene time 0). An asset's `.wgsl` has two parts: the ASSET (constants and functions: `prefix_hit` and `prefix_shade` for 3D, `prefix_draw` for 2D) and below it the CREATE HARNESS, which visualizers and scenes leave out. Parts are wired for OBJECTS TOGGLE, ALL and CRYPTOMATTE (`PREFIX_*_SHOW`, `prefix_part`). Cost: a bounds test first, closed-form shapes where the source allows, pixel-sized precision and a step cap, less detail when small, flat shading.

**Assets (R14, R15, R17, R18).** The source decides: an OBJ, MTL or `.blend` model makes a 3D asset, an SVG or a drawing a 2D one; the whole model is kept even though it opens front facing. One asset, one shader: views are a VIEW value, never a second shader. A 3D asset declares five settings on row 3 (2.2.4, after the standard fourteen):

| Setting | Place | Range, step, default | Meaning |
|---|---|---|---|
| VIEW | settings[4].x | 0 to 6, 1, 1 | 0 free (ORBIT and TILT apply) · 1 front · 2 right · 3 back · 4 left · 5 top · 6 bottom |
| ORBIT | settings[4].y | −180 to 180, 1, 0 | turn around the asset, degrees (VIEW 0) |
| TILT | settings[4].z | −90 to 90, 1, 0 | from above or below, degrees (VIEW 0) |
| LENS | settings[4].w | 0 to 200, 1, 0 | focal length in mm; 0 = orthographic |
| SPIN | settings[5].x | 0 to 4, 0.25, 0 | turns per bar, about the Y axis |

A 2D asset declares VIEW only when it has more than one drawn view (view 0 the front). Model space: metres at the source's real size (`// Size: W x H x D m`), Y up, front +Z, origin at the bottom centre (Y = 0 is the ground). The template code: `stdBasis` (the six views), `stdAim`, `stdDist` and `stdCam(p, half size, aspect)` (the ray), `stdSpin`; `ASSET_FIT` 0.5 and `ASSET_GROUND` 0.25: one zoom per asset fits its turning space into at most 50 % of the frame, standing on a ground line 25 % up (VIEW 0 to 4; 5 and 6 centred), the same in every view and at every SPIN, ORBIT and TILT; SCALE is the zoom. Every asset draws on `ASSET_BG` #404040 (Blender 5.0's default grey) with `ASSET_SUN` light only, colours from the source only, and no grid, axes or ground of its own. Nothing beyond the source, the standard fourteen and R17 unless the product owner asks (R18). In a visualizer or scene only the asset's functions are taken; their own camera, background, light and settings take over.

**R23, the AMU span tables** (V1.3.28a, BLOG0203): selection by the music (the busiest sections, the section before the biggest one, a count that follows each section) reads `amuRow()` and the index slots (2.2.6), never bar positions or a song's own numbers, so one shader works on every song.

**R24, everything moves on the music** (V1.3.32a, 32b, BLOG0318): every animation (motion, cycles, loops, pulses, decays, spawns, camera moves, colour changes, reveals) is driven by AMU and music time (`vizzie.time` in beats, beat and bar phase, section, segment and phrase index and progress, the gates and lanes, the span tables); never seconds, minutes, frame counts or a free-running clock, and beats are never converted to seconds. A speed is per beat or per bar, a duration beats or bars; every timing is a ratio of the music clock (on the beat, a subdivision, or a polyrhythm across beat, bar or phrase) that realigns at a fixed point and never drifts. Claude never swaps in real-world maths on its own because it thinks it will look better: it says so and asks. An exception exists only when a limitation is discussed with the product owner and agreed, and is written into NOTES. The TECHNICAL header points to it under MUSIC TIME. The worked example is StarshipGo (V67).

**App checks.** On `// @type asset` shaders the Settings drawer shows in red a background setting (BG, BACKGROUND, SKY, VIGNETTE, FLOOR, `..._BG`), a camera setting outside R17 (DISTANCE, ORTHO_SCALE, YAW, PITCH, `CAM_`, `VIEW_`) or a 3D VIEW that is not 0 to 6, and says 'Background: an asset draws on ASSET_BG (R17)' when ASSET_BG is never used. Scenes and visualizers keep their own backgrounds.

**CREATE's default** since V1.3.23c (BLOG0310) is BoxBot Squint V08 (`AUTHOR_WGSL`, the product owner's V07 with the Offset effect, place, size and colours as they were) walking in front of a floor object, Orange Julius #FFA500, filling the bottom third of the frame and meeting the purple back wall (`FLOOR_TOP`, `FLOOR_COL`, `FLOOR_SHOW`); the authoring grid's 0, 0 is the asset's origin. From V1.2.05e to V1.3.22a it was Yobot Squint (`OMS_Vizzie_Shader_YobotSquint_Base_BlackOutExtrude_V06`), the worked example of the asset standard: a true 3D extrusion of the Yobot outlines (black plastic, the hairline bevel) through `stdCam`, half size `YS_HALF` (1.63, 1.01, 0.20 m), seven source objects (dome, eye.R, eye.L, mouth, headphones, cup.R, cup.L) wired for OBJECTS TOGGLE, ALL and CRYPTOMATTE. PLAY and PERFORM keep the default scene (9.1); switching between PLAY and CREATE swaps one default for the other, and a loaded shader stays loaded.

**Overlay for assets** (9.4): the GRID follows the asset's camera in the model's metres (frame height about 4 m for Yobot at SCALE 1: major lines 1 m, minor 10 cm). Axis lines through the origin, 0.5 pt: the X axis in Barbie Pink #E0218A, the depth axis in Green Slime #65FF00 (front and back: X; right and left: depth; top and bottom: both; free: none). **REF** (a button next to POINTS) draws a 1.8 m person standing on the ground line at the shader's scale, to check size; its message-bar help since V1.3.29a (BLOG0281): 'Reference person on / off: a 1.8 m person on the ground line, to check the asset is real size'.

---

# 10. Node: Tabs

**PLAY · CREATE · PERFORM · HELP · ABOUT · LEARN**, in that order (V1.4.22a, BLOG0355; PLAY was CREATE and CREATE was AUTHORING; the internal names are unchanged: panel `lab` and mode `public` = PLAY, panel `author` and mode `authoring` = CREATE, its mode shown as AUTHOR), via `switchPanel()`. On the website: PLAY · HELP · ABOUT · LEARN, opening on PLAY. Off-site it opens on CREATE. PERFORM and CREATE are off-site only (7.1). PLAY and CREATE share `#panelLab` in two modes (7.2). HELP (`#panelHelp`) holds LET'S DO THIS: a section header and two outlined modules of four lines each (`#labLetsDo` > `ul.cr-tips`, 15px Courier New, `#0a0a0a`, 1px `#2a2a2a`, radius 6px). ABOUT carries the description, credits, licenses and technical notes. LEARN is not a panel: the tab calls `openLearn()`, which opens `https://onemanshyo.com/#learn` in a new tab. The tabs are keyboard stops: W A S D and the arrows reach them, Enter opens one (8.14). Switching between PLAY and PERFORM pauses the surface left (`window.__surf`, 8.1).

---

# 11. Leaf Reference: Controls and Keyboard

The full keyboard table is E 10 (Keyboard index); every control's help, with its pointer actions, is E 9 (Message index).

- **Global strip (PLAY, CREATE):** TEMPO field · QUANT field · arrangement position · Shaka (SHOUT OUT on / off, 7.9), under the GLOBAL header.
- **Global strip (PERFORM):** TEMPO field · QUANT field (Shift+↑ / ↓, scroll; double-click = 1/4) · master PLAY / PAUSE · master position (double-click = 1.1.1) ........ MASTER field (Shift+↑ / ↓ ±1 dB, Shift+← / → ±0.1 dB, scroll; double-click = 0 dB) · DSP (open / close the master compressor / limiter panel).
- **TEMPO field:** Shift+↑ / ↓ ±1 BPM · Shift+← / → ±0.01 BPM · type + Enter · Escape leaves · double-click = the master deck's BPM · W A S D and the plain arrows move on.
- **Music (every deck):** cover (tap = song info on / off, double tap = MP3 / AMU picker) · waveform (click = cue on QUANT, drag = scrub, double tap = MP3 / AMU picker) · a LIBRARY row dragged onto the deck = load it.
- **Drop (the whole app, any tab):** files or folders anywhere = into the LIBRARY; on a one-deck tab with nothing playing the deck also loads the first song and shader by title (4.5).
- **PLAY Music header:** PLAY NEXT · CONTINUOUS PLAY · SHUFFLE · AUTO MIX · SELECTA (the SELECTA knobs). **PLAY controls row:** PLAY / PAUSE · CUE · LOOP ........ EQ · FX · gear (dot, Shift+click = reset). **Music Understanding header (PLAY):** roll orientation · zoom field · SOLO, far right.
- **SELECTA knobs (PLAY):** POINT · LENGTH · TEMPO · MODE: drag (mouse or finger) = step · click / tap = next (wraps) · Shift+click = back · wheel, ↑ → / ↓ ← = step · double-click / double-tap = SELECTA ID 1's value; from the next mix (7.10.4).
- **CREATE controls row:** PLAY / PAUSE · CUE · LOOP · Music Visual Pair · zoom field · roll orientation ........ SOLO. **Visual : Author row:** scroll lock (padlock, lit on at every load; CREATE only) left of orientation.
- **CUE (every deck):** back to the start of the track; on QUANT while playing (plays on), at once while paused.
- **PERFORM deck:** header (mouse only) lock (DECK LOCK on / off) · MASTER (lit = tempo master; click = master by hand) · `</> Code`; row PLAY / PAUSE · CUE · LOOP · Music Visual Pair · zoom field · orientation · position ........ SOLO.
- **Code view (CREATE, PLAY, each PERFORM deck):** Apply · Copy · Export (the next version to Downloads, the current settings as its defaults) · the editor. Clicks in it stay off the stage.
- **Settings drawer (every stage):** W A S D / arrows between its knobs · Shift+↑ / ↓ ±1 step · Shift+← / → ±5 steps (colour: hue 5° / 30°; Enter = colour wheel) · number encoder drag = value (its range in 150 px, snapped to its step) · double-tap = default; number field: click, then ↑ / ↓ = ± step, or type + Enter · double-click = default · Escape leaves. Colour encoder: tap = colour wheel · drag = hue · double-tap = default; colour field: a hex + Enter · double-click = default.
- **PERFORM panel strip:** ISO · EQ · FX · MODE · gear (the decks' Settings): click or Enter = open / close its drawer · Tab (a drawer open) = into the drawer.
- **FX (PERFORM drawer, PLAY drawer):** knob drag = amount · Shift+↑ / ↓ ±1 % · Shift+← / → ±5 % · click = select · Enter = kill / restore on QUANT · double-click = reset to the default · Tab / Shift+Tab = next / previous; effect box: click, then Shift+arrows = previous / next effect.
- **EQ drawer (PERFORM):** TRIM, EQ and RGB knobs: drag = level · Shift+↑ / ↓ fine · Shift+← / → coarse · click = select · Enter = kill / restore, at once (EQ −26 dB, RGB 0, audio TRIM −15 dB, visual TRIM off) · double-click = 0 dB / ×1.00.
- **MODE drawer (PERFORM):** click or Enter = pick the visual mix mode, at once.
- **MIXER header (PERFORM):** ISOLATOR LOW · MID · HIGH: drag = level · Shift+arrows · click = select · Enter = kill / restore (silence) · double-click = 0 dB.
- **DSP panel (PERFORM):** preset box (click, then Shift+↑ / ↓: Off · Gentle · Medium · Aggressive · Limiter) · THRESH · RATIO · OUTPUT knobs (drag, Shift+arrows, double-click = default) · GR bar · DSP again or Escape = close.
- **LIBRARY:** click = select · ↑ / ↓ or W / S select · A / ← = Deck A · D / → = Deck B (PLAY: both = its deck) · Delete = remove · drag onto a deck = load · PLAY: double-click, double tap or Enter = load and play; header ALL · MUSIC · VISUALS · SETS ........ X (clear) (PLAY: ALL · MUSIC · VISUALS · SETS · expand · add files ........ Music Visual Pair · save · X; expand: again or Escape = back); sort header: click a heading = sort by it, again = reverse; set row: double-click or Enter = apply / turn off.
- **Visuals header (PLAY) / Visual header (CREATE):** PLAY: FOLLOW · visual PLAY NEXT · visual CONTINUOUS · visual SHUFFLE (7.11), then `</> Code` · Pop Out · orientation · REC; CREATE: `</> Code` · Settings (shown while the shader declares settings) · Pop Out · orientation · REC. Stage: drop or double tap = `.wgsl`.
- **Power light (main app):** tap = retype the header name and the tagline for the session, up to 75 characters each (Enter = keep · Esc = cancel · empty = the default).
- **Zoom field:** click in, Shift+↑ / ↓ = 0 / 25 / 50 / 75 / 100.
- **Music Understanding (every surface):** chips: click = solo. Bus bars: click = group solo. SOLO clears.
- **Mixer encoders:** drag = level (VISUAL %, MUSIC dB, in the message bar) · Shift+↑ / ↓ fine · Shift+← / → coarse · click = select · Enter = kill / restore · double-click = the default (VISUAL 0 %, MUSIC silence), restored. **LINK** (the chain between a deck's two encoders): click or Enter = link / unlink (on at open; turning it on glides VISUAL to MUSIC over one beat on QUANT; moving VISUAL unlinks). Meters between the MUSIC encoders: display only.
- **Piano roll:** drag = scrub · click = cue to block start (on QUANT while playing; LOOP on = loop it; stopped = pick it) · Shift+click a second section, segment or phrase = the range between (PLAY: lasting; Escape or a plain chip click clears it) · pinch / ctrl + wheel = zoom.
- **Keyboard:** SPACE = play / pause PLAY's deck on PLAY and CREATE, the master PLAY / PAUSE on PERFORM (ignored while typing). Esc no longer closes the song info (V0.9.05a).
- **Keyboard flow (PLAY, PERFORM, CREATE)** (8.14): W A S D = arrows = the nearest stop that way · Tab / Shift+Tab = page order · Enter = on / off · Shift+arrows = the selected control's value · Shift+L = into the LIBRARY (PLAY and PERFORM) · Shift+A / Shift+B / Shift+M = into Deck A / Deck B / the mixer (PERFORM) · Escape in a drawer = its lit strip button · Tab from a strip button (a drawer open) = the drawer's first control. Ignored while typing or with Ctrl / Cmd / Alt.
- **Touch (every knob):** a drag that starts on a knob turns it; the page does not scroll (12.8).
- **Pocket Rave:** see 7.4.
- **Midi Fighter Twisters (PERFORM)** (8.15): first knob pushed = bind Deck A (left), then Deck B · gains, EQ, RGB, FX: turn = value, push = kill / cut / bypass · Library: turn = cursor, push = press / load to the knob's deck · WF Cue: turn = section cursor, push = jump on QUANT · AMU Solo: turn = cursor, push = solo, double push = release all.
- **EQ and FX buttons (PERFORM):** Shift+click = reset (left third Deck A, centre both, right third Deck B) · Shift+Enter = both. **Settings button:** Shift+click (Shift+Enter on PLAY) = every setting to the shader default.

---

# 12. Design System (Human Interface Guidelines)

## 12.1 Philosophy
Vizzie follows the OMS **Human Interface Guidelines** (Dojo, Chippy): a hardware mindset (once you settle and package, it must be right, as with manufacturing physical goods) and things look as good on the inside (CSS, class structure, markup) as on the outside.

## 12.2 What the Design System is
The shared OMS tokens and component language: the `.app` shell, `.header` (gradient ONEMANSHYO brand + app tag + version; the Yobot logo was removed in V0.9.24a), `.tabbar` / `.tab`, `.sec-hdr` dividers, the `.btn` family, the field, the standard line, and the `.message-bar` footer. Exact values and classes live in Y 11.

## 12.3 Buttons
- **One small-button standard:** 11px Courier New, padding 3px 10px, 1px border, radius 4px. SOLO and Pop Out set it; PLAY, CUE, Music Visual Pair and MASTER follow it on PERFORM and PLAY.
- **A button hugs its label.** It never stretches to fill a row (`flex:0 0 auto`). A row aligns its buttons; it does not size them.
- **A button never changes size with its state.** PLAY / PAUSE is fixed at the width of its longest word (PAUSE, 5 characters of the mono font) in both states, text centred, so the row never shifts.
- **Toggle** (`.btn.loop`): grey off (`#7a7a7a` on `#3a3a3a`), cyan on (`#00d4ff` border and text, cyan glow). LOOP, Music Visual Pair, MASTER, scroll lock, the LIBRARY filters, ISOLATOR / EQ / FX / MODE, PLAY's FX, DSP. CUE takes the toggle style but is a press, never lit.
- **Strip and mode buttons** (PERFORM's ISO · EQ · FX · MODE · gear `.pf-fxbtn`; `.tight`, 9px and no letter spacing, in a narrow window; the visual mix modes `.pf-mode`): a smaller form, 22 px high, 10px Courier New, 1px letter spacing, radius 3px; the strip buttons in the toggle colours, the mode buttons `#aaa` on `#1a1a1a` with a 1px `#333` border. Short labels (four or five letters) with the full name in the message bar. Selected from the keyboard: a 2px ring, cyan on the strip buttons, purple on the mode buttons.
- **Code and Settings** (Visual header, PERFORM deck headers): the small-button standard; lit (`.btn.primary`) while their view or drawer is open.
- **SOLO** on the PLAY panel (`.btn.solo`): grey off, Barbie Pink on (`#E0218A`, glow). PERFORM's SOLO uses the toggle style (cyan on); see 12.10.
- **Primary** (`.btn.primary`): cyan (PLAY). While a QUANT start waits, PLAY blinks (`.btn.armed`).
- **MASTER** (PERFORM deck header): the toggle style, lit while the deck is the tempo master; a button since V1.0.30a (pointer cursor; click = master by hand).
- **DSP** (`#pfDspBtn`): the toggle style at master PLAY's size (11px, padding 3px 10px), lit while its panel is open.
- **Icon toggle** (`.bgtoggle`, roll orientation): 26 × 24. The LIBRARY's X (`.pf-libclr`, CLEAR) is one, at the header's far right; save (`.pf-libsave`, the OMS set) another, left of X; CREATE's scroll lock (`#labLockBtn`, cyan on `#1e4a55` while on) another. Music Visual Pair (`.strip-mvp`) is a toggle with an icon only: speaker cyan, link `#888`, camera Purple People Eater, dimmed until paired. PERFORM's Pop Out (`#pfPopBtn`) is an 18 px square marked by its top-right corner.
- **LINK** (`.pf-link`, PERFORM mixer): a flat horizontal chain icon between a deck's two encoders, 24 × 16, no border or fill; grey `#4a4a4a` off, `#9a9a9a` on hover, Goblin White `#fff` linked. PLAY's CONTINUOUS PLAY and SHUFFLE are icon toggles lit as LOOP (`.cr-ptog.on`); PLAY NEXT is an icon press styled as PERFORM's orientation button (`.cr-pnext`: cyan on a `#1e4a55` border). The VISUALS header's FOLLOW, visual CONTINUOUS and visual SHUFFLE are the same icon toggles, visual PLAY NEXT the same press; while FOLLOW is on, visual CONTINUOUS and SHUFFLE mirror the music's, dimmed (`.mir`). The LIBRARY's expand (bulleted list) and add files (folder with a plus) are icon toggles (`.bgtoggle.mu-ctl`, no margin of their own). The roll orientation icon is `ROLL_ORI`, a cascade of 1, 2 and 4 bars (4.4).
- **Disabled:** opacity 0.4 on PERFORM; 0.35 on PLAY (KEY LOCK's rule until V1.3.04a; 12.10).

## 12.4 Fields
**One standard field** (`.pf-gf`) for every data field: TEMPO and QUANT on both tabs, MASTER on PERFORM and the roll zoom fields. 72 × 24 px, 13px Courier New, line height 18px, text centred, cyan `#00d4ff` on `#060606`, 1px `#333` border, radius 4px. Hover = border `#4a4a4a`; focus = cyan border and glow. No label, no − / + buttons, no unit text beside it: the hover help says what it is and its keys. Click in or reach it from the keyboard, then Shift+arrows (8.14).

**Position box** (`#labRecTime`, `.pf-pos`): 11px Courier New 600, `#888`, 1px `#333` border, radius 4px, fixed width (8 characters + padding), so it never moves. Barbie Pink while REC records.

**Value box** under a knob (FX effect box `.pf-fxsel`, EQ / RGB value `.pf-eqval`, Settings value `.set-val`): 10px Courier New (9px in the FX drawer's columns), 1px border, radius 3px, in the knob's domain colour (cyan text on a `#2c5560` border; visual: Purple People Eater on `rgba(178,77,255,0.35)`), spanning its column. A Settings value box is also a field: click, then type.

## 12.5 Spacing
**One gap between neighbouring controls everywhere: 8 px** (buttons, fields, toggles, mixer mode chips), set by the row's or strip's `gap`, never by per-control margins. A control pushed to the end of a row (SOLO) uses `margin-left:auto`. The Music Understanding grid has its own tighter spacing: lane cells 4 px apart on PLAY and 2 px on PERFORM, bus modules 6 px apart on PLAY.

**Knob modules:** 6 px between modules, 8 px inside each on every side (the FX drawer's columns 4 px at the sides). PLAY's drawers (V1.5.19a): EQ, FX and SELECTA columns 96 px (`.cr-eqgrid`); Settings 8 columns across the drawer, 6 px apart, each cell 3px 4px inside (8 px at its module's top and bottom), only the rows in use (until V1.5.19a: one outlined rack, row gap 10, column gap 4, padding 10, and an empty row). **PERFORM:** 9 px from the app's frame at each side, 12 px between its three columns (8.6); the drawer's columns 9 px from the strip and the sides (EQ also from the bottom).

## 12.6 Lines and modules
**The standard line:** 1px `#2a2a2a`, radius 6px. Modules (DECK A, MIXER, DECK B), stages, the waveform, the cover, the AMU box and the global strip use it. A module is a line only: no fill (`#0a0a0a` belongs to the inner boxes that had it), 8 px inside so content does not touch the line. Section headers keep `.sec-hdr` (3 × 13 bar, 11px uppercase label, 1px `#262626` rule).

**Knob module** (`.pf-eqcol`): a group of knobs sits in outlined modules, the standard line with the `#0a0a0a` fill (1px `#2a2a2a`, radius 6px), one module per column. Each knob: the 36 px knob, an optional name, the value box under it spanning the module. No A / B on the labels: the column's place names the deck (A left, B right) and the message bar names it in full. Used by the EQ and FX drawers, PLAY's SELECTA drawer and, since V1.5.19a (BLOG0379), PLAY's Settings drawer, each column its own module; elsewhere the Settings rack is a grid of the same knob, name and value box. Exception: the PERFORM mixer's four encoders are 36 px knobs alone, with no outline, label or value under them (8.5). The isolator's three knobs are the drawers' 36 px knobs in one outlined box in its own drawer (`.pf-isocol`, V1.3.02a; 20 px on the MIXER header's line before, 8.5); the DSP panel's three knobs sit in a three-column grid with value boxes (7.3).

## 12.7 Colour semantics

**Key colours.** the product owner's own colours: Purple People Eater `#B24DFF`, Barbie Pink `#E0218A`, Green Slime `#65FF00`, Yellow Man `#FFF000`, Orange Julius `#FFA500` (brand), Goblin White `#FFFFFF` and Red Hots `#FF006E` (key). Where the UI needs a colour these fill the role first. **One shade of each colour in the app:** any purple, pink, green or yellow is the key colour; a dim form is the same colour at lower opacity, never a second shade (V0.10.12a, 12b). Shader WGSL colours are the shader's own and are not part of the design system.

- **Domain colours:** visual Purple People Eater `#B24DFF`, audio cyan `#00d4ff`. A control's arc, value box, active state and selected ring all take its domain colour (V0.11.20e). Visual (purple): mixer VISUAL, FX VFX knobs and their effect boxes, EQ drawer RGB knobs, the Settings rack's knobs and value boxes, the visual mix modes (the mode in use and the selected ring), the FX "waiting for QUANT" ring on a VFX knob. Visual TRIM is visual (purple). Audio (cyan): mixer MUSIC, FX AFX knobs and boxes, EQ HIGH / MID / LOW, audio TRIM, the ISOLATOR and the DSP knobs. The LIBRARY dots carry them too. Neutral app buttons (ISOLATOR · EQ · FX · MODE) and every other keyboard stop take the app's cyan ring when selected from the keyboard (8.14).
- Chrome and section headers cyan `#00d4ff`; authoring sections Orange Julius `#ffa500`.
- Messages: info cyan `#00d4ff`, state Orange Julius `#ffa500`, error Red Hots `#ff006e`. The DSP panel's GR bar is Orange Julius too (Dojo's). Red Hots also: the danger button (`.btn.mag`), GPU errors on a stage, the ONEMANSHYO gradient (cyan to Red Hots) and Pocket Rave's stage border while playing.
- Active and recording: Barbie Pink `#E0218A` (SOLO on the PLAY panel, the roll and waveform playheads, all of REC).
- Picked or rendered chip on the roll: Yellow Man; LIBRARY entry loaded on a deck: Yellow Man tint.
- Cueing: a chip waiting for QUANT is filled Orange Julius; the Twister's cue and AMU Solo cursors are Orange Julius outlines (V1.1.09j, V1.1.09k).
- Changed-from-default dots (EQ, FX, Settings buttons): the column's domain colour, dim or glowing.
- Bus colours: RHYTHM Red Hots, STRUCTURE Orange Julius, KEY Yellow Man, PACE Green Slime, LOUDNESS blue `#00a8ff`, INSTRUMENTS Purple People Eater. **Every lane takes its bus colour**; beat is Goblin White.
- Credits and PLUR (ABOUT, Pocket Rave) and the authoring overlay's anchor points: Purple People Eater.
- Active state = border colour + tint + glow (toggle cyan, SOLO Barbie Pink, REC Barbie Pink pulse). Selected knob or box = a 2px ring in its domain colour; killed = dimmed (opacity 0.35).

## 12.8 Interaction pattern matrix
Same gesture = same result everywhere (Dojo's matrix, with Vizzie's values).

**Lane chips (Music Understanding, every surface):**

| Gesture | Result | Feedback |
|---|---|---|
| Hover | Help in the message bar with the lane's live value | cyan message |
| Click a chip | Solo the lane | the lane shows soloed, others dim; SOLO lit |
| Click a bus bar | Solo the group | as above |

**Knobs (mixer encoders, ISOLATOR, FX, TRIM, EQ, RGB, DSP):** one behaviour.

| Gesture | Result | Feedback |
|---|---|---|
| Hover | Help with the current value and the keys | cyan message |
| Drag vertical | Value, full range over 150 px | orange value |
| Shift+↑ / ↓, Shift+← / → | Value, fine / coarse | orange value |
| Click | Select | the ring in the knob's domain colour |
| Enter | Kill / restore (FX on QUANT, the rest at once; DSP knobs: none); the value is kept | dimmed; orange message |
| Double-click | Default, restored (mixer VISUAL 0 %, MUSIC silence; ISOLATOR 0 dB; FX the effect's default; EQ and audio TRIM 0 dB; RGB and visual TRIM ×1.00) | orange value |
| Tab / Shift+Tab | Next / previous control | the ring |
| Touch drag (finger) | As drag; the page does not scroll (V1.5.18a, BLOG0375: a touch that starts on `.pf-enc`, `.cr-skc` or `.amu-knob canvas` blocks `touchmove`) | orange value |

**SELECTA knobs (PLAY, V1.5.17a, 18a):**

| Gesture | Result | Feedback |
|---|---|---|
| Hover | Full name, what it sets, the gestures | cyan message |
| Drag vertical (mouse or finger) | One step per 24 px | orange message |
| Click / tap | Next step (wraps); Shift+click = back | orange message |
| Wheel, ↑ → / ↓ ← | Step | orange message |
| Double-click / double-tap | SELECTA ID 1's value | orange message |

**Settings rack knobs:**

| Gesture | Result | Feedback |
|---|---|---|
| Hover | Help: name, value, the shader's own help, range | cyan message |
| Drag vertical | Value, its range over 150 px, snapped to its step (colour: hue) | orange value |
| Tap (colour) | The colour wheel | the wheel opens |
| Double-tap | Default | orange value |

**Buttons:**

| Gesture | Result |
|---|---|
| Hover | Help in the message bar |
| Click | Act or toggle; orange confirmation |

**Fields (TEMPO, QUANT, MASTER, zoom):**

| Gesture | Result |
|---|---|
| Hover | Help with the keys |
| Click | Focus (cyan border and glow) |
| Shift+↑ / ↓ | Coarse step (TEMPO ±1 BPM; MASTER ±1 dB; QUANT and zoom: next value) |
| Shift+← / → | Fine step (TEMPO ±0.01 BPM; MASTER ±0.1 dB) |
| Type + Enter | Set (TEMPO) |
| Double-click | Default (TEMPO = following again: PLAY the song, PERFORM the MASTER deck; QUANT = 1/4; MASTER = 0 dB; master position = 1.1.1) |
| Escape | Leave the field |

**Music row and stage:**

| Gesture | Result |
|---|---|
| Tap cover | Song info on / off |
| Double-tap cover or waveform | MP3 / AMU picker |
| Click waveform | Cue (on QUANT while playing) |
| Drag waveform | Scrub |
| Double-tap stage | `.wgsl` picker |
| Drop anywhere | Into the LIBRARY; on a one-deck tab with nothing playing, the deck also loads (4.5) |
| Drag a LIBRARY row onto a deck | Load it |

**Piano roll:** drag = scrub · click a block = cue to its start · Shift+click a second section, segment or phrase = the range between (Escape clears PLAY's) · pinch / ctrl + wheel = zoom.

**FX effect box:** click, then the arrows = previous / next effect (a new effect starts at its neutral value).

**Visual mix mode buttons:** click or Enter = pick, at once; the mode in use purple.

**LINK:** click or Enter = link / unlink; turning it on glides VISUAL to MUSIC over one beat, on QUANT, then VISUAL follows MUSIC; moving VISUAL unlinks.

**Keyboard** (8.14): W A S D = arrows = the nearest stop that way, across the whole UI; Tab in page order; Enter = on / off; Shift+arrows = the value; Tab from a strip button enters the open drawer; Escape leaves a drawer to its lit button; Shift+L, and on PERFORM Shift+A / Shift+B / Shift+M, jump to a section.

**Drop zone:** one, the whole window on every tab (`appDrop`): "Drop files" and the types one per line (`dropHint`); files and folders. A LIBRARY row over a deck: "Drop to load".

**LIBRARY list:** click = select · double-click, double tap or Enter = load and play (PLAY) · drag onto a deck = load · click a sort heading = sort by it, again = reverse.

A value changes only on the selected field, knob, box or list (Shift+arrows); the page-wide keys are SPACE (PLAY and CREATE: PLAY's deck; PERFORM: master PLAY), the keyboard flow's W A S D, arrows, Tab and Enter (8.14), Shift+L on PLAY and PERFORM, and Shift+A / Shift+B / Shift+M on PERFORM.

## 12.9 The module hierarchy
**section → bus → lane cell → chip** (`.amu-mod` → `.amu-cell` → `.lab-lane`), on every surface since V0.11.10a (`buildLanes` can still add `.amu-knob` encoders; no surface does). The piano roll sits in its own module perimeter aligned with the bus modules above. PERFORM: **tab → global strip + DECK A | MIXER column | DECK B → deck view rows** (8.2); the MIXER column → MIXER (its header carries Pop Out), panel strip (ISOLATOR · EQ · FX · MODE), LIBRARY modules, the drawer over the LIBRARY (8.6, 8.7); the global strip → the DSP panel over Deck B's top (7.3) → the drawer's knob modules (`.pf-eqcol`). PLAY: **tab → GLOBAL + MUSIC column | VISUALS stage → Music Understanding**; the MUSIC column → music row, controls row, LIBRARY module, the FX drawer over the LIBRARY (7.2, 7.6). Module per function.

## 12.10 Known design debt
Where the build does not follow the standard.
- The small-button standard is applied per container (`.pf-trans .btn`, `#labTransportHold > .btn`, `.pf-sm`, inline styles in the Visual header), not by one class; the base `.btn` still declares 12px / padding 6px 12px.
- Disabled opacity differs: 0.4 on PERFORM buttons, 0.35 on PLAY (KEY LOCK's rule until V1.3.04a; nothing on PLAY uses it now).
- SOLO lights pink on PLAY (`.btn.solo`) and cyan on PERFORM (`.btn.loop`): two looks for one function.
- The Dojo button spec (34 px high, 600 weight, uppercase, 0.5 letter spacing, no border) and Vizzie's small button differ; Vizzie's is the one in use.
- Some code comments describe earlier layouts (PLAY "render" mode stacking PLAY / LOOP, PERFORM placeholders, PLAY's LIBRARY as a drawer opened by a LIBRARY button, "PLAY PUBLIC", the drop zone's "an .m3u8 lights QUEUE", the control strip's "the CUE placeholder only where decks are mixed", PERFORM's `bindDrop` call as "the whole deck is the drop zone"); `MODES.idle` and `IDLE_MSG` are set but no longer shown (idle = empty bar).
- Left from QUEUE: `LIB.queue`, `LIB.queueOn`, `queueUI()` and `queueMsg()` remain, and `queueResolve()` keeps its QUEUE fallback; nothing sets `LIB.queue` since QUEUE was removed (V1.0.03a).
- PERFORM's Code Apply keeps a branch for `d===DK` (PLAY's renderer), unreachable since V1.0.30i.
- The mode key for PLAY is still `public` in `MODES` and `mode()`; the word PUBLIC is gone from the UI.
- HELP's line "Press LIBRARY to see more music and visuals" names a button PLAY no longer has (the LIBRARY is always open since V0.10.09a); the wording is the product owner's, kept as is.
- The Settings rack's knobs do not follow the one knob behaviour (12.11): no Enter kill, no arrows, not reached by Tab or W A S D (`tabindex="-1"`); they keep drag and double-tap (V10's model), and their value boxes take the keys.
- The mixer encoders still build a value box each (`.pf-encs span.pf-eqval.pf-fxsel`), hidden by CSS; their CSS comments still describe the outlined modules and value boxes of V0.11.19a to 21d.
- Left from the placeholders: the dashed `.pf-fxbtn.ph` rule (EQ before V0.11.13a), the cyan `.pf-modes .pf-on` rule (overridden by the purple `.pf-mode.pf-on`).
- The compact authoring CSS still sizes `.amu-knob` encoders that are no longer built.
- AUTO MIX's hover help still reads 'SELECTA 1: the last two sections, shaded on the waveform' (SELECTA ID 1's values; the knobs can change them).
- `MU_H` is still declared, no longer used (V1.5.20a); the TEMPO IN MIX entry is a comment in the SELECTA knob list (V1.5.19a).
- PLAY's Settings columns are drawn as modules by their cells' borders, not by a wrapper per column (the rack stays one grid shared with PERFORM and CREATE).

## 12.11 Control rules
Settled in V0.11.13a to 20e and written down as design system rules (BLOG0188 Design system: control colours, modules, values, keys), for every surface:
1. **Domain colour.** Visual = Purple People Eater `#B24DFF`, audio = cyan `#00d4ff`. A control's arc, value box, active state and selected ring all take its domain colour: VISUAL, VFX, RGB, shader settings and the visual mix modes purple; MUSIC, AFX and the EQ bands cyan. Neutral app buttons (ISOLATOR · EQ · FX · MODE) take a cyan ring (12.7).
2. **Knob module.** Knob, optional name, value box under it; a group of knobs in outlined modules (1px `#2a2a2a`, radius 6px, `#0a0a0a`), 8 px inside on every side, 6 px between modules, the value box spanning the module. No A / B on labels: the column's place names the deck (A left, B right); the message bar names it in full (12.6). **Exception:** the PERFORM mixer's four encoders are 36 px knobs alone, with no outline, label or value under them; the level is in the message bar (V0.11.21e).
3. **Values in their unit.** dB for audio level (audio taper), % for picture strength, × gain for RGB, the setting's own number for settings.
4. **Knob behaviour.** Drag and Shift+arrows (↑ / ↓ fine, ← / → coarse) = value; click = select; Enter = kill / restore (dims, keeps its value; FX on QUANT, the rest at once); double-click = default and restored (12.8).
5. **Keyboard.** One flow for the whole UI (BLOG0210, 8.14): W A S D = arrows = the nearest stop that way; Tab in page order over the same stops; Enter = on / off; Shift+arrows = the selected control's value; Tab enters an open drawer from its strip button; Escape leaves a drawer to its lit button; Shift+L into the LIBRARY, and on PERFORM Shift+A / Shift+B / Shift+M into Deck A / Deck B / the mixer; one cyan focus ring.
6. **Small buttons** (strip, mix modes): 22 px, 10px Courier New, 1px letter spacing, radius 3px; short labels (four or five letters) with the full name in the message bar (12.3).
7. **Spacing.** PERFORM 9 px from the app frame, 12 px between its columns (12.5, 8.6).

---

# 13. User Media: AMU Data and Shaders

Everything the performer provides: music, its AMU, shaders, cover images and playlists (sets, 8.10). Vizzie saves none of it: the gig folder is the set.

## 13.1 AMU data
Apple's Music Understanding framework (Swift module `MusicUnderstanding`) analyses a track on-device; the OMS Sozo Sidecar writes it to JSON; Vizzie embeds it. Chain of trust: Apple → Sozo → JSON → `readAMU()` and `MASTER` → `pack()` → shader. Apple is the authority.

## 13.2 Shaders
Vizzie runs any WGSL shader written to the uniform contract. Shaders are authored in the app itself (9), named `OMS_Vizzie_Shader_<Name>_V##.wgsl` / `.html`, and kept in `VIZZIE/App Folder/Library/Shaders/`, one folder per shader. Moving a shader onto V0.7.0 or later means restating any `vizzie.time` rates per beat (2.2.2). A shader exposes its tuning values as settings (binding 1, R13; 2.2.4, 9.1); an exported version (`_V##` + 1) carries the tuned values as its defaults.

**Shader names, one rule everywhere, as track names** (V1.0.26a, BLOG0208): a shader names itself with its `// @title`, `// @author`, `// @type` and `// @desc` lines under line 1 (R16, 9.1). `shMeta(txt)` reads them from the first 60 lines when the shader is imported or loaded; the version comes from the file name's `_V##` (`shVer`). Without `@title` the app shows the file name minus `OMS_Vizzie_Shader_` and `_V##` (`shFallback`, e.g. "Starburst"). The same names show in the LIBRARY (8.9), the row hint (title · author — description) and the deck messages (`shNameOf`: 'Loaded …', '… on the next 1/4', 'WGSL error in …').

---

**END OF DEVELOPER DOCUMENTATION**
