# OMS Vizzie app [Beta V1.1.0] Developer Documentation

**Run date:** 2026-11-09  
**Current Unix Epoch:** 1794244147  
**Document purpose:** The explanatory technical spec for OMS Vizzie: how each system works and why. Uses the shared OMS **Cortex / Node / Leaf** vocabulary (Dojo, Chippy), sized to Vizzie's scope.  
**Filename:** OMS_Vizzie_Beta_V1_1_0_C_Developer_Documentation.md  

## About this document

Vizzie Beta V1.1.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## CONTENTS

**1** Introduction  
&emsp;1.1 What is Vizzie?  
&emsp;1.2 Application development tiers  
**2** Cortex and the Critical Stack  
&emsp;2.1 The master music clock (CORTEX)  
&emsp;2.2 The uniform contract (critical: the one public interface)  
&emsp;&emsp;2.2.1 Namespaces  
&emsp;&emsp;2.2.2 Rules  
&emsp;&emsp;2.2.3 Gates  
&emsp;&emsp;2.2.4 The settings block (binding 1)  
&emsp;&emsp;2.2.5 Authoring preview bindings (@group(3))  
&emsp;2.3 The WGSL runtime (critical)  
&emsp;2.4 Message System: the feedback bar (CORTEX)  
**3** Node: Deck Audio, Tempo, Key Lock  
&emsp;3.1 Deck audio engine  
&emsp;3.2 Warp: steering the deck to the clock  
&emsp;3.3 TEMPO and the tempo master  
&emsp;3.4 KEY LOCK  
&emsp;3.5 The master bus: ISOLATOR, MASTER, DSP  
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
&emsp;7.2 MODES and LAYOUT: CREATE and AUTHORING  
&emsp;7.3 Global strips  
&emsp;7.4 Pocket Rave  
&emsp;7.5 Compact authoring  
&emsp;7.6 CREATE: LIBRARY, FX and the playlist controls  
&emsp;7.7 The Moogerfooger strip and the header rename  
&emsp;7.8 The Settings drawer  
**8** Node: PERFORM  
&emsp;8.1 Two decks on one clock  
&emsp;8.2 The deck view  
&emsp;8.3 QUANT  
&emsp;8.4 Master position  
&emsp;8.5 Mixer, OUT, encoders and LINK  
&emsp;8.6 Layout fit  
&emsp;8.7 Panel strip: EQ · FX · MODE  
&emsp;8.8 FX  
&emsp;8.9 LIBRARY  
&emsp;8.10 SETS (playlists)  
&emsp;8.11 Demo playlists (the website set)  
&emsp;8.12 EQ and RGB  
&emsp;8.13 MODE: video mix modes (OUT)  
&emsp;8.14 Keyboard: one flow for the whole UI  
**9** Node: Authoring (the template the app carries)  
&emsp;9.1 The per-shader block  
&emsp;9.2 Renderer hooks: AUTH_GPU  
&emsp;9.3 Objects toggle and CRYPTOMATTE  
&emsp;9.4 Authoring overlay  
&emsp;9.5 Standard settings (R13)  
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
- **Cortex** = the small, load-bearing core. Everything traces back to it; a change cascades everywhere. The label is used **sparingly on purpose**: if everything is Cortex, the word means nothing. In Vizzie two systems carry it: **the master music clock** (timing) and **the Message System** (the single feedback channel), matching the OMS suite convention.
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

A deck (`makeDeck(id,amu)`) is one track on the master clock. Its position is `d.beat`, in its own track's beats: beat 0 is the track's first AMU beat, the fraction is the phase within the beat. Every frame each playing deck moves by the beats the master moved. `DECKS` holds the decks, `DECKS=[DK,DA,DB]`. `DK` is CREATE's deck (`perf=false`), the one CREATE, AUTHORING and Pocket Rave show and drive. PERFORM makes its own two, `DA` and `DB` (`perf=true`, 8.1). Since V1.0.30i (BLOG0219 CREATE and PERFORM: separate play controls) the surfaces share no deck; before, CREATE's deck was PERFORM's Deck A. `surfDecks()` gives the open surface's decks. The model is three channels and one global part: the tempo, the master clock, QUANT and the master bus (3.5) are the app's, one value each. A deck carries its AMU, warp map, lane data, knobs and solos, play / KEY LOCK state, a pending QUANT action (`d.pend`, 8.3), a pending shader load (`d.shPend`, 6.2) and its audio engine; `d.setTrack(amu)` replaces its track (5.4).

### 2.1.2 The warp map
Each track's AMU beats are its warp markers, set by the analysis instead of by hand. `warpMap(beats)` builds each track's smoothed map once: each AMU beat time is replaced by a straight-line fit over the beats within ±8 (a 4-bar window), so analysis jitter averages out while real tempo drift is still followed (on Ain't No Trick the AMU marks sit 7.7 ms off a steady grid typically, 22.7 ms worst). `d.timeToBeat(t)` and `d.beatToTime(b)` convert through the deck's map (linear between beats, extended past the first and last beat at their spacing); `d.beatLen(b)` is the track seconds per beat at beat `b`, the track's local tempo. `d.t` is a getter / setter through the map, for the places that need track seconds (the audio, the AMU reader).

### 2.1.3 Heartbeat and the loop
`hb()` is the clock's heartbeat: `audioCtx.currentTime` (the audio hardware clock) once a track is loaded, otherwise `performance.now()`. One rAF loop, `chrome()`, does, in order, every frame:
1. advances `MASTER` by the heartbeat delta (clamped to 0.1 s);
2. moves each playing deck by the same number of beats and steers it (3.2), or handles its track end;
3. `quantTick()`: fires due QUANT starts, cues, song switches and shader loads; a deck playing alone leads the master grid (8.3);
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

Contract **V0.5.0A** (V0.11.02a; was V0.4.0D). Two bindings in `@group(0)`:
- **Binding 0, the AMU block:** unchanged from V0.4.0D, **9 × vec4 / 36 floats / 144 bytes**, frozen like a published API: new data goes only into reserved slots, never by renaming or reshuffling. `pack(dk,a,w,h)` builds all 36 floats each frame for deck `dk` from the AMU reader's fields (`a = readAMU(dk, dk.t)`), the deck's gates and beat, and the canvas size.
- **Binding 1, the settings block:** new, **16 × vec4 / 64 floats** (`SET_VEC4` = 16, `SET_BYTES` = 256), the shader's own values (2.2.4).

A shader may use binding 0, binding 1 or both; shaders written for V0.4.0D run unchanged. Each PERFORM deck packs its own uniforms and writes its own settings block for its own shader. The full slot table is in Y 2.2.

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

**One block per deck.** `deckSettings(d)` gives deck `d`'s 64 floats (`d.settings`, a `Float32Array`), zero until something writes them. CREATE's renderer (`DK`) and each PERFORM deck write their deck's block every frame beside the AMU block.

**The declaration** (part of the contract). A shader declares its settings in comment lines anywhere in the `.wgsl`, so the shader compiles as it is:

```
// @setting NAME settings[N].c min max step default | help      a number (N 0 to 15, c one of x y z w)
// @setting NAME settings[N].xyz color r g b | help              a colour (.xyz or .yzw, 0 to 1)
```

The place is written as the shader reads it, so the line and the code match; the help after `|` is optional. Example: `// @setting HUE settings[1].z 0 1 0.01 0.5 | Hue/Saturation/Value node: hue (0.5 = none)`, read in the shader as `settings[1].z`.

**Reading it.** `readSettings(src)` parses the lines into `{list, errs}`: each entry `{name, type, idx, min, max, step, def, help}` (`type` 'number' or 'color'; `idx` the float indices in the block). A line that does not fit is skipped with its reason: name; settings[N].c; N is 0 to 15; a number is .x, .y, .z or .w; a colour is .xyz or .yzw; min max step default; color r g b; min below max; step above 0; default from min to max; name used twice; place used twice. The reasons show in red in the message bar, e.g. `Settings: line 1 · Q: N is 0 to 15` ("Deck B: " in front on PERFORM).

**On a compile.** `settingsFrom(d,src)` runs when a shader compiles cleanly on a deck (CREATE's `main()` build and `makeDeckGpu`'s build). It reads the declaration from the shader as written, not from the authoring preview's patched copy, and keeps it on the deck as `d.setDecl` `{src, list}`. A setting with the same name, type and place as before keeps its value; a new or moved setting takes its default; floats no setting declares are 0. The same source again changes nothing, so a second compile of the running shader keeps its values. Every change of declaration calls the functions in `SET_ON` (the Settings drawers rebuild, 7.8).

**Export: keeping a look.** `settingsBake(src,d)` returns `src` with each declared setting's default replaced by deck `d`'s current value, matched by name; only the default numbers change, and a number whose value has not changed stays exactly as written. `shaderNextName(d)` gives the next version's name: the deck's shader name with `_V##` stepped up by one, the digits kept, or `_V01` added to a name without a version; a shader with no name is `OMS_Vizzie_Shader_V01`. `saveShader(d,src)` downloads `settingsBake(src,d)` as `NAME.wgsl` (the original file is never touched); the deck then holds that version: its name (`d.shaderName`), and, when `src` is the deck's running shader, its defaults (a double-tap goes to the exported values) and its source; any Code view showing that code shows the exported text. Message 'Exported NAME_V12.wgsl to Downloads' ("Deck B: " in front on PERFORM). Export sits in the Code views (6.1). The internal names keep "save" (`saveShader`, `#labSave`, `.pf-csave`); what shows is Export.

**The bind group layout.** `contractLayout(device)` is one explicit group 0 layout with bindings 0 and 1 (uniform, vertex and fragment), cached on the device. The automatic layout lists only the bindings a shader uses, so one bind group could not serve shaders with and without binding 1; the explicit layout always has both, and a shader may use either. PERFORM's FX and OUT pipelines are separate and keep their own layouts.

### 2.2.5 Authoring preview bindings (@group(3))
The authoring preview's three bindings sit in `@group(3)`, keeping their binding numbers: 1 object mask (`partMask`), 2 overlay probe (`gprobe`), 3 CRYPTOMATTE (`cm`). They are patched into the preview's copy of the WGSL only (9.2); the shipped `.wgsl` is unchanged and group 0 is the contract's alone. Group 3 rather than 1: the contract roadmap keeps group 1 for assets, and 3 is the last group WebGPU allows by default. When the preview has objects, `bindP` holds bind groups 1 to 3 (1 and 2 empty, as WebGPU expects every group in the layout to be set; 3 the preview's buffers, with an explicit layout from `AUTH_GPU.entries()`), and each frame sets them after group 0. PERFORM's deck renderer never had the preview bindings.

## 2.3 The WGSL runtime (critical)

`main()` requests the adapter and device, configures a `webgpu` context on `#labGpu`, creates the 144-byte uniform buffer and the settings buffer (`SET_BYTES`), and calls `AUTH_GPU.init(device)`. `build(src)` compiles the shader (through `AUTH_GPU.patch`, 9.2), reads `getCompilationInfo()`, and only if it is clean reads the settings declaration (`settingsFrom`), builds a new pipeline on `contractLayout(device)` and a bind group, and swaps them in: a bad shader never kills the running one; the error line shows in `#labGpuMsg`. `build` is exposed as `window.__applyWGSL`.

### 2.3.1 Why it runs like a game engine
Per frame: write 144 bytes (AMU block) and 256 bytes (settings block), the authoring buffers when on, one render pass, `draw(6)` (a full-screen quad). No per-frame recompilation, no analysis, no cross-origin messaging. A settings change is a buffer write, not a recompile. Keep it that way.

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

**Keys win over a resting mouse** (V1.0.24c, BLOG0206): a key press puts `.kbd-nav` on the body, and until the mouse moves `bindHelp` shows no hover help (focus help still shows) and the LIBRARY shows no hover tint. Before, a list redrawn under a still mouse fired the hovered row's help over the keyed row's. It lives in the one hover handler, so it applies to every control.

---

# 3. Node: Deck Audio, Tempo, Key Lock

## 3.1 Deck audio engine
`makeDeckAudio(ctx,buf,canStretch,keyLock)` plays the decoded track through Web Audio: an `AudioBufferSourceNode` (or the KEY LOCK worklet) into a `pre` node, then the deck gain node, into the master bus (`masterIn(ctx)`, 3.5). The FX rack sits between them where the deck's FX are live (`FX_LIVE`, 8.8): PERFORM's decks, and CREATE's deck on CREATE: `pre` → AFX1 → AFX2 → gain; on PERFORM the deck's TRIM and EQ come first, `pre` → TRIM → LOW → MID → HIGH → AFX1 → AFX2 → gain (8.12); in AUTHORING and Pocket Rave `pre` connects straight to the gain. Position = the offset played from + AudioContext time since the start × rate (the audio hardware clock, sample-accurate). It keeps the interface the app used with an `<audio>` element (`currentTime`, `duration`, `paused`, `ended`, `play`, `pause`, `captureStream`) plus `rate` and `keyLock`. One engine per deck (`d.audio`), all on the app's one AudioContext. `audioContext()` creates the AudioContext inside the drop or pick gesture; any pointer, key, touchend or click event resumes it if the browser suspended it. Web Audio only, no browser-specific APIs, with two iOS / iPadOS Safari provisions (V0.10.07d): `navigator.audioSession.type = 'playback'` where the browser has it, so silent mode does not mute the music, and the first touchend or click plays one silent sample (`audioUnlocked`), which unlocks the AudioContext for the session.

Deck volume: on PERFORM each deck's gain follows its AUD encoder with an audio taper, gain = position² (8.5); on CREATE its deck plays at full.

## 3.2 Warp: steering the deck to the clock
`steerDeck(d)` runs every frame for each playing deck. Target = the deck's track time (`d.t`). Speed = its warp map's local tempo × TEMPO (`d.beatLen(d.beat) × MASTER.tempo / 60`), times a correction that closes the gap over about a second, capped at ±2 %. A gap over 250 ms (a seek, a stall) is jumped instead. Known limit: the KEY LOCK worklet's real read position is not reported back, so the gap is measured against the engine's own position model.

A seek, PLAY or load on one deck does not reset the master clock's last tick (V0.8.09b), so scrubbing one deck never stalls another.

## 3.3 TEMPO and the tempo master
**The tempo master** (`tempoMaster`) is the deck that sets the tempo, as Traktor AUTO and the CDJ master. `masterTick()` runs every frame over the open surface's decks (`surfDecks()`) (V1.0.30a, 30e; BLOG0215 Tempo master):
- The deck started first is master. It keeps mastership while it plays; on PERFORM, while it plays and its AUD is up (above 0, not killed).
- When the master stops, a playing deck takes over: on PERFORM one whose AUD is up first. When the master's AUD goes down while it plays (PERFORM), a playing deck whose AUD is up takes over, as on a pause; with none, the master stays.
- With nothing playing on PERFORM, a master whose AUD is down hands mastership to a deck whose AUD is up. With nothing playing on CREATE, the master stays.
- Bringing the old master's AUD back up does not take mastership back.
- **By hand:** a click on a deck's MASTER (or Enter from the keyboard) calls `setMasterByHand(d)`: the deck becomes master and is pinned (`masterPin`). The next start or stop of any deck, or any deck's AUD going up or down (`masterSig`), ends the pin and hands it back to AUTO.
- The tempo never changes on a start, a stop or a handover.

On CREATE the master is its one deck. A surface switch (`window.__surf`, 8.1) gives mastership to the open surface: CREATE's deck on CREATE; back on PERFORM, PERFORM's last master. On PERFORM the master deck's MASTER is lit.

**A load and the tempo** (`tempoOnLoad(d)`): a track load sets the tempo to the new track's BPM only when no other deck on its surface is playing and the deck is the master (CREATE's deck always is). A playing deck is never retempoed by another deck's load (V1.0.30a; before, any load on deck A set the tempo, so a playing deck B was retempoed).

**TEMPO** is one field in the global strip (7.3), the same field on CREATE and PERFORM (`bindTempoField(tv)`). It is a keyboard stop (8.14): W A S D and the plain arrows move on from it; Shift+↑ / ↓ = ±1 BPM, Shift+← / → = ±0.01 BPM (V1.0.29b); type a value and Enter, Escape leaves the field, double-click = the master deck's track BPM exactly. These keys act only in that field; there are no app-wide tempo keys. `setTempo(bpm,exact)` sets `MASTER.tempo`, rounded to 0.01, clamped to half and one and a half times the **master deck's** track BPM, and every loaded deck's rate. `d.ratio()` = master tempo / the deck's track BPM. The change message is "TEMPO 129.01 BPM" (orange). There is no tempo % any more.

## 3.4 KEY LOCK
On, the deck plays through the `vizzie-stretch` AudioWorklet: a WSOLA time-stretch (Hann-windowed frames, overlap-added) that holds pitch at any rate. The worklet source is `STRETCH_SRC`, loaded once per AudioContext by `loadStretch(ctx)` as a `data:` URL module (a `blob:` module is refused from `file://`; blob is the fallback). Transients: `findOnsets(buf)` finds the track's onsets once (high-passed level steps over twice the recent average, at least 50 ms apart) and the worklet places attacks so drum hits keep their snap. Off, the plain source's playback rate moves pitch with tempo, like a turntable.

Per deck (`d.keyLock`), **on by default** on every deck since V0.8.28a. Where the browser has no AudioWorklet, KEY LOCK shows off and disabled.

## 3.5 The master bus: ISOLATOR, MASTER, DSP
V1.0.20a (BLOG0180 Master gain for PERFORM audio, BLOG0181 Isolator in the mixer (3-band, full kill), BLOG0197 DSP: master compressor / limiter). Every deck's gain node feeds one bus, built once per AudioContext by `masterIn(ctx)`: ISOLATOR → MASTER gain → DSP compressor (a `DynamicsCompressorNode`) → DSP OUTPUT gain → the speakers. Before, each deck went straight to the speakers. The state is `MSTR`; `masterApply()` sets the nodes.
- **ISOLATOR:** three bands split at 250 Hz and 2.5 kHz by Linkwitz-Riley crossovers (two Butterworth filters on each side; an allpass at 2.5 kHz keeps LOW in phase with MID + HIGH), so the bands sum flat at 0 dB. Each band (`MSTR.iso`, a linear gain) runs from full kill (left) through 0 dB (centre, the default) to +6 dB (right); a killed band (`MSTR.isoK`) is silent.
- **MASTER** (`MSTR.db`): the output level after the isolator, before DSP. −60 dB = off (−∞), default 0 dB, top +6 dB.
- **DSP** (`DSP_PRESETS`, Dojo V5.9.0's values from its code): Off 0 dB 1:1; Gentle −12 dB 2:1; Medium −18 dB 4:1, OUTPUT +1.58 dB; Aggressive −24 dB 8:1, OUTPUT +2.92 dB; Limiter −3 dB 20:1. It starts on Limiter. THRESH −48 to 0 dB, RATIO 1:1 to 20:1, OUTPUT −12 to +12 dB; turning a knob makes the preset CUSTOM.
- **PERFORM only**, as the EQ and TRIM: a check every 200 ms (`mixOn()`) sets `MSTR.perf`; off PERFORM every stage is neutral (bands at 1, MASTER 0 dB, compressor at 0 dB threshold and 1:1, OUTPUT 0 dB). The nodes stay in the path on every tab.

The controls are on PERFORM: the isolator in the MIXER header (8.5), MASTER and DSP at the global strip's right end (7.3).

---

# 4. Node: Deck Controls (one code for every deck)

Since V0.8.07a every deck control is one shared component, used by CREATE's deck, both PERFORM decks and, for the pickers, Pocket Rave. A deck view places the components; it owns no control of its own. A fix to a component reaches every deck.

## 4.1 The control strip
`STRIP` is the one definition of a deck's transport buttons: **PLAY** (`.btn primary`), **CUE**, **LOOP** and **KEY LOCK** (`.btn loop`). `buildStrip(holder,o)` builds them into a deck view (`o.ids` keeps CREATE's element ids, `o.ctx.mix` says whether decks are mixed); `bindDeckButtons(d,b)` binds them and SOLO; `deckButtonsUI(d,b)` shows their state each frame (PLAY / PAUSE text, `armed` while a QUANT start waits, LOOP lit, KEY LOCK lit, SOLO lit). CUE was removed in V0.8.21a (it did nothing); LOOP, removed in V0.8.41a, came back in V0.9.06a as the musical loop (2.1.3).

**CUE** came back in V1.0.30h (BLOG0218 CUE button right of PLAY / PAUSE), right of PLAY: back to the start of the track (0 s) through `deckCue(d,0,…)`, the waveform click's path. Playing, it lands on QUANT and the deck plays on, as a chip click; paused, at once. A chip loop is released on landing. One strip definition, so CREATE (both modes) and both PERFORM decks have it. A press, never lit.

PLAY goes through `deckPlayPress(d)`: a start waits for QUANT when another deck on its surface is playing (`othersPlaying(d)`, 8.3), so CREATE's one deck starts at once; a second press while armed cancels it, and a press while a song switch waits cancels the switch ('Switch cancelled · the song plays on', 5.1). A deck's own PLAY clears the master PLAY's memory (8.4).

## 4.2 Lanes, buses and encoders
`LANES` holds the 12 AMU parameters (beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other), each with an id, bus, label, colour, draw kind, contract slot and data. `buildLanes(d,box,o)` builds a deck's six bus modules (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS), each lane a cell with a chip and an encoder. `o.buses` adds the bus headers; `o.labels` gives short chip labels (`LANE_SHORT`); `o.chips` builds chips only, no encoder (the mini players); `o.only` builds a subset of the lanes (Pocket Rave, 7.4).

**Chips on every surface** (V0.11.10a, BLOG0172 AUTHORING: Music Understanding encoders become the standard chips): every `buildLanes` call passes `o.chips`, so each lane is a chip (click = solo) with its short label, no encoder; the bus headers are thin colour bars without text (click = group solo); the solo shows on the chip. PERFORM decks, CREATE's `#labMini` and AUTHORING's `#labAMU` (`CREATE_LANES`) are the same. The lane gain (`d.knob`) stays at its value (1) in the deck model, so shaders get the same gates on every surface. On CREATE the large section is hidden and not painted (`paintLanes` runs on it in AUTHORING only). `buildLanes` can still build encoders without `o.chips`; no surface uses them.

## 4.3 Solo
Owned per deck by `makeSolo()` (`d.solo`): a set of lane ids and `grp:<bus>` keys. `d.solo.on(id)` is true when nothing is soloed, the lane is soloed, or its bus is. Solos are additive. The deck's SOLO button lights when any solo is active and clears all on click. One canonical id per parameter (the lane id) is used by the chips, the encoders, the gates and SOLO.

## 4.4 Piano roll
`deckRoll(cv,d,o)` is one roll component for every deck: draw, scrub, cue, zoom and orientation. **Its axis is master-grid beats**: the window starts at `R.view(t).b0` and is `R.win()` beats long; lanes come from the deck and are placed by `d.timeToBeat`, so bars stay bars at any TEMPO. The playhead is fixed at the centre (`ROLL_PH` = 0.5) at every zoom; the content scrolls under it. `o.only` draws a subset of the lanes and `o.wt` their relative sizes (`laneGeo`; tap-to-cue uses the same sizes), for Pocket Rave (7.4); every other roll passes neither and draws the twelve lanes, equal.

- **Window:** `o.base()` beats at zoom 1 × `R.zoom`, up to twice the song (`R.maxZoom()`), so the whole song is in view from the centre playhead wherever it is. Base: AUTHORING's roll `ROLL_WIN` from `MODES` (16 beats = 4 bars); CREATE's mini roll and PERFORM 16 beats.
- **Zoom field:** one data field (`ui.field`), the standard field (12.4). Click in, ↑ / ↓ move through five steps, 0, 25, 50, 75, 100. `R.step()` maps the zoom to that scale: 0 = the closest view (zoom 1), 100 = the whole song, evenly spaced between. Ctrl + wheel and two-finger pinch on the roll still zoom freely; the field shows where that lands on the same scale.
- **Opening view:** `o.step` and `o.horiz`. PERFORM rolls, CREATE's mini roll and Pocket Rave's roll open at 25 %, horizontal. AUTHORING's roll opens horizontal at 0 %, 120 px high (`o.hh`, the fixed horizontal height; V0.11.16a, BLOG0183 AUTHORING music row and roll as CREATE's); vertical it is 75 px high (`MODES` rollH).
- **Two rolls on the CREATE panel** (`o.active`): the full roll is active in AUTHORING, the mini on CREATE (the full roll is hidden there, V0.10.05a); each keeps its own zoom and orientation, and `R.syncUI()` puts the active roll's values on the shared zoom field and orientation button at every switch. The zoom field sits in AUTHORING's controls row and on CREATE's Music Understanding header (7.2).
- **Orientation:** vertical (lanes as columns) or horizontal (lanes as rows), toggled by the deck's orientation button.
- **Input** (`rollInput`): drag = scrub in beats; click without dragging = cue to that block's start (`amuStart` / `amuCue`: beat, bar, section, segment, phrase, key span, pace step; loudness and the instruments are not cue targets). A cue goes through `deckCue(d,sec,landed)` and waits for QUANT whenever the deck is playing and QUANT is not None (8.3). With LOOP on the cued chip becomes the loop span; clicking the lit chip again releases it to the whole track. On a stopped deck the chip is **picked** (`d.pick`): the playhead goes to its start and REC renders it (6.4); any other playhead move, or PLAY, clears it. The looped or picked chip is lit solid cyan (Dojo 'selected').

## 4.5 The drop zone and double-tap loaders
**One drop zone for the whole app** (`appDrop`, V1.0.01a to 12a, BLOG0191 One drop zone for the whole app). Files and folders dragged anywhere over the window, on any tab, show one layer over the whole window (`.drop-hint.app-drop`) with one hint built by `dropHint(main,types)`: "Drop files" with MP3, AMU .json, .wgsl, cover image, .m3u8 playlist, one per line. `readDrop()` reads files and folders (File System Access handles first, which work on `file://`; then the older entries; then plain files) and records each file's path inside the drop (`f._rel`). **Every drop goes into the LIBRARY** (`libImport`, 8.9); the LIBRARY's summary is the last message. What else happens:
- **PERFORM:** nothing loads onto a deck; load from the LIBRARY (8.9).
- **A one-deck tab** (CREATE, AUTHORING, HELP, ABOUT, LEARN, Pocket Rave) **with its song playing:** the LIBRARY only; the song and its shader carry on (V1.0.04a).
- **A one-deck tab, nothing playing:** `deckDrop(fs,DK)` also loads CREATE's deck, in the LIBRARY's order, not the drop order (V1.0.10a): the first song by title (its MP3 tag, else its file name; `ALNUM`) among those with their AMU in the drop, else the first song; the AMU and cover with its name (a lone AMU or cover dropped with it goes with it); the first shader by name, at its newest `_V##`. They load shader, AMU, audio, then the cover (after the track, so its message comes before the LIBRARY's).
- **The LIBRARY's view** (V1.0.12a): a drop with nothing playing sets it to ALL, its default (any filter and any applied set cleared); a drop with a song playing leaves it as it is. "Playing" is either deck on PERFORM, the deck on a one-deck tab. A drop applies no set (8.10).

The deck drop zones for files, CREATE's LIBRARY module drop zone and PERFORM's MIXER column drop zone are gone. `bindDrop(el,d)` is now only the target for a LIBRARY row dragged onto a deck (CREATE's `#labWrap`, each PERFORM deck): the deck shows "Drop to load" while the row is over it, and the drop loads the row there (`__libLoad`). The MIXER column gets its positioning frame (`position: relative`) where the drawers are made, because the EQ, FX and MODE drawers are placed in its coordinates (V1.0.14a: the removed drop zone code had given the column that frame).

**Double-tap loaders** (`bindLoaders`, `bindCover`): two taps within 300 ms. Cover = MP3 / AMU picker, waveform = MP3 / AMU picker, stage = `.wgsl` picker (not inside CREATE's Code view). The `.wgsl` picker has no `accept` filter because iOS greys out `.wgsl` when filtered; the name is checked instead. Single taps keep their own job.

---

# 5. Node: Song Info, Audio Loading, Waveform

## 5.1 Loading audio
`loadAudioFromBlob(blob,name,d)` reads the ID3 tags, decodes the track, loads the KEY LOCK worklet in parallel, builds the deck engine at the current tempo, places it at the clock's position and computes the waveform peaks. Sources: a packed MP3 (`TRACK_MP3`, 9.1), the example MP3 auto-loaded on the hosted site when none is packed (http / https only, from `./examples/`), a drop on the app (4.5), a LIBRARY entry (8.9), or the hidden pickers (4.5). Under `file://` the app runs on the AMU clock alone until audio is loaded.

**A song switch on a playing deck** (`deckSwitch(d,e)`, V1.0.21a, BLOG0198 Song switch on a playing deck, on QUANT): a LIBRARY track loaded onto a deck that is playing (CREATE: double-click, Enter, ← / →; PERFORM: ← / →, or a row dragged onto the deck) does not stop the deck. The playing song carries on while the new track is fetched, decoded (tags and waveform) and its AMU read. When it is ready the switch waits for the master's next QUANT step (`d.pend` with `sw`, the PLAY / cue rule, 8.3). On that line, in one step, the old song stops; the new AMU, audio, name, cover and waveform come in; and the new song starts from its bar 1 (its first AMU bar line, past any pre-roll), at the master tempo. QUANT None: at once, as soon as it is ready. A later load replaces a waiting one (`d._sw`); PLAY while a switch waits cancels it; a failed load leaves the playing song alone. Messages: 'Loading NAME … (switches on QUANT)', 'NAME on the next 1/4', 'Playing NAME' ("Deck A: " in front on PERFORM). A deck that is not playing loads at once, as before; the MP3 picker is unchanged.

## 5.2 ID3, track names, cover art and the song info
`readID3()` is an inline ID3v2 parser (v2.2 to 2.4, UTF-8 / UTF-16, no library): cover (APIC), title, artist, label, year, copyright. **The picture is copied (`slice()`) before decoding**: `decodeAudioData` takes over (detaches) the file's buffer, and a view into it would read empty afterwards (fixed in V0.8.32a; PERFORM decks showed no cover art before). `deckCover(d)` gives a deck's cover: the authoring pack's `TRACK_COVER` on CREATE's deck (`DK`) when packed, else the MP3's art, else the default. `deckInfo(d)` gives title and artist from the tags, the file name or the embedded track's info.

**Track names, one rule everywhere** (V1.0.24a, BLOG0206 LIBRARY: track names from the MP3 tags, one rule everywhere): the MP3's ID3 title · artist; no title = the file name without its extension; no artist = the title alone; other formats (WAV, M4A, AAC, FLAC, OGG) = the file name. The LIBRARY reads them with `tagsOf(f)`: the tag's bytes only, ID3v2 at the start of the file (its header gives its size) or ID3v1 in the last 128 bytes; a website track (`_url`) is read from its first 64 KB (a Range request). Each file is read once (`TAGS`), in the background after an import (`libMeta`), and the views redraw when the tags are in. The same names show in the LIBRARY, the song info and the message bar ('Loaded …', 'Loading …', 'Playing …', the row's hint; `tagLabel`, `trackLabel`). Pairing a song with its AMU and cover, and a set finding its tracks, stay on file names.

**The song info line** (`infoLine(box,d)`) is one shared function for PERFORM's decks and CREATE in both modes: one line, "title · artist · BPM · key", one style (11px Courier New, `#cfd6dd`, on `rgba(10,10,10,.85)`). It always scrolls (`.pf-tick.run`, V0.9.05a) right to left at about 40 px a second, repeating after a gap so it loops without a jump. It is measured again only on a new song or a resize.

A cover tap shows or hides the info over the waveform (`bindCover`: single tap = toggle, double tap = picker); it stays until the cover is tapped again: no click-elsewhere or Esc close, mode switches and track loads leave it as set. The info lets the pointer through (`pointer-events:none`), so the waveform keeps working under it.

CREATE uses the same line since V0.9.03a (the static panel is retired there and the cover no longer flips; the flip stays in AUTHORING). The panel's fields stay in the page, hidden: Pocket Rave reads them.

**Dropped cover** (V0.9.16a): a square image dropped with its track (4.5), or a LIBRARY track's cover (8.9), goes through `setDeckCover` and sets `d.coverURL`, which wins in `deckCover(d)` over `TRACK_COVER` and the ID3 art; loading another track clears it (`clearDeckCover`).

## 5.3 Waveform
`computeLevels(buffer,600)` → normalised RMS peaks per deck (`d.peaks`). `waveView(cv,d,hold)` draws a deck's whole-song waveform with its own cache, rebuilt when the audio, the track or the size changes, and its own playhead. The cache keeps its source (`w.src`: `d.peaks`, else `d.amu`), so a new track repaints every view of the deck, CREATE, PERFORM and Pocket Rave (V1.0.30f, BLOG0216; before, only CREATE's was reset and PERFORM's decks kept the first track's waveform). A click without drag is a cue through `deckCue()` (on QUANT while playing, message 'Cue · bar x.y · QUANT n'); a drag of 4 px or more scrubs (V0.9.04a). Before audio: on CREATE a dim placeholder envelope, in AUTHORING the sidecar's momentary loudness. The waveform is a whole-song view.

## 5.4 Loading a track's AMU JSON
A Sozo Sidecar v2 `.json` dropped on the app with its song (4.5), loaded with its track from the LIBRARY (8.9), or picked with the MP3 picker (CREATE, PERFORM decks and Pocket Rave), is recognised by its file type (`isAMU`). `amuFromSozo(j)` converts it to the compact AMU (`rhythm`, `structure`, `key`, `pace`, `loudness.momentary`, `instrumentActivity`; tonic names to 0 to 11 via `TONICS`; the instruments' ranges are not carried, as in the embedded AMU) and refuses a file that does not match, naming the missing field. `loadAMUFromFile(f,d)` puts it on the deck with `d.setTrack()`: new warp map and lanes, playhead to the start, the song title from the JSON's `file` field until ID3 tags fill it. Audio and AMU load in either order; `checkPair(d)` reports a loaded MP3 more than 2 s longer or shorter than the AMU. The key name comes from the track (`TONIC_NAMES`).

---

# 6. Node: Viewer Surfaces

These are on the CREATE panel (CREATE and AUTHORING). Each PERFORM deck has a Code view too (6.1); PERFORM has no REC or Pop Out (8.2). On CREATE the stage shows its deck's visual FX when a VFX slot is live (7.6), so Pop Out and REC carry them too.

## 6.1 Code view
`</> Code` (`#labCodeBtn`) shows the current shader source over the stage (`#labCodeView`, editor `#labCode`), with three buttons and a status line beside them (`#labCodeMsg`):
- **Apply** (`#labApply`) compiles the editor text as the preview (`window.__applyWGSL`): "applied (preview only)" or "error, see stage".
- **Copy** (`#labCopy`) copies the editor text, as written: "copied".
- **Export** (`#labSave`) exports the editor text as the next version with the deck's current settings as its defaults (`saveShader`, 2.2.4); the editor then shows the exported text: "exported".

**PERFORM decks** (V0.11.09a, BLOG0175 Code on PERFORM decks; Export in every Code view): each deck header has `</> Code` (`.pf-code`), left of Settings. It opens the same Code view (`.pf-codeview`: the same markup, styles and button order, Apply · Copy · Export, editor `.pf-codeta`) over that deck's stage, with that deck's shader; Code lights while open. Apply sets the deck's shader (`d.wgsl`, `d.wgslVer`) and its stage compiles it ("applied", or "error, see stage" when the stage shows a WGSL error), on either deck; before V1.0.30i deck A's Apply went through CREATE's renderer, since the two shared the deck. A new shader loaded on the deck shows in its open Code view unless the editor has focus (`v.codeSync`). Clicks inside the Code view do not reach the stage, so a double-click in the code does not open the shader picker.

Editing a setting's default in the code and pressing Apply keeps the setting's current value (same name, type and place, 2.2.4); the new default applies on a fresh load or a double-tap reset. Export writes the current value as the default.

## 6.2 Drop or pick a `.wgsl`
Drop a `.wgsl` on the app (it loads on a one-deck tab with nothing playing, 4.5), load one from the LIBRARY (8.9), or double-tap the stage to pick one: the code view fills and the same compile path runs.

**Shader loads wait for QUANT** (`loadDeckShader(d,txt,name)`, V1.0.13a, BLOG0194 Shader loads wait for QUANT): a load from the LIBRARY, the picker or a drop follows the song-start rule. With any deck playing it swaps on the master's next QUANT step (`d.shPend`, fired by `quantTick()`); with nothing playing, or QUANT None, at once (`shaderNow`). While it waits the message bar shows 'NAME on the next 1/4' ("Deck B: " in front on PERFORM); a second load replaces it. The shader compiles at the step, not before. Apply in a Code view stays immediate. Deck messages name the shader by its title (`shNameOf`, 13.2): 'Loaded …', '… on the next 1/4', 'WGSL error in …'.

## 6.3 Pop-out
`openPopOut()` opens a window with a `<video>` whose source is `#labGpu`'s capture stream: the same pixels, hot-swapped shaders included. Double-click for fullscreen.

## 6.4 REC
REC records from the playhead (`startRec()`, no jump to 0; V0.9.07a). On a stopped deck with a picked chip (4.4): LOOP off = one pass, `REC.span`, and `chrome()` stops the recording and the deck at the chip's end ('Chip rendered · recording saved'); LOOP on = the chip loops and the recording runs until REC is pressed again. With no pick: from the playhead to the track end (LOOP off) or across the wraps until REC is pressed (LOOP on). On a playing deck it records from where it is. Capture stream of `#labGpu` at 60 fps + the deck engine's audio (`captureStream()` on its gain) → `MediaRecorder`, preferring H.264 / AAC MP4, falling back to VP9 / VP8 WebM; downloads as `VizzieWGSL_<WxH>_<time>`. The arrangement position box turns red while recording.

## 6.5 Orientation
Cycles 16:9 → 1:1 → 9:16 (`ASPECTS`); `fitStage()` keeps the stage 16:9 of its width and centres the narrower shapes in it. Compact AUTHORING does the same since V1.0.23a (BLOG0204 Compact AUTHORING: stage keeps its 16:9 height in every orientation): its stage box is 16:9 of its width, capped at 60 % of the window height, in every orientation (`fw*9/16`; before, the box took the orientation's shape and everything under it jumped).

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
| roll height (vertical) / window | 75 px / 16 beats (horizontal: 120 px, 4.4) | (the large roll is hidden) |
| readout line | yes | no |
| placeholder waveform before audio | no (sidecar loudness) | yes |
| song info from the sidecar | yes | no |

`LAYOUT.render()` / `LAYOUT.author()` move the same elements between the two arrangements; nothing is duplicated. The Visual header row is found by its label (`#labVisTxt`), not by position.

**CREATE** (`LAYOUT.render()`), top to bottom:
1. **GLOBAL** section header (`#labModeHdr`, text `Global`) over the global strip (7.3).
2. A row of two columns. Left, under a **Music** header (`#labVisTxt` reads Music): `#labLeftCol` holding the music row (`#labMusic`, 40 px: cover 40 × 40 and the waveform), the controls row (`#labTransportHold`) and the LIBRARY module (`#labLibSec`, 7.6) down to the stage's bottom. Right, under a **Visuals** header holding Code, Settings (while the shader declares settings, 7.8), Pop Out, orientation and REC: the stage.
3. **Music Understanding** (`#labMuSec`), full width: the mini (`#labMini`: `buildLanes` with chips and bus bars, and its own `deckRoll` on CREATE's deck). Its header carries the roll zoom field and SOLO at the far right (V0.10.10d), at the header buttons' height. `LAYOUT.fitMu()` sizes the mini down to the bottom of the page (at least 160 px), trimming any overflow so the page does not scroll; it runs on render, on window resize and from a ResizeObserver on the left column and `.body`.

The large Music Understanding (`#labAMU`, its header) and the large roll (`#labRollWrap`) are hidden on CREATE. Because the controls row is off the page while the layouts swap, `LAYOUT` holds SOLO and the zoom field as references (`soloEl`, `zoomEl`) and moves them back in `author()`.

CREATE controls row: **PLAY | CUE | LOOP | KEY LOCK | roll orientation | PLAY NEXT | CONTINUOUS PLAY | SHUFFLE ........ FX** (FX pushed to the far right).

**AUTHORING** (`LAYOUT.author()`): the GLOBAL header and strip, the Visual header (`Visual : Authoring`, holding Code, Settings, Pop Out, orientation and REC) over the stage, the music row (cover 40 × 40 and the waveform box 40 px high, as CREATE's; V0.11.16a), the controls row **PLAY | CUE | LOOP | KEY LOCK | zoom | roll orientation ........ SOLO**, the large Music Understanding (`#labAMU`: the lane chips and bus bars, as CREATE's and PERFORM's; V0.11.10a), the large roll (horizontal, 120 px, 4.4) and the authoring sections. FX, PLAY NEXT, CONTINUOUS PLAY and SHUFFLE are hidden; the deck plays dry.

`setMode(on)` switches mode, layout, roll and messages, and closes the FX drawer and the Settings drawer.

## 7.3 Global strips
A thin strip across the top of the tab, as Ableton's top bar: global settings you set and leave. One look on both panels (`.pf-global`; the CREATE panel adds `.cr-global` for its margins). On the CREATE panel it sits under a **GLOBAL** section header, which switches nothing (V0.10.08a). A global setting belongs here; a deck setting belongs on the deck.

| Tab | Strip |
|---|---|
| CREATE, AUTHORING | TEMPO · QUANT · arrangement position (one deck = the master) |
| PERFORM | TEMPO · QUANT · PLAY · master position ........ MASTER · DSP |

QUANT is one value on every tab: `bindQuantField()` binds every QUANT field (`QUANT_FIELDS`), and a change updates all of them (V0.9.04a).

**MASTER and DSP** (PERFORM, V1.0.20a; the bus is 3.5), at the strip's right end. **MASTER** (`#pfMasterGain`) is a standard field (12.4), as TEMPO and QUANT: Shift+↑ / ↓ ±1 dB, Shift+← / → ±0.1 dB (8.14), scroll, double-click = 0 dB; message 'MASTER −2.0 dB'. **DSP** (`#pfDspBtn`, the toggle style, sized as master PLAY, lit while open) opens a panel (`.pf-dspwin`, 280 px wide) that slides down out of the strip's right end, the drawers' slide, over the top of Deck B: a DSP header with the preset box (`.pf-dsppre`; click, then Shift+↑ / ↓ steps Off · Gentle · Medium · Aggressive · Limiter, then CUSTOM once a knob turns), the THRESH, RATIO and OUTPUT knobs with value boxes (`mkKnob`, the drawers' knob without a kill), and a GR bar (`.pf-dspgr`: the compressor's gain reduction, Orange Julius, 0 to 12 dB, drawn while the panel is open). Opening focuses the preset box; DSP again or Escape closes it. The strip has a positioning frame (`position: relative`) for the panel.

## 7.4 Pocket Rave
The website's compact surface, on CREATE's deck. Opens full frame (`.pr-expanded`); the ONEMANSHYO header toggles full frame and the normal view (off-site a further tap goes to compact authoring); the top strip (power light, jacks) returns off-site to AUTHORING. Shader: tap = play / pause; double tap in full frame = normal view, in the normal view = `.wgsl` picker. Cover: tap = song info over the waveform, on / off (the card follows the 5.2 rule); double tap = MP3 picker. The chrome (song card, waveform) redraws at about 22 fps only while Pocket Rave is on screen. Pocket Rave draws without FX. It is touch only: the keyboard flow (8.14) does not run there.

**Normal view** (V1.0.22a to 22h, BLOG0199 Pocket Rave normal view), modelled on compact AUTHORING, under the MUSIC / ABOUT / LEARN tabs, full width (8 px from the frame); the view scrolls. Top to bottom (`#prMusic`): **VISUAL** header (Settings, REC) · the canvas (`#prPlay`), 16:9, framed as AUTHORING's stage in the standard line (1px `#2a2a2a`, radius 6px; no glow, no colour while playing) · **MUSIC** header · the 40 px music row (cover 40 × 40, waveform beside it; the song info on the cover's back) · **MUSIC UNDERSTANDING** header · the lane buttons · the roll · the status line (section · bar · BPM · key, as AUTHORING's) · vizzie app [version] · PLUR.
- The controls are the app's components: the lane buttons are `buildLanes` (chips and bus bars, click = solo) and the roll is `deckRoll`, both with `o.only` = STRUCTURE (section, segment, phrase) and INSTRUMENTS (drums, bass, vocals, other); beat, bar, key, pace and loudness are left out. The roll is horizontal, opens at 4 bars, 25 %; drag = scrub, tap a block = cue to its start, pinch = zoom; the instrument lanes are 0.75 of a structure lane's height (`o.wt`). It draws every frame.
- **Settings** (`#prSetBtn`): CREATE's deck's rack, the same drawer (`settingsDrawer`), sliding down out of the canvas; shown while the shader declares settings, closed by full frame. **REC** drives CREATE's REC (one state). The canvas follows CREATE's orientation (1:1 and 9:16 at most 60 % of the screen tall); Pocket Rave has no orientation button of its own (V1.0.22h).
- Left out: GLOBAL (TEMPO and QUANT still apply), the transport row (tap the canvas to play; pinch to zoom the roll), Code, Pop Out, the objects toggle and the authoring sections.

## 7.5 Compact authoring
Off-site on a compact viewport: Pocket Rave's frame and header with the authoring sections in one column (one row of 12 lanes, colour bars for chips). Its header goes to Pocket Rave. It can be forced on a wide viewport (Pocket Rave header, third tap), where it shows as a 430 px column. The arrangement position box, Pop Out and REC are hidden there. Its stage box keeps its 16:9 height in every orientation (6.5).

## 7.6 CREATE: LIBRARY, FX and the playlist controls
Built once when the app opens (V0.10.03a to 10e). CREATE only: AUTHORING hides FX and the three icons (`html.author-on`), and a mode or surface switch closes the FX drawer (`window.__crFx.show(false)`).

- **LIBRARY module** (`#labLibSec`, `.pf-mod.pf-libmod`): a `Library` section header, the filter row and the list (`.cr-libin` > `.pf-list`), the same LIBRARY as PERFORM's (8.9) through a second view (`crView = libView(box,{decks:[DK]})`). It is placed in the left column under the controls row and fills it to the stage's bottom; its surround is the page gradient (V0.10.10b). Files reach it through the app's one drop zone (4.5); it has no drop zone of its own since V1.0.01a. A one-deck view: A / ← and D / → both load CREATE's deck; Enter on a row does what its double-click does (V1.0.30b); a **double-click or double tap** on a row (the same row twice within 400 ms, timed by the list: `box._tapId`, `box._tapT`, because the first click redraws the row and iOS reports no second click) loads a track and plays it from the top (on a playing deck: the song switch on QUANT, 5.1), or loads a shader (on QUANT while playing, 6.2). LIBRARY lists take `touch-action:manipulation` (no double-tap zoom).
- **FX** (`#labFxBtn`, `.btn.loop`): opens a drawer (`#labFxPanel`, `.pf-fxpanel` > `.pf-fxslide` > `.pf-fxin`) that slides down out of the controls row over the LIBRARY module: the row's width, from its bottom to the column's bottom (`place()`, re-run on resize and from a ResizeObserver on the left column). The drawer's grid (`.cr-fxgrid`) is AFX1 over AFX2, VFX1 over VFX2 to the right: CREATE's deck's own slots (`fxCell(DK,dom,i,true)`, no deck name), not PERFORM's since V1.0.30i. Its hover help is bound when it is first placed.
- **Music and visual FX on CREATE**: CREATE's deck's rack is live on CREATE (`FX_LIVE`: `DK`, CREATE mode, not Pocket Rave, the CREATE panel shown). With a live VFX slot the renderer draws the shader into a texture (`ctex`), runs the shared visual FX chain (`vfxRun`, state `cvst`) and blits the result to the stage, so Pop Out and REC carry it.
- **PLAY NEXT** (`#labNextBtn`, `.bgtoggle.cr-pnext`, a press), **CONTINUOUS PLAY** (`#labContBtn`) and **SHUFFLE** (`#labShufBtn`) (both `.bgtoggle.cr-ptog`, toggles lit cyan as LOOP): icons, no text, after the roll orientation button (V0.10.06a, 06b). State `CP {cont, shuf}`. `window.__crNext(now)` takes the next track in the LIBRARY list as shown (`crView.rows`; an empty list falls back to every track in the LIBRARY's order, `libCmp`), after the one on the deck, wrapping: `now` (PLAY NEXT) stops the playing track and plays the next from the top; at a track's end (LOOP off) the end-of-track handler calls it, and it acts only while CONTINUOUS PLAY is on. SHUFFLE gives each track in CREATE's view a random sort key (`crView.shuf`), the track on the deck first, kept until SHUFFLE is off: the list is put in a random order and play follows it, as streaming players do.

## 7.7 The Moogerfooger strip and the header rename
The strip (`#prSafeTop`: red power light `.pr-pwr` and five jacks) shows on the main app on every tab, on the website and off it, inside the wood frame above the header (`html:not(.pr-on) #prSafeTop`; `.app` padding-top 26 px under the safe area), as on Pocket Rave (V0.10.11a). A tap on the strip acts only on Pocket Rave and compact authoring (off-site: back to AUTHORING); on the main app it does nothing.

**Metal inserts** (V0.11.06a, BLOG0173 Metal inserts run to the top through the Moogerfooger strip): the two metal inserts on the inner edge of the wood panels (`.app::before`, `.app::after`) sit above the strip (z-index 121; the strip is 120), so they run from the top of the window to the bottom, as in Mezcla.

**Header rename** (V0.10.11c): on the main app a tap on the power light makes the header text (`#brandTxt`) editable, selected, with a dashed cyan outline. Enter or a blur keeps it, Esc restores it, empty restores ONEMANSHYO; whitespace is collapsed and the text cut to 24 characters; pasted text is plain. Keys typed there stop at the header (Space does not play). It lasts for the session: nothing is saved.

## 7.8 The Settings drawer
One component, `settingsDrawer(d,btn,anchor,limit,side)`, for every WGSL stage (BLOG0164 SETTINGS drawer, BLOG0176 Settings drawer: a fixed rack of 32 slots). It is built from the deck's declaration (`d.setDecl.list`, 2.2.4), rebuilt through `SET_ON` whenever the deck's shader changes, and writes straight into the deck's settings block (`deckSettings(d)`): no recompile, the picture follows the next frame. Values last for the session.

**The button.** **Settings** shows only while the deck's shader declares settings; a shader without settings hides it and closes the drawer. AUTHORING: in the Visual header after Code (`#labSetBtn`); CREATE: in the VISUALS header with Code, Pop Out, orientation and REC; each PERFORM deck: in its header right of `</> Code` (`.pf-set`); Pocket Rave: in its VISUAL header (`#prSetBtn`, 7.4). It lights while the drawer is open; click again to close. A mode or surface switch closes CREATE's drawer (`window.__setDrawer`), as the FX drawer.

**Where it opens.**
- **CREATE:** sideways (class `set-left`), out of the stage box's left edge over the MUSIC column (`#labLeftCol`: cover, waveform, controls row, LIBRARY), the stage's height, from the column's left edge to 6 px behind the stage's left edge, the stage on top. Music Understanding below stays uncovered, and Space still plays. The side is set before the drawer is placed, so the first open also comes from the side (V0.11.09e).
- **AUTHORING:** slides down out of the Visual module's bottom edge, tucked 6 px behind it, at the module's width, as the PERFORM FX drawer.
- **Pocket Rave:** slides down out of the canvas, on CREATE's deck's values; full frame closes it.
- **PERFORM deck:** slides down out of the stage box's bottom edge, at the stage's width, over the rows below. The deck column clips what passes its bottom edge, so the drawer stays inside the column, 8 px above its bottom, and its panel scrolls when the settings do not fit. Each deck has its own drawer and block; PERFORM's Deck A is not CREATE's deck (V1.0.30i), so their values are separate.

**The rack** (`.set-pnl`, `SLOTS` = 32): 32 slots in 4 rows of 8, always drawn, the same on every stage, as Ableton's macros: a slot not used shows an empty encoder (dashed, dim) and an empty value box (`.set-empty`). Settings in the standard area (`settings[0]` to `settings[3]`) fill the rack first, in declaration order; a shader's own settings start on a fresh row. A shader with no standard settings fills from slot 1. More than 32: the first 32 show and the bar says "Settings: N beyond the 32 slots not shown" in red. Each slot: the 36 px encoder, the name (10px, cut with "…" when it does not fit; the full name in the hover help), the value box (`.set-val`, 10px, 16 px high, up to 64 px wide, as wide as its column allows). A colour takes one slot.

**A slot.**
- **Number:** encoder drag up / down = its range in 150 px, snapped to its step; double-tap = its default. Field: click, then ↑ / ↓ = ± step, or type + Enter; double-click = default; Escape leaves.
- **Colour:** the encoder shows the colour, its pointer the hue; drag up / down = hue; tap = the colour wheel at the foot of the drawer (hue around, saturation from the centre out, a value bar beside it); double-tap = default. Field: a hex + Enter; double-click = default.

Purple People Eater `#B24DFF` throughout (visual domain): arcs, names, value boxes and the selected ring. The drawer holds no Export: Export is in the Code views (6.1; V0.11.09f).

---
# 8. Node: PERFORM

Two decks and a mixer, for playing visuals live to music. Shown off-site only (7.1). Every control on it is live: the sixteen video mix modes (8.13), the EQ and RGB (8.12) and the FX (8.8).

## 8.1 Two decks on one clock
PERFORM makes its own two decks, `DA` and `DB` (`makeDeck('A',AMU)`, `makeDeck('B',AMU)`, `perf=true`), pushed onto `DECKS` after CREATE's `DK`. Both start on the embedded track and the default shader. Since V1.0.30i (BLOG0219 CREATE and PERFORM: separate play controls) CREATE and PERFORM share no deck: a load, PLAY, CUE, shader, Code Apply or FX on one surface never touches the other. Before, Deck A was `DK`, CREATE's deck, and PLAY on Deck A played CREATE too. The tempo, the master clock, QUANT and the master bus stay one for the app: three channels, one global part (2.1.1). Both decks follow `MASTER`, the tempo master (3.3) and QUANT (8.3).

**One surface plays.** `switchPanel()` calls `window.__surf()`: a switch between CREATE and PERFORM pauses the decks of the surface left, drops their pending QUANT actions and master PLAY's memory, so only one surface plays. MASTER, QUANT waits and the LIBRARY's on-deck marks use the open surface's decks (`surfDecks()`, `othersPlaying(d)`); on CREATE its deck is master, back on PERFORM, PERFORM's last master (3.3).

## 8.2 The deck view
`deckView(d,root)` places the shared deck controls (4) in a deck's column. It owns nothing of its own. Top to bottom:
1. **Header:** DECK A / B · KEY LOCK · MASTER · `</> Code` · Settings (right-aligned). MASTER (`.pf-master`) is in the standard toggle style, lit while the deck is the tempo master; since V1.0.30a it is also a button: a click (pointer cursor) makes the deck master by hand (3.3). `</> Code` opens the deck's Code view over its stage (6.1); Settings, shown while the deck's shader declares settings, opens its Settings drawer (7.8). The header's controls are mouse only: Tab, W A S D and the arrows pass them by (V1.0.30c, 8.14).
2. **Stage:** the deck's shader, 16:9, in the standard line.
3. **Music row, 40 px:** cover 40 × 40 and the waveform beside it; the song info line opens over the waveform.
4. **Row:** PLAY | CUE | LOOP | zoom | orientation | position ........ SOLO.
5. **Music Understanding:** the lane chips and bus bars (mini player, 4.2) and the roll, which takes the remaining height.

No REC or Pop Out on PERFORM: it is for performing, not authoring. Code and Settings are there so a deck's shader can be read, tuned and exported where it plays. The stage shows the deck's picture after its visual FX and its RGB (8.8, 8.12).

## 8.3 QUANT
One master value in music time, in the PERFORM global strip: **None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars** (`QUANT_STEPS`); default 1/4 (`QUANT_DEF`). Triplets and the steps below 1/4 were removed in V0.8.13a: they have no use for starting and cueing a track, and triplet timing in a visual is the shader's job.

The step size is the master's; each deck lands its own AMU point on that step. That alignment is the sync: there is no separate DJ-style SYNC button. The QUANT field is on both tabs' global strips (7.3).
- **PLAY on a stopped deck** (`deckPlayPress`) waits for the master's next step when the other deck on its surface is playing (`othersPlaying(d)`); the deck starts from its own nearest step line on its AMU grid (bar 1 = its first AMU bar). PLAY blinks (`armed`) while it waits; a second press cancels.
- **A cue on a playing deck** (`deckCue`: roll blocks, waveform clicks, CUE) waits for the master's next point at the cue's place within the step, whenever QUANT is not None (V0.9.04a), one deck or two. A cue on a paused deck is at once.
- **A song switch on a playing deck** (`deckSwitch`, 5.1) waits for the master's next step; the new song's bar 1 lands on the line (QUANT 1 Bar lands it on a bar line).
- **A shader load** (`loadDeckShader`, 6.2) waits for the master's next step while any deck plays (`d.shPend`).
- **FX kills and restores** wait for the next step while any deck plays (`fxLater`, 8.8). EQ, RGB and mixer kills are at once (8.5, 8.12).
- **Forward only** (OMS canon). None = at once.
- A deck playing alone leads the master grid: `quantTick()` sets the master's phase to the deck's position in an 8-bar cycle from its bar 1 (`QCYCLE` = 32 beats), so every step size lines up with its phrases.

## 8.4 Master position
**Master PLAY** (`#pfMasterPlay`, `window.__masterPlay()`, V0.9.13a), in the PERFORM strip between QUANT and the position, as Ableton's Space, on PERFORM's decks (`PD`): with any deck playing it pauses every playing deck at once and remembers them and the master grid's beat (`__mpHeld`); pressed again it resumes the remembered decks at once from where they stopped and puts the grid back, so QUANT stays on the beat. With nothing remembered it starts every deck from its playhead. No QUANT wait, no snapping. Space on PERFORM calls it; a deck's own PLAY clears the memory. Its label is PLAY or PAUSE by whether any deck plays.

The PERFORM global strip's position box (`#pfMasterPos`) is the session on the master clock, not a deck position, in bars.beats.sixteenths. It starts at 1.1.1 and counts at the master tempo while any deck plays, from the first PLAY. When every deck stops it holds, and carries on when a deck plays again. Double-click = back to 1.1.1. The count is kept in `window.__mpB` (beats) and advanced in `chrome()` from `performance.now()`. The deck positions stay on the decks.

## 8.5 Mixer, OUT, encoders and LINK
- **OUT** (`#pfOut`): the two deck pictures (after their visual FX and RGB) combined at their VID strengths in the video mix mode picked in the MODE drawer (`OUT_MODE`, 8.13); MIX, the weighted blend, on open.
- **Encoders** (`.pf-encs`), in a row: A VID, A AUD, B AUD, B VID. VID = the deck's strength in OUT (`d.outGain`); AUD = the deck's volume (`d.audGain`). They are 36 px knobs alone: no outline, no label and no value under them (V0.11.21e; the outlined modules and value boxes of V0.11.19a were tried and removed in V0.11.21b to 21e to give the drawer below its room). The encoder's place and colour say which it is: VID Purple People Eater `#B24DFF` outside, AUD cyan `#00d4ff` inside; deck A left, deck B right. The level shows in the message bar on hover, drag and Shift+arrows: VID in %, AUD in dB.
- **AUD in dB, audio taper:** the deck gain is the knob position squared (gain = p²), so the turn spreads evenly by ear: full left −∞ dB (silence), 9 o'clock −24 dB, 12 o'clock −12 dB, full right 0 dB. AUD tops out at 0 dB; the output level after the mix is MASTER's (3.5).
- **Behaviour** (the drawers' rule, BLOG0186 Mixer encoders: values, dB, kill rule, compact): drag up / down = level (full range over 150 px); Shift+↑ / ↓ ±0.01, Shift+← / → ±0.05 of the turn (8.14); click = select (the ring in the encoder's domain colour), no change; Enter = kill / restore the selected encoder (AUD: silence; VID: the deck out of OUT), killed dims and the level is kept (`d.mixK` `{audGain, outGain}`); double-click = the default, 0, and restored (VID 0 %, AUD silence, as on open). VID and AUD open at 0 (V1.0.15a, BLOG0195 Mixer: VID starts at 0): OUT is black and the speakers silent on open.
- **LINK** (V1.0.29a, BLOG0178 Mixer: LINK per deck; on by default since V1.0.30g, BLOG0217): a horizontal chain icon (`.pf-link`) between each deck's two encoders, A VID and A AUD, B AUD and B VID. Click, or Enter with it selected, links or unlinks; white = linked, grey = off. State `d.link` `{on, caught}`. Linked, AUD leads: VID stays where it is until AUD reaches its level (pick-up, `caught`), then follows AUD exactly. Moving VID unlinks, so the visual can go its own way mid mix. Messages: '… LINK: VID n% catching up' or '… follows' while AUD moves, and 'LINK off (VID moved)'. Both decks open linked with AUD and VID at 0, so VID follows AUD from the first move. Each encoder keeps its own kill. Session only.
- **ISOLATOR** (V1.0.20a; the bus is 3.5): LOW · MID · HIGH at the MIXER header's right end (`.pf-iso`), each its name then a 20 px knob on the header's line. Full kill (left), 0 dB (centre), +6 dB (right); the drawers' knob behaviour: drag, Shift+arrows, click = select, Enter = kill / restore (true silence), double-click = 0 dB. Cyan (audio).

## 8.6 Layout fit
PERFORM is three columns side by side, DECK A | MIXER column | DECK B (`.pf`, grid `1fr / 0.563fr / 1fr`, gap 24 px), under the global strip. The MIXER column reaches 12 px into each gap (`.pf-col.pf-mix` margin `0 -12px`), so the gaps either side are 12 px and the decks keep their width (V0.11.18a). PERFORM sits 9 px from the app's frame at each side (`#panelPerform.active` margin `0 -9px`; the other tabs keep the page's 18 px; V0.11.18b) (BLOG0185 PERFORM spacing: centre column and outer gaps). Each deck is a module in the standard line (12.6). The MIXER column has no line of its own: it holds three modules of the same width, each in the standard line, 6 px apart: the MIXER (`.pf-mixmod`: header with the isolator, OUT, encoders and LINK), the panel strip (`.pf-pwrap`, 8.7) and the LIBRARY (`.pf-libmod`, 8.9), which takes the remaining height. The page fits the window without scrolling. Per deck, `fit(v)` sizes the stage 16:9 from the column width, smaller on short windows, after reserving the fixed rows, the gaps, the lanes and 40 px of roll, so the Music Understanding panel always keeps room for chips and roll.

## 8.7 Panel strip: EQ · FX · MODE (PERFORM)
`.pf-panelrow`: three equal buttons in the toggle style (`.btn.loop.pf-fxbtn`, 22 px high, 10px with 1px letter spacing), **EQ · FX · MODE**, left to right by priority (V0.11.14b, BLOG0182 Panel strip order: EQ · FX · MODE; was MODE · FX · EQ). Each opens a **drawer** (`.pf-fxslide`, V0.9.22d to 22g) that slides out of the strip's bottom edge, `transform: translateY(-100%)` → 0 in 0.26 s, inside a clipping window (`.pf-fxpanel`, `overflow:hidden`). The window is the strip's width, tucked 6 px under it, and reaches the bottom of the LIBRARY module (`fxPlace()`, re-run on resize); it covers the whole LIBRARY, which is left as it is underneath, so its height follows the window. One panel at a time (`fxShow`, `fxOpen` = 'eq' | 'fx' | 'mode' | null); the open button is lit; clicking it again slides the drawer back up. EQ holds the deck EQs and RGB (8.12), FX the deck effects (8.8), MODE the video mix modes (8.13). The drawer comes right after the strip in the page order, so Tab goes strip, drawer, LIBRARY (8.14).

**Drawer layout** (EQ and FX, V0.11.14a to 14e): four columns, as the mixer above (`.pf-eqgrid`, each column a `.pf-eqcol` module: 1px `#2a2a2a`, radius 6px, `#0a0a0a`), visual outside, audio inside: deck A's two on the left, deck B's on the right. No DECK A / DECK B header and no deck letter on the labels (V0.11.15b): the column's place names the deck; the message bar names it in full. The columns sit 9 px from the strip, the sides and (EQ) the drawer's bottom (`.pf-eqpan` padding 15px 8px 8px: the drawer starts 6 px under the strip), 6 px apart, 8 px inside each column.

## 8.8 FX
One FX engine for PERFORM and CREATE (V0.10.01a): `fxInit(d)` gives a deck `d.fx = {a:[2 slots], v:[2 slots]}`, slot `{name, amt, killed, node}`; session only. PERFORM's two decks and CREATE's deck each have their own slots (7.6; V1.0.30i). PERFORM's FX drawer (V0.11.14e, BLOG0135 PERFORM FX panel) is four outlined columns, as the EQ drawer (8.7): A VFX · A AFX | B AFX · B VFX (`.pf-eqgrid.pf-fxcols`), slot 1 above slot 2 in each; the columns keep their height (two rows) and the space is below them; 4 px inside at the sides (`.pf-fxcols .pf-eqcol` padding 8px 4px) so the effect names fit. Each cell (`fxCell`) is a knob (`.pf-enc.pf-fxk`, labelled AFX1, AFX2, VFX1, VFX2) and an effect box under it (`.pf-fxsel`, spanning its column at 9px; a name too long ends in "…", the message bar shows it in full: click, then the arrows step the bank; a new effect starts at its neutral value). AFX cells are cyan `#00d4ff`, VFX Purple People Eater `#B24DFF`.

**The knob** (the one kill rule, V0.11.15a, the same on CREATE's FX drawer): drag = amount; Shift+↑ / ↓ ±0.01, Shift+← / → ±0.05; click = select (the ring in the knob's domain colour), it no longer kills; Enter = kill / restore on QUANT (`fxLater`; the ring shows while it waits, purple on a VFX knob, cyan on AFX); a killed knob dims and keeps its amount; double-click (a second click within 300 ms) = reset to the effect's default, unmuted, dropping a kill already armed (`s.gen`); Tab / Shift+Tab = the next / previous control.

**Music FX** (`AFX`), where `FX_LIVE` says the deck's rack plays (PERFORM's decks; CREATE's deck on CREATE). `fxWire(d)` rewires when the slots, the EQ's place or that answer change: live = `pre` → AFX1 → AFX2 → gain (killed slots bypassed), with the deck's TRIM and EQ before AFX1 on PERFORM (8.12); otherwise `pre` → gain. Each effect is a `mixer()` (dry / wet). Filter (bipolar, neutral at 0.5: left low-pass 20 kHz → 150 Hz, right high-pass 20 Hz → 6 kHz, Q 1.1), Washout (high-pass 20 Hz → 2 kHz), Dubby (band-passed feedback echo, dotted 1/8), Delay (the QUANT division, None = 1/4), Reverb (2.8 s noise impulse), Flanger and Phaser (LFO = 1 / (4 × QUANT division)), Bitcrush (16 → 3 bits, curve of 65 536 points). Defaults AFX1 Filter, AFX2 Dubby. Tempo-timed effects follow TEMPO and QUANT every frame (`tick`).

**Visual FX** (`VFX`, V0.9.22h; one shared chain `vfxRun` since V0.10.02a). One WGSL post pass, `PERF_VFX`, with a uniform of kind, amount, deck beat, beat phase, size, QUANT division, time, Feedback decay, QUANT step, beat kick and bar phase. `makeDeckGpu` (PERFORM) and CREATE's renderer render the shader into a texture, then `vfxRun` runs each live slot (`vfxLive(d)`: not killed, not at its neutral value) as a pass ping-ponging two textures (`fxA` / `fxB`, in the chain's state `vfxState`), Feedback reading `prev` (a copy of the last final picture). On PERFORM the deck's RGB pass follows (8.12) and its result is the deck's stage view and what OUT mixes; on CREATE the final picture is the stage. Bank: RGB Split, Feedback, Glitch, Pixelate, Scanlines, Mirror, Kaleidoscope, VHS, Shake (Dojo's nine), Tone (bipolar: left darker / softer, right brighter / sharper), Tile (1 to 8), Rotate (at tempo; a mirrored repeat at the edges), Zoom (pulses on the beat). Defaults VFX1 RGB Split, VFX2 Feedback.

**Kills on QUANT:** `fxLater(run,armed)` queues the kill or restore in `FXQ` for the master's next step (`nextMaster`) while any deck plays, else at once; `fxTick()` fires due entries every frame (called from `chrome()` through `window.__fxTick`).

## 8.9 LIBRARY
One LIBRARY (`LIB`, shared since V0.10.03a) shown in any number of views (`libView(box,o)`, `LIB.views`): PERFORM's MIXER column and CREATE's LIBRARY module (7.6). Every view has the same header and list, and a change in one redraws all. Files and folders, subfolders included, reach it through the app's one drop zone (`appDrop`, `readDrop()`, 4.5). `libImport()` sorts by type and reports one message:
- **Tracks:** each audio file paired with its AMU `.json` by the JSON's `file` field, or its name minus `_sozo_v2_AMU`; audio without its JSON and a JSON without its audio are left out and counted. The JSON is attached data, never an entry. A square image with the track's name is its cover (`entry.cover`).
- **Shaders:** grouped by name stem without `_V##`, the highest `_V##` kept; names without a version fall back to the newest file date. Each kept shader's `@title @author @type @desc` lines are read on import (`shMeta`, 13.2).
- **Sets:** each `.m3u8` becomes a set (8.10).
- A re-drop of the same name replaces its entry.

**The header** (`.pf-libfrow`), one line: **ALL · MUSIC · VISUALS · SETS ........ X** (V1.0.16a; VISUALS was SHADERS, and QUEUE and the playlist buttons are gone, 8.10). ALL clears an applied set; MUSIC and VISUALS keep it; SETS is greyed with no sets. **X** (`.pf-libclr`, the controls row's icon-button style, at the far right; `libClear`, V1.0.02a, 05a, 08a) empties the LIBRARY: tracks and their covers, shaders, the tracks without AMU and every set; the filter returns to ALL; the decks keep what they have ('Library cleared · the decks keep what they have').

**The list** (`.pf-lib`) has a sticky sort header (`.pf-libhd`, V1.0.24a, BLOG0206) that covers the list's top edge: **TITLE · ARTIST · BPM · KEY**, and on VISUALS **TITLE · AUTHOR · VER · TYPE** (V1.0.26a, BLOG0208). Click a heading to sort by it (`LIB.sort`, `libCmp`), again to reverse; the default is TITLE, A to Z, alphanumeric (`ALNUM`: 2 before 10, case ignored). A row without the sorted value goes last; VER sorts by number. BPM and KEY come from the track's AMU (`keyShort`: the key the song spends longest in, short: Em, F#m, C). On ALL a shader shows its title and author beside the tracks. An applied set and CREATE's SHUFFLE keep their own order, and the header shows no arrow (`.fixed`). Entry = title, artist (a track) or author (a shader), BPM · KEY or VER · TYPE, and a dot (audio cyan, shader Purple People Eater). A row's hint in the message bar: title · artist (a track), title · author — description (a shader), then its keys.

**Keys and pointer:** click = select (cyan border) and keyboard focus on the list (Dojo focus ring); ↑ / ↓ or W / S move the selection and show the row's hint in the message bar, as a click (V1.0.24b); A / ← loads it on Deck A, D / → on Deck B (`__libLoad`; CREATE: either loads its deck); Delete or Backspace removes it (a deck keeps what it has). W (or ↑) on the first row goes up to the header's lit filter; on the header A / D (or ← / →) move along the buttons and S (or ↓) goes down into the list; S on the last row stays (`libNav`, one code for every view, V1.0.25a, BLOG0207). Drag an entry onto a deck = load it (track: its AMU, audio and cover; shader: the `.wgsl`). A track loaded onto a playing deck switches on QUANT (5.1); a shader load waits for QUANT too (6.2). An entry on a deck of the open surface is tinted Yellow Man (Dojo 'loaded'; `onDeck`, `surfDecks()`); `window.__libTick` redraws the views when a deck's track or shader changes. The LIBRARY is session only: Vizzie saves nothing (13).

## 8.10 SETS (playlists)
An `.m3u8` in a drop (4.5), before or after the music, becomes a set (V1.0.03a to 19a, BLOG0193 LIBRARY: playlists in the header): its non-`#` lines in order (`file://` URLs decoded), named by its `#PLAYLIST:` line, else its file name with underscores as spaces. `LIB.lists` holds the sets `{name, paths}` in alphabetical order (`plSort`: case-blind, 2 before 10); a set with the same name replaces it. Its paths are tail-matched against each library file's path inside the drop (`f._rel`), with a file-name fallback (`queueResolve(list)`); a library drop re-matches.

**SETS** is a filter like the others (V1.0.16a): it lights and shows the sets as LIBRARY rows (`.pf-plrow`): the set's name, its tracks in the library of its total in grey (e.g. 12/14), and a cyan name and dot on the applied set. Double-click (double tap) or Enter on a set applies it (`setApply`, `LIB.set`): the list goes to MUSIC with that set's tracks in its order, and MUSIC and SETS are lit. The same on the applied set turns it off (the list stays on SETS); on another set, it switches. A set stays applied through MUSIC and VISUALS (VISUALS shows the shaders, SETS stays lit) and through loading a track or shader; ALL clears it, and so does a drop with nothing playing (4.5). ← → and Delete do nothing on a set row. SETS' hint names the set applied: 'Library: Set NAME · N sets · click to show'.

A drop applies no set; an applied set stays applied after another drop. The drop's message names the sets it added (V1.0.19a): 'Library: set Night Set added · 2 of 2 found', or 'Library: 2 sets added · Afternoon 1/1 · Day 1/2' (alphabetical, found / total), after the usual summary when tracks or shaders came too. An `.m3u8` typed `audio/x-mpegurl` (macOS) is not taken as audio (`isAudio`, V0.9.23b). Vizzie writes no playlist. QUEUE (V0.9.23a) and the PLAYLIST drop-down and drawer (V1.0.05a, 06a) are removed: SETS does their job.

## 8.11 Demo playlists (the website set)
On http / https, `libWebSet()` reads `./examples/library.json` on open: `{"files":[file names in ./examples/], "playlists":[{"name","file"}]}` (V0.10.04a). Audio files and AMU `.json` files are listed as stand-ins: an audio entry keeps its URL (`_url`) and is fetched when its track is loaded; an AMU entry (`_lazy`, its `text()` fetches) pairs with its MP3 by name and is fetched when its track loads (V0.10.07g), so opening the page fetches no music or analysis. Other files are fetched on open. They are imported quietly (no message). Each playlist becomes a set (`LIB.lists`, 8.10), in alphabetical order. Its tracks' names come from their MP3 tags, read from each file's first 64 KB (5.2), like every other track; its `#EXTINF` lines no longer rename them (V1.0.24a), and it keeps its order. Tracks match by path, then file name. The LIBRARY opens with the first set applied (MUSIC). Loading a website track fetches its MP3 and AMU, with the message 'Loading NAME …'.

## 8.12 EQ and RGB
The EQ drawer (BLOG0137 EQ per deck (3-band) and RGB; TRIM since V1.0.18a): four outlined columns (8.7), four rows, visual outside under the VID encoders, audio inside under the AUD encoders:

| Row | A RGB | A EQ | B EQ | B RGB |
|---|---|---|---|---|
| 1 | TRIM | TRIM | TRIM | TRIM |
| 2 | BLUE | HIGH | HIGH | BLUE |
| 3 | GREEN | MID | MID | GREEN |
| 4 | RED | LOW | LOW | RED |

Red sits with LOW, green with MID, blue with HIGH (the DVS waveform colours). Each cell (`eqCell(d,i,vis)`; `i` 3 = TRIM) is a 36 px knob, its name and its value box (`.pf-eqval`), spanning its column. The rows spread evenly over the column's height and close up to 6 px in a short window. PERFORM only; levels are kept for the session.

**TRIM** (V1.0.18a, BLOG0196 Mixer: TRIM at the top of the EQ drawer, after the Ecler mixer): index 3 of `d.eq` and `d.rgb`. Audio TRIM is the deck's input gain before the EQ (`R.trim`, a gain node): −15 dB (left), 0 dB (centre, the default), +15 dB (right); killed = −15 dB, its left end. Visual TRIM is one gain on the whole picture, R, G and B together, before the RGB knobs, on RGB's scale: off (left), ×1.00 (centre, the default), ×1.33 (right); killed = off. Each TRIM plays where the EQ plays (PERFORM). Messages: 'Deck A audio TRIM …', 'Deck A visual TRIM …'.

**EQ, audio** (V0.11.13a). `d.eq` = `[low, mid, high, trim]` in dB, per deck (`fxInit`). Three biquad filters (`createBiquadFilter`): LOW `lowshelf` 70 Hz, MID `peaking` 1 kHz Q 0.7, HIGH `highshelf` 13 kHz, the DJ channel EQ (as Pioneer's DJM). Each band runs from −26 dB (left) through 0 dB (centre) to +6 dB (right); near the centre it snaps to 0 dB. `eqApply(d)` sets the gains. The chain is `pre` → TRIM → LOW → MID → HIGH → the FX rack → gain (the AUD encoder). It plays on PERFORM only: `fxWire` routes through it when `window.__eqOn(d)` says so; on CREATE its deck plays without it (CREATE has no EQ control). Cyan knobs, the value in dB ("+6.0 dB", "0 dB"). A shelf at −26 dB cuts the sub and most of the kick, not all of it; a full kill is the isolator's job (3.5, 8.5).

**RGB, visual** (V0.11.14a, Dojo's visual EQ). `d.rgb` = `[r, g, b, trim]` gains on the deck's picture, each channel times the visual TRIM: left = channel off (×0.00), centre = ×1.00, right = ×1.33 (Dojo's top). It runs as one more `PERF_VFX` pass, kind 14, after the deck's visual FX and before OUT (`vfxRun(…, rgb)`, PERFORM decks only), so the deck stage and OUT both show it. The pass is drawn only when a channel is off ×1.00, so a deck at ×1.00 costs nothing. Feedback keeps its trail from the picture before RGB, so a channel change does not build up in the trail. Purple knobs, the value as a gain ("×1.00").

**The knob** (the one kill rule, V0.11.15a): drag = level; Shift+↑ / ↓ fine, Shift+← / → coarse; click = select; Enter = kill / restore, at once (EQ: the band at −26 dB, `d.eqK`; RGB: the channel at 0, `d.rgbK`; TRIM: its left end); killed dims and the level is kept; double-click = 0 dB / ×1.00, restored. Message: "Deck B RGB BLUE ×1.00", "Deck A EQ HIGH +6.0 dB".

## 8.13 MODE: video mix modes (OUT)
The MODE drawer (BLOG0184 Video mix modes (OUT)): sixteen buttons (`.pf-modes` > `.pf-mode`), four rows of four, each with a short label; the message bar gives the full name and what it does. Click or Enter picks a mode; it changes at once; the mode in use is purple (visual domain). `OUT_MODE` (session) goes to `PERF_MIX` as `m.mode`. With `a` = deck A × VID A, `b` = deck B × VID B, `A` / `B` the decks' pictures, `ga` / `gb` the VIDs:

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

In the modes with a base (MULTIPLY, OVERLAY, SOFT LIGHT, DODGE, BURN, COLOR) deck A is the base at VID A and VID B is how much of B goes over it; with VID A at 0, B alone. In LUMA and INV LUMA, VID B is B's strength and VID A how much matte. A VID at 0 takes its deck out in every mode, so there is no CUT: pulling a VID to 0 is the cut (dropped in V0.11.17a). MIX and ADD look the same while the two VIDs add up to 100 % or less.

The mode buttons are styled as the strip buttons (22 px, 10px Courier New, 1px letter spacing, radius 3px).

## 8.14 Keyboard: one flow for the whole UI
BLOG0210 Keyboard: W A S D and Tab across the whole UI; Enter on / off; Shift+A / Shift+B / Shift+M on PERFORM (V1.0.28a to 30d). One document-level `keydown` handler (capture phase) serves CREATE, PERFORM and AUTHORING, on a local file and on the website. Pocket Rave is touch only (`prActive()`). It replaces PERFORM's MIXER column grid (BLOG0187) and CREATE's own LIBRARY handler.
- **The stops** (`kbdItems`, `KBD_SEL`): on the open tab, buttons, selects, links, the TEMPO field and anything with a tab index, plus the tab bar; lane chips, bus bars and lane knobs are stops. Not a stop: `tabindex="-1"` (the Settings rack's knobs), a control clipped out of view (the buttons of a closed drawer) or under an open drawer or panel (`kbdShown`), and PERFORM's deck-header controls (KEY LOCK, MASTER, Code, Settings), which are mouse only (V1.0.30c; CREATE keeps its headers in the flow).
- **W A S D = arrows** (V1.0.29b): the nearest stop that way. W / S go to the next row close to straight ahead (a wider cone when nothing is), then the nearest in it; A / D move along the same row first. **Tab / Shift+Tab** move in page order over the same stops. With nothing selected, the first press goes to the tab's first control (`kbdFirst`: its top row's leftmost; controls a few px apart in height count as one row).
- **The tab bar:** W (or ↑) into it lands on the open tab; S (or ↓) from it goes to the tab's first control (TEMPO), as Tab does; Enter opens a tab.
- **Enter = on / off:** presses a button, opens a tab, solos a lane chip or bus bar (`_enter`), kills / restores a knob or encoder, opens / closes a drawer from its strip button, applies a set, makes a deck MASTER.
- **Shift+arrows = the selected control's value:** encoders, knobs, the TEMPO, QUANT, zoom and MASTER fields, the effect and preset boxes. The plain arrows only move, so ↓ on TEMPO no longer lowers the tempo. TEMPO: digits type a tempo, Shift+↑ / ↓ ±1 BPM, Shift+← / → ±0.01. Text fields and the Code views keep their keys.
- **The LIBRARY** keeps its rules (`libNav`, 8.9): in the list W / S step the rows and A / D (← / →) load; on the header A / D move along and S goes down into the list. W on the header goes on by the general rule (PERFORM: up into the mixer).
- **Jump keys**, each to a section's first control, from anywhere (also from the TEMPO field), with no exit first: **Shift+L** into the LIBRARY (ALL), on CREATE and PERFORM, website included; with an EQ, FX or MODE drawer over the LIBRARY the bar says to close it first. On PERFORM (`window.__pfKeys`): **Shift+A** / **Shift+B** into Deck A / Deck B (their PLAY), **Shift+M** into the mixer (A VID), with the message "Mixer: W A S D, arrows or Tab move · Shift+arrows = level · Enter = kill / open · Escape = out of a drawer". Plain M is retired. CREATE has no other section keys.
- **Drawers (PERFORM):** Tab from a strip button with a drawer open goes straight to the drawer's first control (EQ: A's visual TRIM; FX: VFX1; MODE: MIX), then steps on through the drawer. W A S D and the arrows stay in the open drawer's grid (`.pf-fxin`): only W from its top row leaves, to the strip (V1.0.31b, BLOG0222). W / S take a stop straight below / above first (overlapping it side to side), the nearest row first, then that row's leftmost: PLAY → the RHYTHM bus bar → beat (V1.0.31c, 31d); with none straight that way, the nearest in a cone as before. **Escape** anywhere in a drawer goes to its lit strip button.
- **One focus look:** the app's cyan ring (`box-shadow: 0 0 0 2px #00d4ff`) on every stop picked from the keyboard (`.kbd-nav … :focus-visible`); the video mix modes keep their purple ring.
- Nothing acts while typing in a field or the Code view (TEMPO excepted, as above), or with Ctrl / Cmd / Alt held.
---

# 9. Node: Authoring (the template the app carries)

The app is the shader authoring template: a copy of the app HTML at any build works on its own as the template, opening in AUTHORING off-site. There is no separate template version line; the app build is the template version. To author a shader, copy out the current app HTML; it becomes `OMS_Vizzie_Shader_<Name>_V<nn>.html` with its `.wgsl`.

## 9.1 The per-shader block
One contiguous block holds everything a shader fills: `RULES` (TECHNICAL, carried unchanged; in the order R11 music time, R12 authoring pack, R13 settings, then R1 to R10, then R16 shader metadata), `NOTES`, `BUILD`, `TEMPLATE` (the app build it was copied from), the `WGSL`, the embedded `AMU`, the authoring pack (`TRACK_INFO`, `TRACK_MP3`, `TRACK_COVER`), `SPECDOC` (scene, music understanding mapping, objects definitions, hierarchy), `CHANGELOG`, `RIG` (one entry per object), the objects-toggle and CRYPTOMATTE patches, and the overlay slots (`OV_PRELUDE`, `OV_V`, `OV_H`, `OV_AP`, `OV_FRAME_M`). App code sits outside it.

**Music time (R11).** Every position, length and cue in authoring is bars and beats, never seconds: 62.1 = bar 62, beat 1; bar.beat B.N = beat (B − 1) × 4 + (N − 1) in `vizzie.time`.

**Authoring pack (R12).** The shader HTML can pack the song it is authored against: its AMU (compact) in the AMU slot, its info in `TRACK_INFO`, its MP3 and cover as data URIs in `TRACK_MP3` / `TRACK_COVER`. A packed MP3 and cover load on open from anywhere (`dataBlob`), so the song survives every iteration and the file can be sent as one; the `.wgsl` stays lean. Empty = the default, Ain't No Trick. App code is never changed for it.

**Default scene.** The AMU test tunnel with Yobot Squint on top, Squint sized as in HalloweenBounceFeatSquint V60 at 16:9 (`SUBJECT_HEIGHT` 0.765, the Yobot 43.7 % of the frame height; V0.8.02a). It declares and uses the template's standard fourteen settings (9.5), so on open the Settings button shows with the template's own picture. Its WGSL carries the four metadata lines under line 1 (V1.0.27a, BLOG0209 Template: new shaders start named right): `// @title Template Default Scene`, `// @author Wes Smith`, `// @type scene`, `// @desc the AMU test tunnel background (every AMU lane) with Yobot Squint`. A new shader replaces them with its own.

**Settings (R13).** The values an author exposes to tune the look are settings, not consts: declare the block once and each setting as a `// @setting` line (2.2.4); read it where the const was used, with a `let` at the top of each function that uses it (`let CAM_DIST = settings[0].w;`). A WGSL const cannot be built from a setting: a value made from one is a `let` inside the function. Settings are static: to make one move with the music, write that in the shader from the AMU slots and expose the amount as its own setting. Nothing checks the declaration against the code: a setting never read does nothing, a wrong `settings[N]` reads another value. Export in a Code view exports the shader to Downloads as the next version, the tuned values as its defaults. Its check: the drawer lists every declared setting at its default, each one changes the picture, no Settings line in red, no const left that a setting replaces.

**Shader metadata (R16)** (V1.0.26a, 27a; BLOG0208 Shader metadata, BLOG0209): under line 1 of the `.wgsl`, one line each: `// @title` (the name the app shows), `// @author` (one or more, comma-separated, as a track's artists: the source first, e.g. Ducky3D, Wes Smith), `// @type` (visualizer, asset, scene, story or decal), `// @desc` (one line, optional). The version stays in the file name (`_V##`). Write them when the shader is made, never after the fact. File name: `OMS_Vizzie_Shader_<Name>_V##`, underscores and no spaces, the same for the `.wgsl` and its `.html`, `<Name>` the title in CamelCase. Its check: @title, @author and @type present (not the default scene's), @type one of the five, @desc one line, the file name as above. The app reads them as 13.2 says.

## 9.2 Renderer hooks: AUTH_GPU
Everything the preview adds to the WebGPU renderer lives in `AUTH_GPU`; the renderer calls `init`, `patch`, `entries`, `write`, `copy` and `read`. `patch(src)` adds the preview-only bindings in `@group(3)` (1 object mask `partMask`, 2 overlay probe `gprobe`, 3 CRYPTOMATTE table `cm`; 2.2.5) and patches; the shipped `.wgsl` is unchanged.

## 9.3 Objects toggle and CRYPTOMATTE
One tile per object (`RIG`) shows or hides it on the stage through a bit mask (`@group(3)` binding 1). CRYPTOMATTE paints each object in its ID colour (`@group(3)` binding 3, `cmTable()`), from `RIG` `cm` or a colour from the tile index. CRYPTOMATTE shows its ID colours at the standard HUE 0.5 and VALUE 1; with other values the default scene's HSV node shifts them too.

## 9.4 Authoring overlay
GRID, GUIDES and POINTS draw on a 2D canvas over the stage, never in the shader (R5). Guides and anchor points are WGSL expressions of the shader's own constants (R6): the preview's shader evaluates them at one pixel (`ovProbeWGSL()`, binding 2), reads them back every sixth frame and `drawOverlay()` draws them. A shader's `OV_PRELUDE` defines `ov_origin` (vec2) and `ov_m` (frame units per metre); guides are metres from `ov_origin`, anchor points are frame units.

**Camera and grid (R10).** World units are always metres; framing belongs to the camera, as in Blender. A shader with its own camera declares it in `OV_PRELUDE`; the GRID steps with the camera: major = the largest power of ten not above the frame height in metres, minor = a tenth (2 m frame: 1 m / 10 cm; 20 cm: 10 cm / 1 cm; 2 cm: 1 cm / 1 mm); labels in metres and a corner label naming the step. A shader with no camera uses `OV_FRAME_M` (template: 2 m).

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

---

# 10. Node: Tabs

**CREATE · PERFORM · AUTHORING · HELP · ABOUT · LEARN**, in that order (V0.10.10a), via `switchPanel()`. On the website: CREATE · HELP · ABOUT · LEARN, opening on CREATE. Off-site it opens on AUTHORING. PERFORM and AUTHORING are off-site only (7.1). CREATE and AUTHORING share `#panelLab` in two modes (7.2). HELP (`#panelHelp`) holds LET'S DO THIS: a section header and two outlined modules of four lines each (`#labLetsDo` > `ul.cr-tips`, 15px Courier New, `#0a0a0a`, 1px `#2a2a2a`, radius 6px). ABOUT carries the description, credits, licenses and technical notes. LEARN is not a panel: the tab calls `openLearn()`, which opens `https://onemanshyo.com/#learn` in a new tab. The tabs are keyboard stops: W A S D and the arrows reach them, Enter opens one (8.14). Switching between CREATE and PERFORM pauses the surface left (`window.__surf`, 8.1).

---

# 11. Leaf Reference: Controls and Keyboard

The full keyboard table is E 10 (Keyboard index); every control's help, with its pointer actions, is E 9 (Message index).

- **Global strip (CREATE, AUTHORING):** TEMPO field · QUANT field · arrangement position, under the GLOBAL header.
- **Global strip (PERFORM):** TEMPO field · QUANT field (Shift+↑ / ↓, scroll; double-click = 1/4) · master PLAY / PAUSE · master position (double-click = 1.1.1) ........ MASTER field (Shift+↑ / ↓ ±1 dB, Shift+← / → ±0.1 dB, scroll; double-click = 0 dB) · DSP (open / close the master compressor / limiter panel).
- **TEMPO field:** Shift+↑ / ↓ ±1 BPM · Shift+← / → ±0.01 BPM · type + Enter · Escape leaves · double-click = the master deck's BPM · W A S D and the plain arrows move on.
- **Music (every deck):** cover (tap = song info on / off, double tap = MP3 / AMU picker) · waveform (click = cue on QUANT, drag = scrub, double tap = MP3 / AMU picker) · a LIBRARY row dragged onto the deck = load it.
- **Drop (the whole app, any tab):** files or folders anywhere = into the LIBRARY; on a one-deck tab with nothing playing the deck also loads the first song and shader by title (4.5).
- **CREATE controls row:** PLAY / PAUSE · CUE · LOOP · KEY LOCK · roll orientation · PLAY NEXT · CONTINUOUS PLAY · SHUFFLE ........ FX. **Music Understanding header (CREATE):** zoom field · SOLO, far right.
- **AUTHORING controls row:** PLAY / PAUSE · CUE · LOOP · KEY LOCK · zoom field · roll orientation ........ SOLO.
- **CUE (every deck):** back to the start of the track; on QUANT while playing (plays on), at once while paused.
- **PERFORM deck:** header (mouse only) KEY LOCK · MASTER (lit = tempo master; click = master by hand) · `</> Code` · Settings (shown while the shader declares settings); row PLAY / PAUSE · CUE · LOOP · zoom field · orientation · position ........ SOLO.
- **Code view (AUTHORING, CREATE, each PERFORM deck):** Apply · Copy · Export (the next version to Downloads, the current settings as its defaults) · the editor. Clicks in it stay off the stage.
- **Settings drawer (every stage):** number encoder drag = value (its range in 150 px, snapped to its step) · double-tap = default; number field: click, then ↑ / ↓ = ± step, or type + Enter · double-click = default · Escape leaves. Colour encoder: tap = colour wheel · drag = hue · double-tap = default; colour field: a hex + Enter · double-click = default.
- **PERFORM panel strip:** EQ · FX · MODE: click or Enter = open / close its drawer · Tab (a drawer open) = into the drawer.
- **FX (PERFORM drawer, CREATE drawer):** knob drag = amount · Shift+↑ / ↓ ±1 % · Shift+← / → ±5 % · click = select · Enter = kill / restore on QUANT · double-click = reset to the default · Tab / Shift+Tab = next / previous; effect box: click, then Shift+arrows = previous / next effect.
- **EQ drawer (PERFORM):** TRIM, EQ and RGB knobs: drag = level · Shift+↑ / ↓ fine · Shift+← / → coarse · click = select · Enter = kill / restore, at once (EQ −26 dB, RGB 0, audio TRIM −15 dB, visual TRIM off) · double-click = 0 dB / ×1.00.
- **MODE drawer (PERFORM):** click or Enter = pick the video mix mode, at once.
- **MIXER header (PERFORM):** ISOLATOR LOW · MID · HIGH: drag = level · Shift+arrows · click = select · Enter = kill / restore (silence) · double-click = 0 dB.
- **DSP panel (PERFORM):** preset box (click, then Shift+↑ / ↓: Off · Gentle · Medium · Aggressive · Limiter) · THRESH · RATIO · OUTPUT knobs (drag, Shift+arrows, double-click = default) · GR bar · DSP again or Escape = close.
- **LIBRARY:** click = select · ↑ / ↓ or W / S select · A / ← = Deck A · D / → = Deck B (CREATE: both = its deck) · Delete = remove · drag onto a deck = load · CREATE: double-click, double tap or Enter = load and play; header ALL · MUSIC · VISUALS · SETS ........ X (clear); sort header: click a heading = sort by it, again = reverse; set row: double-click or Enter = apply / turn off.
- **Visuals header (CREATE) / Visual header (AUTHORING):** `</> Code` · Settings (shown while the shader declares settings) · Pop Out · orientation · REC. Stage: drop or double tap = `.wgsl`.
- **Power light (main app):** tap = retype the header for the session (Enter = keep · Esc = cancel · empty = ONEMANSHYO).
- **Zoom field:** click in, Shift+↑ / ↓ = 0 / 25 / 50 / 75 / 100.
- **Music Understanding (every surface):** chips: click = solo. Bus bars: click = group solo. SOLO clears.
- **Mixer encoders:** drag = level (VID %, AUD dB, in the message bar) · Shift+↑ / ↓ fine · Shift+← / → coarse · click = select · Enter = kill / restore · double-click = the default (VID 0 %, AUD silence), restored. **LINK** (the chain between a deck's two encoders): click or Enter = link / unlink (on at open; moving VID unlinks).
- **Piano roll:** drag = scrub · click = cue to block start (on QUANT while playing; LOOP on = loop it; stopped = pick it) · pinch / ctrl + wheel = zoom.
- **Keyboard:** SPACE = play / pause CREATE's deck on CREATE and AUTHORING, the master PLAY / PAUSE on PERFORM (ignored while typing). Esc no longer closes the song info (V0.9.05a).
- **Keyboard flow (CREATE, PERFORM, AUTHORING)** (8.14): W A S D = arrows = the nearest stop that way · Tab / Shift+Tab = page order · Enter = on / off · Shift+arrows = the selected control's value · Shift+L = into the LIBRARY (CREATE and PERFORM) · Shift+A / Shift+B / Shift+M = into Deck A / Deck B / the mixer (PERFORM) · Escape in a drawer = its lit strip button · Tab from a strip button (a drawer open) = the drawer's first control. Ignored while typing or with Ctrl / Cmd / Alt.
- **Pocket Rave:** see 7.4.

---

# 12. Design System (Human Interface Guidelines)

## 12.1 Philosophy
Vizzie follows the OMS **Human Interface Guidelines** (Dojo, Chippy): a hardware mindset (once you settle and package, it must be right, as with manufacturing physical goods) and things look as good on the inside (CSS, class structure, markup) as on the outside.

## 12.2 What the Design System is
The shared OMS tokens and component language: the `.app` shell, `.header` (gradient ONEMANSHYO brand + app tag + version; the Yobot logo was removed in V0.9.24a), `.tabbar` / `.tab`, `.sec-hdr` dividers, the `.btn` family, the field, the standard line, and the `.message-bar` footer. Exact values and classes live in Y 11.

## 12.3 Buttons
- **One small-button standard:** 11px Courier New, padding 3px 10px, 1px border, radius 4px. SOLO and Pop Out set it; PLAY, CUE, KEY LOCK and MASTER follow it on PERFORM and CREATE.
- **A button hugs its label.** It never stretches to fill a row (`flex:0 0 auto`). A row aligns its buttons; it does not size them.
- **A button never changes size with its state.** PLAY / PAUSE is fixed at the width of its longest word (PAUSE, 5 characters of the mono font) in both states, text centred, so the row never shifts.
- **Toggle** (`.btn.loop`): grey off (`#7a7a7a` on `#3a3a3a`), cyan on (`#00d4ff` border and text, cyan glow). LOOP, KEY LOCK, MASTER, the LIBRARY filters, EQ / FX / MODE, CREATE's FX, DSP. CUE takes the toggle style but is a press, never lit.
- **Strip and mode buttons** (PERFORM's EQ · FX · MODE `.pf-fxbtn`, the video mix modes `.pf-mode`): a smaller form, 22 px high, 10px Courier New, 1px letter spacing, radius 3px; the strip buttons in the toggle colours, the mode buttons `#aaa` on `#1a1a1a` with a 1px `#333` border. Short labels (four or five letters) with the full name in the message bar. Selected from the keyboard: a 2px ring, cyan on the strip buttons, purple on the mode buttons.
- **Code and Settings** (Visual header, PERFORM deck headers): the small-button standard; lit (`.btn.primary`) while their view or drawer is open.
- **SOLO** on the CREATE panel (`.btn.solo`): grey off, Barbie Pink on (`#E0218A`, glow). PERFORM's SOLO uses the toggle style (cyan on); see 12.10.
- **Primary** (`.btn.primary`): cyan (PLAY). While a QUANT start waits, PLAY blinks (`.btn.armed`).
- **MASTER** (PERFORM deck header): the toggle style, lit while the deck is the tempo master; a button since V1.0.30a (pointer cursor; click = master by hand).
- **DSP** (`#pfDspBtn`): the toggle style at master PLAY's size (11px, padding 3px 10px), lit while its panel is open.
- **Icon toggle** (`.bgtoggle`, roll orientation): 26 × 24. The LIBRARY's X (`.pf-libclr`, CLEAR) is one, at the header's far right.
- **LINK** (`.pf-link`, PERFORM mixer): a flat horizontal chain icon between a deck's two encoders, 24 × 16, no border or fill; grey `#4a4a4a` off, `#9a9a9a` on hover, Goblin White `#fff` linked. CREATE's CONTINUOUS PLAY and SHUFFLE are icon toggles lit as LOOP (`.cr-ptog.on`); PLAY NEXT is an icon press styled as PERFORM's orientation button (`.cr-pnext`: cyan on a `#1e4a55` border).
- **Disabled:** opacity 0.4 on PERFORM; CREATE's KEY LOCK 0.35 (12.10).

## 12.4 Fields
**One standard field** (`.pf-gf`) for every data field: TEMPO and QUANT on both tabs, MASTER on PERFORM and the roll zoom fields. 72 × 24 px, 13px Courier New, line height 18px, text centred, cyan `#00d4ff` on `#060606`, 1px `#333` border, radius 4px. Hover = border `#4a4a4a`; focus = cyan border and glow. No label, no − / + buttons, no unit text beside it: the hover help says what it is and its keys. Click in or reach it from the keyboard, then Shift+arrows (8.14).

**Position box** (`#labRecTime`, `.pf-pos`): 11px Courier New 600, `#888`, 1px `#333` border, radius 4px, fixed width (8 characters + padding), so it never moves. Barbie Pink while REC records.

**Value box** under a knob (FX effect box `.pf-fxsel`, EQ / RGB value `.pf-eqval`, Settings value `.set-val`): 10px Courier New (9px in the FX drawer's columns), 1px border, radius 3px, in the knob's domain colour (cyan text on a `#2c5560` border; visual: Purple People Eater on `rgba(178,77,255,0.35)`), spanning its column. A Settings value box is also a field: click, then type.

## 12.5 Spacing
**One gap between neighbouring controls everywhere: 8 px** (buttons, fields, toggles, mixer mode chips), set by the row's or strip's `gap`, never by per-control margins. A control pushed to the end of a row (SOLO) uses `margin-left:auto`. The Music Understanding grid has its own tighter spacing: lane cells 4 px apart on CREATE and 2 px on PERFORM, bus modules 6 px apart on CREATE.

**Knob modules:** 6 px between modules, 8 px inside each on every side (the FX drawer's columns 4 px at the sides). **PERFORM:** 9 px from the app's frame at each side, 12 px between its three columns (8.6); the drawer's columns 9 px from the strip and the sides (EQ also from the bottom).

## 12.6 Lines and modules
**The standard line:** 1px `#2a2a2a`, radius 6px. Modules (DECK A, MIXER, DECK B), stages, the waveform, the cover, the AMU box and the global strip use it. A module is a line only: no fill (`#0a0a0a` belongs to the inner boxes that had it), 8 px inside so content does not touch the line. Section headers keep `.sec-hdr` (3 × 13 bar, 11px uppercase label, 1px `#262626` rule).

**Knob module** (`.pf-eqcol`): a group of knobs sits in outlined modules, the standard line with the `#0a0a0a` fill (1px `#2a2a2a`, radius 6px), one module per column. Each knob: the 36 px knob, an optional name, the value box under it spanning the module. No A / B on the labels: the column's place names the deck (A left, B right) and the message bar names it in full. Used by the EQ and FX drawers; the Settings rack is a grid of the same knob, name and value box. Exception: the PERFORM mixer's four encoders are 36 px knobs alone, with no outline, label or value under them (8.5). The isolator's three knobs are 20 px, name then knob, on the MIXER header's line, so the header keeps its height (8.5); the DSP panel's three knobs sit in a three-column grid with value boxes (7.3).

## 12.7 Colour semantics

**Key colours.** Wes's own colours: Purple People Eater `#B24DFF`, Barbie Pink `#E0218A`, Green Slime `#65FF00`, Yellow Man `#FFF000`, Orange Julius `#FFA500` (brand), Goblin White `#FFFFFF` and Red Hots `#FF006E` (key). Where the UI needs a colour these fill the role first. **One shade of each colour in the app:** any purple, pink, green or yellow is the key colour; a dim form is the same colour at lower opacity, never a second shade (V0.10.12a, 12b). Shader WGSL colours are the shader's own and are not part of the design system.

- **Domain colours:** visual Purple People Eater `#B24DFF`, audio cyan `#00d4ff`. A control's arc, value box, active state and selected ring all take its domain colour (V0.11.20e). Visual (purple): mixer VID, FX VFX knobs and their effect boxes, EQ drawer RGB knobs, the Settings rack's knobs and value boxes, the video mix modes (the mode in use and the selected ring), the FX "waiting for QUANT" ring on a VFX knob. Visual TRIM is visual (purple). Audio (cyan): mixer AUD, FX AFX knobs and boxes, EQ HIGH / MID / LOW, audio TRIM, the ISOLATOR and the DSP knobs. The LIBRARY dots carry them too. Neutral app buttons (EQ · FX · MODE) and every other keyboard stop take the app's cyan ring when selected from the keyboard (8.14).
- Chrome and section headers cyan `#00d4ff`; authoring sections Orange Julius `#ffa500`.
- Messages: info cyan `#00d4ff`, state Orange Julius `#ffa500`, error Red Hots `#ff006e`. The DSP panel's GR bar is Orange Julius too (Dojo's). Red Hots also: the danger button (`.btn.mag`), GPU errors on a stage, the ONEMANSHYO gradient (cyan to Red Hots) and Pocket Rave's stage border while playing.
- Active and recording: Barbie Pink `#E0218A` (SOLO on the CREATE panel, the roll and waveform playheads, all of REC).
- Picked or rendered chip on the roll: Yellow Man; LIBRARY entry loaded on a deck: Yellow Man tint.
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
| Double-click | Default, restored (mixer VID 0 %, AUD silence; ISOLATOR 0 dB; FX the effect's default; EQ and audio TRIM 0 dB; RGB and visual TRIM ×1.00) | orange value |
| Tab / Shift+Tab | Next / previous control | the ring |

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
| Double-click | Default (TEMPO = master deck's BPM; QUANT = 1/4; MASTER = 0 dB; master position = 1.1.1) |
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

**Piano roll:** drag = scrub · click a block = cue to its start · pinch / ctrl + wheel = zoom.

**FX effect box:** click, then the arrows = previous / next effect (a new effect starts at its neutral value).

**Video mix mode buttons:** click or Enter = pick, at once; the mode in use purple.

**LINK:** click or Enter = link / unlink; linked, VID follows AUD after the pick-up; moving VID unlinks.

**Keyboard** (8.14): W A S D = arrows = the nearest stop that way, across the whole UI; Tab in page order; Enter = on / off; Shift+arrows = the value; Tab from a strip button enters the open drawer; Escape leaves a drawer to its lit button; Shift+L, and on PERFORM Shift+A / Shift+B / Shift+M, jump to a section.

**Drop zone:** one, the whole window on every tab (`appDrop`): "Drop files" and the types one per line (`dropHint`); files and folders. A LIBRARY row over a deck: "Drop to load".

**LIBRARY list:** click = select · double-click, double tap or Enter = load and play (CREATE) · drag onto a deck = load · click a sort heading = sort by it, again = reverse.

A value changes only on the selected field, knob, box or list (Shift+arrows); the page-wide keys are SPACE (CREATE and AUTHORING: CREATE's deck; PERFORM: master PLAY), the keyboard flow's W A S D, arrows, Tab and Enter (8.14), Shift+L on CREATE and PERFORM, and Shift+A / Shift+B / Shift+M on PERFORM.

## 12.9 The module hierarchy
**section → bus → lane cell → chip** (`.amu-mod` → `.amu-cell` → `.lab-lane`), on every surface since V0.11.10a (`buildLanes` can still add `.amu-knob` encoders; no surface does). The piano roll sits in its own module perimeter aligned with the bus modules above. PERFORM: **tab → global strip + DECK A | MIXER column | DECK B → deck view rows** (8.2); the MIXER column → MIXER (its header carries the isolator), panel strip, LIBRARY modules, the drawer over the LIBRARY (8.6, 8.7); the global strip → the DSP panel over Deck B's top (7.3) → the drawer's knob modules (`.pf-eqcol`). CREATE: **tab → GLOBAL + MUSIC column | VISUALS stage → Music Understanding**; the MUSIC column → music row, controls row, LIBRARY module, the FX drawer over the LIBRARY (7.2, 7.6). Module per function.

## 12.10 Known design debt
Where the build does not follow the standard.
- The small-button standard is applied per container (`.pf-trans .btn`, `#labTransportHold > .btn`, `.pf-sm`, inline styles in the Visual header), not by one class; the base `.btn` still declares 12px / padding 6px 12px.
- Disabled opacity differs: 0.4 on PERFORM buttons, 0.35 on CREATE's KEY LOCK.
- SOLO lights pink on CREATE (`.btn.solo`) and cyan on PERFORM (`.btn.loop`): two looks for one function.
- The Dojo button spec (34 px high, 600 weight, uppercase, 0.5 letter spacing, no border) and Vizzie's small button differ; Vizzie's is the one in use.
- Some code comments describe earlier layouts (CREATE "render" mode stacking PLAY / LOOP, PERFORM placeholders, CREATE's LIBRARY as a drawer opened by a LIBRARY button, "CREATE PUBLIC", the drop zone's "an .m3u8 lights QUEUE", the control strip's "the CUE placeholder only where decks are mixed", PERFORM's `bindDrop` call as "the whole deck is the drop zone"); `MODES.idle` and `IDLE_MSG` are set but no longer shown (idle = empty bar).
- Left from QUEUE: `LIB.queue`, `LIB.queueOn`, `queueUI()` and `queueMsg()` remain, and `queueResolve()` keeps its QUEUE fallback; nothing sets `LIB.queue` since QUEUE was removed (V1.0.03a).
- PERFORM's Code Apply keeps a branch for `d===DK` (CREATE's renderer), unreachable since V1.0.30i.
- The mode key for CREATE is still `public` in `MODES` and `mode()`; the word PUBLIC is gone from the UI.
- HELP's line "Press LIBRARY to see more music and visuals" names a button CREATE no longer has (the LIBRARY is always open since V0.10.09a); the wording is Wes's, kept as is.
- The Settings rack's knobs do not follow the one knob behaviour (12.11): no Enter kill, no arrows, not reached by Tab or W A S D (`tabindex="-1"`); they keep drag and double-tap (V10's model), and their value boxes take the keys.
- The mixer encoders still build a value box each (`.pf-encs span.pf-eqval.pf-fxsel`), hidden by CSS; their CSS comments still describe the outlined modules and value boxes of V0.11.19a to 21d.
- Left from the placeholders: the dashed `.pf-fxbtn.ph` rule (EQ before V0.11.13a), the cyan `.pf-modes .pf-on` rule (overridden by the purple `.pf-mode.pf-on`).
- The compact authoring CSS still sizes `.amu-knob` encoders that are no longer built.

## 12.11 Control rules
Settled in V0.11.13a to 20e and written down as design system rules (BLOG0188 Design system: control colours, modules, values, keys), for every surface:
1. **Domain colour.** Visual = Purple People Eater `#B24DFF`, audio = cyan `#00d4ff`. A control's arc, value box, active state and selected ring all take its domain colour: VID, VFX, RGB, shader settings and the video mix modes purple; AUD, AFX and the EQ bands cyan. Neutral app buttons (EQ · FX · MODE) take a cyan ring (12.7).
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
