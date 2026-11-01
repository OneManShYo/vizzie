# OMS Vizzie app [Beta V0.9.0] Complete Changelog

**Run date:** 2026-11-01  
**Current Unix Epoch:** 1793543222  
**Document purpose:** The readable version of the PM backlog: the BLOGs each release packaged, grouped by release, newest first, with the builds that carried them.  
**Filename:** OMS_Vizzie_Beta_V0_9_0_B_Complete_Changelog.md  

## About this document

Vizzie Beta V0.9.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

Versions are major.minor.iteration; a full package rolls the minor, and the iteration line before it becomes that release's iterations. Letters are revisions of the same piece of work.

---

## V0.9.0

Packages the V0.8 iteration line (V0.8.01a to V0.8.50a). Baseline V0.8.50a. PERFORM arrives (off-site, in development): two decks and a mixer on the one master clock, with QUANT, the tempo master and a global strip. CREATE takes the same deck controls, strip and design-system rules. The Message System core is built but parked.

- **PERFORM tab** (BLOG0064 · V0.8.03a, 35a): Off-site only while in development. DECK A | MIXER | DECK B fitted to the window. Deck A is the CREATE deck; deck B is a second deck on the master clock with its own stage, shader, waveform, transport, lanes and roll. Tab order CREATE, PERFORM, ABOUT, LEARN; CREATE opens (35a).
- **Deck controls as one code** (BLOG0075 · V0.8.06a, 07a to 07e, 08a): One deck-controls module (lanes, transport buttons and state, waveform draw and seek, drops, pickers, shader load, deck info) used by CREATE, both PERFORM decks and Pocket Rave's pickers; the per-view copies deleted (07a). The PERFORM rolls take CREATE's scrub and cue (06a). One drop zone per deck, the whole deck, each file read by its type, one to three at once (07b, 07c), with a drop layer over the deck naming what drops there (07d). Roll zoom, orientation and the double-tap loaders on every deck (07e). Every deck opens paused with LOOP off on every surface (08a).
- **PERFORM layout** (BLOG0075 · V0.8.14a, 17a to 27a, 29a to 34a, 37a): Each deck is a thin-line module: header DECK | KEY LOCK | MASTER; the stage in the standard line; a 40 px row with the cover and waveform, the song info on one scrolling line over the waveform, which stays usable under it; a row PLAY | zoom | orientation | position .... SOLO; the Music Understanding lanes with their group buses, without labels (the coloured knob is the lane, buses are thin colour bars, solo shows on the knob); the roll below. No Code, REC, CUE or LOOP on PERFORM. Buttons hug their labels in the small-button style, PLAY / PAUSE keeps one width, MASTER is a standard toggle, one 8 px gap between controls. The roll zoom is a field in five steps, 0 to 100; rolls open at 25 %, horizontal.
- **KEY LOCK on by default** (BLOG0075 · V0.8.28a): Every deck opens with KEY LOCK on.
- **Cover art on PERFORM decks** (BLOG0075 · V0.8.32a): Fix: the ID3 picture is copied before decoding, which detached the buffer and left PERFORM decks without cover art.
- **CREATE parity with PERFORM** (BLOG0075 · V0.8.39a, 41a to 43a, 47a, 49a): The one-line song info on CREATE (39a). Header "Music Understanding" with its controls moved to the row; zoom as the field; LOOP removed from every deck (41a). Buttons hug their labels, 8 px gaps throughout CREATE (42a). Row PLAY | KEY LOCK | zoom | orientation .... SOLO (43a). The position box to the global strip in both modes (47a). Zoom fields centred as standard fields (49a).
- **CREATE public layout** (BLOG0075 · V0.8.45a, 46a, 50a): The public layout is its own layout: the static song info panel (45a); the position in the global strip (46a); the authoring controls row under the music in place of its own big transport, the cover and waveform taking the freed height (50a).
- **Global strip** (BLOG0096 · V0.8.10a, 12a, 15a, 40a, 44a, 48a): A thin strip across the top, as Ableton's top bar, for set-and-leave settings (10a). Bare fields, no labels, no − / +, no % (12a). TEMPO ← / → for the decimals (15a). The same strip on CREATE with TEMPO and the position (40a); the public layout fixed after 40a by finding its rows by label (44a). PERFORM's master position (48a).
- **QUANT** (BLOG0078, BLOG0094 · V0.8.09a to 09c, 13a): A per-deck SYNC / QUANT strip first (09a), then one master QUANT value in music time: each deck lands its own AMU point on the master's step; forward only; acts only where decks are mixed; a lone deck leads the master grid (09c). Values cut to None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars (13a). Fix: a seek or load on one deck no longer stalls another (09b).
- **Tempo master** (BLOG0079, BLOG0095 · V0.8.11a): The playing deck sets the tempo, as Traktor AUTO / CDJ master; the tempo range and double-click follow the master deck; a MASTER indicator per PERFORM deck.
- **OUT and mixer encoders** (BLOG0076, BLOG0077 · V0.8.04a, 05a, 05b, 36a, 38a): Each deck renders into its own texture; OUT blends them at the VID strengths (04a). Four encoders A VID, A AUD, B AUD, B VID; AUD = deck volume (05a). VID in the visual-domain purple #aa00ff (05b). The Pop Out placeholder removed (36a). VID encoders open at 12 o'clock (38a).
- **Message System core** (BLOG0100 · V0.8.16a, 16b, 16c): `showMessage` as Dojo's, hover help on every control and label from one table, idle = empty bar, per-element hover binding. Parked: hover help stops showing in Chrome after switching to PERFORM.
- **REC renders the track; arrangement position** (BLOG0092 · V0.8.01a, 01b): REC on a paused deck renders the track from its start to its end; the position box in bars.beats.sixteenths with four places for the bar.
- **Default scene: Squint size** (BLOG0093 · V0.8.02a): Yobot Squint sized as in HalloweenBounceFeatSquint V60 at 16:9.

---

## V0.8.0

Packages the V0.7 iteration line (V0.7.01a to V0.7.06b). Baseline V0.7.06b. The deck becomes a component on one master clock, a track's AMU JSON can be loaded, and the authoring template gains the camera grid, the music-time rule and the authoring pack.

- **Authoring pack** (BLOG0090 · V0.7.06a, 06b): The shader HTML can pack the song it is authored against: per-shader slots `TRACK_INFO`, `TRACK_MP3`, `TRACK_COVER` beside the AMU (empty in the template = Ain't No Trick). A packed MP3 and cover load on open from anywhere, so the song survives every iteration and the file can be sent as one; the `.wgsl` stays lean. RULES R12 tells the author how. The artist and year that were hard-coded in app code now come from `TRACK_INFO`.
- **Template states music time first** (BLOG0091 · V0.7.05a): RULES R11, listed first, and a MUSIC TIME line at the top of TECHNICAL: positions are bar.beat (62.1 = bar 62, beat 1), lengths in bars or beats, never seconds; bar.beat B.N = beat (B − 1) × 4 + (N − 1) in `vizzie.time`.
- **Load a track's AMU JSON** (BLOG0073 · V0.7.04a): Drop a Sozo Sidecar v2 `.json` on the music row, or pick it with the MP3 picker: it is converted to the compact AMU and the deck switches to that track (warp map, lanes, roll, readout; playhead to the start; TEMPO to the track's BPM). Audio and AMU load in either order; a length mismatch between them is reported. The readout's key comes from the track (it was a fixed E).
- **Authoring grid follows the shader camera** (BLOG0089 · V0.7.03a): World units are always metres and framing is the camera's job (RULES R10). A shader declares its camera in `OV_PRELUDE` (`ov_origin`, `ov_m`), with or without guides, and the grid steps with it: major = the largest power of ten not above the frame height, minor = a tenth (2 m frame: 1 m / 10 cm; 20 cm: 10 cm / 1 cm). A corner label names the step.
- **Two decks from one deck code** (BLOG0074 · V0.7.02a): `MASTER`, the master music clock (beat, tempo), is split from `makeDeck`, one track on that clock (its AMU, warp map, position in its own beats, audio engine, KEY LOCK, lane knobs and solos, play and loop). CREATE shows deck A; a second deck runs on the same clock and is steered the same way (tested headless). No visible change.
- **KEY LOCK as its own button** (BLOG0088 · V0.7.01a): KEY LOCK leaves the TEMPO module and becomes a transport button in LOOP's toggle style, as on Pioneer hardware. Transport order: PLAY · LOOP · KEY LOCK · TEMPO. The TEMPO tile keeps three rows with even space above and below.

---

## V0.7.0

Packages the V0.6 iteration line (V0.6.01a to V0.6.22a). Baseline V0.6.22a. CREATE becomes one app with PUBLIC and AUTHORING modes and carries the shader authoring template; the music clock moves to bars and beats; the deck plays through Web Audio with TEMPO and KEY LOCK.

- **Default scene: AMU test tunnel + Yobot Squint** (BLOG0087 · V0.6.16a): The template's default scene is the AMU test tunnel as the background, every lane drawn and gated by its knob, with Yobot Squint as seven objects on top. Its motion rates were restated per beat in V0.6.22a.
- **`vizzie.time` in cumulative beats** (BLOG0072 · V0.6.22a): Slot 13 carries the master clock's beat count (beat 0 = the first AMU beat) instead of song seconds; uniform contract V0.4.0C → V0.4.0D, only slot 13's unit changes. No seconds slot is kept. Shaders that drive motion from `vizzie.time` restate their rates per beat (handoff: `OMS_Vizzie_Beta_V0_6_22a_VizzieTimeShaderMod.md`).
- **Piano roll axis in beats** (BLOG0085 · V0.6.21a): The roll's window, zoom, scrub and cue-on-click work in master-grid beats: 16 beats (4 bars) in AUTHORING, 32 (8 bars) in PUBLIC. Lanes sit at their beat on the warp map, so 4 bars stay 4 bars at any TEMPO. The waveform stays a whole-song view.
- **Warp the deck to the master grid** (BLOG0084 · V0.6.20a): Smooth warp. The master clock advances on an even grid at the TEMPO; the track is mapped onto it by its AMU beats, smoothed by a line fit over ±8 beats; the deck's audio is steered every frame (speed = the map's local tempo × TEMPO, plus a pull of at most 2 % that closes a gap over about a second; a gap over 250 ms is jumped).
- **Web Audio deck engine with KEY LOCK** (BLOG0083 · V0.6.17a, 18a, 19a, 19b): The deck plays its decoded track through Web Audio (`makeDeckAudio`) instead of an `<audio>` element, on the audio hardware clock. TEMPO sets the playback rate (BLOG0079, built early in V0.6.18a; that BLOG stays open for PERFORM's tempo source). KEY LOCK runs a WSOLA time-stretch in an AudioWorklet, with onsets found once per track so drum attacks keep their snap.
- **Master music clock as clock of record** (BLOG0082 · V0.6.15a): `CLOCK.beat`, a position in beats on the track's AMU beat grid, is the clock of record; seconds are read and written only through the track's beat map.
- **Master music clock in bars and beats, AMU warp** (BLOG0071 · V0.6.15a to 22a): The story the four tasks above deliver for the single deck: AMU beats act as automatic warp markers onto one master clock in bars and beats. Two-deck sync continues in BLOG0078.
- **Shader authoring template carried by the app** (BLOG0070 · V0.6.08a to 14a): No separate template version line: a copy of the app HTML at any build is the authoring template. The per-shader block (TECHNICAL to the overlay slots) is segmented from the app code; renderer hooks live in `AUTH_GPU`, mode values in `MODES`. Overlay guides are generic: a shader's `OV_PRELUDE` sets `ov_origin` and `ov_m`.
- **Responsive design, host check and surface rendering** (BLOG0069 · V0.6.04a): Two checks pick the surface: the host check (public site or off-site, read once) and the compact viewport (portrait, or 500 px tall or less, re-checked live). Neither detects the device. Names in the code match (`compactMQ`, `isCompact()`, html class `compact`).
- **AMU structure as cue points** (BLOG0068 · V0.6.07a): A click on a block in the piano roll cues to that block's start (beat, bar, section, segment, phrase, key span, pace step). Nothing is saved; the cues come from the AMU data.
- **CREATE: double-tap loaders for parity** (BLOG0067 · V0.6.03a): Double-tap the cover or the waveform for the MP3 picker and the shader for the `.wgsl` picker, as in Pocket Rave. Drag and drop unchanged.
- **AMU piano roll: orientation toggle and interaction** (BLOG0065 · V0.6.05a, 06a, 07a): Vertical or horizontal roll, drag to scrub, zoom with a fixed centre playhead (− / +, pinch, ctrl + wheel), zoom shown as the share of the song in view.
- **Phone authoring layout** (BLOG0063 · V0.6.02f to 02k): Off the public site on a compact viewport, AUTHORING takes Pocket Rave's frame and header with the authoring sections in one column. It can be forced on a wide viewport, where it shows as a 430 px column.
- **Pocket Rave: full-frame default, header cycle, combined music row** (BLOG0062 · V0.6.02a to 02k): Pocket Rave opens full frame; the ONEMANSHYO header toggles full frame and the normal view (off-site a further tap goes to compact authoring); the cover sits beside the waveform; a double tap on the shader in the normal view loads a `.wgsl`.
- **CREATE: Public and Authoring modes in one app** (BLOG0061 · V0.6.01a to 01h, 02l, 02m): Built on ShaderTemplate V11 with the V0.6.0 parts ported in. The public site opens PUBLIC (the V0.6.0 CREATE layout); anywhere else opens AUTHORING (the template layout with the authoring sections). The same elements move between the two arrangements; the VISUAL header switches them off-site. Orientation adds 1:1.

---

## V0.6.0

Packages the V0.5.0 iteration line. Baseline V0.5.04a. Pocket Rave work: song card, double-tap loading, expanded mode.

- **Expanded mode** (BLOG0060 · V0.5.04a): Tap the footer Yobot: the tabs, song card, waveform, version line and footer fold away and the shader fills the frame under the ONEMANSHYO header; the border fades out. Tap anywhere off the shader to come back.
- **Header logo links to onemanshyo.com** (BLOG0059 · V0.5.04a): The link moves from the footer Yobot to the ONEMANSHYO logo in the Pocket Rave header.
- **Double-tap the shader to load a .wgsl** (BLOG0058 · V0.5.03a): A single tap still plays and pauses; a double tap opens the device file picker for a `.wgsl` shader.
- **Double-tap the cover to load an MP3** (BLOG0057 · V0.5.02a): Opens the device file picker; tags, cover, waveform and audio load the same way as a desktop drop.
- **Song card** (BLOG0056 · V0.5.01a): Pocket Rave's song info is a card showing the cover art only. Tap it to flip to the title, artist, label, year and copyright, one line each, no wrapping.

---

## V0.5.0

Packages the V0.4.0 iteration line. Baseline V0.4.02a.

- **LEARN opens the website** (BLOG0055 · V0.4.02a): The LEARN tab, on desktop and on phones, opens the learning page on onemanshyo.com in a new tab. The in-app LEARN panels are gone; the learning content lives on the site only.
- **Waveform scrub** (BLOG0054 · V0.4.01a): Click or drag on the waveform, on desktop or on phones, to move the playhead; the shader follows. Works with or without audio loaded.

---

## V0.4.0

Packages V0.2.x, V0.3.0 and V0.3.1. Baseline V0.3.1. WebGPU/WGSL becomes the only renderer.

- **Beta stripped, alpha promoted** (BLOG0053 · V0.3.1): The original Canvas visual and everything built around it (beta Music panel, session-view timeline, beta waveform, beta Pocket Rave, parameter pills, beta transport, hidden Yo Lab unlock) were deleted. The Yo Lab became the CREATE tab. One shader viewer serves desktop and phone, moving between them as the screen changes; the pop-out mirrors it. Fixed on the way: the phone waveform never drew.
- **Separate alpha/beta deploy channels** (BLOG0050 · closed, superseded by BLOG0053): Not built. Promoting the alpha and deleting the beta removed the problem with one deploy.
- **Invented values stripped, raw AMU passed** (BLOG0052 · V0.3.0): Beat/bar flashes, the invented loudness floor, and pace scaled to the track's own max were removed. Shaders now get raw momentary loudness (LUFS), raw pace, the key at the playhead (mode, tonic, key index), and beat/bar position. Shaders do their own scaling.
- **Fabricated break detection removed** (BLOG0051 · V0.3.0): "Break" was never AMU data; it was a guess from section length that mis-flagged short sections. Removed from the lanes, the visual and the default shader; its contract slots are reserved.
- **Pocket Rave Alpha** (BLOG0049 · V0.2.18a to c): Phones stay in Pocket Rave in both orientations: song info, the visual (tap to play), the waveform, footer. Clean tab switching.
- **Audio drag-and-drop, placeholders, Yobot default cover** (BLOG0046 · V0.2.17a to g): Drop an audio file on the song info box to load it. Placeholders until then, with the Yobot as the default cover.
- **Music info from MP3 tags** (BLOG0045 · V0.2.16a to b): Cover, title, artist, label, year and copyright are read from the file's ID3 tags. Nothing hardcoded.
- **Song info fit + click-to-enlarge cover** (BLOG0044 · V0.2.15a to b)
- **PLAY button casing** (BLOG0043 · V0.2.14a)
- **Piano-roll frame + centred playhead** (BLOG0042 · V0.2.13a)
- **Music-column layout + messaging cleanup** (BLOG0041 · V0.2.12a to d): Even three-way split, button sizing, all status moved to the bottom message bar.
- **Drag a WGSL file onto the visual** (BLOG0040 · V0.2.11a): Drop a `.wgsl` file on the viewer to load it.
- **Label pass + smart Apply** (BLOG0039 · V0.2.10a to c): MUSIC tab renamed CREATE; "Music Understanding Controls". Apply compiles a full shader as-is and wraps a fragment-only paste.
- **Record to video with audio** (BLOG0038 · V0.2.09a): Records the visual with the track's audio; MP4 where supported, WebM otherwise.
- **Viewer moved in-page** (BLOG0037 · V0.2.08a): The shader viewer no longer runs in an iframe. Direct uniform writes and hot-swap compiles; the reason it runs like a game engine.
- **Orientation toggle 16:9 / 9:16** (BLOG0036 · V0.2.07a to b)
- **SOLO moved to the controls header** (BLOG0035 · V0.2.06a)
- **Transport moved into the music column** (BLOG0034 · V0.2.05a)
- **Per-bus control modules** (BLOG0033 · V0.2.04a to b): Six bordered bus modules; each lane a cell with its chip above its encoder.
- **Rotary encoders** (BLOG0032 · V0.2.03a to g): Encoders under the AMU section: drag sets intensity, press solos, double-click resets.
- **About/Learn copy + Pocket Rave single source** (BLOG0031 · V0.2.01a to i): New About copy; Pocket Rave's About and Learn copy the desktop panels instead of duplicating them.
- **Alpha → Beta layout prep** (BLOG0030 · V0.2.02a to h): Info row above the controls: song info and waveform on the left, a true 16:9 viewer on the right.

---

## V0.2.0

Packages the V0.1.x line. Baseline V0.1.05v.

- **WebGPU/WGSL alpha** (BLOG0029 · V0.1.05a to v): A WebGPU version of the visual driven by an AMU-native uniform contract, with its own layout, a vertical scrolling piano roll, per-parameter knobs, and a live code editor with hot-swap compile. Needs HTTPS.
- **The Yo Lab: hidden R&D tab** (BLOG0028 · V0.1.04a to b, 04f): An experiment surface in the same file, reached from LEARN, off the public tab row.
- **Pocket Rave: portrait phone view** (BLOG0027 · V0.1.03a to c): A branded portrait-only view with tap-to-play that replaces the desktop app on phones.
- **Performance tuning** (BLOG0026 · V0.1.02a to b): Cached waveform and throttled timeline redraws ended the mouse/keyboard stall; the clock no longer sputters when the tab regains focus.
- **Example audio loads itself on the site** (BLOG0025 · V0.1.01a to b): The hosted page fetches the example track, so the waveform and audio are there with no upload.

---

## V0.1.0: first published release

Packages the V0.0.x development line, published to vizzie.onemanshyo.com.

- **LEARN simplified to a website pointer** (BLOG0024 · V0.0.21a to b)
- **Pop-out corner icon** (BLOG0023 · V0.0.20a): A small expand icon in the visual's top-right corner replaces the text button.
- **Colour system** (BLOG0022 · V0.0.19a to d): Rainbow bus headers (RHYTHM red, STRUCTURE orange, KEY yellow, PACE green, LOUDNESS blue, INSTRUMENTS violet); 12 pairwise-distinct lane colours plus white for beat; every parameter got its own colour-matched element in the visual.
- **End-of-track reset + loop** (BLOG0021 · V0.0.17a, 18a): At the end the playhead returns to zero and the transport resets; LOOP keeps it going from the start.
- **User-facing AMU→visual mapping** (BLOG0020 · closed, no build): Covered by the per-lane controls in the app plus the mapping table in the shader authoring template.
- **WGSL renderer path** (BLOG0019 · closed, no build): Realised through the Yo Lab alpha (BLOG0029), later the whole app (BLOG0053).
- **AMU parameter pills** (BLOG0017 · V0.0.4a to b): An early readout row; removed when the design system and timeline labels replaced it.
- **Controls above the waveform** (BLOG0016 · V0.0.15b)
- **Pop-out window at native resolution** (BLOG0015 · V0.0.15a, 16a): The visual in its own window, rendered at that window's resolution; double-click for fullscreen.
- **Solo any parameter** (BLOG0014 · V0.0.12a, 13d, 13f, 13g): Click a chip to solo a lane, a group header to solo a bus; solos stack; a master SOLO clears all. Soloed elements keep colour, the rest go grey but keep moving. Rebuilt onto one solo module after the first version's two id systems drifted apart.
- **Full-canvas visual + distinct palette** (BLOG0013 · V0.0.13a to c, 13e): A wheel that fills the frame width, one colour-matched layer per AMU parameter.
- **Session-view vertical timeline** (BLOG0012 · V0.0.11a): Parameters as columns, time running top to bottom, vertical scrub snapping to the bar.
- **Waveform view** (BLOG0011 · V0.0.10a to c): The real waveform from the uploaded audio, bar-aligned, playhead in sync; a placeholder before audio.
- **Transport controls** (BLOG0010 · V0.0.9h): Play/pause; spacebar toggles.
- **Tabs & chrome** (BLOG0009 · V0.0.9i to k, 14a to b): MUSIC / ABOUT / LEARN tabs, section relabels, unified header colours, inline status removed.
- **OMS message system** (BLOG0008 · V0.0.9e): Hover hints, action messages and errors in one bar at the bottom.
- **Full V2 AMU data on every lane** (BLOG0007 · V0.0.9c to d): Sections, segments, phrases, key, pace, loudness and per-instrument activity all drawn from the sidecar.
- **INFO section + song box** (BLOG0006 · V0.0.9a to b, 9f to g): Song box with cover and credits, and the visual in its own box.
- **OMS design system + header/logo** (BLOG0005 · V0.0.6a, 7a to b): Rebuilt inside the shared OMS design system with the Yobot logo and favicon.
- **AMU timeline** (BLOG0004 · V0.0.5a to c, 8a to c): From a single structure strip to a lane per parameter with bus groups and drag-to-scrub.
- **Every AMU field drives an element** (BLOG0003 · V0.0.3a)
- **Audio upload: the clock rides the real track** (BLOG0002 · V0.0.2a)
- **AMU-driven visual core** (BLOG0001 · V0.0.1a): One self-contained HTML file; the clock rides the musical timeline.

---

**END OF CHANGELOG**
