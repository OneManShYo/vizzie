# OMS Vizzie app [Beta V1.0.0] System Reference

**Run date:** 2026-11-07  
**Current Unix Epoch:** 1794051010  
**Document purpose:** Machine-readable index for an AI or developer picking up the single-file codebase. Names below are the actual identifiers in the HTML's inline script and markup.  
**Filename:** OMS_Vizzie_Beta_V1_0_0_Y_ClaudeProject_SystemReference.md  

## About this document

Vizzie Beta V1.0.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

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
| App file | `OMS_Vizzie_Beta_V1_0_0.html` (single self-contained HTML; also the shader authoring template) |
| Renderer | WebGPU / WGSL only (Canvas-2D = UI chrome and authoring overlay only) → C 2.3 |
| Audio | Web Audio deck engine, KEY LOCK AudioWorklet → C 3 |
| Data | embedded AMU sidecar (`const AMU={…}`) → C 2.1.5 |
| Clock of record | `MASTER` (master music clock) and each deck's `d.beat`, beats → C 2.1 |
| Uniform contract | V0.5.0A: `@group(0)` binding 0 AMU block 9 × vec4 / 36 floats / 144 bytes (slot 13 = beats); binding 1 settings block 16 × vec4 / 64 floats / 256 bytes, one per deck → C 2.2 |
| Tabs | CREATE · PERFORM (off-site only) · AUTHORING (off-site only) · HELP · ABOUT · LEARN → C 10 |
| Site | vizzie.onemanshyo.com |
| License | GPL-3.0 (software); embedded assets separately reserved |

## 1.2 Systems index

| # | System | Tag | Tier | Governance scope |
|---|--------|-----|------|------------------|
| 1 | **Master music clock** | `MUSIC_CLOCK` | **CORTEX** | `MASTER`, `makeDeck` / `warpMap`, `DECKS` / `DK`, `hb()`, `chrome()`, `seekTo()`, `readAMU()`, `tempoMaster` / `masterTick()`, `quantTick()` |
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
- `makeDeck(id,amu)` → deck `d`: `id`, `amu`, `beat`, getter / setter `t`, `timeToBeat`, `beatToTime`, `beatLen`, `lanes`, `knob`, `solo` (`makeSolo()`), `playing`, `loop` (LOOP button), `loopSpan` (null = whole track, or a chip's `{li,start,end}`), `pick` (a chip picked while stopped, `{start,end}`), `keyLock` (default **true**), `pend` (a QUANT start or cue waiting), `audio`, `peaks`, `setTrack(amu)`, `len()`, `ratio()`, `gate(id)`, `gateOf(i)`. Set later: `name`, `info0`, `tags`, `canStretch`, `outGain`, `audGain`, `mixK` (`{audGain, outGain}`, mixer kills: true = that encoder at 0, its level kept), `wgsl`, `wgslVer` (bumped on each new source), `shaderName` (the loaded shader's name without `.wgsl`; the exported version after Export), `coverURL` (a dropped cover), `settings` (`Float32Array(64)`, the settings block, `deckSettings(d)`), `setDecl` (`{src, list}`, the shader's settings declaration), `fx` (FX slots, `fxInit(d)`; deck A's shared by PERFORM and CREATE), and from `fxInit(d)`: `eq` (`[low, mid, high]` dB, 0), `eqK` (`[false,false,false]`, EQ kills), `rgb` (`[r, g, b]` gains, 1), `rgbK` (`[false,false,false]`, RGB kills).
- `DECKS` (`[A]` on CREATE; `[A, B]` with PERFORM), `DK` (deck A: CREATE's deck and PERFORM's deck A, the same object).
- `hb()`: heartbeat, `audioCtx.currentTime` once any deck has audio, else `performance.now()/1000`.
- Transport: `togglePlay(d=DK)`, `setPlayUI()`, `seekTo(sec,d=DK)`, `lastW`; SPACE: ignored in INPUT / TEXTAREA; while `#panelPerform` is active → `window.__masterPlay()`, else `togglePlay()` (deck A). Track end (LOOP off) on deck A calls `window.__crNext()` (CONTINUOUS PLAY, C 7.6) before the end-of-track message.
- Loop: IIFE `chrome()`: `MASTER.advance` → each playing deck `d.beat +=` → picked-chip render end (`REC.span`) → chip loop wrap (`d.loop && d.loopSpan`) → track end (LOOP on = wrap to 0) / `steerDeck(d)` → `quantTick()` → master position (`window.__mpB`, `window.__mpT`) → `masterTick()` → `fitStage()` → readout `#labMsg`, hover lane message, `#labRecTime` (`arrPos`), CREATE info line, `paintLanes` (AUTHORING only), `deckButtonsUI`, `labWave.draw()`, `drawRoll()` → `window.__libTick()` → `window.__fxTick()` → `window.__perfDraw()`.
- Tempo master: `tempoMaster` (a deck; starts `DK`), `masterTick()` (hands over to a playing deck when the master is not playing).
- QUANT: `QUANT_STEPS` (`[{n,b}]`: None 0, 1/4 1, 1/2 2, 1 Bar 4, 2 Bars 8, 4 Bars 16, 8 Bars 32 beats), `QUANT_DEF` (1 = 1/4), `quantIdx`, `QCYCLE` (32), `mixOn()`, `othersPlaying(d)`, `mixed(d)`, `deckBar0(d)`, `deckPos(d,b,q)`, `onStep(d,b,q)`, `nextMaster(q,ph)`, `deckPlayPress(d)` (waits when `othersPlaying(d)`), `deckCue(d,sec,landed)` (waits when the deck plays and QUANT is not None), `quantTick()`. `bindQuantField(qv)`, `QUANT_FIELDS` (every QUANT field, one value): `#labQuantVal` (CREATE), `#pfQuantVal` (PERFORM).
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
- `main()`: adapter, device, `webgpu` context on `canvas` (`#labGpu`), 144-byte uniform buffer `ubuf`, settings buffer `sbuf` (`SET_BYTES`), `AUTH_GPU.init(device)`, `build(WGSL)`, then the `frame()` rAF loop (write `ubuf` and `sbuf` (`deckSettings(DK)`), `AUTH_GPU.write`, one pass: `setBindGroup(0,bind)`, then `bindP` as groups 1 to 3 when set, `draw(6)`; `AUTH_GPU.copy` / `read`, `drawOverlay(canvas)`). `bind`: group 0 on `contractLayout(device)` (bindings 0 `ubuf`, 1 `sbuf`); `bindP`: the authoring preview's bind groups 1 to 3 (1 and 2 empty, 3 `AUTH_GPU.entries()`) or null. With deck A's FX live on CREATE and a live VFX slot (`window.__fxLiveDK()`, `vfxLive(DK)`), the pass draws into `ctex`, `vfxRun(device,PG,cvst,enc,ctex,DK,w,h)` runs the visual FX and `PG.blit` puts the result on the canvas.
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
- Component help: `el._msg` (function) or `el.dataset.msg` (text), set by `bindDeckButtons` (`dp(d)` prefix + `STRIP[].msg(d)`), the mixer encoders (live value: VID %, AUD dB), the buses, `fxCell` (knob, its label and effect box), `eqCell` (knob, label, value box), the video mix mode buttons (full mode name and what it does), the panel strip buttons (ending "(W A S D move)"), `settingsDrawer` (each slot's encoder, label and field, the shader's own help after "·"), the PERFORM Code views (`.pf-capply`, `.pf-ccopy`, `.pf-csave`, `.pf-codeta`), the LIBRARY filters (demo playlists included), entries and QUEUE, CREATE's FX, PLAY NEXT, CONTINUOUS PLAY and SHUFFLE (`dataset.msg`).
- State and error messages are written at their source with `showMessage(text,'state'|'error')`; GPU failures write to the stage (`note(t)` → `#labGpuMsg` / the deck's `.pf-msg`).
- `bindHelp()`: assigns `HELP`, moves every `title` into `dataset.msg` and removes it, binds per element `mouseenter` / `mouseleave` / `focusin`; `window.__bindHelp(root)` binds new elements (CREATE's Visuals header, LIBRARY module and FX drawer when first placed, the Settings drawer's rack on each build, the demo playlist buttons).
- Lanes: `hoverLane` `{L,d}`, `laneMsg(L,a,d,chip)`: live values each frame from `chrome()`; `chip` = the mini-player form (no knob %, '(click = solo)').
- `IDLE_MSG` / `MODES.*.idle`: set, not shown (idle = empty bar since V0.8.16b).
<!-- @/tags -->

---

# 3. Node: Deck Audio, Tempo, Key Lock

See C 3.

- `audioContext()`, `audioCtx` (one for the app); each deck's engine is `d.audio`. Resume on `pointerdown`, `keydown`, `touchend`, `click` (capture); iOS: `navigator.audioSession.type='playback'`, `audioUnlocked` (one silent 1-sample buffer on the first touchend / click).
- `makeDeckAudio(ctx,buf,canStretch,keyLock)` → `{duration, paused, ended, currentTime (get/set), rate (get/set), keyLock (get/set), play(), pause(), stop(), captureStream(), pre, gain}`; source → `pre` → (EQ on PERFORM, then the FX rack, where `FX_LIVE`, 8) → `gain`.
- `steerDeck(d)`: speed = `d.beatLen(d.beat)*MASTER.tempo/60` × (1 ± up to 0.02); gap > 0.25 s → jump.
- TEMPO: `setTempo(bpm,exact)` (rounds to 0.01; clamp `tempoMaster.amu.bpm` × 0.5 … 1.5; every loaded deck's rate; message "TEMPO n BPM"), `d.ratio()`, `tempoUI()` (writes `#labTempoVal`), `bindTempoField(tv)` (keys `ArrowUp` +1, `ArrowDown` −1, `ArrowRight` +0.01, `ArrowLeft` −0.01, Enter, Escape; dblclick = `tempoMaster.amu.bpm`). Fields `#labTempoVal` (CREATE), `#pfTempoVal` (PERFORM).
- KEY LOCK: `d.keyLock` (per deck, default true), `keyLockUI(ok)`, `#labKeyLock` (CREATE; strip key `kl`, class `strip-kl`); worklet `vizzie-stretch` from `STRETCH_SRC`, `loadStretch(ctx)` (`data:` URL, blob fallback), `stretchReady`; `findOnsets(buf)`; `d.canStretch === false` = disabled.

---

# 4. Node: Deck Controls

See C 4.

- `STRIP`: `[{k:'play',label:'PLAY',cls:'btn primary',msg}, {k:'loop',label:'LOOP',cls:'btn loop',msg}, {k:'kl',label:'KEY LOCK',cls:'btn loop',msg}]`. `buildStrip(holder,{ids,ctx,before})` → `{play, loop, kl}` (class `strip-<k>`); `CREATE_STRIP` (ids `labPlay`, `labLoop`, `labKeyLock`); `CREATE_BTNS` (strip + `#labSolo`).
- `bindDeckButtons(d,b)` (PLAY → `deckPlayPress`, LOOP toggles `d.loop` (off releases the chip loop), KEY LOCK, SOLO clears), `deckButtonsUI(d,b)` (PLAY / PAUSE text, `.armed`, `.on`, KEY LOCK `disabled`), `dp(d)` (message prefix).
- Lanes: `LANES[]` 12 descriptors `{id,grp,label,col,kind,slot,src}`; ids `beats,bars,sections,segments,phrases,key,pace,loudness,ia:drum,ia:bass,ia:vocal,ia:other`; kinds `ticks|blocks|keyspan|paceStep|curve|stem`; helpers `series()`, `blocks()`. `GRP[]` (six buses + colours); every lane's `col` is its bus colour, beat `#ffffff`.
- `buildLanes(d,box,{buses,labels,chips})` → cells (`.amu-cell` > `.lab-lane` chip + `.amu-knob` > canvas 88 × 88; `chips` = chip only, no knob, cell `kctx` null); `LANE_SHORT` (short chip labels: beat, bar, sect, seg, phr, key, pace, loud, drum, bass, voc, oth); every call passes `chips:true`: `CREATE_LANES` (`#labAMU`, AUTHORING, `{buses:true,chips:true,labels:LANE_SHORT}`, V0.11.10a), `MINI.lanes` (CREATE `#labMini`), each PERFORM deck's `v.lanes`; `paintLanes(d,cells)` (`.key` soloed, `.dim` muted; knob arcs only on knob cells, none built).
- `makeSolo()` → `d.solo`: `on(id)`, `muted(id)`, `anyOn()`, `toggleLane(id)`, `toggleGroup(grp)`, `isLaneKey(id)`, `clear()`.
- Piano roll: `deckRoll(cv,d,{base,step,horiz,hh,ui:{txt,field,orient},square,vh,active})` → `R` `{zoom, horiz, maxZoom(), win(), view(t)→{b0,WB,t0,t1}, step(), zoomTo(z), fit(), draw(t), syncUI()}` (`active` = which of two rolls owns the shared zoom field and orientation button; `hh` = the fixed horizontal height, else square); `drawRollOn(cv,g,d,t,hz,RV)`; `rollInput(cv,d,view,hz)` (drag < 4 px = cue). CREATE: `labRoll` (`#labRoll`), `labRollV` (AUTHORING: `horiz:true`, `hh` 120px, vertical `vh` = `MODES` rollH 75px; V0.11.16a), `MINI.roll` (CREATE `#labMini`, base 16 beats, `step:0.25`, `horiz:true`), `ROLL_WIN` (from `MODES`), `ROLL_PH` 0.5, `rollHeight()`, `drawRoll(t)`; zoom field `#labZoomTxt`, orientation `#labRollBtn`. PERFORM: `ROLL_PF` 16, `step:0.25`, `horiz:true`.
- Cues: `amuStart(L,a,tc)`, `amuCue(li,tc,d=DK)` → `deckCue` (LOOP on: sets / releases `d.loopSpan` when it lands; stopped: sets `d.pick`). Looped or picked chip drawn solid cyan; a picked chip being rendered: Yellow Man band `rgba(255,240,0,0.16)`, edge `#FFF000`.
- Drops and pickers: `readDrop(dt)` (File System Access handles → entries → plain files; folders and subfolders; sets `f._rel`), `bindDrop(el,d)` (`.drop-hint` built by `dropHint(main,types)`, `.drop-on`; drags inside a `.lib-drop` are left to it; first of each type: `.wgsl`, AMU, audio, image; the rest counted as ignored), `isImage(f)`, `coverSize(f)` (square only), `deckFile(f,d,kinds,verb)`, `pickFile(d,kinds)` (hidden inputs made per deck in `d._pick`), `bindDoubleTap(el,fn,skip)` (300 ms), `bindLoaders(d,wf,stage,skip)`, `bindCover(cover,d,setInfo,isOpen,inside)`.

---

# 5. Node: Song Info, Audio Loading, Waveform

See C 5.

- `loadAudioFromBlob(blob,name,d=DK)` (clears a dropped cover); `autoLoadExample()` (http / https, `./examples/`, only when no `TRACK_MP3` is packed); `isAudio(f)` (audio MIME or extension; `.m3u` / `.m3u8` excluded).
- AMU JSON: `isAMU(f)`, `amuFromSozo(j)`, `loadAMUFromFile(f,d=DK)`, `checkPair(d)`, `TONICS`, `TONIC_NAMES`.
- `readID3(arrBuf)` (`tags.pic` copied with `slice()` before decoding), `decodeText()`; `applyTagsToInfo(tags)` → `#coverArt`, `#trackName`, `#trackArtist`, `#trackLabel`, `#trackYear`, `#trackCopyright`; cover card `#coverCard`; info `#songInfo`.
- `deckInfo(d)` → `{title, artist}`; `deckCover(d)` (`d.coverURL`, else `TRACK_COVER` on `DK`, else `d.tags.pic`, else `COVER0`); `setDeckCover(d,f)`, `clearDeckCover(d)`.
- `infoLine(box,d)`: fills `.pf-one` × 2 inside `.pf-tick`; `.pf-tick.run` animates (`--dur` = width / 40 s); `box._tickKey` re-measure key. `.pf-tick.run` always on (V0.9.05a). Used for `#songInfo` (both modes) and each PERFORM `.pf-info`. `bindCover`: single tap = toggle, double tap = picker; no outside or Esc close.
- Waveform: `computeLevels(buffer,600)` → `d.peaks`; `waveView(cv,d,hold)` → `{draw(), cache(W,H), key}` (click < 4 px = `deckCue`, drag = scrub); `paintWave(cc,cx,d,W,H,hold)`; CREATE `labWave` on `labWf` (`#labWf`) in `#labWfBox`.

---

# 6. Node: Viewer Surfaces

See C 6.

- Code view: `#labCodeBtn`, `#labCodeView`, `#labCode`, `#labApply` ('applied (preview only)' / 'error, see stage'), `#labCopy` ('copied', plain copy), `#labSave` (label Export: `saveShader(DK,ta.value)`, 'exported'), `#labCodeMsg`. PERFORM deck: `.pf-code` (`</> Code`, `.primary` while open) → `.pf-codeview` over `.pf-stage` (z 3; click, dblclick, pointerdown, pointerup stopped) > `.pf-capply`, `.pf-ccopy`, `.pf-csave` (Export), `.pf-cmsg`, `.pf-codeta` (`ta._deck`); deck A's Apply → `window.__applyWGSL`, deck B's → `d.wgsl`, `d.wgslVer`; `v.codeSync()` (from `__perfDraw`: refills an open view when `d.wgslVer` changes and the editor has no focus).
- `openPopOut()`, `popWin`: `<video>` mirror of `#labGpu.captureStream(60)`; `#labPopBtn`.
- REC: `startRec()` (from the playhead; picked chip + LOOP off = `REC.span`) / `stopRec()`, `REC`, `#labRecBtn` (`.recording`); `VizzieWGSL_<WxH>_<time>.mp4|webm`.
- Orientation: `ASPECTS` (16:9, 1:1, 9:16), `aspI`, `#labAspectBtn`; `fitStage()`.
- Arrangement position: `arrPos(a)` (`padStart(4,' ')` bar . beat . sixteenth); `labPos` = `#labRecTime` (`.recording` while REC); PERFORM `.pf-pos` per deck.

---

# 7. Node: Surfaces and Modes

See C 7.

- Host: `PUBLIC_HOST`, `AUTHOR_MODE`; `authorOn`. Website: `#tabPerform`, `#panelPerform` and `#tabAuthor` removed.
- Compact: `compactMQ` (`(orientation:portrait), (max-height:500px)`), `compactForced`, `isCompact()`, `compactClass()` (html classes `compact`, `compact-forced`).
- Modes: `MODES.authoring` / `MODES.public` (= CREATE) `{autoplay,loop,idle,rollH,rollWin,readout,waveHold,sidecarInfo}` (autoplay and loop false in both), `mode()`, `setMode(on)` (closes `window.__crFx` and `window.__setDrawer`), `visLabel()` (`#labVisTxt` = `Visual : Authoring` / `Music`; `#labModeTxt` = `Global`); html class `author-on`. `switchPanel('author')` → `#panelLab` + `setMode(true)`; `switchPanel('lab')` → `setMode(false)`.
- `LAYOUT` `{render, author, info, mini, muSec, left, fitMu}`: header row = `#labVisTxt.closest('.sec-hdr').parentElement`. `render()` (CREATE): creates `#labLeftCol` (`position:relative`) and moves `#labMusic` (40 px) and `#labTransportHold` into it; a `Visuals` `.sec-hdr` over the stage receives the Visual header's buttons (`vBtns`: Code, Settings, Pop Out, orientation, REC); `#labMuSec` (`Music Understanding` header + `.mu-body` > `#labMini`) inserted after the row; the zoom field then `#labSolo` appended to `#labMuSec .sec-hdr` (`data-home`); `#labMuHdr` hidden. `author()` reverses it: SOLO to the end of `#labTransportHold`, the zoom field before `#labRollBtn`. `soloEl`, `zoomEl`: held references. `fitMu()`: `#labMini` height = `.body` bottom − its top − padding − 12, at least 160 px, minus any overflow; on resize and a ResizeObserver on `#labLeftCol` and `.body`.
- CREATE hidden: `html:not(.author-on) #labRollWrap`, `#labAMU`, `#labMuHdr`.
- CREATE controls row `#labTransportHold`: `#labPlay`, `#labLoop`, `#labKeyLock`, `#labRollBtn`, `#labNextBtn`, `#labContBtn`, `#labShufBtn`, `#labFxBtn` (`margin-left:auto`). AUTHORING: `#labPlay`, `#labLoop`, `#labKeyLock`, `#labZoomTxt`, `#labRollBtn`, `#labSolo` (SOLO `margin-left:auto`); `html.author-on #labFxBtn, html.author-on .cr-ptog` hidden.
- CREATE global strip: `#labModeHdr` (GLOBAL) over `.pf-global.cr-global` holding `#labTempoVal`, `#labQuantVal` and `#labRecTime`.
- CREATE LIBRARY, FX and playlist controls (one block, built on open): `#labLibSec` (`.pf-mod.pf-libmod.lib-drop`; `Library` header; `.pf-fxin.cr-libin` > `.pf-list`; its own `.drop-hint`; drop → `readDrop` → `libImport`), `crView = libView(box,{decks:[DK], keys, help, qhelp})`; `#labFxPanel` (`.pf-fxpanel`, `z-index:6`) > `.pf-fxslide` > `.pf-fxin` > `.cr-fxgrid` (`fxCell(DK,'a'|'v',i,true)`); `place(win)` (row width, row bottom to `#labLeftCol` bottom), `show(which)`, `window.__crFx {show}`; `FX_LIVE` entry for deck A on CREATE. Icons `.bgtoggle.mu-ctl.cr-ptog` (`#labContBtn`, `#labShufBtn`, `.on` lit) and `#labNextBtn` (`.cr-pnext`); `CP {cont, shuf}`, `cpUI()`; `window.__crNext(now)` (next row of `crView.rows` after the track on the deck, wrapping; `now` = PLAY NEXT; without `now` only when `CP.cont`; does nothing in AUTHORING); SHUFFLE: `crView.shuf` (a `Map` id → random key; the deck's track −1), `null` when off.
- Settings drawer (C 7.8): `settingsDrawer(d,btn,anchor,limit,side)` → `{show, close, build, place, isOpen, win}`; `COL` `#B24DFF`; window `.pf-fxpanel.set-win` (z-index 40; the anchor module 41) > `.pf-fxslide` > `.set-pnl` (the rack, `SLOTS` 32, 8 columns) + the colour wheel `PK` (one per drawer, `PK.open`, `PK.close`, `PK.draw`); cells `numCell(s)` / `colorCell(s)` (`.pf-encw` > `.pf-enc` (`tabindex -1`) + `.set-txt` > `.pf-encl` + `.set-val` input), `.set-empty` for unused slots; order: the standard area (`idx` < 16) first, a shader's own from a fresh row; more than `SLOTS`: error 'Settings: N beyond the 32 slots not shown'; `place()`: `side()` set → `.set-left` (sideways, the anchor's height, from the side element's left to 6 px behind the anchor), else down from the anchor's bottom − 6 px at its width, with `limit()` the panel's `maxHeight` to 8 px above the limit's bottom (scrolls); `btn` hidden when the list is empty, `.primary` while open; `SET_ON` → `build()`. The drawer's Export button (`sv`) is built but not placed (Export is in the Code views). CREATE / AUTHORING: `window.__setDrawer = settingsDrawer(DK, #labSetBtn, () => authorOn ? #labFaceBox.parentElement : #labFaceBox, null, () => authorOn ? null : #labLeftCol)`; closed by `setMode` and `setSurface`.
- Metal inserts: `.app::before`, `.app::after` z-index 121 (above `#prSafeTop`, 120).
- Moogerfooger strip: `#prSafeTop` shown on the main app (`html:not(.pr-on) #prSafeTop`, left / right 22 px; `.app` padding-top `calc(env(safe-area-inset-top) + 26px)`); click acts only with `pr-on`, `pr-auto` or `compact` + `author-on` (then `setSurface(false)`).
- Header rename: `#brandTxt` (inside `.brand`), power light `.pr-pwr`: `mainApp()`, `edit()` (`contenteditable`, select all), `done(keep)` (collapse whitespace, 24 characters, empty = `ONEMANSHYO`), keys Enter / Escape, blur = keep, plain-text paste; `pointerdown` `preventDefault` keeps the selection; style `#brandTxt[contenteditable]` (1px dashed cyan outline).
- Pocket Rave: `#pocketRave` (`.pr-expanded`), `prMQ`, `prForced`, `prActive()`, `setSurface(pr,compact)` (html `pr-on`, `pr-auto`; closes `window.__crFx`; leaving lands on AUTHORING), `#prSafeTop`, `#appPrHeader` (compact authoring's header → `setSurface(true)`), `#prTabMusic` / `#prTabAbout` / `#prTabLearn`, `window.prTab(name)`, `#prMusic`, `#prAbout`, `#prPlay`, `#prShaderIn`, `#prCoverCard`, `#prSongInfo`, `#prInfo`, `#prAudioIn`, `#prWf`; `window.__prExpand`, `window.__prFull`; `prChrome()` (~22 fps while visible).

---

# 8. Node: PERFORM

See C 8. Built only when `AUTHOR_MODE`; on the website `#tabPerform` and `#panelPerform` are removed.

<!-- @tags: PERFORM -->
- Panel `#panelPerform`; global strip `.pf-global` > `#pfTempoVal` (`.pf-gf`), `#pfQuantVal` (`.pf-gf`, tabindex 0), `#pfMasterPlay` (`.btn.primary`), `#pfMasterPos` (`.pf-pos`).
- `#panelPerform.active`: margin `0 -9px` (9 px from the app frame; other tabs 18 px).
- Grid `.pf` (columns `minmax(0,1fr) minmax(200px,0.563fr) minmax(0,1fr)`, gap 24 px) of `.pf-col`: `#pfDeckA`, the mixer column `.pf-col.pf-mix` (no line; gap 6 px; margin `0 -12px`, so 12 px to each deck) > `.pf-mod.pf-mixmod` (MIXER) + `.pf-pwrap` (panel strip) + `.pf-fxpanel` (the drawer window, right after the strip in the page order) + `.pf-mod.pf-libmod` (LIBRARY), `#pfDeckB`.
- Deck B: `DB = makeDeck('B',AMU)`, `DB.wgsl = WGSL`; pushed to `DECKS`.
- `deckView(d,root)` → `v` `{d, root, stage, msg, roll, cover, info, btns, lanes, wave, pos, rollV, gpu, lamp, setD, codeSync}`; parts `.sec-hdr` > `.pf-trans` (KEY LOCK, `.pf-master`, `.pf-code`, `.pf-set`), `.pf-stagebox` > `.pf-stage` (+ `.pf-codeview`), `.pf-music` (40 px) > `.pf-cover` + `.pf-wf` > `.pf-info` > `.pf-tick` > `.pf-one` × 2, `.pf-row2` (PLAY, LOOP, `.pf-ztxt`, `.pf-orient`, `.pf-pos`, `.pf-solo`), `.pf-mu` > `.pf-lanes` (chips) + `.pf-roll`. Short lane labels `SHORT` = `LANE_SHORT`. `v.setD = settingsDrawer(d, .pf-set, () => .pf-stage, () => root)` (down out of the stage, inside the column).
- `fit(v)`: stage width from the column, reserving fixed rows, 6 px gaps, lanes + 12 + 40 px of roll; minimum height 60 px.
- MASTER indicator `.pf-master` (`.btn.loop`, `.on` when `d === tempoMaster`, cursor default).
- QUANT field: ↑ / ↓ and wheel step `quantIdx`; dblclick = `QUANT_DEF`; message "QUANT n".
- Master position: `window.__mpB` (beats since the first PLAY, advanced while any deck plays), dblclick on `#pfMasterPos` = 0 ("Master position 1.1.1").
- Master PLAY: `window.__masterPlay()`; `window.__mpHeld` (the paused decks and the master beat; cleared by a deck's own PLAY); label from `DECKS.some(d=>d.playing)` in `__perfDraw`.
- Mixer: `#pfOut` (`.pf-out`), `outGpu`; encoders `.pf-encs` > `.pf-encw` > `.pf-enc[data-deck][data-kind]` (A vid, A aud, B aud, B vid; also `.pf-fxk`, VID `.pf-v`, `tabindex 0`) → `d.outGain` (VID, opens 0.5) / `d.audGain` (AUD, opens 0); the markup's `.pf-encl` label is replaced by a value box `.pf-fxsel.pf-eqval` hidden by CSS (the knob alone); value text `val()`: VID `Math.round(v*100)+'%'`, AUD `40*log10(v)` dB (−∞ dB below 0.001); drag full range over 150 px; ↑ / ↓ ±0.01, ← / → ±0.05; click = focus (select); Enter = kill / restore (`d.mixK[k]`, `.killed`); dblclick (pointer timing, 300 ms) = default (VID 0.5, AUD 0), restored; `.pf-arc`, `.pf-ptr` SVG. Messages 'Deck A audio · −12.0 dB', 'Deck B in OUT · 50%' (+ ' · killed' / ' · restored').
- Deck volume in `__perfDraw`: `mg(d,k)` = 0 when `d.mixK[k]`, else `d[k]`; `vol(d, mg(d,'audGain')²)` (audio taper); OUT `outGpu.draw(texA, texB, mg(DK,'outGain'), mg(DB,'outGain'), OUT_MODE)`.
- Video mix modes: `OUT_MODE` (0 to 15, session; `let` beside `_perfGpu`); `PERF_MIX` (WGSL, uniform `M {ga, gb, mode, pad}`; 0 MIX, 1 NAM, 2 ADD, 3 SCREEN, 4 MULTIPLY, 5 OVERLAY, 6 DIFFERENCE, 7 LUMA, 8 DARKEN, 9 SOFT LIGHT, 10 EXCLUSION, 11 INV LUMA, 12 SUBTRACT, 13 DODGE, 14 BURN, 15 COLOR); buttons `.pf-modes` > `.pf-mode` × 16 (`tabindex 0`; labels MIX NAM ADD SCRN / MULT OVER DIFF LUMA / DARK SOFT EXCL INVL / SUB DODGE BURN COLOR), the mode in use `.pf-on`; `MODES` (local: `[name, what it does]`); `pick(i)`: click or Enter; message 'Video mix mode NAME: …'.
- Panel strip: `.pf-pwrap` > `.pf-panelrow` (`eqBtn`, `fxBtn`, `modeBtn`: EQ, FX, MODE `.btn.loop.pf-fxbtn`, built by `pBtn`); drawer window `.pf-fxpanel` (`fxWin`, `overflow:hidden`, `.open`; inserted after `fxWrap`) > `.pf-fxslide` (`translateY(-100%)` → 0, 0.26 s) > three `.pf-fxin` panes: `modePan` (`.pf-modes`), `fxPan` (`.pf-eqpan` > `.pf-eqgrid.pf-fxcols` > 4 × `.pf-eqcol`: `fxCell` A v, A a, B a, B v; slots 0, 1), `eqPan` (`.pf-eqpan` > `.pf-eqgrid` > 4 × `.pf-eqcol`: `eqCell` A RGB, A EQ, B EQ, B RGB; bands 2, 1, 0 top to bottom); `fxPlace()` (strip width, 6 px under it, to the LIBRARY module's bottom), `fxShow(which)`, `fxOpen` ('eq' | 'fx' | 'mode' | null); Tab on a strip button with a drawer open focuses the drawer's first `.pf-fxk, button.pf-fxsel, .pf-mode`. Help: `dataset.msg` ending "(W A S D move)".
- W A S D / M / Escape: one `document` `keydown` listener (capture), skipped with Ctrl / Meta / Alt and in INPUT / TEXTAREA / contenteditable. M (PERFORM only, `on()`): focus `.pf-encs .pf-enc` (A VID), message 'Mixer: W A S D move · arrows = level · Enter = kill / open · Escape = out of a drawer'. Items = the four `.pf-encs .pf-enc` + `eqBtn`, `fxBtn`, `modeBtn` + the open pane's visible `.pf-fxk, button.pf-fxsel, .pf-mode`. Escape on a drawer item → its strip button. W / A / S / D = `[0,-1] [-1,0] [0,1] [1,0]`: nearest item by centre with along > 4 px and across ≤ 1.2 × along, score along + 3 × across; nothing selected and a drawer open: the drawer's first item.
- EQ / RGB: `fxInit(d)` sets `d.eq` `[0,0,0]`, `d.rgb` `[1,1,1]`, `d.eqK`, `d.rgbK` `[false,false,false]`; `fxWire` builds `R.eq` (BiquadFilter `lowshelf` 70, `peaking` 1000 Q 0.7, `highshelf` 13000) chained LOW → MID → HIGH → `R.inp`, and connects `pre` to `R.eq[0]` when `window.__eqOn(d)` (PERFORM shown), else to `R.inp`; `eqApply(d)` (gain = `d.eq[i]`, −26 when `d.eqK[i]`; `setTargetAtTime` 0.01); `EQ_BANDS` `['LOW','MID','HIGH']`, `RGB_CH` `['RED','GREEN','BLUE']`; `eqCell(d,i,vis)` → `.pf-encw` > `.pf-enc.pf-fxk` (`.pf-v` when visual) + `.pf-encl` + `.pf-fxsel.pf-eqval` (`.v`); EQ knob: left −26 dB, centre 0 dB, right +6 dB; RGB knob: left 0, centre 1, right 1.33; both snap to the centre within 0.004 of the turn; drag over 150 px, ↑ / ↓ ±0.01, ← / → ±0.05 of the turn; click = focus; Enter = kill / restore; dblclick = centre, restored; `eqCells` (ui refreshers). RGB pass: `vfxRun(…,rgb)` writes `[14, r, g, b, w, h, …]` and runs `PERF_VFX` kind 14 after the VFX slots, only when a gain is off 1; kills as 0.
- FX (shared engine, above PERFORM's block): `fxInit(d)` → `d.fx` `{a:[slot,slot], v:[slot,slot], au, inp, out}` (+ `eq`, the three filters, set by `fxWire`), slot `{name,amt,killed,node,gen}`; `FX_LIVE` (functions: does this deck's rack play); `AFX` (Filter `n` 0.5 bipolar, Washout, Dubby, Delay, Reverb, Flanger, Phaser, Bitcrush), `VFX` (RGB Split, Feedback, Glitch, Pixelate, Scanlines, Mirror, Kaleidoscope, VHS, Shake, Tone, Tile, Rotate, Zoom), `AFX_NAMES`, `VFX_NAMES`; `mixer(c,fin,fout,set)`, `echo(c,fixed,dub)`; `fxWire(d)` (`pre` → [EQ when `__eqOn`] → `R.inp` → AFX1 → AFX2 → `R.out` → gain where `FX_LIVE`, else `pre` → gain; rewires when `live|eq|slots` changes); `fxDiv()`, `fxBeat()`; `FXQ`, `fxLater(run,armed)`, `fxTick()`; `fxCell(d,dom,i,one)` → `.pf-encw` > `.pf-enc.pf-fxk` (`.pf-v` = visual) + `.pf-encl` (AFX1, AFX2, VFX1, VFX2) + `button.pf-fxsel` (`.v` = visual; `one` = no deck name); knob `pointerup`: a click = focus (select), a second within 300 ms = `reset()` (default amount, unmuted, `s.gen` drops the armed kill); Enter = `kill()` on QUANT (`.armed` while waiting); `fxCells` (ui refreshers); GPU: `PERF_VFX` post pass (kinds 1 to 13 the effects, 14 the RGB gains), `vfxLive(d)`, `vfxState(device)` (`fxA`, `fxB`, `prev`, `vbuf`), `vfxRun(device,PG,st,enc,src,d,cw,ch,rgb)` → final texture (`rgb` = the RGB pass too, PERFORM); `window.__fx` (tests); `window.__fxTick`, `window.__fxLiveDK()`.
- LIBRARY (shared, above PERFORM's block): `LIB` `{tracks, shaders, filter, sel, noAmu, queue, queueOn, views, lists}`, `libKey()`, `shStem()`, `libImport(files,quiet)`, `libRender()` (every view) / `libRenderView(v)`, `onDeck(e)`, `window.__libLoad(id,d)` (returns a promise; a stand-in MP3 is fetched from `_url`), `window.__libImport`, `window.__libTick`; `libView(box,o)` → view `{box, keys, rows, decks, hdr, shuf}` (`o.decks`, `o.keys`, `o.help`, `o.qhelp`; one deck: double-click timed by `box._tapId` / `box._tapT`, 400 ms); list `.pf-lib` (focusable, `touch-action:manipulation`; keys ↑ ↓ ← → Delete / Backspace), filters `.pf-libfrow` > `.pf-libf` (ALL, then `.pf-libq` QUEUE (`.dis` until a playlist), MUSIC, SHADERS, then `.pf-libpl` per demo playlist, filter `pl:<i>`); `libFilterUI()`, `queueUI()`, `libListButtons()`; entry states selected (cyan border), loaded (Yellow Man tint); drop zones: PERFORM's MIXER column, CREATE's `#labLibSec`.
- Demo playlists: `libWebSet()` (http / https): `./examples/library.json` `{files, playlists:[{name,file}]}`; audio → stand-in `{name, type, _url}`; AMU `.json` → stand-in `{_url, _lazy, text()}`; others fetched; `libImport(fs,true)`; each playlist → `LIB.lists` `{name, paths}`, `#EXTINF` → track name 'Title · Artist'; `LIB.filter = 'pl:0'` when any.
- Playlist: `LIB.queue` `{name, paths}`, `queueResolve(list)` (tail match on `f._rel`, file-name fallback; `list` = a demo playlist) → `{ids, noAmu, notFound}`, `queueMsg()`; message 'Playlist NAME: N queued · N no AMU · N not found'.
- `vol(d,v)`: deck gain to `audGain`² on PERFORM (0 when killed), deck A at 1 on CREATE.
- `window.__perfDraw()`: per frame while PERFORM is shown: master PLAY label, `fxTick()`, fit, MASTER indicator, `v.codeSync()`, deck GPU draw (shader + VFX + RGB), waveform, cover, position, info line, lanes, buttons, roll; OUT draw (with `OUT_MODE`); TEMPO field value.
<!-- @/tags -->

---

# 9. Node: Authoring

See C 9.

- Per-shader block: `RULES` (R11, R12, R13, then R1 to R10), `NOTES`, `BUILD`, `TEMPLATE`, `WGSL`, `AMU`, `SPECDOC`, `CHANGELOG`, `RIG`, `PART_PATCHES`, `CRYPTO_PATCHES`, `OV_PRELUDE`, `OV_V`, `OV_H`, `OV_AP`, `OV_FRAME_M`; authoring pack `TRACK_INFO`, `TRACK_MP3`, `TRACK_COVER` (loaded on open via `dataBlob`).
- `AUTH_GPU`: `init(device)`, `patch(src)`, `entries()`, `write(queue)`, `copy(enc)`, `read(rd)`; preview bindings in `@group(3)`: 1 object mask `partMask` (`vec4<u32>`, `partMaskWords()`), 2 overlay probe `gprobe` (storage, `array<f32, 64>`), 3 CRYPTOMATTE `cm` (`cmTable()`).
- R13 (settings) and the standard fourteen (C 9.5): the default scene `WGSL` declares the settings block and 14 `// @setting` lines (SCALE `settings[0].x`, ROTATION `.y`, OFFSET_X `.z`, OFFSET_Y `.w`; SPEED `settings[1].x`, REACT `.y`, HUE `.z`, VALUE `.w`; PIVOT_X `settings[2].x`, PIVOT_Y `.y`, TILE `.z`, TIME_OFFSET `.w`; SATURATION `settings[3].x`, CONTRAST `.y`); WGSL `stdFrame(p0, asp)` (TILE, then rotate / zoom around PIVOT, then OFFSET), `stdHSV(c)` (HUE, SATURATION, VALUE), then CONTRAST around 0.5; the tunnel clock `f(13) * settings[1].x + settings[2].w`, gates × `REACT`. A shader's own settings from `settings[4]`.
- Objects / CRYPTOMATTE: `partOn`, `partMaskBits`, `cmOn`, `cmHex(b,i)`; `#authWrap`, `#partsAll`, `#cmMode`, `#bgrid .tile`.
- Overlay: `OV` `{grid,guides,points,probe,pending,n,tap}`, `OV_N`, `ovProbeWGSL()`, `drawOverlay(cv)`; `#labOverlay`, `#ovGrid`, `#ovGuides`, `#ovPoints`.
- Readout: `#labMsg` (AUTHORING only).

---

# 10. Node: Tabs and DOM

See C 10.

- `.tab[data-panel]` + `switchPanel(name)`, order: CREATE (`lab` → `#panelLab`), PERFORM (`perform` → `#panelPerform`, `#tabPerform`), AUTHORING (`author` → `#panelLab` in author mode, `#tabAuthor`), HELP (`help` → `#panelHelp`), ABOUT (`#panelAbout`), LEARN (no panel → `window.openLearn()` → `https://onemanshyo.com/#learn`). Opening: `setMode(authorOn); if(authorOn) switchPanel('author')`.
- HELP: `#panelHelp` > `.sec-hdr` (`Let's do this`) + `#labLetsDo` (grid of two `ul.cr-tips`).
- Header: `.header` > `.hdr-left` > `.brand` > `#brandTxt` (`ONEMANSHYO`) + `.sub` + `.ver`.
- CREATE panel: `#labWrap` (the deck's drop zone), `#labModeHdr`, `#labModeTxt`, `#labMusic`, `#labFaceBox`, `#labStage`, `#labGpu`, `#labGpuMsg`, `#labOverlay`, `#labCodeBtn`, `#labSetBtn`, `#labCodeView`, `#labCode`, `#labApply`, `#labCopy`, `#labSave`, `#labCodeMsg`, `#labTransportHold`, `#labPlay`, `#labLoop`, `#labKeyLock`, `#labZoomTxt`, `#labRollBtn`, `#labSolo`, `#labNextBtn`, `#labContBtn`, `#labShufBtn`, `#labFxBtn`, `#labFxPanel`, `#labLeftCol`, `#labLibSec`, `#labMuSec`, `#labMuHdr`, `#labMuTxt`, `#labAMU`, `#labRollWrap`, `#labRoll`, `#labMsg`, `#labTempoVal`, `#labQuantVal`, `#labRecTime`, `#labMini`, `#messageBar`.

---

# 11. Design System values

See C 12 (narrative, rules and the interaction matrix).

<!-- @tags: DESIGN_SYSTEM, HIG -->
## 11.1 Classes
`.app`, `.header`, `.tabbar` / `.tab`, `.sec-hdr` (`.bar`, `.txt`, `.rule`), `.btn` (`.primary`, `.mag`, `.loop`, `.solo`, `.armed`), `.bgtoggle`, `.pf-gf`, `.pf-pos`, `.pf-global`, `.cr-global`, `.pf-col`, `.amu-mod` / `.amu-bus` / `.amu-cells` / `.amu-cell` / `.amu-knob`, `.lab-lane`, `.drop-hint` (`.dh-main`, `.dh-sub`), `.message-bar`; PERFORM mixer column `.pf-mod`, `.pf-mixmod`, `.pf-encs`, `.pf-pwrap`, `.pf-panelrow`, `.pf-fxbtn`, `.pf-fxpanel`, `.pf-fxslide`, `.pf-fxin`, `.pf-eqpan`, `.pf-eqgrid`, `.pf-fxcols`, `.pf-eqcol`, `.pf-encw`, `.pf-enc`, `.pf-encl`, `.pf-fxk` (`.pf-v`, `.killed`, `.armed`), `.pf-fxsel` (`.v`), `.pf-eqval`, `.pf-modes`, `.pf-mode` (`.pf-on`), `.pf-libmod`, `.pf-libfrow`, `.pf-libf`, `.pf-libq`, `.pf-libpl`, `.pf-lib`; CREATE `.lib-drop`, `.cr-libin`, `.cr-fxgrid`, `.cr-ptog`, `.cr-pnext`, `.mu-body`, `.cr-tips` (HELP); Settings drawer `.set-win`, `.set-left`, `.set-pnl`, `.set-txt`, `.set-val`, `.set-empty`; PERFORM Code `.pf-code`, `.pf-codeview`, `.pf-capply`, `.pf-ccopy`, `.pf-csave`, `.pf-cmsg`, `.pf-codeta`, Settings `.pf-set`; `.pr-pwr` (power light).

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

Song info line: `.pf-info` / `#songInfo` (AUTHORING), 11px Courier New #cfd6dd on rgba(10,10,10,.85), padding 1px 10px, inset 2px, `pointer-events:none`; scroll ~40 px/s, 48 px gap between repeats.

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

## 11.5 Lines and modules
- Standard line: 1px solid #2a2a2a, radius 6px.
- Module `.pf-col` (decks) and `.pf-mod` / `.pf-pwrap` (the mixer column's three modules): the line, padding 8px, no background (the panel strip and drawer #0a0a0a); the mixer column itself has no line.
- Drawer `.pf-fxslide`: 1px #2a2a2a, no top border, radius 0 0 6px 6px, #0a0a0a; slides 0.26 s. Sideways (`.set-left .pf-fxslide`): 1px #2a2a2a, no right border, radius 6px 0 0 6px, `translateX(100%)` → 0.
- Knob module `.pf-eqcol`: 1px #2a2a2a, radius 6px, #0a0a0a, padding 8px (FX 8px 4px).
- Inner boxes with a fill (`.pf-mu`, `.pf-wf`, `.pf-global`): #0a0a0a; stage `.pf-stage`: #060606.
- CREATE's LIBRARY module `#labLibSec`: the line, background the page gradient `linear-gradient(135deg,#0c0c0c,#1a1a1a) fixed`. HELP modules `.cr-tips`: #0a0a0a, 1px #2a2a2a, radius 6px.
- Moogerfooger strip on the main app: `#prSafeTop` 26 px, left / right 22 px.
- Section header `.sec-hdr`: `.bar` 3 × 13 px radius 1px, `.txt` 600 11px Courier New uppercase letter-spacing 1px, `.rule` 1px #262626, gap 8 px.

## 11.6 Colours
- Key colours: Purple People Eater #B24DFF · Barbie Pink #E0218A · Green Slime #65FF00 · Yellow Man #FFF000 · Orange Julius #FFA500 (brand) · Goblin White #FFFFFF · Red Hots #FF006E (key). Listed in the comment at the top of `<style>`. One shade of each; dim forms = the same colour at lower opacity.
- Domains: visual **#B24DFF** (Purple People Eater), audio **#00d4ff**. A control's arc, value box, active state and selected ring take its domain colour. Visual: mixer VID (`.pf-v`), VFX knobs and effect boxes, RGB knobs and values, the Settings rack (`COL`, `.set-pnl .set-val`, `.set-pnl .pf-enc:focus`), the video mix modes (`.pf-mode.pf-on`, `.pf-mode:focus`), the VFX "waiting for QUANT" ring (`.pf-fxk.pf-v.armed`). Audio: mixer AUD, AFX knobs and boxes, EQ HIGH / MID / LOW. LIBRARY entry dots: audio cyan, shader purple. Visual boxes `.pf-fxsel.v`: #B24DFF, border rgba(178,77,255,0.35); audio boxes `.pf-fxsel`: #00d4ff, border #2c5560. EQ · FX · MODE keyboard ring: #00d4ff.
- Killed control: opacity 0.35 (`.pf-fxk.killed`).
- Chrome and section headers cyan #00d4ff; authoring sections Orange Julius #ffa500 (`AUTH`).
- Messages: info #00d4ff · state #ffa500 · error #ff006e; bar background linear-gradient(180deg,#222,#2a2a2a), top 1px #444, 13px Courier New, 30 px high.
- Red Hots #ff006e also: `.btn.mag`; GPU errors on a stage (`#labGpuMsg`, `.pf-msg`) #FF006E; header and Pocket Rave brand gradient linear-gradient(45deg,#00d4ff,#ff006e); Pocket Rave stage border while playing (`.pra-visual.playing`).
- Bus colours (`GRP`): rhythm #FF006E · structure #FFA500 · key #FFF000 · pace #65FF00 · loudness #00a8ff · instruments #B24DFF.
- Lane colours (`LANES[].col`), each its bus colour: beat #ffffff · bar #FF006E · section, segment, phrase #FFA500 · key #FFF000 · pace #65FF00 · loudness #00A8FF · drum, bass, vocal, other #B24DFF.
- Solo on PERFORM lanes: `.amu-cell.key` border and 6px glow in the lane colour; `.amu-cell.dim` opacity 0.3.
- Active and recording: Barbie Pink #E0218A: SOLO on (CREATE panel) text and border, glow rgba(224,33,138,0.5); roll playhead; Pocket Rave waveform playhead; REC button; position box while REC (11.3).
- Picked chip being rendered (roll): band rgba(255,240,0,0.16), edge #FFF000.
- Drop highlight: dashed cyan edge, translucent blur; hint `.dh-main` cyan 13 px, `.dh-sub` grey 11 px, one type per line, padding 16 px, centred.
- LIBRARY entry: selected = cyan border; loaded on a deck = Yellow Man tint rgba(255,240,0,0.10); list focus = cyan ring.
- Purple People Eater #B24DFF also: ABOUT credit labels and PLUR, Pocket Rave PLUR (`.pr-plur`), authoring overlay anchor points.
- Header rename: `#brandTxt[contenteditable]` outline 1px dashed #00d4ff, caret #00d4ff.
- Shader WGSL colours belong to the shader, not the design system.
<!-- @/tags -->

---

**END OF SYSTEM REFERENCE**
