# OMS Vizzie app [Beta V1.1.0] System Reference

**Run date:** 2026-11-09  
**Current Unix Epoch:** 1794244147  
**Document purpose:** Machine-readable index for an AI or developer picking up the single-file codebase. Names below are the actual identifiers in the HTML's inline script and markup.  
**Filename:** OMS_Vizzie_Beta_V1_1_0_Y_ClaudeProject_SystemReference.md  

## About this document

Vizzie Beta V1.1.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## CONTENTS

**1** Overview  
&emsp;1.1 App identity  
&emsp;1.2 Systems index  
**2** Cortex and the Critical Stack  
&emsp;2.1 Master music clock (Cortex)  
&emsp;2.2 Uniform contract: slot table (critical)  
&emsp;2.3 WGSL runtime (critical)  
&emsp;2.4 Message System (Cortex)  
**3** Node: Deck Audio, Tempo, Key Lock  
**4** Node: Deck Controls  
**5** Node: Song Info, Audio Loading, Waveform  
**6** Node: Viewer Surfaces  
**7** Node: Surfaces and Modes  
**8** Node: PERFORM  
**9** Node: Authoring  
**10** Node: Tabs and DOM  
**11** Design System values  
&emsp;11.1 Classes  
&emsp;11.2 Buttons  
&emsp;11.3 Fields and boxes  
&emsp;11.4 Spacing and rows  
&emsp;11.5 Lines and modules  
&emsp;11.6 Colours  

---

# 1. Overview

## 1.1 App identity

| Key | Value |
|-----|-------|
| Product name | Vizzie (V-I-Z-Z-I-E) |
| App file | `OMS_Vizzie_Beta_V1_1_0.html` (single self-contained HTML; also the shader authoring template) |
| Renderer | WebGPU / WGSL only (Canvas-2D = UI chrome and authoring overlay only) → C 2.3 |
| Audio | Web Audio deck engine, KEY LOCK AudioWorklet; every deck into one master bus (`masterIn(ctx)`: ISOLATOR → MASTER → DSP compressor) → C 3 |
| Decks | `DK` (CREATE / AUTHORING / Pocket Rave, `perf=false`); `DA`, `DB` (PERFORM Deck A / Deck B, `perf=true`); `DECKS=[DK,DA,DB]` |
| Data | embedded AMU sidecar (`const AMU={…}`) → C 2.1.5 |
| Clock of record | `MASTER` (master music clock) and each deck's `d.beat`, beats → C 2.1 |
| Uniform contract | V0.5.0A: `@group(0)` binding 0 AMU block 9 × vec4 / 36 floats / 144 bytes (slot 13 = beats); binding 1 settings block 16 × vec4 / 64 floats / 256 bytes, one per deck → C 2.2 |
| Tabs | CREATE · PERFORM (off-site only) · AUTHORING (off-site only) · HELP · ABOUT · LEARN → C 10 |
| Site | vizzie.onemanshyo.com |
| License | GPL-3.0 (software); embedded assets separately reserved |

## 1.2 Systems index

| # | System | Tag | Tier | Governance scope |
|---|--------|-----|------|------------------|
| 1 | **Master music clock** | `MUSIC_CLOCK` | **CORTEX** | `MASTER`, `makeDeck` / `warpMap`, `DECKS` / `DK` / `DA` / `DB`, `surfDecks()`, `hb()`, `chrome()`, `seekTo()`, `readAMU()`, `tempoMaster` / `masterTick()` / `setMasterByHand()` / `tempoOnLoad()`, `quantTick()` |
| 2 | Uniform contract | `UNIFORM_CONTRACT` | critical | `pack()`, `d.gate()` / `d.gateOf()`, slot table; settings block `SET_VEC4`, `SET_BYTES`, `deckSettings()`, the `// @setting` declaration (`readSettings()`, `settingsFrom()`), `contractLayout()` |
| 3 | WGSL runtime | `WGSL_RUNTIME` | critical | `main()`, `build()`, per-frame draw, `window.__placeGpu`, `window.__deckGpu`, `window.__outGpu` |
| 4 | Shader | `SHADER` | rides on 3 | `WGSL` (default scene) or any loaded shader |
| 5 | **Message System** | `MESSAGE_SYSTEM` | **CORTEX** | `showMessage()`, `#messageBar`, `HELP`, `bindHelp()` |
| | Design System | `DESIGN_SYSTEM`, `HIG` | rules | tokens, classes, colour semantics, interaction matrix (C 12) |

Dependency order (bottom-up): master music clock → uniform contract → WGSL runtime → shader.

---

# 2. Cortex and the Critical Stack

## 2.1 Master music clock (Cortex)

See C 2.1, C 3.3, C 8.3.

<!-- @tags: MUSIC_CLOCK -->
- `AMU`: embedded sidecar. Keys: `len`, `bpm`, `beats`, `bars` (ascending s), `sec` / `seg` / `phr` (`[start,end]`), `key` (`[start,end,mode,tonic]`), `pace` (`[start,end,value]`), `mom` (`{t0,dt,v}` LUFS), `act.drum|bass|vocal|other` (`{t0,dt,v}`).
- `TRACK` (title), `BPM`, `SONG` (`AMU.len`).
- `MASTER`: `beat`, `tempo` (master BPM), `advance(dt)` (`beat += dt*tempo/60`, returns the beats moved).
- `warpMap(beats)` → `{timeToBeat, beatToTime, beatLen}`: AMU beat times smoothed by a line fit over ±8 beats.
- `makeDeck(id,amu)` → deck `d`: `id`, `amu`, `beat`, getter / setter `t`, `timeToBeat`, `beatToTime`, `beatLen`, `lanes`, `knob`, `solo` (`makeSolo()`), `playing`, `loop` (LOOP button), `loopSpan` (null = whole track, or a chip's `{li,start,end}`), `pick` (a chip picked while stopped, `{start,end}`), `armed`, `keyLock` (default **true**), `pend` (a QUANT start, cue or song switch waiting: `{at, run(over), sw}`; `sw:true` = a song switch, `deckSwitch`), `audio`, `peaks`, `setTrack(amu)`, `len()`, `ratio()`, `gate(id)`, `gateOf(i)`. Set later: `perf` (false on `DK`, true on `DA` / `DB`: the deck's surface), `_sw` (song-switch token: bumped by each `deckSwitch` and by a cancelled switch; a stale load is dropped), `shPend` (a shader load waiting for QUANT, `{at, run}`, `loadDeckShader`), `name`, `info0`, `tags`, `canStretch`, `outGain` (VID, opens 0), `audGain` (AUD, opens 0), `mixK` (`{audGain, outGain}`, mixer kills: true = that encoder at 0, its level kept), `link` (PERFORM decks: `{on, caught, off, ui}`, LINK, §8), `wgsl`, `wgslVer` (bumped on each new source), `shaderName` (the loaded shader's name without `.wgsl`; the exported version after Export), `coverURL` (a dropped cover), `settings` (`Float32Array(64)`, the settings block, `deckSettings(d)`), `setDecl` (`{src, list}`, the shader's settings declaration), `fx` (FX slots, `fxInit(d)`: `DK` (CREATE), `DA`, `DB` (PERFORM), each its own), and from `fxInit(d)`: `eq` (`[low, mid, high, trim]` dB, 0), `eqK` (`[false,false,false,false]`, EQ kills), `rgb` (`[r, g, b, trim]` gains, 1), `rgbK` (`[false,false,false,false]`, RGB kills); index `[3]` = TRIM.
- `DECKS`: `[makeDeck('A',AMU)]` = `[DK]`; PERFORM's block pushes `DA` and `DB` → `[DK, DA, DB]`. `DK` (CREATE / AUTHORING / Pocket Rave deck, `DK.perf=false`), `DA` (PERFORM Deck A, `makeDeck('A',AMU)`, `perf=true`), `DB` (PERFORM Deck B, `perf=true`). Split in V1.0.30i (before, CREATE's deck was PERFORM's Deck A).
- `surfDecks()`: `DECKS.filter(d=>!!d.perf===on)`, `on` = `#panelPerform.active` (the open surface's decks).
- `hb()`: heartbeat, `audioCtx.currentTime` once any deck has audio, else `performance.now()/1000`.
- Transport: `togglePlay(d=DK)`, `setPlayUI()`, `seekTo(sec,d=DK)`, `lastW`; SPACE: ignored in INPUT / TEXTAREA; while `#panelPerform` is active → `window.__masterPlay()`, else `togglePlay()` (`DK`). Track end (LOOP off) on `DK` calls `window.__crNext()` (CONTINUOUS PLAY, C 7.6) before the end-of-track message.
- Loop: IIFE `chrome()`: `MASTER.advance` → each playing deck `d.beat +=` → picked-chip render end (`REC.span`) → chip loop wrap (`d.loop && d.loopSpan`) → track end (LOOP on = wrap to 0) / `steerDeck(d)` → `quantTick()` → master position (`window.__mpB`, `window.__mpT`) → `masterTick()` → `fitStage()` → readout `#labMsg`, hover lane message, `#labRecTime` (`arrPos`), CREATE info line, `paintLanes` (AUTHORING only), `deckButtonsUI`, `labWave.draw()`, `drawRoll()` → `window.__libTick()` → `window.__fxTick()` → `window.__perfDraw()`.
- Tempo master: `tempoMaster` (a deck; starts `DK`); `masterPin` (a deck picked by hand, or null), `masterSig` (per `surfDecks()` deck: playing bit + AUD-up bit; a change clears `masterPin`). `masterTick()` (over `surfDecks()`; `up(d)` = `d.audGain>0` and not `d.mixK.audGain`): pinned = no change; decks playing: the master keeps it while it plays (on PERFORM: and is up), else a playing deck that is up (PERFORM), else the first playing deck; nothing playing on PERFORM: a master that is down hands over to a deck that is up. `setMasterByHand(d)` (`tempoMaster=d`, `masterPin=d`; PERFORM `.pf-master` click / Enter). `tempoOnLoad(d)`: a load sets the tempo only when no other deck of the same surface (`perf`) plays and `d===DK` or `d===tempoMaster` (used by `loadAMUFromFile`, `deckSwitch`). The tempo never changes on a handover.
- Surface switch: `window.__surf()` (called from `switchPanel`): CREATE ↔ PERFORM pauses the surface left (its decks' `pend` cleared, `togglePlay`), clears `window.__mpHeld`; to PERFORM `tempoMaster` = PERFORM's last master (`pfM`, default `DA`), to CREATE `tempoMaster=DK`; `masterPin=null`, `tempoUI()`, `libRender()`.
- QUANT: `QUANT_STEPS` (`[{n,b}]`: None 0, 1/4 1, 1/2 2, 1 Bar 4, 2 Bars 8, 4 Bars 16, 8 Bars 32 beats), `QUANT_DEF` (1 = 1/4), `quantIdx`, `QCYCLE` (32), `mixOn()`, `othersPlaying(d)` (another playing deck of the same surface: `!!x.perf===!!d.perf`), `mixed(d)`, `deckBar0(d)`, `deckPos(d,b,q)`, `onStep(d,b,q)`, `nextMaster(q,ph)`, `deckPlayPress(d)` (waits when `othersPlaying(d)`; with `d.pend` set: cancels it, a song switch (`pend.sw`) bumps `d._sw`, 'Switch cancelled · the song plays on' / 'Start cancelled'), `deckCue(d,sec,landed)` (waits when the deck plays and QUANT is not None; returns true when it waits), `quantTick()` (fires due `d.pend` (`run(over)`), then due `d.shPend` (`run()`), then a lone playing deck leads the master grid). `bindQuantField(qv)`, `QUANT_FIELDS` (every QUANT field, one value): `#labQuantVal` (CREATE), `#pfQuantVal` (PERFORM).
- Loop and pick: `amuSpan(li,tc,d)` (a chip's span; ticks = to the next tick), `pickOn(d)` (pick && stopped && playhead on its start).
- AMU reader: `readAMU(d,t)` → `{name,bar,beatIdx,beatPhase,barPhase,secP,segP,phrP,secI,phrI,key,tonic,keyIndex,lufs,pace,drum,bass,vocal,other}`; helpers `at()`, `span()`, `sample()`, `phaseIn()`.
- `REC` `{on, stop, span}`: the render state; `span` = a picked chip rendered in one pass; the track end calls `REC.stop()` when LOOP is off.
<!-- @/tags -->

## 2.2 Uniform contract: slot table (critical)

See C 2.2. Contract V0.5.0A (V0.11.02a): binding 0 unchanged from V0.4.0D; binding 1 new.

<!-- @tags: UNIFORM_CONTRACT -->
| Group / binding | WGSL | Size | Written by |
|---|---|---|---|
| `@group(0) @binding(0)` | `var<uniform> u: U;` (the AMU block, slots below) | 9 × vec4 / 36 floats / 144 bytes | `pack(dk,a,w,h)`, every frame, per deck |
| `@group(0) @binding(1)` | `var<uniform> settings: array<vec4<f32>, 16>;` (the shader's own values) | 16 × vec4 / 64 floats / 256 bytes (`SET_VEC4` 16, `SET_BYTES`) | `deckSettings(d)`, every frame, per deck |
| `@group(3) @binding(1 / 2 / 3)` | authoring preview only: `partMask`, `gprobe`, `cm` | | `AUTH_GPU` (9); never in the shipped `.wgsl` |

Binding 0 slots:

| Slot | Name | Namespace | Value |
|---:|---|---|---|
| 0 to 4 | gate beat, bar, section, segment, phrase | vizzie | solo × knob 0..1 |
| 5 | | reserved | 0 (was break gate) |
| 6 to 8 | gate key, pace, loudness | vizzie | solo × knob |
| 9 to 12 | gate drum, bass, vocal, other | vizzie | solo × knob |
| 13 | time | vizzie | **the deck's cumulative beats** (beat 0 = its track's first AMU beat), on the master clock |
| 14 | beatPhase | vizzie | 0..1 |
| 15 | | reserved | 0 (was barPulse) |
| 16 | barPhase | vizzie | 0..1 |
| 17 / 18 / 19 | sectionProgress / segmentProgress / phraseProgress | vizzie | 0..1 |
| 20 / 21 | sectionIndex / phraseIndex | vizzie | int |
| 22 | | reserved | 0 (was break) |
| 23 | mode | amu | 0 major / 1 minor |
| 24 | momentary | amu | LUFS, raw |
| 25 | pace | amu | raw |
| 26 to 29 | drum / bass / vocal / other activity | amu | raw 0..1 |
| 30 | tonic | amu | 0 to 11 |
| 31 | keyIndex | vizzie | index of current key range |
| 32 to 33 | resolution x, y | renderer | px |
| 34 to 35 | | reserved | |

- `pack(dk,a,w,h)` builds all 36 floats; CREATE calls it each frame as `pack(DK,readAMU(DK,DK.t),canvas.width,canvas.height)`; each PERFORM deck packs its own deck. Gates: `dk.gateOf(i)` (every lane knob at 1 since V0.11.10a, so a gate = solo state); slot 13: `dk.beat`.
- Settings block: `deckSettings(d)` → `d.settings` (`Float32Array(SET_VEC4*4)`, zero until written); written each frame to `sbuf` (CREATE `main()` and `makeDeckGpu`).
- Declaration (contract): `// @setting NAME settings[N].c min max step default | help` (number: N 0 to 15, c one of x y z w) and `// @setting NAME settings[N].xyz color r g b | help` (colour: `.xyz` or `.yzw`, 0 to 1); `SET_RE`.
- `readSettings(src)` → `{list, errs}`; list entry `{name, type:'number', idx, min, max, step, def:[v], help}` or `{name, type:'color', idx, def:[r,g,b], help}` (`idx` = float indices `N*4 + c`); errs `'line N · reason'`.
- `settingsFrom(d,src)`: on a clean compile (CREATE `build`, `makeDeckGpu` build); same `src` = no-op; same name, type and place keeps its value, the rest take defaults, undeclared floats 0; sets `d.setDecl = {src, list}`; calls `SET_ON`; errors → `showMessage(dp(d)+'Settings: …','error')`.
- `SET_ON` (`[fn(d)]`): the Settings drawers' rebuild hooks.
- `settingsBake(src,d)` → `{src, n}`: each `// @setting` default replaced by the deck's value (by name; unchanged numbers kept as written, `Math.fround` compare); `n` = lines changed.
- `shaderNextName(d)`: `d.shaderName` `_V##` + 1 (digits kept) or `_V01` (no name: `OMS_Vizzie_Shader_V01`).
- `saveShader(d,src)` → `{src, name}`: downloads `settingsBake(src,d).src` as `NAME.wgsl`; sets `d.shaderName`; when `src` is `d.setDecl.src` also the defaults (`s.def`), `d.setDecl.src`, `d.wgsl`, `SET_ON`; updates `#labCode` / `.pf-codeta` showing `src`; message 'Exported NAME.wgsl to Downloads'.
- `contractLayout(device)`: the explicit group 0 bind group layout, bindings 0 and 1 (`uniform`, vertex + fragment), cached as `device.__vzL0`.
<!-- @/tags -->

## 2.3 WGSL runtime (critical)

See C 2.3.

<!-- @tags: WGSL_RUNTIME -->
- `main()`: adapter, device, `webgpu` context on `canvas` (`#labGpu`), 144-byte uniform buffer `ubuf`, settings buffer `sbuf` (`SET_BYTES`), `AUTH_GPU.init(device)`, `build(WGSL)`, then the `frame()` rAF loop (write `ubuf` and `sbuf` (`deckSettings(DK)`), `AUTH_GPU.write`, one pass: `setBindGroup(0,bind)`, then `bindP` as groups 1 to 3 when set, `draw(6)`; `AUTH_GPU.copy` / `read`, `drawOverlay(canvas)`). `bind`: group 0 on `contractLayout(device)` (bindings 0 `ubuf`, 1 `sbuf`); `bindP`: the authoring preview's bind groups 1 to 3 (1 and 2 empty, 3 `AUTH_GPU.entries()`) or null. With `DK`'s FX live on CREATE and a live VFX slot (`window.__fxLiveDK()`, `vfxLive(DK)`), the pass draws into `ctex`, `vfxRun(device,PG,cvst,enc,ctex,DK,w,h)` runs the visual FX and `PG.blit` puts the result on the canvas.
- `build(src)`: `AUTH_GPU.patch(src)` → compile → `getCompilationInfo()` → if clean: `settingsFrom(DK,src)` (the source as written), pipeline on `contractLayout` (+ group 3 layout when the preview has objects) + bind groups swapped in, `DK.wgsl`, `DK.wgslVer`; exposed as `window.__applyWGSL` (resolves true / false). Errors: `note(t)` → `#labGpuMsg`.
- `WGSL`: the default scene, a complete shader. Full shaders only.
- `window.__placeGpu()`: moves `#labGpu`, `#labOverlay`, `#labGpuMsg` between `#labStage` and `#prPlay` (`prActive()`).
- PERFORM: `window.__deckGpu(cv,msg)` → `makeDeckGpu(device,format,cv,msg)` (a deck's own shader into its own texture, shown on its stage; `ubuf` + `sbuf` on `contractLayout`, `settingsFrom(d,src)` on a clean build; `.draw(d)`, `.tex`; visual FX then the deck's RGB through the shared `vfxRun(…,true)`, state `vfxState(device)`); `window.__outGpu(cv)` → `makeOutGpu(device,format,cv)` (`.draw(texA,texB,ga,gb,mode)`: `PERF_MIX`, uniform `M {ga, gb, mode, pad}`, `mode` = `OUT_MODE`).
<!-- @/tags -->

## 2.4 Message System (Cortex)

See C 2.4 (contract, troubleshooting note) and E 9 (every message, as worded).

<!-- @tags: MESSAGE_SYSTEM -->
- `showMessage(text,type,onClick)` → `#messageBar` (`msg-info` / `msg-state` / `msg-error`). An empty `info` returns early while the bar holds a `state` message. `onClick` sets `messageBar.onclick` and a pointer cursor.
- `HELP`: `[selector, text | (el)=>text]` rows: section headers, app header, tabs, CREATE controls, authoring toggles, PERFORM strip, deck parts, mixer. `deckPre(el)` → "Deck A: " / "Deck B: ".
- Component help: `el._msg` (function) or `el.dataset.msg` (text), set by `bindDeckButtons` (`dp(d)` prefix + `STRIP[].msg(d)`), the mixer encoders (live value: VID %, AUD dB), the buses, `fxCell` (knob, its label and effect box), `eqCell` (knob, label, value box), the video mix mode buttons (full mode name and what it does), the panel strip buttons (ending "(W A S D move)"), `settingsDrawer` (each slot's encoder, label and field, the shader's own help after "·"), the PERFORM Code views (`.pf-capply`, `.pf-ccopy`, `.pf-csave`, `.pf-codeta`), the LIBRARY filters (ALL, MUSIC, VISUALS, SETS), CLEAR (`.pf-libclr`), the sort header (`.pf-libhd`), entries (track: `trackLabel(e)`, shader: `shLabel(e)`, + the view's keys) and set rows, CREATE's FX, PLAY NEXT, CONTINUOUS PLAY and SHUFFLE (`dataset.msg`), the mixer LINK buttons (`.pf-link`), `.pf-master`, the master section (isolator knobs, `#pfMasterGain`, `#pfDspBtn`, DSP preset box, knobs, GR bar). Keys win over a resting mouse: `window.__kbdHelp` (once) sets `body.kbd-nav` on any `keydown` (capture) and clears it on `mousemove`; while set, `mouseenter` / `mouseleave` help is skipped (and the LIBRARY's hover tint, 11.6).
- State and error messages are written at their source with `showMessage(text,'state'|'error')`; GPU failures write to the stage (`note(t)` → `#labGpuMsg` / the deck's `.pf-msg`).
- `bindHelp()`: assigns `HELP`, moves every `title` into `dataset.msg` and removes it, binds per element `mouseenter` / `mouseleave` / `focusin`; `window.__bindHelp(root)` binds new elements (CREATE's Visuals header, LIBRARY module and FX drawer when first placed, the Settings drawer's rack on each build, the LIBRARY header after `libListButtons()`, set rows, the DSP strip).
- Lanes: `hoverLane` `{L,d}`, `laneMsg(L,a,d,chip)`: live values each frame from `chrome()`; `chip` = the mini-player form (no knob %, '(click = solo)').
- `IDLE_MSG` / `MODES.*.idle`: set, not shown (idle = empty bar since V0.8.16b).
<!-- @/tags -->

---

# 3. Node: Deck Audio, Tempo, Key Lock

See C 3.

- `audioContext()`, `audioCtx` (one for the app); each deck's engine is `d.audio`. Resume on `pointerdown`, `keydown`, `touchend`, `click` (capture); iOS: `navigator.audioSession.type='playback'`, `audioUnlocked` (one silent 1-sample buffer on the first touchend / click).
- `makeDeckAudio(ctx,buf,canStretch,keyLock)` → `{duration, paused, ended, currentTime (get/set), rate (get/set), keyLock (get/set), play(), pause(), stop(), captureStream(), pre, gain}`; source → `pre` → (TRIM + EQ on PERFORM, then the FX rack, where `FX_LIVE`, 8) → `gain` → `masterIn(ctx)` (was `ctx.destination`).
- Master bus (MASTER SECTION, V1.0.20a): `MSTR` `{iso:[1,1,1] (LOW / MID / HIGH, linear), isoK:[false,false,false], db:0 (MASTER dB, ≤ −60 = off), preset:'limiter', perf:false, n:null, thr:-3, ratio:20, knee:0, att:0.001, rel:0.1, out:0 (dB)}`; `masterIn(ctx)` builds once per context and returns `MSTR.n.inp`: `inp` → ISOLATOR (Linkwitz-Riley 4th order, crossovers 250 Hz and 2500 Hz: LOW = 2 × lowpass 250 + allpass 2500; MID = 2 × highpass 250 → 2 × lowpass 2500; HIGH = 2 × highpass 250 → 2 × highpass 2500; Q 0.7071 allpass, −3.0103 dB low / high pass) → `g[0..2]` → `sum` → `mg` (MASTER gain) → `comp` (DynamicsCompressor) → `out` → `ctx.destination`; `MSTR.n` `{ctx, inp, g, mg, comp, out}`. `masterApply()` (`setTargetAtTime` 0.01): with `MSTR.perf` false every stage neutral (bands 1, MASTER 1, threshold 0, ratio 1, knee 0, out 1); killed band = 0. `setInterval` 200 ms: `MSTR.perf = mixOn()` (PERFORM only). `DSP_PRESETS` (Dojo V5.9.0 code values) `{thr, ratio, knee, att, rel, out}`: off `0,1,0,0.003,0.25,0` · gentle `-12,2,20,0.01,0.3,0` · medium `-18,4,10,0.003,0.25,1.58` · aggressive `-24,8,6,0.001,0.2,2.92` · limiter `-3,20,0,0.001,0.1,0`. UI: §8.
- `steerDeck(d)`: speed = `d.beatLen(d.beat)*MASTER.tempo/60` × (1 ± up to 0.02); gap > 0.25 s → jump.
- TEMPO: `setTempo(bpm,exact)` (rounds to 0.01; clamp `tempoMaster.amu.bpm` × 0.5 … 1.5; every loaded deck's rate; message "TEMPO n BPM"), `d.ratio()`, `tempoUI()` (writes `#labTempoVal`), `bindTempoField(tv)` (keys `ArrowUp` +1, `ArrowDown` −1, `ArrowRight` +0.01, `ArrowLeft` −0.01, Enter, Escape; dblclick = `tempoMaster.amu.bpm`; the global keyboard flow takes plain W A S D / arrows on the field (move on), so its arrow keys are reached with Shift, §10 Keyboard). Fields `#labTempoVal` (CREATE), `#pfTempoVal` (PERFORM). One tempo for the app; a load retempoes only per `tempoOnLoad(d)` (§2.1).
- KEY LOCK: `d.keyLock` (per deck, default true), `keyLockUI(ok)`, `#labKeyLock` (CREATE; strip key `kl`, class `strip-kl`); worklet `vizzie-stretch` from `STRETCH_SRC`, `loadStretch(ctx)` (`data:` URL, blob fallback), `stretchReady`; `findOnsets(buf)`; `d.canStretch === false` = disabled.

---

# 4. Node: Deck Controls

See C 4.

- `STRIP`: `[{k:'play',label:'PLAY',cls:'btn primary',msg}, {k:'cue',label:'CUE',cls:'btn loop',msg}, {k:'loop',label:'LOOP',cls:'btn loop',msg}, {k:'kl',label:'KEY LOCK',cls:'btn loop',msg}]` (CUE V1.0.30h; items may carry `show(ctx)` / `ph`, none do). `buildStrip(holder,{ids,ctx,before})` → `{play, cue, loop, kl}` (class `strip-<k>`; `e._it` = the item); `CREATE_STRIP` (ids `labPlay`, `labLoop`, `labKeyLock`; CUE has no id, `.strip-cue`; `ctx:{mix:false}`, before `#labZoomTxt`); `CREATE_BTNS` (strip + `#labSolo`); PERFORM: `buildStrip(.pf-trans,{ctx:{mix:true}, before:.pf-ztxt})` per deck.
- `bindDeckButtons(d,b)` (PLAY → `deckPlayPress`; CUE → `deckCue(d,0,()=>{ d.loopSpan=null; })`, `d.armed=null`, message 'CUE · the start' (+ ' · QUANT n' when it waits); LOOP toggles `d.loop` (off releases the chip loop); KEY LOCK; SOLO clears), `deckButtonsUI(d,b)` (PLAY / PAUSE text, `.armed`, `.on`, KEY LOCK `disabled`), `dp(d)` (message prefix).
- Lanes: `LANES[]` 12 descriptors `{id,grp,label,col,kind,slot,src}`; ids `beats,bars,sections,segments,phrases,key,pace,loudness,ia:drum,ia:bass,ia:vocal,ia:other`; kinds `ticks|blocks|keyspan|paceStep|curve|stem`; helpers `series()`, `blocks()`. `GRP[]` (six buses + colours); every lane's `col` is its bus colour, beat `#ffffff`.
- `buildLanes(d,box,{buses,labels,chips,only})` (`only`: lane indices to build, default all; Pocket Rave) → cells (`.amu-cell` > `.lab-lane` chip + `.amu-knob` > canvas 88 × 88; `chips` = chip only, no knob, cell `kctx` null); `LANE_SHORT` (short chip labels: beat, bar, sect, seg, phr, key, pace, loud, drum, bass, voc, oth); every call passes `chips:true`: `CREATE_LANES` (`#labAMU`, AUTHORING, `{buses:true,chips:true,labels:LANE_SHORT}`, V0.11.10a), `MINI.lanes` (CREATE `#labMini`), each PERFORM deck's `v.lanes`, Pocket Rave `#prLanes` (`only`); `paintLanes(d,cells)` (`.key` soloed, `.dim` muted; knob arcs only on knob cells, none built). Keyboard stops (V1.0.28a): a chip (with `chips`) `tabIndex 0`, `chip._enter` = `d.solo.toggleLane(L.id)`; a bus bar `tabIndex 0`, `_enter` = `d.solo.toggleGroup(G.id)`; a lane knob canvas (knob cells) `tabIndex 0`, class `amu-kcv`, `_enter` = solo, keydown ↑ → / ↓ ← ±0.05 of `d.knob[L.id]`, `0` = 1.0, message 'Deck X: LABEL n%'.
- `makeSolo()` → `d.solo`: `on(id)`, `muted(id)`, `anyOn()`, `toggleLane(id)`, `toggleGroup(grp)`, `isLaneKey(id)`, `clear()`.
- Piano roll: `deckRoll(cv,d,{base,step,horiz,hh,ui:{txt,field,orient},square,vh,active,only,wt})` → `R` `{zoom, horiz, maxZoom(), win(), view(t)→{b0,WB,t0,t1,only,wt}, step(), zoomTo(z), fit(), draw(t), syncUI()}` (`active` = which of two rolls owns the shared zoom field and orientation button; `hh` = the fixed horizontal height, else square; `only` = the lanes drawn (indices into `LANES`, default all); `wt` = relative lane sizes, default equal); `laneGeo(ulen,n,wt)` → `{off, bh}` (each lane's offset and size across the roll); `drawRollOn(cv,g,d,t,hz,RV)` (draws `RV.only` with `laneGeo`; chips outside `only` skipped); `rollInput(cv,d,view,hz)` (drag < 4 px = cue; the lane under the tap from `laneGeo` with `view.only` / `view.wt`). CREATE: `labRoll` (`#labRoll`), `labRollV` (AUTHORING: `horiz:true`, `hh` 120px, vertical `vh` = `MODES` rollH 75px; V0.11.16a), `MINI.roll` (CREATE `#labMini`, base 16 beats, `step:0.25`, `horiz:true`), `ROLL_WIN` (from `MODES`), `ROLL_PH` 0.5, `rollHeight()`, `drawRoll(t)`; zoom field `#labZoomTxt`, orientation `#labRollBtn`. PERFORM: `ROLL_PF` 16, `step:0.25`, `horiz:true`. Pocket Rave: `#prRoll` (`base:()=>16`, `step:0.25`, `horiz:true`, `only:[2,3,4,8,9,10,11]`, `wt:[1,1,1,0.75,0.75,0.75,0.75]`).
- Cues: `amuStart(L,a,tc)`, `amuCue(li,tc,d=DK)` → `deckCue` (LOOP on: sets / releases `d.loopSpan` when it lands; stopped: sets `d.pick`). Looped or picked chip drawn solid cyan; a picked chip being rendered: Yellow Man band `rgba(255,240,0,0.16)`, edge `#FFF000`.
- Drops and pickers: `readDrop(dt)` (File System Access handles → entries → plain files; folders and subfolders; sets `f._rel`), `dropHint(main,types)`. One drop zone (V1.0.01a): IIFE `appDrop()`: one `.drop-hint.app-drop` on `document.body` ('Drop files': MP3, AMU .json, .wgsl, cover image, .m3u8 playlist; `.on` shows it); `window` `dragenter` / `dragover` / `dragleave` / `drop` for `Files`; drop → `readDrop` → playing = PERFORM: any deck plays, else `DK.playing`; not PERFORM and not playing: `deckDrop(fs,DK)` first, then (900 ms) `LIB.filter='all'`, `LIB.set=null`, `libFilterUI()`; then `libImport(fs)` (its summary is the last message); PERFORM or playing: the LIBRARY only. `deckDrop(fs,d)`: tags first (`tagsOf`), then the alphanumeric-first (`ALNUM` on tag title, else file stem) shader at its newest `_V` and song (one with its AMU in the drop first), that song's AMU and cover (same `libKey`; a lone one goes with it); order shader → AMU → audio (`deckFile(f,d,'any','Drop')`), then `setDeckCover`. `bindDrop(el,d)`: a deck as the target of a LIBRARY row drag only (`text/x-vizzie-lib` → `window.__libLoad(id,d)`); `.drop-hint` 'Drop to load', `.drop-on`. `isImage(f)`, `coverSize(f)` (square only), `deckFile(f,d,kinds,verb)`, `pickFile(d,kinds)` (hidden inputs made per deck in `d._pick`), `bindDoubleTap(el,fn,skip)` (300 ms), `bindLoaders(d,wf,stage,skip)`, `bindCover(cover,d,setInfo,isOpen,inside)`.

---

# 5. Node: Song Info, Audio Loading, Waveform

See C 5.

- `loadAudioFromBlob(blob,name,d=DK)` (clears a dropped cover; message 'Loaded `tagLabel(d.tags,name)` · AMU driving the visual'); `autoLoadExample()` (http / https, `./examples/`, only when no `TRACK_MP3` is packed); `isAudio(f)` (audio MIME or extension; `.m3u` / `.m3u8` excluded).
- AMU JSON: `isAMU(f)`, `amuFromSozo(j)`, `loadAMUFromFile(f,d=DK)` (`setTempo` only when `tempoOnLoad(d)`), `checkPair(d)`, `TONICS`, `TONIC_NAMES`; `keyShort(amu)` (the key range with the longest span: `TONIC_NAMES[tonic]` + 'm' unless the mode matches /maj/i; e.g. Em, F#m, C).
- Track names (BLOG0206), one rule: `TAGS` (WeakMap file → promise), `tagsOf(f)` → `{title, artist}` or null (ID3v2 from the first 10 + n bytes, else ID3v1 'TAG' in the last 128 bytes; a stand-in with `_url`: its first 64 KB by `Range`; read once per file); `ALNUM(a,b)` (`localeCompare`, numeric, case-blind); `tagLabel(g,fb)` (title · artist, else `fb` without path and extension); `trackTitle(e)` (`e.title || e.name`), `trackLabel(e)` (title · artist).
- Shader names (BLOG0208): `shMeta(txt)` → `{title, author, type, desc}` (first 60 lines, `// @title|@author|@type|@desc value`, first of each; trailing `, ; :` stripped); `shFallback(n)` (file name without path, `.wgsl`, `OMS_Vizzie_Shader_` (`_` or `#`) and `_V##`); `shNameOf(txt,name)` (`@title`, else `shFallback`); `shTitle(e)`, `shLabel(e)` (title · author — desc), `shVer(e)` (`V` + 2 digits, '' without a version).
- Shader loads: `loadDeckShader(d,txt,name)` (song-start rule: QUANT not None and any deck in `DECKS` playing → `d.shPend={at:nextMaster(q,0), run}`, message 'Deck X: TITLE on the next 1/4'; a second load replaces it; else at once) → `shaderNow(d,txt,name)` (`d.shaderName`; `DK`: `#labCode` + `window.__applyWGSL`, 'Loaded TITLE' / 'WGSL error in TITLE, see stage'; other decks: `d.wgsl`, `d.wgslVer`). Code-view Apply stays immediate.
- Song switch on a playing deck (BLOG0198): `deckSwitch(d,e)` (from `window.__libLoad` when `d.playing`): token `d._sw`; fetch / decode (+ `readID3`, `loadStretch`) and the AMU while the song plays; ready → `run(over)` (stops the old audio, new tags / AMU / audio / peaks / cover, `tempoOnLoad`, starts at the AMU's first bar line `amu.bars[0]` + over); QUANT None or deck stopped: at once; else `d.pend={at:nextMaster(q,0), run, sw:true}`. Messages 'Loading … (switches on QUANT)', '… on the next 1/4', 'Playing …', 'Could not load … · the playing song carries on'.
- `readID3(arrBuf)` (`tags.pic` copied with `slice()` before decoding), `decodeText()`; `applyTagsToInfo(tags)` → `#coverArt`, `#trackName`, `#trackArtist`, `#trackLabel`, `#trackYear`, `#trackCopyright`; cover card `#coverCard`; info `#songInfo`.
- `deckInfo(d)` → `{title, artist}`; `deckCover(d)` (`d.coverURL`, else `TRACK_COVER` on `DK`, else `d.tags.pic`, else `COVER0`); `setDeckCover(d,f)`, `clearDeckCover(d)`.
- `infoLine(box,d)`: fills `.pf-one` × 2 inside `.pf-tick`; `.pf-tick.run` animates (`--dur` = width / 40 s); `box._tickKey` re-measure key. `.pf-tick.run` always on (V0.9.05a). Used for `#songInfo` (both modes) and each PERFORM `.pf-info`. `bindCover`: single tap = toggle, double tap = picker; no outside or Esc close.
- Waveform: `computeLevels(buffer,600)` → `d.peaks`; `waveView(cv,d,hold)` → `{draw(), cache(W,H), key, src}` (cache key = `'p'+peaks.length` | `'env'` | `'a'+amu.len` + `:WxH`; `src` = `d.peaks || d.amu`: a new track repaints every view of the deck, V1.0.30f; click < 4 px = `deckCue`, drag = scrub); `paintWave(cc,cx,d,W,H,hold)`; CREATE `labWave` on `labWf` (`#labWf`) in `#labWfBox`.

---

# 6. Node: Viewer Surfaces

See C 6.

- Code view: `#labCodeBtn`, `#labCodeView`, `#labCode`, `#labApply` ('applied (preview only)' / 'error, see stage'), `#labCopy` ('copied', plain copy), `#labSave` (label Export: `saveShader(DK,ta.value)`, 'exported'), `#labCodeMsg`. PERFORM deck: `.pf-code` (`</> Code`, `.primary` while open) → `.pf-codeview` over `.pf-stage` (z 3; click, dblclick, pointerdown, pointerup stopped) > `.pf-capply`, `.pf-ccopy`, `.pf-csave` (Export), `.pf-cmsg`, `.pf-codeta` (`ta._deck`); Apply: `d===DK` → `window.__applyWGSL`, else (`DA`, `DB`) → `d.wgsl`, `d.wgslVer`; `v.codeSync()` (from `__perfDraw`: refills an open view when `d.wgslVer` changes and the editor has no focus).
- `openPopOut()`, `popWin`: `<video>` mirror of `#labGpu.captureStream(60)`; `#labPopBtn`.
- REC: `startRec()` (from the playhead; picked chip + LOOP off = `REC.span`) / `stopRec()`, `REC`, `#labRecBtn` (`.recording`); `VizzieWGSL_<WxH>_<time>.mp4|webm`.
- Orientation: `ASPECTS` (16:9, 1:1, 9:16), `aspI`, `#labAspectBtn`; `fitStage()` (compact AUTHORING: the stage box height `min(fw*9/16, innerHeight*0.6)` in every orientation, 1:1 and 9:16 centred in it; V1.0.23a).
- Arrangement position: `arrPos(a)` (`padStart(4,' ')` bar . beat . sixteenth); `labPos` = `#labRecTime` (`.recording` while REC); PERFORM `.pf-pos` per deck.

---

# 7. Node: Surfaces and Modes

See C 7.

- Host: `PUBLIC_HOST`, `AUTHOR_MODE`; `authorOn`. Website: `#tabPerform`, `#panelPerform` and `#tabAuthor` removed.
- Compact: `compactMQ` (`(orientation:portrait), (max-height:500px)`), `compactForced`, `isCompact()`, `compactClass()` (html classes `compact`, `compact-forced`).
- Modes: `MODES.authoring` / `MODES.public` (= CREATE) `{autoplay,loop,idle,rollH,rollWin,readout,waveHold,sidecarInfo}` (autoplay and loop false in both), `mode()`, `setMode(on)` (closes `window.__crFx` and `window.__setDrawer`), `visLabel()` (`#labVisTxt` = `Visual : Authoring` / `Music`; `#labModeTxt` = `Global`); html class `author-on`. `switchPanel('author')` → `#panelLab` + `setMode(true)`; `switchPanel('lab')` → `setMode(false)`.
- `LAYOUT` `{render, author, info, mini, muSec, left, fitMu}`: header row = `#labVisTxt.closest('.sec-hdr').parentElement`. `render()` (CREATE): creates `#labLeftCol` (`position:relative`) and moves `#labMusic` (40 px) and `#labTransportHold` into it; a `Visuals` `.sec-hdr` over the stage receives the Visual header's buttons (`vBtns`: Code, Settings, Pop Out, orientation, REC); `#labMuSec` (`Music Understanding` header + `.mu-body` > `#labMini`) inserted after the row; the zoom field then `#labSolo` appended to `#labMuSec .sec-hdr` (`data-home`); `#labMuHdr` hidden. `author()` reverses it: SOLO to the end of `#labTransportHold`, the zoom field before `#labRollBtn`. `soloEl`, `zoomEl`: held references. `fitMu()`: `#labMini` height = `.body` bottom − its top − padding − 12, at least 160 px, minus any overflow; on resize and a ResizeObserver on `#labLeftCol` and `.body`.
- CREATE hidden: `html:not(.author-on) #labRollWrap`, `#labAMU`, `#labMuHdr`.
- CREATE controls row `#labTransportHold`: `#labPlay`, CUE (`.strip-cue`, no id), `#labLoop`, `#labKeyLock`, `#labRollBtn`, `#labNextBtn`, `#labContBtn`, `#labShufBtn`, `#labFxBtn` (`margin-left:auto`). AUTHORING: `#labPlay`, CUE, `#labLoop`, `#labKeyLock`, `#labZoomTxt`, `#labRollBtn`, `#labSolo` (SOLO `margin-left:auto`); `html.author-on #labFxBtn, html.author-on .cr-ptog` hidden.
- CREATE global strip: `#labModeHdr` (GLOBAL) over `.pf-global.cr-global` holding `#labTempoVal`, `#labQuantVal` and `#labRecTime`.
- CREATE LIBRARY, FX and playlist controls (one block, built on open): `#labLibSec` (`.pf-mod.pf-libmod`; `Library` header; `.pf-fxin.cr-libin` > `.pf-list`; no drop zone of its own since V1.0.01a: files go to `appDrop`), `crView = libView(box,{decks:[DK], keys:' (W S or ↑↓ · Enter, A D, ←→ or double-click load · Delete)', help, qhelp})` (`qhelp` passed, not read); `#labFxPanel` (`.pf-fxpanel`, `z-index:6`) > `.pf-fxslide` > `.pf-fxin` > `.cr-fxgrid` (`fxCell(DK,'a'|'v',i,true)`); `place(win)` (row width, row bottom to `#labLeftCol` bottom), `show(which)`, `window.__crFx {show}`; `FX_LIVE` entry `d=>d===DK && !authorOn && !prActive() && #panelLab.active`. Icons `.bgtoggle.mu-ctl.cr-ptog` (`#labContBtn`, `#labShufBtn`, `.on` lit) and `#labNextBtn` (`.cr-pnext`); `CP {cont, shuf}`, `cpUI()`; `window.__crNext(now)` (next row of `crView.rows` after the track on the deck, wrapping; no list on screen: the LIBRARY's tracks sorted by `libCmp`; `now` = PLAY NEXT; without `now` only when `CP.cont`; does nothing in AUTHORING); SHUFFLE: `crView.shuf` (a `Map` id → random key; the deck's track −1), `null` when off.
- Settings drawer (C 7.8): `settingsDrawer(d,btn,anchor,limit,side)` → `{show, close, build, place, isOpen, win}`; `COL` `#B24DFF`; window `.pf-fxpanel.set-win` (z-index 40; the anchor module 41) > `.pf-fxslide` > `.set-pnl` (the rack, `SLOTS` 32, 8 columns) + the colour wheel `PK` (one per drawer, `PK.open`, `PK.close`, `PK.draw`); cells `numCell(s)` / `colorCell(s)` (`.pf-encw` > `.pf-enc` (`tabindex -1`) + `.set-txt` > `.pf-encl` + `.set-val` input), `.set-empty` for unused slots; order: the standard area (`idx` < 16) first, a shader's own from a fresh row; more than `SLOTS`: error 'Settings: N beyond the 32 slots not shown'; `place()`: `side()` set → `.set-left` (sideways, the anchor's height, from the side element's left to 6 px behind the anchor), else down from the anchor's bottom − 6 px at its width, with `limit()` the panel's `maxHeight` to 8 px above the limit's bottom (scrolls); `btn` hidden when the list is empty, `.primary` while open; `SET_ON` → `build()`. The drawer's Export button (`sv`) is built but not placed (Export is in the Code views). CREATE / AUTHORING: `window.__setDrawer = settingsDrawer(DK, #labSetBtn, () => authorOn ? #labFaceBox.parentElement : #labFaceBox, null, () => authorOn ? null : #labLeftCol)`; closed by `setMode` and `setSurface`.
- Metal inserts: `.app::before`, `.app::after` z-index 121 (above `#prSafeTop`, 120).
- Moogerfooger strip: `#prSafeTop` shown on the main app (`html:not(.pr-on) #prSafeTop`, left / right 22 px; `.app` padding-top `calc(env(safe-area-inset-top) + 26px)`); click acts only with `pr-on`, `pr-auto` or `compact` + `author-on` (then `setSurface(false)`).
- Header rename: `#brandTxt` (inside `.brand`), power light `.pr-pwr`: `mainApp()`, `edit()` (`contenteditable`, select all), `done(keep)` (collapse whitespace, 24 characters, empty = `ONEMANSHYO`), keys Enter / Escape, blur = keep, plain-text paste; `pointerdown` `preventDefault` keeps the selection; style `#brandTxt[contenteditable]` (1px dashed cyan outline).
- Pocket Rave: `#pocketRave` (`.pr-expanded`), `prMQ`, `prForced`, `prActive()`, `setSurface(pr,compact)` (html `pr-on`, `pr-auto`; closes `window.__crFx`; leaving lands on AUTHORING), `#prSafeTop`, `#appPrHeader` (compact authoring's header → `setSurface(true)`), `#prTabMusic` / `#prTabAbout` / `#prTabLearn`, `window.prTab(name)`, `#prMusic`, `#prAbout`, `#prPlay`, `#prShaderIn`, `#prCoverCard`, `#prSongInfo`, `#prInfo`, `#prAudioIn`, `#prWf`; `window.__prExpand`, `window.__prFull`; `prChrome()` (~22 fps while visible).
- Pocket Rave normal view (BLOG0199, V1.0.22a to 22h; `#prMusic` scrolls): order `.pra-x.pra-hdr` Visual (`#prSetBtn` Settings, `#prRecBtn` REC) → `#prPlay` (`.pra-visual`; `.asp-sq` / `.asp-vert` from `aspI`) → `.pra-hdr` Music → `#prInfo` (`.pra-mrow`: `#prCoverCard`, `.pra-wf` > `#prWf`, `#prSongInfo`) → `.pra-hdr` Music Understanding → `#prLanes` (`.pra-x.pf-lanes.pra-lanes`, `buildLanes(DK,…,{buses:true,chips:true,labels:LANE_SHORT,only:[2,3,4,8,9,10,11]})`) → `#prRollBox` (`.pra-roll`) > `#prRoll` (`deckRoll(…,DK,…)`, §4) → `#prStatus` (`.pra-x.pra-status`: 'SECTION · bar b.n · BPM BPM · TONIC major|minor', from `readAMU(DK,DK.t)`) → `.pr-ver` → `.pr-bottom` > `.pr-plur`. `.pra-x` and `.pra-roll` collapse with `.pr-expanded`. `prViewTick()` (rAF; skipped when hidden or expanded: `paintLanes`, aspect classes, mirrors `#labRecBtn` class and icon into `#prRecBtn`, status line); `prRollTick()` (rAF; `R.draw(DK.t % DK.amu.len)`). `#prRecBtn` click → `#labRecBtn.click()`. Settings: `window.__prSetDrawer = settingsDrawer(DK, #prSetBtn, () => #prPlay, () => #prMusic, null)`, closed when `.pr-expanded` returns (MutationObserver). Removed from the view: GLOBAL, the transport row, the orientation button (CSS for `.pra-glob`, `.pra-tr`, `#prZoomTxt`, `#prSolo` remains without markup).

---

# 8. Node: PERFORM

See C 8. Built only when `AUTHOR_MODE`; on the website `#tabPerform` and `#panelPerform` are removed.

<!-- @tags: PERFORM -->
- Panel `#panelPerform`; global strip `.pf-global` > `#pfTempoVal` (`.pf-gf`), `#pfQuantVal` (`.pf-gf`, tabindex 0), `#pfMasterPlay` (`.btn.primary`), `#pfMasterPos` (`.pf-pos`), `#pfMasterGain` (`.pf-gf.mono`, tabindex 0, `margin-left:auto`), `#pfDspBtn` (`.btn.loop`) + the DSP window `.pf-fxpanel.pf-dspwin` (strip `position:relative` when static).
- `#panelPerform.active`: margin `0 -9px` (9 px from the app frame; other tabs 18 px).
- Grid `.pf` (columns `minmax(0,1fr) minmax(200px,0.563fr) minmax(0,1fr)`, gap 24 px) of `.pf-col`: `#pfDeckA`, the mixer column `.pf-col.pf-mix` (no line; gap 6 px; margin `0 -12px`, so 12 px to each deck) > `.pf-mod.pf-mixmod` (MIXER) + `.pf-pwrap` (panel strip) + `.pf-fxpanel` (the drawer window, right after the strip in the page order) + `.pf-mod.pf-libmod` (LIBRARY), `#pfDeckB`. The mixer column gets `position:relative` when static (the drawers' frame, `fxPlace`; V1.0.14a).
- Decks: `DA = makeDeck('A',AMU)`, `DB = makeDeck('B',AMU)`; each `wgsl = WGSL`, `wgslVer = 1`, `perf = true`, `name = TRACK`, `info0 = TRACK_INFO`; `DECKS.push(DA,DB)`; `outGain = audGain = 0` (OUT black, speakers silent on open); `PD = [DA, DB]` (PERFORM's decks: master PLAY, `__perfDraw`).
- `deckView(d,root)` → `v` `{d, root, stage, msg, roll, cover, info, btns, lanes, wave, pos, rollV, gpu, lamp, setD, codeSync}`; parts `.sec-hdr` > `.pf-trans` (KEY LOCK, `.pf-master`, `.pf-code`, `.pf-set`), `.pf-stagebox` > `.pf-stage` (+ `.pf-codeview`), `.pf-music` (40 px) > `.pf-cover` + `.pf-wf` > `.pf-info` > `.pf-tick` > `.pf-one` × 2, `.pf-row2` (PLAY, CUE, LOOP, `.pf-ztxt`, `.pf-orient`, `.pf-pos`, `.pf-solo`), `.pf-mu` > `.pf-lanes` (chips) + `.pf-roll`. Short lane labels `SHORT` = `LANE_SHORT`. `views` = `[deckView(DA,#pfDeckA), deckView(DB,#pfDeckB)]`. `v.setD = settingsDrawer(d, .pf-set, () => .pf-stage, () => root)` (down out of the stage, inside the column).
- `fit(v)`: stage width from the column, reserving fixed rows, 6 px gaps, lanes + 12 + 40 px of roll; minimum height 60 px.
- MASTER `.pf-master` (`.btn.loop`, `.on` when `d === tempoMaster`): a button since V1.0.30a: inline `cursor:pointer` (the CSS `.pf-trans .pf-master` still says default), click / `_enter` → `setMasterByHand(v.d)`, message 'Deck X is MASTER (by hand; the next start, stop or AUD up / down hands it back to AUTO)'.
- Deck header controls (KEY LOCK, MASTER, Code, Settings): mouse only on PERFORM: `__perfDraw` sets `tabIndex -1` on `:scope > .sec-hdr` buttons / `[tabindex]` each frame, and `kbdItems` skips `.pf-deck > .sec-hdr` (V1.0.30c).
- QUANT field: ↑ / ↓ and wheel step `quantIdx`; dblclick = `QUANT_DEF`; message "QUANT n".
- Master position: `window.__mpB` (beats since the first PLAY, advanced while any deck plays), dblclick on `#pfMasterPos` = 0 ("Master position 1.1.1").
- Master PLAY: `window.__masterPlay()` (over `PD`); `window.__mpHeld` (the paused decks and the master beat; cleared by a deck's own PLAY and by `__surf`); label from `PD.some(d=>d.playing)` in `__perfDraw`.
- Mixer: `#pfOut` (`.pf-out`), `outGpu`; encoders `.pf-encs` (`position:relative`) > `.pf-encw` > `.pf-enc[data-deck][data-kind]` (A vid, A aud, B aud, B vid; `data-deck` A → `DA`; also `.pf-fxk`, VID `.pf-v`, `tabindex 0`) → `d.outGain` (VID, opens 0) / `d.audGain` (AUD, opens 0); `encs[]` entries `{d, k, ui}`; the markup's `.pf-encl` label is replaced by a value box `.pf-fxsel.pf-eqval` hidden by CSS (the knob alone); value text `val()`: VID `Math.round(v*100)+'%'`, AUD `40*log10(v)` dB (−∞ dB below 0.001); drag full range over 150 px; ↑ / ↓ ±0.01, ← / → ±0.05 (with Shift: plain arrows move, §10 Keyboard); click = focus (select); Enter = kill / restore (`d.mixK[k]`, `.killed`); dblclick (pointer timing, 300 ms) = default `DEF` 0 (VID and AUD; V1.0.15a), restored; `.pf-arc`, `.pf-ptr` SVG. Messages 'Deck A audio · −12.0 dB', 'Deck B in OUT · 50%' (+ ' · killed' / ' · restored'; AUD with LINK on: + ' · LINK: VID n% follows' / ' catching up'; VID after an unlink: + ' · LINK off (VID moved)').
- LINK (BLOG0178, V1.0.29a; on by default V1.0.30g): per PERFORM deck `d.link = {on:true, caught:|audGain − outGain| < 0.005, off, ui()}`; button `.pf-link` (chain SVG 18 × 9) appended to `.pf-encs`, `left` `calc(25% - 1.5px)` (A) / `calc(75% + 1.5px)` (B); `.on` = linked. Click: toggles `on`, recomputes `caught`. In the encoder `set`: AUD moves with `on` → `caught` once AUD crosses VID, then `outGain = audGain` (VID `ui()`); VID moves with `on` → `on=false`, `caught=false`, `off=true`. Message `b._msg()` 'Deck X LINK on|off (click = … · linked: move AUD and VID catches up, then follows · move VID = unlinks)'.
- Deck volume in `__perfDraw`: `mg(d,k)` = 0 when `d.mixK[k]`, else `d[k]`; `vol(DK,1)`; `vol(DA, mg(DA,'audGain')²)`, `vol(DB, mg(DB,'audGain')²)` (audio taper); OUT `outGpu.draw(texA, texB, mg(DA,'outGain'), mg(DB,'outGain'), OUT_MODE)`.
- Master section UI (V1.0.20a): local `mkKnob(o)` (`{name, tag, get, set, toV, fromV, fmt, unity, centre (0.5), box, killed, kill, changed, cls}` → `{w, ui}`; `.pf-encw` > `.pf-enc.pf-fxk` (cyan SVG `KSVG`) + `.pf-encl` (+ `.pf-fxsel.pf-eqval` with `box`); snap to `centre` within 0.004; drag 150 px; ↑ ↓ ±0.01, ← → ±0.05; click = focus, second within 300 ms = `unity` (unkilled); Enter = kill / restore; Escape = blur). ISOLATOR `.pf-iso` (appended to `.pf-mix .pf-mixmod .sec-hdr`): LOW · MID · HIGH (`MSTR.iso[i]`, `MSTR.isoK[i]`; left full kill, centre 0 dB, right +6 dB; `isoV` / `isoG`; text '−∞ dB' / '0 dB' / '±n.n dB'). MASTER `#pfMasterGain` (`MSTR.db` −60 … +6, 0.1 steps; ↑ ↓ ±1 dB, ← → ±0.1 dB, wheel ±1, dblclick 0; Enter / Escape blur; text '−∞ dB' at −60). DSP `#pfDspBtn` toggles `.pf-dspwin.open` (`.on` on the button; `place()`: top = strip height − 1, right −1px, width 280px): `.pf-fxslide.pf-dsps` > `.pf-dsptop` (DSP `.sec-hdr` + preset box `.pf-fxsel.pf-dsppre`, tabindex 0: ↑ ← / ↓ → step `Object.keys(DSP_PRESETS)`; text `MSTR.preset` upper case, CUSTOM after a knob turn) + `.pf-dspknobs` (THRESH −48 … 0 dB, RATIO 1 … 20 :1, OUTPUT −12 … +12 dB; `changed` → 'custom') + `.pf-dspgr` (GR bar `.m` > `.b`, value `.v`; `grTick()` rAF while open: `MSTR.n.comp.reduction`, 0 … 12 dB); Escape in the panel closes it. `setPreset(nm)`. `window.__master {MSTR, setPreset, open}` (tests).
- Surface split: PERFORM's block defines `window.__surf` (§2.1).
- Video mix modes: `OUT_MODE` (0 to 15, session; `let` beside `_perfGpu`); `PERF_MIX` (WGSL, uniform `M {ga, gb, mode, pad}`; 0 MIX, 1 NAM, 2 ADD, 3 SCREEN, 4 MULTIPLY, 5 OVERLAY, 6 DIFFERENCE, 7 LUMA, 8 DARKEN, 9 SOFT LIGHT, 10 EXCLUSION, 11 INV LUMA, 12 SUBTRACT, 13 DODGE, 14 BURN, 15 COLOR); buttons `.pf-modes` > `.pf-mode` × 16 (`tabindex 0`; labels MIX NAM ADD SCRN / MULT OVER DIFF LUMA / DARK SOFT EXCL INVL / SUB DODGE BURN COLOR), the mode in use `.pf-on`; `MODES` (local: `[name, what it does]`); `pick(i)`: click or Enter; message 'Video mix mode NAME: …'.
- Panel strip: `.pf-pwrap` > `.pf-panelrow` (`eqBtn`, `fxBtn`, `modeBtn`: EQ, FX, MODE `.btn.loop.pf-fxbtn`, built by `pBtn`); drawer window `.pf-fxpanel` (`fxWin`, `overflow:hidden`, `.open`; inserted after `fxWrap`) > `.pf-fxslide` (`translateY(-100%)` → 0, 0.26 s) > three `.pf-fxin` panes: `modePan` (`.pf-modes`), `fxPan` (`.pf-eqpan` > `.pf-eqgrid.pf-fxcols` > 4 × `.pf-eqcol`: `fxCell` A v, A a, B a, B v; slots 0, 1), `eqPan` (`.pf-eqpan` > `.pf-eqgrid` > 4 × `.pf-eqcol`: `eqCell` A RGB, A EQ, B EQ, B RGB; indices 3 (TRIM), 2, 1, 0 top to bottom: TRIM · HIGH · MID · LOW / TRIM · BLUE · GREEN · RED); `fxPlace()` (strip width, 6 px under it, to the LIBRARY module's bottom), `fxShow(which)`, `fxOpen` ('eq' | 'fx' | 'mode' | null); Tab on a strip button with a drawer open focuses the drawer's first `.pf-fxk, button.pf-fxsel, .pf-mode`. Help: `dataset.msg` ending "(W A S D move)".
- PERFORM hot keys: `window.__pfKeys(e)` (asked first by the global keyboard flow, §10 Keyboard; false off PERFORM): Shift+M → focus `.pf-encs .pf-enc` (A VID), message 'Mixer: W A S D, arrows or Tab move · Shift+arrows = level · Enter = kill / open · Escape = out of a drawer'; Shift+A / Shift+B → `kbdFirst(#pfDeckA | #pfDeckB)` (the deck's PLAY), message 'Deck X: W A S D or Tab move · Enter = on / off'; Escape with `fxOpen` and focus inside the open pane → its strip button. Plain M and the old mixer-column W A S D grid are retired (V1.0.28a).
- EQ / RGB / TRIM: `fxInit(d)` sets `d.eq` `[0,0,0,0]`, `d.rgb` `[1,1,1,1]`, `d.eqK`, `d.rgbK` `[false,false,false,false]` (`[3]` = TRIM); `fxWire` builds `R.eq` (BiquadFilter `lowshelf` 70, `peaking` 1000 Q 0.7, `highshelf` 13000) chained LOW → MID → HIGH → `R.inp`, and `R.trim` (Gain → `R.eq[0]`); connects `pre` to `R.trim` when `window.__eqOn(d)` (PERFORM shown), else to `R.inp`; `eqApply(d)` (`R.trim` gain `10^(dB/20)` of `d.eq[3]`, −15 dB when `d.eqK[3]`; bands: gain = `d.eq[i]`, −26 when `d.eqK[i]`; `setTargetAtTime` 0.01); `EQ_BANDS` `['LOW','MID','HIGH','TRIM']`, `RGB_CH` `['RED','GREEN','BLUE','TRIM']`; `eqCell(d,i,vis)` → `.pf-encw` > `.pf-enc.pf-fxk` (`.pf-v` when visual) + `.pf-encl` + `.pf-fxsel.pf-eqval` (`.v`); tag 'Deck X EQ NAME' / 'Deck X RGB NAME', index 3: 'Deck X audio TRIM' / 'Deck X visual TRIM'; EQ knob: left −26 dB, centre 0 dB, right +6 dB; audio TRIM: left −15 dB, centre 0 dB, right +15 dB (`0.5 + dB/30`); RGB knob and visual TRIM: left 0, centre 1, right 1.33; both snap to the centre within 0.004 of the turn; drag over 150 px, ↑ / ↓ ±0.01, ← / → ±0.05 of the turn; click = focus; Enter = kill / restore; dblclick = centre, restored; `eqCells` (ui refreshers). RGB pass: `vfxRun(…,rgb)` writes `[14, r, g, b, w, h, …]` (each channel × the visual TRIM `rgb[3]`, 0 when `rgbK[3]`) and runs `PERF_VFX` kind 14 after the VFX slots, only when a gain is off 1; kills as 0.
- FX (shared engine, above PERFORM's block): `fxInit(d)` → `d.fx` `{a:[slot,slot], v:[slot,slot], au, inp, out}` (+ `eq`, the three filters, and `trim`, set by `fxWire`), slot `{name,amt,killed,node,gen}`; `FX_LIVE` (functions `f(d)`: does this deck's rack play; PERFORM's entry `d=>on()&&d.perf`; `fxInit(DA)`, `fxInit(DB)`); `AFX` (Filter `n` 0.5 bipolar, Washout, Dubby, Delay, Reverb, Flanger, Phaser, Bitcrush), `VFX` (RGB Split, Feedback, Glitch, Pixelate, Scanlines, Mirror, Kaleidoscope, VHS, Shake, Tone, Tile, Rotate, Zoom), `AFX_NAMES`, `VFX_NAMES`; `mixer(c,fin,fout,set)`, `echo(c,fixed,dub)`; `fxWire(d)` (`pre` → [TRIM → EQ when `__eqOn`] → `R.inp` → AFX1 → AFX2 → `R.out` → gain where `FX_LIVE`, else `pre` → gain; rewires when `live|eq|slots` changes); `fxDiv()`, `fxBeat()`; `FXQ`, `fxLater(run,armed)`, `fxTick()`; `fxCell(d,dom,i,one)` → `.pf-encw` > `.pf-enc.pf-fxk` (`.pf-v` = visual) + `.pf-encl` (AFX1, AFX2, VFX1, VFX2) + `button.pf-fxsel` (`.v` = visual; `one` = no deck name); knob `pointerup`: a click = focus (select), a second within 300 ms = `reset()` (default amount, unmuted, `s.gen` drops the armed kill); Enter = `kill()` on QUANT (`.armed` while waiting); `fxCells` (ui refreshers); GPU: `PERF_VFX` post pass (kinds 1 to 13 the effects, 14 the RGB gains), `vfxLive(d)`, `vfxState(device)` (`fxA`, `fxB`, `prev`, `vbuf`), `vfxRun(device,PG,st,enc,src,d,cw,ch,rgb)` → final texture (`rgb` = the RGB pass too, PERFORM); `window.__fx` (tests); `window.__fxTick`, `window.__fxLiveDK()`.
- LIBRARY (shared, above PERFORM's block): `LIB` `{sort:{col,dir}, tracks, shaders, filter, set, sel, noAmu, queue, queueOn, views, lists}`: `sort` (default `{col:'title', dir:1}`; `col` title | artist | bpm | key | ver | type; `dir` 1 / −1), `filter` the view (`'all'` | `'audio'` (MUSIC) | `'visual'` (VISUALS) | `'sets'`), `set` the set applied (`'pl:<i>'` or null; kept through MUSIC / VISUALS and loads; cleared by ALL, by CLEAR and by a drop with nothing playing), `sel` the selected row id (`t:<key>` track, `s:<key>` shader, `p:<i>` set row), `lists` the sets `[{name, paths}]` (`plSort`: alphabetical, case-blind, numeric). `queue` / `queueOn` remain but are never set (QUEUE button removed, V1.0.03a); `queueUI()`, `queueMsg()` vestigial.
- Entries: track `{id:'t:'+key, name (file name, pairs and matches), audio, json, rel, bpm, key, cover?, title?, artist?, _meta}` (`bpm` / `key` from the AMU via `f._meta = {bpm, key:keyShort(a)}` on import; `title` / `artist` from `tagsOf`, `libMeta()`); shader `{id:'s:'+key, name, ver, file, title, author, type, desc}` (`shMeta` on import; newest `_V` kept). `libKey()`, `shStem()`.
- Functions: `libImport(files,quiet)` (playlists: name from `#PLAYLIST:` else the file name, `_` → space; same name (case-blind) replaces; `LIB.lists.sort(plSort)`, the set applied before the drop stays applied; set message 'set NAME added · f of t found' / 'N sets added · NAME f/t · …'; then `libRender()`, `libMeta()`), `libMeta()` (background: tags, and lazy website AMU for BPM / key; one `libRender()` when all are in), `libCmp(x,y)` (by `LIB.sort`; a row without the value last; ties by title; bpm / ver numeric, else `ALNUM`), `libRender()` (every view) / `libRenderView(v)` (SETS: one `.pf-libitem.pf-plrow` per set (`.t` name, `.n` found/total, `.dot`; `.on` applied, `.sel`); else the sort header `.pf-libhd` (`.fixed` when a set, QUEUE or SHUFFLE gives the order: no arrow, no sort; columns MUSIC / ALL: TITLE `.t` · ARTIST `.a` · BPM `.b` · KEY `.k`; VISUALS: TITLE · AUTHOR · VER `.b` · TYPE `.y`; arrow ▲ / ▼ on the sorted heading; click = sort, again = reverse) then rows `.pf-libitem` (`.t` title, `.a` artist / author, `.b` BPM or VER, `.k` key or `.y` type, `.dot` cyan track / purple shader)), `onDeck(e)` (over `surfDecks()`), `setApply(id)` (`p:<i>` → apply: `LIB.set`, `filter='audio'`; the applied one again = off), `plUI()` (SETS `.dis` with no sets; `filter='sets'` with none → `'all'`), `libListButtons()` (one SETS button per view, then CLEAR last), `libFilterUI()` (lit: `data-f === LIB.filter`, SETS also while `LIB.set`; calls `plUI()`), `libClear()` (empties tracks, shaders, noAmu, queue, lists; `filter='all'`, `set=null`, `sel=null`; 'Library cleared · the decks keep what they have'), `window.__libLoad(id,d)` (`p:` → `setApply`; a track onto a playing deck → `deckSwitch(d,e)`; else as before; returns a promise; a stand-in MP3 is fetched from `_url`), `window.__libImport`, `window.__libTick` (`libRender()` when any `DECKS` name / shader changes).
- `libView(box,o)` → view `{box, keys, rows, decks, hdr, clr, pl:{b}, oneLoad(id), shuf}` (`o.decks`, `o.keys`, `o.help`; `o.qhelp` passed, not read); list `.pf-lib` (focusable, `touch-action:manipulation`; ↑ ↓ move the selection and show its `_msg`; set row: Enter = `setApply`; one deck: Enter = `v.oneLoad`; ← → load (Deck A / Deck B; one deck: it); Delete / Backspace remove); set rows: double-click (double tap, `box._pTapId` / `box._pTapT`, 400 ms) = `setApply`; one deck: double-click (`box._tapId` / `box._tapT`, 400 ms) = `v.oneLoad(id)` (shader: load; track on a playing deck: switch on QUANT; else load and play from the top); header `.pf-libfrow` > `.pf-libf` ALL · MUSIC · VISUALS (`data-f` all / audio / visual) · SETS (`.pf-libpl`, `data-f` sets) · CLEAR (`.bgtoggle.mu-ctl.pf-libclr`, X icon, far right). PERFORM: `libView(.pf-mix .pf-list, {decks:[DA,DB], keys:' (W S or ↑↓ · A or ← Deck A · D or → Deck B · Delete)'})`. Entry states selected (cyan border), loaded (Yellow Man tint). Drop zone: `appDrop` (§4).
- `libNav(e,cur,key)` (BLOG0207; one code for every LIBRARY; true = handled): in the list, A / D re-dispatch ← / → (load), W / S re-dispatch ↑ / ↓ (synthetic `KeyboardEvent` with `_viz=1`); W on the first row → the header's lit filter (else its first button); S on the last row stays; on the header A / D move along `:scope > button`, S goes down into the list; W on the header: not handled (PERFORM: the flow moves up; CREATE: nothing above).
- Website set: `libWebSet()` (http / https): `./examples/library.json` `{files, playlists:[{name,file}]}`; audio → stand-in `{name, type, _url}`; AMU `.json` → stand-in `{_url, _lazy, text()}`; others fetched; `libImport(fs,true)`; each playlist → `LIB.lists` `{name, paths}` (non-`#` lines only; names come from the MP3 tags); `LIB.lists.sort(plSort)`, `LIB.set = 'pl:0'`, `LIB.filter = 'audio'` when any.
- Sets against the library: `queueResolve(list)` (tail match on `f._rel`, file-name fallback) → `{ids, noAmu, notFound}`; the applied set's message 'Playlist NAME: N found · N no AMU · N not found'.
- `vol(d,v)`: deck gain (`setTargetAtTime` 0.01); `DK` at 1, `DA` / `DB` at `audGain`² (0 when killed).
- `window.__perfDraw()`: per frame while PERFORM is shown: master PLAY label, `fxTick()`, fit, MASTER indicator, `v.codeSync()`, deck GPU draw (shader + VFX + RGB), waveform, cover, position, info line, lanes, buttons, roll; OUT draw (with `OUT_MODE`); TEMPO field value.
<!-- @/tags -->

---

# 9. Node: Authoring

See C 9.

- Per-shader block: `RULES` (R11, R12, R13, then R1 to R10, then R16), `NOTES`, `BUILD`, `TEMPLATE`, `WGSL`, `AMU`, `SPECDOC`, `CHANGELOG`, `RIG`, `PART_PATCHES`, `CRYPTO_PATCHES`, `OV_PRELUDE`, `OV_V`, `OV_H`, `OV_AP`, `OV_FRAME_M`; authoring pack `TRACK_INFO`, `TRACK_MP3`, `TRACK_COVER` (loaded on open via `dataBlob`).
- `AUTH_GPU`: `init(device)`, `patch(src)`, `entries()`, `write(queue)`, `copy(enc)`, `read(rd)`; preview bindings in `@group(3)`: 1 object mask `partMask` (`vec4<u32>`, `partMaskWords()`), 2 overlay probe `gprobe` (storage, `array<f32, 64>`), 3 CRYPTOMATTE `cm` (`cmTable()`).
- R13 (settings) and the standard fourteen (C 9.5): the default scene `WGSL` declares the settings block and 14 `// @setting` lines (SCALE `settings[0].x`, ROTATION `.y`, OFFSET_X `.z`, OFFSET_Y `.w`; SPEED `settings[1].x`, REACT `.y`, HUE `.z`, VALUE `.w`; PIVOT_X `settings[2].x`, PIVOT_Y `.y`, TILE `.z`, TIME_OFFSET `.w`; SATURATION `settings[3].x`, CONTRAST `.y`); WGSL `stdFrame(p0, asp)` (TILE, then rotate / zoom around PIVOT, then OFFSET), `stdHSV(c)` (HUE, SATURATION, VALUE), then CONTRAST around 0.5; the tunnel clock `f(13) * settings[1].x + settings[2].w`, gates × `REACT`. A shader's own settings from `settings[4]`.
- R16 (shader metadata, V1.0.26a / 27a): under line 1 of the `.wgsl`, `// @title`, `// @author` (one or more, comma-separated, the source first), `// @type` (visualizer, asset, scene, story or decal), `// @desc` (one line, optional); version stays in the file name `_V##`; file name `OMS_Vizzie_Shader_<Name>_V##` (underscores, no spaces, `.wgsl` and `.html` alike; `<Name>` = the title in CamelCase); written when the shader is made. Check: @title, @author, @type present (not the default scene's), @type one of the five, @desc one line, the file-name form. Read by `shMeta` (§5). The default scene `WGSL` carries, under its line 1: `// @title Template Default Scene`, `// @author Wes Smith`, `// @type scene`, `// @desc the AMU test tunnel background (every AMU lane) with Yobot Squint`.
- Objects / CRYPTOMATTE: `partOn`, `partMaskBits`, `cmOn`, `cmHex(b,i)`; `#authWrap`, `#partsAll`, `#cmMode`, `#bgrid .tile`.
- Overlay: `OV` `{grid,guides,points,probe,pending,n,tap}`, `OV_N`, `ovProbeWGSL()`, `drawOverlay(cv)`; `#labOverlay`, `#ovGrid`, `#ovGuides`, `#ovPoints`.
- Readout: `#labMsg` (AUTHORING only).

---

# 10. Node: Tabs and DOM

See C 10.

- `.tab[data-panel]` + `switchPanel(name)`, order: CREATE (`lab` → `#panelLab`), PERFORM (`perform` → `#panelPerform`, `#tabPerform`), AUTHORING (`author` → `#panelLab` in author mode, `#tabAuthor`), HELP (`help` → `#panelHelp`), ABOUT (`#panelAbout`), LEARN (no panel → `window.openLearn()` → `https://onemanshyo.com/#learn`). Opening: `setMode(authorOn); if(authorOn) switchPanel('author')`. `switchPanel` ends with `window.__surf()` (§2.1). Each `.tab`: `tabIndex 0`, `_enter` = `click()`.
- HELP: `#panelHelp` > `.sec-hdr` (`Let's do this`) + `#labLetsDo` (grid of two `ul.cr-tips`).
- Header: `.header` > `.hdr-left` > `.brand` > `#brandTxt` (`ONEMANSHYO`) + `.sub` + `.ver`.
- CREATE panel: `#labWrap` (the deck's drop zone), `#labModeHdr`, `#labModeTxt`, `#labMusic`, `#labFaceBox`, `#labStage`, `#labGpu`, `#labGpuMsg`, `#labOverlay`, `#labCodeBtn`, `#labSetBtn`, `#labCodeView`, `#labCode`, `#labApply`, `#labCopy`, `#labSave`, `#labCodeMsg`, `#labTransportHold`, `#labPlay`, `#labLoop`, `#labKeyLock`, `#labZoomTxt`, `#labRollBtn`, `#labSolo`, `#labNextBtn`, `#labContBtn`, `#labShufBtn`, `#labFxBtn`, `#labFxPanel`, `#labLeftCol`, `#labLibSec`, `#labMuSec`, `#labMuHdr`, `#labMuTxt`, `#labAMU`, `#labRollWrap`, `#labRoll`, `#labMsg`, `#labTempoVal`, `#labQuantVal`, `#labRecTime`, `#labMini`, `#messageBar`.
- PERFORM global strip additions: `#pfMasterGain`, `#pfDspBtn`. Pocket Rave additions: `#prSetBtn`, `#prRecBtn`, `#prLanes`, `#prRollBox`, `#prRoll`, `#prStatus`.
- Keyboard (BLOG0210, V1.0.28a to 30d; one flow on CREATE, PERFORM, AUTHORING; not Pocket Rave): `KBD_SEL` = `'button, select, a[href], input.pf-gf, [tabindex]:not([tabindex="-1"])'`; `kbdItems(root)` (visible, enabled, `tabIndex ≥ 0`, not inside `.pf-deck > .sec-hdr`); `kbdShown(x)` (not clipped by an `overflow:hidden|clip` ancestor; off screen kept; else `elementFromPoint` at its centre must be it or related: under a drawer or panel = not a stop); `kbdFirst(root)` (shown items sorted by row (`Math.round((r.top+r.height/2)/12)`) then left: the top row's leftmost); `kbdValue(x)` (defined, not called). One `document` `keydown` listener (capture): skipped with Ctrl / Meta / Alt, in Pocket Rave (`prActive()`), for `e._viz` (a key the flow sent itself), and while typing (INPUT except `input.pf-gf` with plain W A S D / arrows or Shift+A/B/L/M; TEXTAREA; contenteditable). Order: Shift+L → `kbdFirst(.panel.active .pf-libmod)` ('Library: W A S D, arrows or Tab move · in the list A / D load'; nothing shown: 'Library: under the open drawer (EQ · FX · MODE); close it first'); `window.__pfKeys(e)` (§8); Enter on an element with `_enter` (tabs, lane chips, bus bars, lane knobs, `.pf-master`) → `_enter()`; any other Shift key → the control's own keys (values, TEMPO, a LIBRARY row's own ← →); arrows = W A S D (`{ArrowUp:'w', ArrowLeft:'a', ArrowDown:'s', ArrowRight:'d'}`); `libNav`; then nearest-stop move over the visible `.tab`s + `kbdItems(.panel.active)` filtered by `kbdShown`: nothing selected → `kbdFirst`; S from a tab → `kbdFirst`; candidates only that way (> 4 px); edge-to-edge `along`, `across`; W / S: a tight pool (`across ≤ max(60, 0.3 × along)`), else a cone (`across ≤ 0.6 × along + 20`), else all; nearest row (`along ≤ min + 12`), then least `across`, then centre offset; A / D: same row first (`across 0`, nearest), else score `along + 3 × across`; W into the tab bar lands on `.tab.active`; `focus()` + `scrollIntoView({block:'nearest'})`. Focus look: the cyan ring (11.2).
- Drawer grid (BLOG0222, V1.0.31b): when the selected control is inside an open drawer (`.pf-fxin`), the move candidates are limited to that drawer; with none that way, W leaves (to the strip) and S / A / D stay put.
- W / S order (BLOG0222, V1.0.31c, 31d): candidates overlapping the selected stop side to side (`across === 0`) first, nearest row first (rows within 4 px count as one), then leftmost; else the cone pool by `across`, then `dc`, as before.

---

# 11. Design System values

See C 12 (narrative, rules and the interaction matrix).

<!-- @tags: DESIGN_SYSTEM, HIG -->
## 11.1 Classes
`.app`, `.header`, `.tabbar` / `.tab`, `.sec-hdr` (`.bar`, `.txt`, `.rule`), `.btn` (`.primary`, `.mag`, `.loop`, `.solo`, `.armed`), `.bgtoggle`, `.pf-gf`, `.pf-pos`, `.pf-global`, `.cr-global`, `.pf-col`, `.amu-mod` / `.amu-bus` / `.amu-cells` / `.amu-cell` / `.amu-knob`, `.lab-lane`, `.amu-kcv` (lane knob canvas, a keyboard stop), `.drop-hint` (`.dh-main`, `.dh-sub`; `.app-drop` the app's one drop zone, `.on`), `.message-bar`, `.kbd-nav` (on `body` while keys are in use), `.strip-play` / `.strip-cue` / `.strip-loop` / `.strip-kl` (control strip; composed in `buildStrip` as `'strip-'+k`); PERFORM mixer column `.pf-mod`, `.pf-mixmod`, `.pf-encs`, `.pf-pwrap`, `.pf-panelrow`, `.pf-fxbtn`, `.pf-fxpanel`, `.pf-fxslide`, `.pf-fxin`, `.pf-eqpan`, `.pf-eqgrid`, `.pf-fxcols`, `.pf-eqcol`, `.pf-encw`, `.pf-enc`, `.pf-encl`, `.pf-fxk` (`.pf-v`, `.killed`, `.armed`), `.pf-fxsel` (`.v`), `.pf-eqval`, `.pf-modes`, `.pf-mode` (`.pf-on`), `.pf-link` (`.on`), `.pf-iso`, `.pf-dspwin`, `.pf-dsps`, `.pf-dsptop`, `.pf-dsppre`, `.pf-dspknobs`, `.pf-dspgr` (`.m`, `.b`, `.v`), `.pf-libmod`, `.pf-libfrow`, `.pf-libf`, `.pf-libpl` (SETS, `.dis`), `.pf-libclr`, `.pf-libhd` (`.fixed`), `.pf-lib`, `.pf-libitem` (`.t`, `.a`, `.b`, `.k`, `.y`, `.dot`; `.sel`, `.loaded`), `.pf-plrow` (`.n`, `.on`, `.sel`); CREATE `.cr-libin`, `.cr-fxgrid`, `.cr-ptog`, `.cr-pnext`, `.mu-body`, `.cr-tips` (HELP); Settings drawer `.set-win`, `.set-left`, `.set-pnl`, `.set-txt`, `.set-val`, `.set-empty`; PERFORM Code `.pf-code`, `.pf-codeview`, `.pf-capply`, `.pf-ccopy`, `.pf-csave`, `.pf-cmsg`, `.pf-codeta`, Settings `.pf-set`; `.pr-pwr` (power light); Pocket Rave normal view `.pra-x`, `.pra-hdr`, `.pra-lanes`, `.pra-roll`, `.pra-status`, `.pra-visual` (`.asp-sq`, `.asp-vert`), `.pra-mrow`, `.pra-wf`. Removed from use: `.lib-drop` (CREATE's LIBRARY drop zone), the QUEUE button `.pf-libq` (its CSS rule remains).

## 11.2 Buttons

| Property | Small-button standard (in use) |
|---|---|
| Font | 11px Courier New |
| Padding | 3px 10px |
| Border | 1px solid #333 |
| Radius | 4px |
| Background | #1a1a1a (hover #252525, text #fff, border #444) |
| Sizing | `flex:0 0 auto`: hugs its label, never stretches |
| Fixed width | PLAY / PAUSE: `box-sizing:content-box; width:5ch; text-align:center` |
| Disabled | opacity 0.4 (`.pf .btn:disabled`); CREATE `#labKeyLock:disabled` 0.35 |

Where it is applied: `.pf-trans .btn`, `#labTransportHold > .btn`, `.pf-sm` (PERFORM SOLO), inline on CREATE's Visual header buttons. The base `.btn` rule still says 12px, padding 6px 12px (C 12.10).

| State | Class | Text / border | Glow |
|---|---|---|---|
| Toggle off | `.btn.loop` | #7a7a7a / #3a3a3a | none |
| Toggle on | `.btn.loop.on` | #00d4ff / #00d4ff | 0 0 8px rgba(0,212,255,0.5) |
| SOLO off (CREATE) | `.btn.solo` | #7a7a7a / #3a3a3a | none |
| SOLO on (CREATE panel) | `.btn.solo.on` | #E0218A / #E0218A | 0 0 8px rgba(224,33,138,0.5) |
| Primary | `.btn.primary` | #00d4ff / #00d4ff | none |
| Armed (QUANT wait) | `.btn.armed` | blink 0.5 s: rgba(0,212,255,0.28), #fff | none |
| Danger | `.btn.mag` | #ff006e / #ff006e | none |
| Icon toggle on (CREATE) | `.cr-ptog.on` | #00d4ff / #00d4ff | 0 0 8px rgba(0,212,255,0.5) |
| PLAY NEXT (CREATE) | `.cr-pnext` | #00d4ff / #1e4a55 (hover #5ce0ff / #00d4ff) | none |

Small strip and mode buttons (PERFORM):

| Property | EQ · FX · MODE `.pf-fxbtn` | Video mix mode `.pf-modes span.pf-mode` |
|---|---|---|
| Size | height 22px, border-box, grid cell width (3 across, gap 8 px) | height 22px, border-box, grid cell width (4 across, gap 8 px) |
| Font | 10px Courier New, line-height 20px, letter-spacing 1px | 10px/20px Courier New, letter-spacing 1px, `white-space:nowrap` |
| Colours | toggle: #7a7a7a / #3a3a3a off, #00d4ff on with glow | #aaa on #1a1a1a, border 1px #333 (hover / focus #fff on #252525, #444) |
| Radius | 3px | 3px |
| In use | `.on` (cyan) | `.pf-on`: #B24DFF text and border |
| Keyboard ring | `:focus-visible` 0 0 0 2px #00d4ff | `:focus` 0 0 0 2px #B24DFF |

Code and Settings buttons (`#labCodeBtn`, `#labSetBtn`, `.pf-code`, `.pf-set`): the small-button standard; `.primary` while open.

CUE (`.btn.loop.strip-cue`, V1.0.30h): no rule of its own; the toggle-off look (#7a7a7a / #3a3a3a) at the small-button standard from its row (`#labTransportHold > .btn`: 11px, padding 3px 10px, `flex:0 0 auto`, `white-space:nowrap`; PERFORM `.pf-row2`). Right of PLAY / PAUSE.

LINK `.pf-link` (mixer, V1.0.29a): `position:absolute; top:18px; transform:translate(-50%,-50%)`, 24 × 16, padding 0, border 0, radius 3px, transparent; colour #4a4a4a (hover #9a9a9a), `.on` (and `.on:hover`) #fff; chain SVG 18 × 9 (two 12 × 8 rounded rects, rx 4, stroke 1.8); `left` `calc(25% - 1.5px)` / `calc(75% + 1.5px)` inside `.pf-encs` (`position:relative`).

DSP `#pfDspBtn`: 11px, padding 3px 10px, margin 0, `flex:0 0 auto` (as master PLAY); `.btn.loop`, `.on` while the panel is open. `#pfMasterGain`: `.pf-gf` (11.3), `margin-left:auto` (MASTER + DSP at the strip's right end).

LIBRARY header (`.pf-libfrow`, one line: ALL · MUSIC · VISUALS · SETS ........ X): `display:flex; gap:8px; flex:0 0 auto`; filters `.pf-libf` 11px, padding 3px 8px (was 10px), `margin-left:0`, `flex:0 0 auto`; SETS `.pf-libf.pf-libpl` `display:flex; gap:5px; justify-content:center; white-space:nowrap`, `.dis` opacity .35, cursor default, no shadow; CLEAR `.bgtoggle.mu-ctl.pf-libclr` (X SVG 14 × 14, stroke 1.6), `.pf-libfrow > .pf-libclr { margin-left:auto; flex:0 0 auto }`.

Keyboard focus ring (BLOG0210): `.kbd-nav button:focus-visible, .kbd-nav [tabindex]:focus-visible, .tab:focus-visible, .lab-lane:focus-visible, .amu-bus:focus-visible, .amu-kcv:focus-visible { outline:none; box-shadow:0 0 0 2px #00d4ff }` (the cyan ring on every stop); `.pf-fxbtn:focus-visible` the same ring.

Icon toggle `.bgtoggle`: 26 × 24, #1a1a1a, 1px #333, radius 5px, #888 (PERFORM orientation: #00d4ff on #1e4a55). REC `#labRecBtn`: 26 × 24, #E0218A on #1a1a1a, border rgba(224,33,138,0.35) (hover #E0218A); recording: border #E0218A, background rgba(224,33,138,.12), pulse. CREATE's Music Understanding header: SOLO padding 3px 10px, 11px; zoom field 21 px high, 11px, 8 px before SOLO.

## 11.3 Fields and boxes

| Property | Field `.pf-gf` | Position box `#labRecTime`, `.pf-pos` |
|---|---|---|
| Size | 72 × 24, border-box | width calc(8ch + 14px), padding 3px 6px |
| Font | 13px Courier New, line-height 18px, centred | 600 11px Courier New, centred, `white-space:pre` |
| Colour | #00d4ff on #060606 | #888 |
| Border | 1px #333, radius 4px | 1px #333, radius 4px |
| Hover / focus | #4a4a4a / #00d4ff + 0 0 6px rgba(0,212,255,0.35) | n/a |
| Special | | REC: text and border #E0218A, background rgba(224,33,138,.10), glow 0 0 8px rgba(224,33,138,.22) |

Knobs and value boxes:

| Property | Knob `.pf-enc` | Name `.pf-encl` | Value box `.pf-fxsel` / `.pf-eqval` | Settings value `.set-val` |
|---|---|---|---|---|
| Size | 36 × 36 px, border-box, round | | padding 2px 4px; spans its column (`.pf-eqcol`); `.pf-eqval` min-width 52px outside a column | width 100%, max 64px, height 16px, padding 0 4px |
| Font | | 700 10px Courier New, `white-space:nowrap` (Settings: cut with an ellipsis) | 10px Courier New (FX drawer columns 9px, padding 2px 0, ellipsis) | 10px Courier New, centred |
| Colour | #0d0d0d fill, 1px #2c2c2c border; SVG arc and pointer in the domain colour | the domain colour | audio: #00d4ff on a #2c5560 border; visual (`.v`): #B24DFF on rgba(178,77,255,0.35) | #B24DFF on #060606, border rgba(178,77,255,0.35) |
| Radius | 50% | | 3px | 3px |
| Selected | `.pf-fxk:focus` 0 0 0 2px #00d4ff; visual (`.pf-v`) #B24DFF; Settings (`.set-pnl .pf-enc:focus`) #B24DFF | | `:focus` 0 0 0 2px #00d4ff; `.v` #B24DFF | `:focus` 0 0 0 2px #B24DFF |
| Killed | `.pf-fxk.killed` opacity 0.35 | | | |
| Waiting for QUANT | `.pf-fxk.armed` ring #00d4ff; `.pf-v.armed` #B24DFF | | | |
| Empty (Settings) | `.set-empty`: dashed border, opacity 0.45 | | | opacity 0.3 |

The mixer's four encoders: the 36 px knob alone (`.pf-encs span.pf-eqval.pf-fxsel` `display:none`).

Isolator knobs `.pf-iso` (MIXER header, right end): `.pf-iso` `display:flex; gap:8px; align-items:center`; `.pf-iso .pf-encw` row, `align-items:center`, gap 3px; knob `.pf-iso .pf-enc` **20 × 20 px**; name `.pf-iso .pf-encl` `order:-1` (name then knob), 9px, letter-spacing 0.5px; cyan (#00d4ff) arc and name.

DSP panel: window `.pf-dspwin` z-index 9 (top = strip height − 1, right −1px, width 280px); `.pf-dsps` column, gap 10px, padding 10px, 1px #2a2a2a, no top border; `.pf-dsptop` space-between; preset box `.pf-dsppre` min-width 84px, centred; `.pf-dspknobs` 3 columns `repeat(3,minmax(0,1fr))`, gap 8px, value boxes full width, centred; GR `.pf-dspgr` 10px Courier New #888, gap 6px; bar `.m` 6px high, #1c1c1c, radius 3px; fill `.b` #FFA500; value `.v` #FFA500, min-width 52px, right-aligned.

LIBRARY sort header `.pf-libhd`: `display:flex; align-items:center; gap:8px`, padding 4px 7px 3px, margin-top −4px, `position:sticky; top:-4px; z-index:1`, background #0a0a0a, bottom border 1px #1e1e1e, #6a6a6a, 9px, letter-spacing .08em, `cursor:pointer`, `user-select:none`, `white-space:nowrap`, `flex:0 0 auto`; heading hover #00d4ff; `.dot` spacer 7px; `.fixed` cursor default, no hover colour. Columns (header and rows): `.t` `flex:1.4 1 0` (ellipsis), `.a` `flex:1 1 0` (ellipsis; rows #8a949c), `.b` 28px right-aligned, `.k` 30px, `.y` 68px (ellipsis). Set rows `.pf-plrow`: `.n` #7a7a7a, `.dot` transparent; `.on` text and dot #00d4ff; `.sel` / `:focus` border #00d4ff.

Song info line: `.pf-info` / `#songInfo` (AUTHORING), 11px Courier New #cfd6dd on rgba(10,10,10,.85), padding 1px 10px, inset 2px, `pointer-events:none`; scroll ~40 px/s, 48 px gap between repeats. Pocket Rave song info (`.pra-mrow .song-info`): `left:52px`, padding 4px 8px; title `.t` 700 11px #fff, line-height 1.2; fields `.r` 9px #cfd6dd, line-height 1.2, gap 8px. Pocket Rave status `.pra-status`: 11px Courier New #00d4ff, centred, `min-height:14px` (0 when expanded), one line, ellipsis.

## 11.4 Spacing and rows
- Gap between neighbouring controls: **8 px** (row / strip `gap`; per-control margins 0). Music Understanding grid: `.amu-cells` 4 px (CREATE), `.pf-lanes .amu-cells` 2 px (PERFORM), `#labAMU` 6 px.
- CREATE controls row `#labTransportHold`: height 44 px, padding 6px, gap 8 px, `align-items:center`.
- PERFORM header controls `.pf-trans` and row `.pf-row2`: 24 px, gap 8 px.
- Global strip `.pf-global`: padding 4px 8px, gap 8 px.
- PERFORM: `#panelPerform.active` margin `0 -9px` (9 px from the app frame); grid gap 24 px, the mixer column `margin:0 -12px` (12 px between the columns); inside a deck 6 px between rows; music row 40 px (cover 40 × 40).
- PERFORM mixer column: modules 6 px apart; `.pf-encs` 4 columns, gap 6 px, the encoder row the knob's height; `.pf-panelrow` 3 columns, gap 8 px; `.pf-modes` 4 columns, gap 8 px.
- PERFORM drawers: `.pf-fxin.pf-eqpan` padding 15px 8px 8px (with the drawer 6 px under the strip and its 1px border: 9 px from the strip, the sides and the bottom); `.pf-eqgrid` 4 columns, gap 6 px; `.pf-eqcol` padding 8px, gap 6 px, rows `justify-content:space-between`; `.pf-eqcol .pf-encw` gap 2px; FX columns `.pf-fxcols .pf-eqcol` padding 8px 4px.
- Settings rack `.set-pnl`: 8 columns `repeat(8,minmax(0,1fr))`, row gap 10px, column gap 4px, padding 10px; `.set-txt` gap 4px.
- CREATE panel: the cover 40 × 40 and the waveform box 40 px high (2 px padding) in both modes. CREATE: `#labLeftCol` gap 10 px; LIBRARY `.pf-fxin` gap 6 px; FX grid `.cr-fxgrid` columns 72 px 72 px, row gap 12 px; Music Understanding `.mu-body` padding 6px, `#labMini` at least 160 px (`fitMu`). HELP `#labLetsDo`: two columns, gap 10 px, padding 6px; `.cr-tips` padding 10px 14px 10px 30px, 15px Courier New #ccc, line height 1.9, square markers cyan.
- LIBRARY list `.pf-list.pf-lib`: gap 2px, padding 4px; rows `.pf-libitem` gap 8px, padding 3px 6px; header row `.pf-libfrow` gap 8px; sort header padding 4px 7px 3px (11.3).
- Mixer LINK: `.pf-link` centred on the gap between a deck's two encoders, `top:18px` (11.2). Isolator: `.pf-iso` gap 8px, name-to-knob 3px (11.3). DSP panel: padding 10px, rows gap 10px, knobs gap 8px.
- Pocket Rave normal view (V1.0.22c / 22g): every module 8 px from the frame (`margin:0 8px`: `.pra-hdr`, `.pra-visual`, `.pra-mrow`, `.pra-lanes`, `.pra-roll`, `.pra-status`); `#prMusic` column, gap **10px**, padding **10px 0 10px** (section headers 10 px above and below: `.pra-hdr .sec-hdr` margin 0; the header buttons `.pra-hdr .btn` 11px, padding 3px 10px, `margin-left:8px`); status `.pra-status` margin `-2px 8px 0`; version `.pr-ver` inline `margin-top:-4px`; `.pr-bottom` (PLUR) gap 10px, `margin-top:-4px` (status, version and PLUR 6 px apart); music row `.pra-mrow` gap 6px, padding 6px, cover 40 × 40, waveform `.pra-wf` 40 px high, padding 2px; lane buttons `.pra-lanes` gap 3px, `.amu-mod` padding 2px gap 2px, `.amu-cells` gap 2px, `.amu-cell` padding 2px 1px gap 3px, `.amu-bus` / `.lab-lane` 8px high, no text (`font-size:0`, padding 0); roll `.pra-roll` **144px** high, `#prRoll` inset 4px; `.pra-visual` 16:9 (`.asp-sq` 1:1, width `min(calc(100% - 16px),60vh)`; `.asp-vert` 9:16, width `min(calc(100% - 16px),calc(60vh * 9 / 16))`; both `margin:0 auto`); REC `#prRecBtn` 26 × 24, `margin-left:6px`.

## 11.5 Lines and modules
- Standard line: 1px solid #2a2a2a, radius 6px.
- Module `.pf-col` (decks) and `.pf-mod` / `.pf-pwrap` (the mixer column's three modules): the line, padding 8px, no background (the panel strip and drawer #0a0a0a); the mixer column itself has no line.
- Drawer `.pf-fxslide`: 1px #2a2a2a, no top border, radius 0 0 6px 6px, #0a0a0a; slides 0.26 s. Sideways (`.set-left .pf-fxslide`): 1px #2a2a2a, no right border, radius 6px 0 0 6px, `translateX(100%)` → 0.
- Knob module `.pf-eqcol`: 1px #2a2a2a, radius 6px, #0a0a0a, padding 8px (FX 8px 4px).
- Inner boxes with a fill (`.pf-mu`, `.pf-wf`, `.pf-global`): #0a0a0a; stage `.pf-stage`: #060606.
- CREATE's LIBRARY module `#labLibSec`: the line, background the page gradient `linear-gradient(135deg,#0c0c0c,#1a1a1a) fixed`. HELP modules `.cr-tips`: #0a0a0a, 1px #2a2a2a, radius 6px.
- Moogerfooger strip on the main app: `#prSafeTop` 26 px, left / right 22 px.
- Pocket Rave normal view: canvas `.pra-visual` framed as AUTHORING's stage: 1px solid #2a2a2a, radius 6px, background #050505, no glow, no colour change while playing (V1.0.22d; full frame: no border); music row `.pra-mrow` 1px #2a2a2a, radius 10px, #0a0a0a; waveform `.pra-wf` 1px #2a2a2a, radius 6px, #0a0a0a; roll `.pra-roll` 1px #2a2a2a, radius 10px, #060606.
- DSP panel `.pf-dsps`: 1px #2a2a2a, no top border (the drawer slide `.pf-fxslide`).
- Drop zone `.drop-hint.app-drop`: `position:fixed; inset:12px; z-index:100000` (shown with `.on`).
- Section header `.sec-hdr`: `.bar` 3 × 13 px radius 1px, `.txt` 600 11px Courier New uppercase letter-spacing 1px, `.rule` 1px #262626, gap 8 px.

## 11.6 Colours
- Key colours: Purple People Eater #B24DFF · Barbie Pink #E0218A · Green Slime #65FF00 · Yellow Man #FFF000 · Orange Julius #FFA500 (brand) · Goblin White #FFFFFF · Red Hots #FF006E (key). Listed in the comment at the top of `<style>`. One shade of each; dim forms = the same colour at lower opacity.
- Domains: visual **#B24DFF** (Purple People Eater), audio **#00d4ff**. A control's arc, value box, active state and selected ring take its domain colour. Visual: mixer VID (`.pf-v`), VFX knobs and effect boxes, RGB knobs and values, the Settings rack (`COL`, `.set-pnl .set-val`, `.set-pnl .pf-enc:focus`), the video mix modes (`.pf-mode.pf-on`, `.pf-mode:focus`), the VFX "waiting for QUANT" ring (`.pf-fxk.pf-v.armed`). Audio: mixer AUD, AFX knobs and boxes, EQ HIGH / MID / LOW. LIBRARY entry dots: audio cyan, shader purple. Visual boxes `.pf-fxsel.v`: #B24DFF, border rgba(178,77,255,0.35); audio boxes `.pf-fxsel`: #00d4ff, border #2c5560. EQ · FX · MODE keyboard ring: #00d4ff.
- Killed control: opacity 0.35 (`.pf-fxk.killed`).
- Chrome and section headers cyan #00d4ff; authoring sections Orange Julius #ffa500 (`AUTH`).
- Messages: info #00d4ff · state #ffa500 · error #ff006e; bar background linear-gradient(180deg,#222,#2a2a2a), top 1px #444, 13px Courier New, 30 px high.
- Red Hots #ff006e also: `.btn.mag`; GPU errors on a stage (`#labGpuMsg`, `.pf-msg`) #FF006E; header and Pocket Rave brand gradient linear-gradient(45deg,#00d4ff,#ff006e). (The Pocket Rave stage's cyan / Red Hots playing border, `.pra-visual.playing`, is removed: V1.0.22d.)
- Keyboard focus: the cyan ring `0 0 0 2px #00d4ff` on every keyboard stop (11.2). Mixer LINK: off #4a4a4a, hover #9a9a9a, on #fff. Master section knobs (isolator, DSP): cyan #00d4ff. DSP GR: Orange Julius #FFA500 (state).
- Bus colours (`GRP`): rhythm #FF006E · structure #FFA500 · key #FFF000 · pace #65FF00 · loudness #00a8ff · instruments #B24DFF.
- Lane colours (`LANES[].col`), each its bus colour: beat #ffffff · bar #FF006E · section, segment, phrase #FFA500 · key #FFF000 · pace #65FF00 · loudness #00A8FF · drum, bass, vocal, other #B24DFF.
- Solo on PERFORM lanes: `.amu-cell.key` border and 6px glow in the lane colour; `.amu-cell.dim` opacity 0.3.
- Active and recording: Barbie Pink #E0218A: SOLO on (CREATE panel) text and border, glow rgba(224,33,138,0.5); roll playhead; Pocket Rave waveform playhead; REC button; position box while REC (11.3).
- Picked chip being rendered (roll): band rgba(255,240,0,0.16), edge #FFF000.
- Drop highlight: dashed cyan edge, translucent blur; hint `.dh-main` cyan 13 px, `.dh-sub` grey 11 px, one type per line, padding 16 px, centred.
- LIBRARY entry: selected = cyan border; loaded on a deck = Yellow Man tint rgba(255,240,0,0.10); list focus = cyan ring; hover #141414 (none while `.kbd-nav`, except a loaded row); artist / author column #8a949c; sort header #6a6a6a (heading hover #00d4ff); set row count #7a7a7a, applied set #00d4ff (text and dot).
- Purple People Eater #B24DFF also: ABOUT credit labels and PLUR, Pocket Rave PLUR (`.pr-plur`), authoring overlay anchor points.
- Header rename: `#brandTxt[contenteditable]` outline 1px dashed #00d4ff, caret #00d4ff.
- Shader WGSL colours belong to the shader, not the design system.
<!-- @/tags -->

---

**END OF SYSTEM REFERENCE**
