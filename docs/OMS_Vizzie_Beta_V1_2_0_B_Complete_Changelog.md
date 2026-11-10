# OMS Vizzie app [Beta V1.2.0] Complete Changelog

**Run date:** 2026-11-10  
**Current Unix Epoch:** 1794328405  
**Document purpose:** The readable version of the PM backlog: the BLOGs each release packaged, grouped by release, newest first, with the builds that carried them.  
**Filename:** OMS_Vizzie_Beta_V1_2_0_B_Complete_Changelog.md  

## About this document

Vizzie Beta V1.2.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

Versions are major.minor.iteration; a full package rolls the minor, and the iteration line before it becomes that release's iterations. Letters are revisions of the same piece of work.

---

## V1.2.0

Packages the V1.1 iteration line (V1.1.01 to V1.1.09k). Baseline V1.1.09k. The audio core is checked and fixed (KEY LOCK phase lock and sound, load thump) with five calibration tests written down; PERFORM gets changed-from-default dots and Shift+click resets, the Settings drawer joins the keyboard flow, and two Midi Fighter Twisters play the PERFORM mixer by the Hardware Perform Map. V1.1.01 to V1.1.05 carry no letter; the line is lettered from V1.1.06a.

- **KEY LOCK: phase lock to the grid** (BLOG0226 · V1.1.01, 02): The time-stretch worklet reports its real read position every 8 blocks and the deck's pull to its clock works from that report, not from a prediction; a late start begins in place. KEY LOCK decks no longer drift.
- **Load thump** (BLOG0227 · V1.1.02): A new audio path starts at the deck's volume (one function, `deckVol`, at load and every frame), so a load onto a deck with its AUD down or killed is silent.
- **KEY LOCK sound** (BLOG0228 · V1.1.03): The splice match is normalised cross-correlation over 1024 samples, searched ±512; the echo and muddy kicks are gone, and it costs less CPU.
- **Audio calibration tests** (BLOG0229 · V1.2.0 documentation): Drift, two-deck phase, load thump (six cases), KEY LOCK kick fidelity and CPU, written as one spec and reported in every audio build's notes (C 3.6).
- **Header name: 75 characters** (BLOG0224 · V1.1.04): Typing stops at 75, a paste is trimmed, Enter keeps what is shown; the bar counts while typing.
- **Tagline** (BLOG0231 · V1.1.05): The power light makes the name and the tagline editable; the tagline follows the name's rules. Default "Music makes magic!".
- **EQ and FX: changed-from-default dots** (BLOG0232 · V1.1.06a): Four dots per button in the drawer's column order, dim at default, a steady glow when changed.
- **EQ and FX: Shift+click reset** (BLOG0234 · V1.1.06b): Left third Deck A, centre both, right third Deck B; Shift+Enter both; the drawer stays as it is.
- **Settings drawer: keyboard** (BLOG0236 · V1.1.07a): Every rack knob is a stop; the keys stay in the open drawer; Shift+arrows step a value (colour: the hue); Enter opens a colour wheel.
- **Settings button: dot and reset** (BLOG0237 · V1.1.08a): Wider, one purple dot that glows while a setting is off its default, Shift+click resets them all (not on Pocket Rave).
- **Midi Fighter Twisters on PERFORM** (BLOG0238 · V1.1.09a to 09k): Two Twisters on factory settings, bound by a knob push (left Deck A, right Deck B), every MIDI input read, not by name; rings set and coloured by the app, so the knobs carry on from its values. The Hardware Perform Map is blueprint sheet 12.
  - **Gains, EQ and FX** (BLOG0240 · V1.1.09a to 09d): Turn and push as the knobs on screen; an EQ or FX knob opens its drawer; the EQ rows follow the drawer (HIGH / BLUE, MID / GREEN, LOW / RED).
  - **Library** (BLOG0241 · V1.1.09e, 09f): One cursor for both knobs over the LIBRARY buttons and rows; push presses or loads to the knob's deck; one stop per 8 counts.
  - **WF Cue** (BLOG0242 · V1.1.09g to 09j): A section cursor in Orange Julius; push jumps on QUANT and the cursor stays as a cue point; a chip waiting for QUANT is filled Orange Julius (was a cyan outline).
  - **AMU Solo** (BLOG0243 · V1.1.09k): A cursor over the deck's buses and lanes; push solos, a double push clears.

---

## V1.1.0

Packages the V1.0 iteration line (V1.0.01a to V1.0.31d). Baseline V1.0.31d. CREATE and PERFORM split: three decks on one global layer (tempo, clock, QUANT, master bus), as Ableton's channels, and switching surface pauses the one left. One drop zone for the whole app feeds the LIBRARY, which gains SETS, a sort header and names from the MP3 tags and the shader's own metadata. PERFORM gets a master bus (ISOLATOR, MASTER, DSP), TRIM, LINK, automatic and hand-picked tempo master and song switches on QUANT. CUE on every deck. One keyboard flow for the whole UI. Pocket Rave gets a normal view modelled on compact AUTHORING.

- **One drop zone for the whole app** (BLOG0191 · V1.0.01a, 04a, 10a, 12a, 14a): Files and folders dropped anywhere, on any tab, show one overlay and go into the LIBRARY; the deck drop zones, CREATE's LIBRARY drop zone and PERFORM's MIXER column drop zone are gone (01a). On a one-deck tab with nothing playing the deck also loads the drop's alphabetically first song (with its AMU) and first shader (10a), and the LIBRARY returns to ALL (12a); while a song plays, or on PERFORM, a drop goes to the LIBRARY only (04a). Removing the MIXER column's drop zone also removed its positioning frame, so EQ, FX and MODE opened off to the left; restored in 14a.
- **LIBRARY: Clear** (BLOG0192 · V1.0.02a, 05a, 08a): One button empties the LIBRARY (tracks, covers, shaders, playlists); the decks keep what they have (02a). An X icon at the far right of the header (05a, 08a).
- **LIBRARY: sets** (BLOG0193 · V1.0.03a, 05a to 09a, 11a, 16a, 17a, 19a): A dropped .m3u8 becomes a set named for its `#PLAYLIST:` line or its file name (03a). After a drop-down (05a) and a drawer (06a), SETS became a filter like the others: ALL · MUSIC · VISUALS · SETS · X, set rows with found/total, double-click or Enter applies a set (MUSIC, in the set's order) and again turns it off; SHADERS renamed VISUALS; QUEUE and the PLAYLIST drawer removed (16a). Sets in alphabetical order (08a); a drop applies no set (10a); the set button keeps one size (11a); W A S D and arrows through the header and list on PERFORM (07a, 09a, 17a); the message bar names the sets a drop added (19a).
- **Shader loads wait for QUANT** (BLOG0194 · V1.0.13a): With music playing a shader load (LIBRARY, picker, drop) swaps on the next QUANT step, as a song start does; nothing playing or QUANT None, at once. Apply in a Code view stays immediate.
- **Mixer: VID starts at 0** (BLOG0195 · V1.0.15a): Both VID encoders open at 0%, as AUD; OUT is black on open. Double-click returns VID to 0%.
- **EQ drawer: TRIM** (BLOG0196 · V1.0.18a): A TRIM knob at the top of each EQ column, as on an Ecler mixer: audio TRIM is the deck's input gain before the EQ (−15 to +15 dB), visual TRIM one gain on the whole picture before RGB (off to ×1.33). The drawer's knob rules and the W A S D grid include it.
- **Master bus: ISOLATOR, MASTER, DSP** (BLOG0180, BLOG0181, BLOG0197 · V1.0.20a): Both decks feed one bus: ISOLATOR → MASTER → DSP compressor → speakers. ISOLATOR (LOW · MID · HIGH, 250 Hz and 2.5 kHz Linkwitz-Riley, full kill to +6 dB) in the MIXER header; MASTER, a dB field at the global strip's right end; DSP, a button after it with Dojo V5.9.0's compressor panel (presets Off, Gentle, Medium, Aggressive, Limiter; THRESH, RATIO, OUTPUT, GR bar), starting on Limiter. PERFORM only; elsewhere every stage is neutral.
- **Song switch on a playing deck, on QUANT** (BLOG0198 · V1.0.21a): A LIBRARY track loaded onto a playing deck no longer stops it: the new track loads in the background, then on the next QUANT step the old song stops and the new one starts from its bar 1 at the master tempo. A second load replaces a waiting one; PLAY cancels it.
- **Pocket Rave normal view** (BLOG0199 · V1.0.22a to 22h): A tap on the header from full frame opens a view modelled on compact AUTHORING, full width (22a to 22c): VISUAL (Settings, REC), the 16:9 canvas in AUTHORING's grey frame (22d), MUSIC with the 40 px cover and waveform, MUSIC UNDERSTANDING lane buttons and the roll, the status line, version and PLUR. GLOBAL removed (22e), the transport row removed, tap the canvas to play (22f), spacing set to 10 px around headers (22g), the orientation button removed and the instrument lanes 25% lower, roll 144 px (22h). The roll shows the structure and instrument lanes only (22c).
- **Compact AUTHORING: stage keeps 16:9 height** (BLOG0204 · V1.0.23a): The compact stage box is 16:9 of its width in every orientation; 1:1 and 9:16 sit centred in it, so nothing under it jumps.
- **LIBRARY: names from the MP3 tags, sort header** (BLOG0206 · V1.0.24a, 24b, 24c): One rule everywhere: the ID3 title · artist, else the file name. TITLE, ARTIST, BPM and KEY columns under a sort header on CREATE and PERFORM, default TITLE A to Z, alphanumeric; a set keeps its own order (24a). Arrow keys show the row in the message bar (24b) and win over a resting mouse (24c). Workflow §2.13, one behaviour, one code path.
- **W A S D in CREATE's LIBRARY** (BLOG0207 · V1.0.25a, 28a): One LIBRARY key handler for CREATE and PERFORM, on the website too (25a); folded into the app-wide keyboard flow (28a).
- **Shader metadata** (BLOG0208 · V1.0.26a): `// @title`, `// @author`, `// @type`, `// @desc` under a .wgsl's first line name the shader everywhere; without `@title`, the file name minus prefix and `_V##`. VISUALS columns TITLE · AUTHOR · VER · TYPE. RULES R16.
- **Template: new shaders start named right** (BLOG0209 · V1.0.27a): The default scene carries the four metadata lines; R16 says to write them when the shader is made, and gives the file-name rule `OMS_Vizzie_Shader_<Name>_V##`.
- **Keyboard: one flow for the whole UI** (BLOG0210 · V1.0.28a, 29b, 30b, 30c, 30d): W A S D, Tab and the arrows move over the same stops on CREATE, PERFORM and AUTHORING, the tab bar and AMU lanes included; Enter is on / off everywhere; one cyan focus ring (28a). Values move with Shift+arrows; TEMPO is a stop (29b). LIBRARY list: A / ← Deck A, D / → Deck B; Enter on CREATE loads (30b). PERFORM: Shift+A / Shift+B / Shift+M into Deck A, Deck B, the mixer; the deck headers' buttons are mouse only (30c). Shift+L into the LIBRARY on CREATE and PERFORM (30d).
- **Mixer: LINK per deck** (BLOG0178 · V1.0.29a): A chain icon between each deck's encoders. Linked, AUD leads: VID waits until AUD reaches it, then follows; moving VID unlinks.
- **Tempo master** (BLOG0215 · V1.0.30a, 30e): A load sets the tempo only when nothing else on its surface plays and the deck is the master, so a playing deck is never retempoed by another's load. A master that stops, or whose AUD goes to 0 or is killed, hands MASTER to a playing deck that is up; with nothing playing, the deck up in the mix. Click a deck's MASTER to pick it by hand until the next start, stop or AUD change. The tempo never changes on a handover.
- **PERFORM waveform repaints on a new track** (BLOG0216 · V1.0.30f): The waveform cache now redraws when the deck's track changes; PERFORM's decks had kept their first track's picture.
- **Mixer LINK on by default** (BLOG0217 · V1.0.30g): Both decks' LINK starts on.
- **CUE** (BLOG0218 · V1.0.30h): A CUE button right of PLAY / PAUSE on CREATE and each PERFORM deck: back to the start of the track, on QUANT while playing, at once when paused.
- **CREATE and PERFORM split** (BLOG0219 · V1.0.30i): CREATE (with AUTHORING and Pocket Rave) has its own deck; PERFORM has its own Deck A and Deck B. A load, PLAY, CUE, shader or FX on one surface never touches the other. Switching between them pauses the surface left. MASTER, QUANT and the LIBRARY's on-deck marks use the open surface's decks; the tempo stays one value for the app. An optional link between the two is parked (BLOG0220).
- **Help texts match the keys** (BLOG0221 · V1.0.31a): Every value control's hover help names Shift+arrows (the mixer encoders, the EQ, RGB and TRIM knobs, the FX effect box, TEMPO, QUANT, MASTER, zoom), as the keys work since V1.0.29b. The deck, stage and MUSIC hints say drop files anywhere, into the LIBRARY (the deck drop zones went in V1.0.01a).
- **Keyboard: drawer grid, decks top to bottom** (BLOG0222 · V1.0.31b, 31c, 31d): With EQ, FX or MODE open, W A S D and the arrows stay in the drawer's grid; only W from its top row leaves, to the strip; S from a visual TRIM had jumped to the deck's SOLO or PLAY (31b). W / S take a control straight below or above first, the nearest row first: PLAY → the RHYTHM bus bar, not the beat chip under it, and on Deck B not the LIBRARY (31c); of a row under the selected control, its first, leftmost: a bus bar → its first chip (31d).

---

## V1.0.0

Packages the V0.11 iteration line (V0.11.01a to V0.11.21e). Baseline V0.11.21e. Shaders get their own settings: uniform contract V0.5.0A adds a settings block, a shader declares its settings in the `.wgsl`, and the Settings drawer sets them live on every stage; Export in every Code view writes a tuned look as the shader's next version. PERFORM gains the EQ drawer (audio EQ and RGB per deck), sixteen video mix modes, one kill rule for every knob and W A S D through the MIXER column. AUTHORING takes CREATE's chips, music row and roll, and the control rules are written down as design system rules.

- **PERFORM: EQ drawer, audio EQ and RGB per deck** (BLOG0137 · V0.11.13a, 14a to 14e, 15a, 15b): The EQ button in the panel strip is live and slides its drawer over the LIBRARY, as FX does. Per deck HIGH, MID, LOW on the audio: high shelf 13 kHz, bell 1 kHz, low shelf 70 Hz, −26 dB to +6 dB, before the deck's FX rack; PERFORM only, CREATE plays without it (13a). RGB, Dojo's visual EQ: BLUE, GREEN, RED, a gain on each colour channel of the deck's picture after its visual FX, from off through ×1.00 to ×1.33 (14a). Four outlined columns, A RGB, A EQ | B EQ, B RGB, visual outside and audio inside as the mixer, no DECK A / DECK B header (14a); spacing settled in 14b to 14d: 9 px from the strip, sides and bottom, 8 px inside each column. The FX drawer re-laid the same way: A VFX, A AFX | B AFX, B VFX (14e). One kill rule on every EQ and FX knob, CREATE's FX panel included: click selects, Enter kills or restores (FX on QUANT, EQ and RGB at once), Tab steps to the next, double-click returns to the default; a killed knob dims (15a). Labels without the deck letter; the message bar names the deck (15b).
- **Authoring preview bindings out of group 0** (BLOG0161 · V0.11.01a): The authoring preview's object mask, overlay probe and CRYPTOMATTE move from `@group(0)` to `@group(3)`, in the preview's copy of the WGSL only; group 0 is left to the contract. AUTHORING renders as before.
- **Settings binding: the shader's own uniform block** (BLOG0162 · V0.11.02a): Uniform contract V0.4.0D → V0.5.0A. Binding 1, `@group(0) @binding(1) var<uniform> settings: array<vec4<f32>, 16>`: 64 floats belonging to the shader, one block per deck (CREATE and each PERFORM deck). Binding 0 is unchanged; shaders on binding 0 only run unchanged.
- **Settings declaration in the .wgsl** (BLOG0163 · V0.11.03a): Comment lines, so the shader compiles as it is: `// @setting NAME settings[N].c min max step default | help` for a number, `// @setting NAME settings[N].xyz color r g b | help` for a colour. Read when the shader compiles on any deck; the deck's block takes the defaults; values kept across an edit when name, type and place match; a bad line is skipped and named in the message bar.
- **SETTINGS drawer** (BLOG0164 · V0.11.04a, 04b): A Settings button on every stage whose shader declares settings: the Visual header on AUTHORING and the VISUALS header on CREATE (04a), each PERFORM deck's header right of MASTER (04b). One shared drawer built from the declaration, with encoders, fields and the colour wheel; a change goes straight into the deck's settings block, no recompile. Laid out as a fixed rack in BLOG0176.
- **Settings: keeping a look** (BLOG0165 · V0.11.05a): Code's Copy wrote the current values in as the `// @setting` defaults. Replaced by Export (BLOG0174, BLOG0175); Copy is a plain copy again.
- **AUTHORING: Music Understanding encoders become the standard chips** (BLOG0172 · V0.11.10a): AUTHORING's encoders are gone; the twelve lanes are chips and the six buses thin colour bars, as on CREATE and PERFORM: click a chip to solo the lane, a bus bar to solo the group, SOLO clears. Lane gains stay at full, so shaders get the same values on every surface.
- **Metal inserts run to the top** (BLOG0173 · V0.11.06a): The metal inserts on the wood panels' inner edges draw above the Moogerfooger strip and run from the top of the window to the bottom; the strip had covered their top 26 px.
- **Settings: Export** (BLOG0174 · V0.11.08a, 09b, 09f): Keeping a look became Save in the drawer (08a), named Export (09b), then moved out of the drawer into the Code views (09f). Export downloads the shader to Downloads as the next version (`_V11` → `_V12`; a name without a version gets `_V01`), the current settings as its defaults; the deck then holds that version. RULES R13 says so.
- **Code on PERFORM decks; Export in every Code view** (BLOG0175 · V0.11.09a, 09b, 09f): Each PERFORM deck header has `</> Code` left of Settings, opening CREATE's Code view over its stage for that deck's shader: Apply, Copy, Export (09a; label 09f). Every Code view (AUTHORING, CREATE, each PERFORM deck) has Export after Copy (09a, named 09b).
- **Settings drawer: a fixed rack of 32 slots** (BLOG0176 · V0.11.09c to 09g, 11a, 12a): The drawer is a fixed rack, the same on every stage: a 36 px encoder, the name and a value box per slot, unused slots empty and dashed (09c, 16 slots). On CREATE it slides out of the stage's left edge over the MUSIC column, Music Understanding left uncovered; AUTHORING and PERFORM slide down (09d; first open fixed in 09e). No Export in the drawer (09f). Empty value boxes fit narrow columns (09g, 11a). 32 slots in 4 rows of 8: settings in the standard area first, a shader's own from a fresh row (12a).
- **Template standard settings** (BLOG0177 · V0.11.11a, 12a): The template's default scene declares and uses fourteen standard settings in settings[0] to settings[3]: row 1 SCALE, ROTATION, OFFSET_X, OFFSET_Y, PIVOT_X, PIVOT_Y, TILE, TIME_OFFSET; row 2 SPEED, REACT, HUE, SATURATION, VALUE, CONTRAST (eight in 11a, six added in 12a). A shader's own settings start at settings[4], on row 3. RULES R13 names them: "give me the defaults" means these.
- **Panel strip order: EQ · FX · MODE** (BLOG0182 · V0.11.14b): PERFORM's panel strip reads EQ · FX · MODE, left to right (was MODE · FX · EQ).
- **AUTHORING music row and roll as CREATE's** (BLOG0183 · V0.11.16a): Cover 40 px square and waveform 40 px high (were 80); the piano roll opens horizontal at 120 px high, vertical 75 px on the orientation button.
- **Video mix modes (OUT)** (BLOG0184 · V0.11.17a to 17e): The MODE drawer sets how OUT combines the decks: sixteen modes in four rows, one row per build (17a to 17d), MIX NAM ADD SCRN / MULT OVER DIFF LUMA / DARK SOFT EXCL INVL / SUB DODGE BURN COLOR. Click or Enter picks; the change is instant; the full name in the message bar. CUT is gone: a VID at 0 is the cut (17a). Buttons in the strip's small-button style with short labels (17e).
- **PERFORM spacing: centre column and outer gaps** (BLOG0185 · V0.11.18a, 18b): The centre column 24 px wider, the gaps either side 12 px, the decks unchanged (18a). PERFORM 9 px from the app frame each side (was 18); the other tabs keep 18 px (18b).
- **Mixer encoders: values, dB, kill rule** (BLOG0186 · V0.11.19a, 19b, 21a to 21e): The four mixer encoders are 36 px knobs alone, with no label and no value under them; the level shows in the message bar, VID in %, AUD in dB with an audio taper (12 o'clock −12 dB). They follow the drawers' rule: click selects, Enter kills or restores, double-click returns to the default (19b). Outlined modules and value boxes (19a) and smaller sizes (21a to 21d) were removed in 21e, giving the LIBRARY and the drawers the room.
- **W A S D: the MIXER column as one grid** (BLOG0187 · V0.11.20a to 20d): W A S D move by direction through the encoders, the EQ · FX · MODE strip and the open drawer (20a, 20c). Enter on the strip opens or closes its drawer; Escape in a drawer goes to its lit button (20c). Tab from a strip button goes into the open drawer (20b). M on PERFORM selects A VID (20d). Arrows still change values.
- **Design system: control colours, modules, values, keys** (BLOG0188 · V0.11.20e): Selected and active rings take the control's domain colour: purple #B24DFF on visual controls (VID, VFX, RGB, the Settings rack, the mix modes), cyan #00d4ff on audio (AUD, AFX, EQ); the strip buttons show a cyan ring from the keyboard. The control rules settled in V0.11.13a to 21e (domain colours, knob modules, values in their unit, one knob behaviour, keys, small buttons, PERFORM spacing) are written down as design system rules.
- **Deliverables: F, the blueprints** (BLOG0189 · V1.0.0): The blueprints ship with the release as F: `OMS_Vizzie_Beta_V1_0_0_F_Blueprints.html`, the editable source (ten sheets, one per page, fonts embedded), and `OMS_Vizzie_Beta_V1_0_0_F_Blueprints.pdf`, printed from it. Published from V1.0.0 on.

---

## V0.11.0

Packages the V0.10 iteration line (V0.10.01a to V0.10.12b). Baseline V0.10.12b. CREATE becomes the music-and-visuals surface: the LIBRARY always open with the website's demo playlists, FX with music and visual effects, PLAY NEXT, CONTINUOUS PLAY and SHUFFLE, and a full-width Music Understanding. Authoring moves to its own tab and LET'S DO THIS to a HELP tab. The music plays on iPhone and iPad. The Moogerfooger strip frames the main app, and the app takes Wes's key colours.

- **CREATE: music FX** (BLOG0144 · V0.10.01a, 01b, 07b, 07c): An FX button in the controls row opens a drawer that slides down out of the row; AFX1 over AFX2 as on the mixer (01b); deck A's slots, shared with PERFORM; the music FX play on CREATE, AUTHORING plays dry; a mode or surface switch closes the drawer (01a). Hover help on the drawer's knobs and labels (07b). Click = kill, double-click = reset to the default, on CREATE and PERFORM (07c).
- **CREATE: visual FX** (BLOG0145 · V0.10.02a, 07b, 07c): VFX1 / VFX2 to the right of AFX1 / AFX2; the effect shows on CREATE's stage, in Pop Out and in REC; one visual FX chain shared with PERFORM.
- **CREATE: LIBRARY** (BLOG0146 · V0.10.03a, 06a, 07a, 07g): The same LIBRARY as PERFORM's on CREATE, its own drop zone; on the website the published set is listed on open and an MP3 is fetched only when loaded (03a). Double-click a row to load it (06a); a track double-clicked loads and plays from the top (07a); timed per row so a double tap works on iPad (07g).
- **Demo Playlists** (BLOG0147 · V0.10.04a, 05b, 07g): `./examples/library.json` lists the website's playlists; each is a filter button after SHADERS in capitals (BIG WHEEL ENERGY), showing its tracks in its order and naming them from its `#EXTINF` lines (04a); 'Title · Artist', title first (05b). The website's AMU files are fetched only when their track loads, which fixed the slow page on iPad (07g). The Big Wheel Energy set (12 tracks with AMU) is published in `examples/`.
- **CREATE headers: MUSIC and VISUALS** (BLOG0148 · V0.10.05a): The left header reads MUSIC; a VISUALS header over the stage holds Code, Pop Out, orientation and REC; the large piano roll is gone from CREATE; the word PUBLIC is gone.
- **CREATE: PLAY NEXT, CONTINUOUS PLAY and SHUFFLE** (BLOG0149 · V0.10.06a, 06b): Three icons after the roll orientation button, help on hover. PLAY NEXT plays the next track in the LIBRARY list now; CONTINUOUS PLAY plays the next at a track's end; SHUFFLE puts the list in a random order, the playing track first, and play follows it (06b).
- **LET'S DO THIS** (BLOG0150 · V0.10.07a, 07e, 07f): The large Music Understanding section is gone from CREATE (07a); Wes's lines in two outlined modules, 15px (07e, 07f); moved to the HELP tab in V0.10.10a (BLOG0154).
- **iPhone and iPad: music plays on tap** (BLOG0151 · V0.10.07d): Safari's audio session set to playback, so silent mode does not mute it; the first tap plays a silent sample, which unlocks the audio.
- **AUTHORING tab; GLOBAL header** (BLOG0152 · V0.10.08a, 08b): Tabs CREATE, PERFORM, AUTHORING, ABOUT, LEARN (08b); AUTHORING is the authoring surface, off-site only, opening first off-site; the header over the global strip reads GLOBAL and switches nothing (08a).
- **CREATE: LIBRARY always open; Music Understanding full width** (BLOG0153 · V0.10.09a, 09b, 10a, 10b): The LIBRARY is its own module under the controls row with a 'Library' header (09b); Music Understanding (chips and roll) is a full-width section (09a) filling the page down to the bottom, at least 160 px, with no page scroll (10a); the LIBRARY's surround matches PERFORM's (10b).
- **HELP tab** (BLOG0154 · V0.10.10a): LET'S DO THIS on its own tab before ABOUT.
- **SOLO and the roll zoom on the Music Understanding header** (BLOG0155 · V0.10.10c, 10d): On CREATE both sit at the far right of the header, zoom just left of SOLO; AUTHORING keeps them in the controls row.
- **Code review loose ends** (BLOG0156 · V0.10.10e): A drop on CREATE's LIBRARY adds to the LIBRARY (the deck's drop zone had taken it since 09b); the hidden LIBRARY button and drawer removed; CREATE no longer paints the hidden large Music Understanding; stale header-switch CSS and comments removed.
- **The Moogerfooger strip on the main app** (BLOG0157 · V0.10.11a): The strip (red power light, five jacks) frames the main app on every tab, on the website and off it; a tap on it does nothing there.
- **Power light: rename the header** (BLOG0158 · V0.10.11b, 11c): A tap on the power light retypes the ONEMANSHYO header for the session: Enter keeps, Esc cancels, empty restores, 24 characters (11b was a long press; 11c a tap).
- **Design System colours** (BLOG0159 · V0.10.12a, 12b): Wes's key colours: Purple People Eater, Barbie Pink, Green Slime, Yellow Man, Orange Julius, Goblin White, Red Hots; one shade of each in the app (12a). Buses RHYTHM Red Hots, STRUCTURE Orange Julius, KEY Yellow Man, PACE Green Slime, INSTRUMENTS Purple People Eater; every lane takes its bus colour, beat Goblin White (12b).

---

## V0.10.0

Packages the V0.9 iteration line (V0.9.01a to V0.9.24a). Baseline V0.9.24a. QUANT governs every cue and PLAY on both tabs, LOOP returns as a musical loop, REC renders from the playhead or a picked chip, and PERFORM (off-site) gains master PLAY, the LIBRARY with playlist QUEUE, and the FX panel with music and visual effects. The Message System is closed: its every message and every key are documented as tables.

- **PUBLIC CREATE: slim music row and mini Music Understanding** (BLOG0118 · V0.9.01a, 02a, 03a): The music row fixed at 40 px (cover 40 × 40) and a mini Music Understanding (lanes and a roll on deck A, opening at 25 %, horizontal) in the left column, without scrolling (01a). Order as the PERFORM deck: music row, controls row, mini; two rolls share CREATE's zoom field and orientation button, the active one by mode, each keeping its own zoom (02a). The PUBLIC cover no longer flips; the static song info panel is retired in PUBLIC for the one-line ticker (03a).
- **QUANT on every cue and PLAY, every tab** (BLOG0119, BLOG0120, BLOG0121 · V0.9.04a): A cue waits for QUANT whenever its deck plays and QUANT is not None, one deck or two; PLAY waits whenever another deck plays. A waveform click is a cue on QUANT; a drag of 4 px or more scrubs. CREATE's global strip reads TEMPO · QUANT · position, with the one shared QUANT value.
- **Cover and waveform: one behaviour** (BLOG0123 · V0.9.05a): The song info line always scrolls, on every deck and both CREATE modes. A cover tap toggles it and it stays until tapped again: the click-elsewhere and Esc closes are removed, and mode switches and track loads leave it as set. Pocket Rave's song card follows the same rule.
- **Musical LOOP** (BLOG0124 · V0.9.06a, 08a): LOOP back on every deck view, after PLAY. On, the whole track loops; a chip click (on QUANT) loops that chip's span; the lit chip again returns to the whole track; LOOP off lets play run past the chip. With LOOP on and the deck stopped, a chip click moves the playhead to it and it becomes the loop on PLAY (06a). The looped or picked chip is lit solid cyan (08a).
- **REC from the playhead; picked chip** (BLOG0125 · V0.9.07a): REC starts at the playhead, no jump to the start. A chip clicked while stopped is picked: REC records exactly that chip and stops (LOOP off), or loops it until REC is pressed (LOOP on). No pick: to the track end (LOOP off) or across the wraps (LOOP on).
- **Library and loading to decks** (BLOG0080 · V0.9.09a, 11a, 12a, 18a to 21a): The MIXER column is a drop zone for files and folders; tracks pair each audio file with its AMU JSON (audio or JSON alone left out), shaders keep the highest `_V##`, one summary message (09a). Folders read through File System Access handles first, which work on `file://` (11a). Entries: click = select and focus, ↑ / ↓ select, ← Deck A, → Deck B, Delete removes; drag onto a deck loads (12a). The QUEUE placeholder removed; the LIBRARY fills the column (18a). No text inside the empty list (19a). Help = name + keys only (20a). Filters ALL · MUSIC · SHADERS (21a).
- **Deck drop: one file of each type** (BLOG0126 · V0.9.10a): A deck takes the first file of each type in a drop and ignores the rest, counted in the message.
- **Master PLAY / PAUSE** (BLOG0128 · V0.9.13a): A master transport in PERFORM's strip, as Ableton's Space: pauses every playing deck and resumes them from the same spot with the master grid restored; no QUANT wait. Space on PERFORM calls it.
- **Drop-zone hint: one standard** (BLOG0129 · V0.9.14a, 15a): One small centred hint on every drop zone, the types one per line (14a); one text, "Drop files", and folders accepted on every drop zone, decks included (15a).
- **Cover image, the fourth drop type** (BLOG0130 · V0.9.16a): A square image dropped on a deck becomes its cover, over the packed and ID3 art, until another track loads. In the LIBRARY an image pairs with the track of the same name.
- **Mini players: lane chips** (BLOG0131 · V0.9.17a): PERFORM decks and PUBLIC CREATE show each lane as a chip (click = solo) instead of an encoder; lane gains stay at full, so shaders get the same values. AUTHORING keeps the full section.
- **PERFORM FX panel and music FX** (BLOG0135 · V0.9.22a to 22d, 22f, 22g): Per deck AFX1 / AFX2 on PERFORM: Filter, Washout, Dubby, Delay, Reverb, Flanger, Phaser, Bitcrush; tempo-timed on TEMPO and QUANT; kills on QUANT; session only (22a). A panel strip MODE · FX · EQ under the MIXER; the panel slides down out of the strip as a drawer over the LIBRARY, which is left as it is (22b to 22d). The MIXER column as three bordered modules of one width: MIXER, panel strip, LIBRARY (22f, 22g). (22e was a test, undone.)
- **Visual FX** (BLOG0136 · V0.9.22h): VFX1 / VFX2 per deck as a WGSL post pass on the deck's picture, seen on its stage and in OUT: RGB Split, Feedback, Glitch, Pixelate, Scanlines, Mirror, Kaleidoscope, VHS, Shake, Tone, Tile, Rotate, Zoom; defaults RGB Split and Feedback.
- **Playlist QUEUE** (BLOG0138 · V0.9.23a, 23b): An `.m3u8` dropped with the music, in either order: QUEUE shows the library in the playlist's order, combined with the filters; matched by path, then file name; a second playlist replaces the first; held for the session (23a). An `.m3u8` typed `audio/x-mpegurl` on macOS is no longer read as audio (23b).
- **Branding** (BLOG0140 · V0.9.24a): Tagline "Music drives the vision ;)". The Yobot icon is removed from the header and Pocket Rave (its embedded image had been corrupt since V0.6.01a); Squint stays in the shaders.
- **Message System closed** (BLOG0100, BLOG0141, BLOG0142): Hover help stopping after a click in Chrome was traced to a Chrome extension in one profile; no code change. Every message and its wording documented as a table (E 9).
- **Keyboard table** (BLOG0127): Every key documented as a table (E 10, C 11).
- **Song switching** (BLOG0066): A new track dropped on a playing deck switches to it.

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
