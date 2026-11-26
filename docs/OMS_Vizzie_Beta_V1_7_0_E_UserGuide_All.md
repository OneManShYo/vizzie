# OMS Vizzie app [Beta V1.7.0] User Guide

**Run date:** 2026-11-26  
**Current Unix Epoch:** 1795695763  
**Document purpose:** How to use Vizzie.  
**Filename:** OMS_Vizzie_Beta_V1_7_0_E_UserGuide_All.md  

## About this document

Vizzie Beta V1.7.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## CONTENTS

**1** What is Vizzie?  
**2** Where to find Vizzie  
**3** Navigation  
**4** Messages  
**5** Pocket Rave (phones and tablets)  
**6** Message index  
**7** Keyboard index  
**8** Getting your content into Vizzie  

---

## 1. What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

Everything in Vizzie counts in music time: bars and beats. A position written 62.1 is bar 62, beat 1; 62.1.3 is bar 62, beat 1, third sixteenth.

Vizzie saves nothing. Your gig folder is the set: the MP3s, their Music Understanding `.json` files, the `.wgsl` shaders, cover images and playlists. Drop it in and play.

## 2. Where to find Vizzie

Go to **vizzie.onemanshyo.com**, or open `OMS_Vizzie_Beta_V1_7_0.html` in a WebGPU-capable browser: current Chrome, Edge or Safari on desktop, or Safari on iOS / iPadOS 26 or later. The reference track's analysis is embedded, so it works immediately. On the website the example audio loads by itself and the LIBRARY lists the demo sets; opened as a local file, load an audio file to hear it (drop it anywhere in the app, or double-click the cover or the waveform).

On iPhone and iPad, Safari plays the music when you tap PLAY, with the silent switch on or off.

## 3. Navigation
**Blueprints:** the drawings are in `OMS_Vizzie_Beta_V1_7_0_F_Blueprints.pdf`, one sheet per page; sheet 1, SURFACE MAP.

This section covers:
- **PLAY**: tab (3.1)
- **CREATE**: tab, off the website only (3.2)
- **PERFORM**: tab, off the website only (3.3)
- **HELP**, **ABOUT**, **LEARN**: tabs (3.4)
- **Keyboard** (7)
- **Midi Fighter Twisters**: PERFORM (3.3.14)
- **Pocket Rave**: phones and tablets (5)

### 3.1 PLAY tab
**Blueprints:** sheet 2, PLAY (DESKTOP).

Music and visuals: one deck, its shader on the stage, the LIBRARY, effects, and the Music Understanding that drives it all. The deck is PLAY's own (3.3.1). On the website PLAY opens; off the website CREATE opens.
- **Header**, on every tab: above it the strip with the red power light and five jacks. Tap the power light to type your own name in place of ONEMANSHYO and your own tagline (up to 75 characters each; Enter keeps, Esc cancels, empty goes back to the default); it lasts until you reload the page.
- **GLOBAL section** on top (3.1.1).
- **MUSIC section** (3.1.2) on the left: on its header what plays next (PLAY NEXT · CONTINUOUS · SHUFFLE · AUTO MIX · SELECTA); then the cover and waveform, the controls row, and the LIBRARY section below them.
- **VISUALS section** (3.1.3) on the right: the stage, with FOLLOW, the visual PLAY NEXT, CONTINUOUS and SHUFFLE, then Code, Pop Out, orientation and REC on its header.
- **MUSIC UNDERSTANDING section** (3.1.4) across the bottom, full width, filling the window down to the message bar. The MUSIC and VISUALS row is always as tall as the picture, in any window shape; Music Understanding takes all the room below it.
- **Message bar** (3.1.5) at the bottom of the screen.

#### 3.1.1 GLOBAL section
The thin strip under the GLOBAL header: settings you set and leave. **TEMPO · QUANT · position · Shaka.**
- **TEMPO.** Click it, then Shift+↑ / ↓ for one BPM, Shift+← / → for a hundredth of a BPM, or type a value and press Enter. The TEMPO follows the song as it was recorded: a song with a tempo change plays its changes, and the number moves with it. Set it yourself and it holds until a track loads; double-click to follow the song again. A song with tempo changes starts at its main tempo, the one most of its bars play at. The audio, the visual and the piano roll all follow, locked to the beat. The range is half to one and a half times the track's tempo.
- **QUANT.** The same value as on PERFORM (3.3.6): cues, PLAY, CUE and shader loads wait for the next step while the music plays. Click it, then Shift+↑ / ↓ or scroll; double-click = 1/4.
- **Position.** Where you are in the track, in bars.beats.sixteenths. It turns pink while REC records.
- **Shaka** (SHOUT OUT): click it to show the credits bottom left of the picture: "Music: title · artist" and "Visual: title · author". They stay while it is lit; click again to hide them. One switch for PLAY, CREATE and PERFORM, **on** when you open the app. The text is solid white over a soft dark shade at the bottom of the picture, which fades in and out with SHOUT OUT over one beat. In square and vertical pictures on PLAY, a line too long for the picture keeps its label (Music: or Visual:) still and scrolls the rest. On PERFORM each deck shows its own credits, and OUT shows one strip scrolling right to left: Deck A with its Music and Visual lines, then Deck B; a deck with MUSIC and VISUAL both at 0 is left out.
  - **The tagline line:** the header's tagline ("Music makes magic!", or your own) can scroll across the top of the picture, with its own shade, on PLAY, OUT and both pop-outs. It starts off; **double-click the tagline in the header** to turn it on (the header text turns orange) or off (grey).

#### 3.1.2 MUSIC section
**Blueprints:** sheet 8, PLAY · LIBRARY, FX AND PLAY CONTROLS.

The left side of PLAY: the MUSIC header, the cover and waveform, the controls row, and the LIBRARY section under them.

##### 3.1.2.1 MUSIC header
PLAY NEXT, CONTINUOUS PLAY, SHUFFLE, AUTO MIX and SELECTA, at the right of the header. CONTINUOUS PLAY, SHUFFLE and AUTO MIX light cyan while on.
- **PLAY NEXT** (next-track icon): the next track in the LIBRARY list, as it is shown, plays from the start now. After the last track it goes back to the first.
- **CONTINUOUS PLAY** (playlist icon), on when you open the app: when a track ends (LOOP off) the next track in the list plays from the start.
- **SHUFFLE** (crossed arrows): on, the LIBRARY list is put in a random order, with the playing track first and still playing; PLAY NEXT and CONTINUOUS PLAY then follow that order, as streaming players do. Off, the list goes back to its own order.
- **AUTO MIX** (blender): each song mixes into the next (3.1.2.2).
- **SELECTA** (record): opens the SELECTA panel (the knobs, recording and the tracker), how AUTO MIX mixes; with AUTO MIX on only (3.1.2.2).

##### 3.1.2.2 AUTO MIX and SELECTA
**Blueprints:** sheet 13, AUTO MIX; sheet 14, SELECTA · PARAMETERS; sheet 15, AUTO MIX · THE ZONE; sheet 16, AUTO MIX · THE MIX.

A party feature on PLAY: with **AUTO MIX** on, each song in the list mixes into the next, the way a DJ would. **AUTO MIX** runs the mix; the **SELECTA** decides how it sounds and looks.
- **Turn it on** with the blender button on the MUSIC header. It is off when you open the app. While it is on, the list plays on at the end of a song even with CONTINUOUS PLAY off.
- **What happens:** about 30 seconds before the mix, the next song in the list loads (the one PLAY NEXT would play, SHUFFLE's order included); the message bar says when it comes in ('AUTO MIX: NAME comes in at bar 129'). At that bar the next song starts at its own bar 1, on the beat, and the two blend over the mix. At the end, the next song simply carries on as the song on the deck: its name, cover, waveform and Music Understanding. The song before stops.
- **The visuals mix too:** if the next song has a paired shader, it comes up on the stage as the music does and takes over at the end, blended in the SELECTA's mode. With FOLLOW off and the visual CONTINUOUS on, the visual list's next shader blends in instead (3.1.3.1).
- **Every mix happens**, whatever the two tempos. During the mix the tempo holds where it is and the next song is matched to it; after the mix the tempo moves to the new song's own tempo, over the bars the SELECTA's TEMPO knob says. A TEMPO you typed yourself is left alone.
- **On the waveform:** with AUTO MIX on, the mix is shaded orange where it will happen, with a line where each part starts, and two curves show how the songs move: the incoming song in green, the outgoing song in white; solid = volume, dashed = bass. It redraws as soon as you turn a SELECTA knob.
- **Stopping a mix:** pause, a seek, loading a track, PLAY NEXT, leaving PLAY or turning AUTO MIX off during a mix ends it: the incoming song stops and the first one plays on as it was.
- **SELECTA** (the record button) opens the SELECTA panel over the LIBRARY, with AUTO MIX on only (with AUTO MIX off the button is dimmed and says to turn it on). The panel has the SELECTA header (record, the dice), six knobs and the tracker. Each knob sets how the next mix goes, for this session:
  - **MIX PT** (MIX POINT): where the mix sits: at the start of the song's last full section, or 1 to 10 segments earlier (−N seg). The song then hands over earlier, and its last bars are not played.
  - **MIX DUR** (MIX LENGTH): how long the mix is: instant (a cut), 1, 2, 4, 8, 16 or 32 bars, half on each side of the line; shorter where a section is shorter.
  - **TEMPO DUR** (TEMPO AFTER MIX): how long the tempo takes to reach the new song's own after the mix: instant, 1, 2, 4, 8 or 16 bars.
  - **VIS MODE**: how the two visuals blend, from PERFORM's modes (MIX to COLOR).
  - **VIS FREQ** (VISUAL CHANGE): when the visual changes: **match** (at each mix), **song/2**, **song/4**, **song/8** (that many visuals per song, each change on the nearest section line, the next shader from the visual list), or **chaos** (random phrase lines, each with a random shader). The dice on the SELECTA header, lit on chaos, rolls new lines and shaders.
  - **VIS DUR** (VISUAL BLEND LENGTH): how long the visual blend takes: match (as long as the mix), instant, 1 beat, 1 bar, 4 bars or 8 bars.
  - Drag a knob up or down (mouse or finger), or click / tap it for the next step (Shift+click goes back); the wheel and the arrow keys step too. **Double-click** (or double-tap) a knob for its default. The message bar names each knob in full. All at the minimum is a hot, radio-style mix; all at the maximum a long house blend.
- **Record your mix:** press record in the SELECTA panel. Every AUTO MIX mix is logged with the knobs as they stood, and every knob change and tempo you set is logged at its bar; the tracker shows each one. It records the moves only, no sound or picture. Press it again to stop: the mix is saved as a set (`NAME_<number>.omsset`, in Downloads) and added to SETS at once. Turning AUTO MIX off while recording saves it too. If only the first song was logged, nothing is saved. Leaving the page while recording loses it, as REC does.
- **Play a recorded set:** open the set, turn AUTO MIX on and play: each song mixes in exactly as recorded (its point, length, tempo and visuals); the mix message says "the set's recorded transition". The knobs keep their own values and apply to any song without a recorded mix. If a song of the set is missing from the LIBRARY, the mix after it uses the knobs. A set made from an Ableton mix can also carry where each song starts and its volume and bass moves; with AUTO MIX on, they are followed.
- **SELECTA 1** (house club) is the SELECTA built in, and its values are the knobs' defaults: the last full section, 32 bars, 16 bars of tempo, MIX, visuals changing at each mix. In the first part, the next song comes up from silent with its bass out; in the second, the bass swaps from one song to the other; in the last bar the first song goes out. The visuals blend in MIX across the last part. After the mix the tempo moves to the new song's over 16 bars.

##### 3.1.2.3 Cover and song info
The cover shows the track's art. **Click** it to show the song info over the waveform: one line, title · artist · BPM · key, scrolling. It stays until you click the cover again. **Double-click** the cover to pick an audio file or the track's Music Understanding `.json`.

The waveform keeps working while the song info is showing.

##### 3.1.2.4 Waveform
The whole track with the playhead.
- **Click** to cue to that place. While the track plays, the cue waits for the next QUANT step; with QUANT at None, or when stopped, it jumps at once.
- **Drag** to scrub.
- **Double-click** to pick an audio file or its `.json`.

Audio isn't needed to press PLAY: Vizzie runs from the embedded Music Understanding analysis.

##### 3.1.2.5 Controls row
**Blueprints:** sheet 8, PLAY · LIBRARY, FX AND PLAY CONTROLS.

Under the waveform: PLAY, CUE and LOOP on the left; EQ, FX and Settings on the right.
- **PLAY / PAUSE** starts and stops. **Spacebar** does the same.
- **CUE**, right of PLAY / PAUSE: back to the start of the track. While the track plays it jumps on the next QUANT step and plays on, as a chip click; paused, at once. A chip loop is released.
- **LOOP**, off when you open the app. On, the whole track loops. Click a piano roll block while LOOP is on and that block loops instead (the jump lands on QUANT); click the lit block again to go back to the whole track. Off, the track stops at its end and the playhead goes back to the start.
- **EQ** opens the deck's EQ and RGB (3.1.2.6).
- **FX** opens the effects (3.1.2.6). Its dot lights while any effect is turned; **Shift+click** puts every effect back to neutral.
- **Settings** (gear) opens the shader's settings (3.1.3.7).

EQ, FX, Settings and SELECTA open one at a time, in one panel over the LIBRARY, each column of knobs in its own outlined box; click the lit button again to close it. The piano roll orientation, zoom and SOLO are on the Music Understanding header (3.1.4). **Music Visual Pair** is in the LIBRARY header (3.1.2.7).

**Touch:** on an iPad or a phone, put a finger on any knob and drag up or down to turn it; the page does not scroll.

##### 3.1.2.6 EQ and FX
**Blueprints:** sheet 8, PLAY · LIBRARY, FX AND PLAY CONTROLS; sheet 17, PLAY · DRAWERS.

**EQ** slides a panel down over the LIBRARY with the deck's RGB (TRIM · BLUE · GREEN · RED, on the picture) and EQ (TRIM · HIGH · MID · LOW, on the music), the same controls as a PERFORM deck's (3.3.12). The EQ plays on PLAY and on Pocket Rave, and the RGB colours the picture. Its dot lights while anything is off its default; **Shift+click** resets it.

**FX** slides a panel down over the LIBRARY; click FX again to close it. Four knobs in two boxes: **AFX1** over **AFX2** (music, cyan), then **VFX1** over **VFX2** (visual, purple). They are PLAY's deck's own effects; PERFORM's decks have theirs (3.3.9).
- **Knob:** drag up or down for the amount. Click it to select it (a ring: cyan on a music knob, purple on a visual one), then Shift+↑ / ↓ (fine) or Shift+← / → (coarse). **Enter** kills the effect; Enter again restores it. Kills land on the next QUANT step while the track plays. A killed knob dims. **Double-click** resets the effect to its default.
- **Effect box** (under the knob): click it, then Shift+arrows step through the bank.

The music effects play on PLAY and Pocket Rave; the visual effects show on the stage, in Pop Out and in REC. CREATE plays without effects.

##### 3.1.2.7 LIBRARY section
**Blueprints:** sheet 8, PLAY · LIBRARY, FX AND PLAY CONTROLS; sheet 18, SETS AND BEAM ME UP.

The same LIBRARY as PERFORM's (3.3.10), always open under the controls row. On the website it lists the content published with Beam Me Up (8.2), the artist's own sets of music and visuals, paired and ready to play (3.3.11), and opens with the first set applied.
- **Header:** ALL · MUSIC · VISUALS · SETS · expand · add files ........ Music Visual Pair · save · X (3.3.10).
- **Expand** (bulleted list, right of SETS): the list slides down over the left half of Music Understanding, to its bottom, so more rows show (for example while pairing songs and shaders); the filter buttons stay where they are. Press it again, press **Escape**, or open EQ, FX, Settings or SELECTA to bring it back. Not on phones or in CREATE.
- **Add files** (folder with a plus): opens your device's file picker; the files come in exactly as a drop (3.1.2.8): songs, their `.json`, shaders, covers, playlists, `.omsset` and `.zip` files. On an iPad, where nothing can be dropped, this is how a pack gets in.
- **Music Visual Pair** (speaker, link, camera), beside save: pairs the song on the deck with the shader on the stage. Lit = paired. Load a paired song from the LIBRARY, onto any deck, and its shader comes with it. Click the lit button to unpair. One shader per song; a shader can pair with many songs. Pairs last for the session, on PLAY and PERFORM; to keep them, save an OMS set (3.3.11). The pitch always moves with the tempo, like a turntable (KEY LOCK is no longer offered).
- The list always ends on a whole row.
- **Double-click** (or double-tap) a track, or select it and press **Enter**: it loads and plays from the start. A shader loads onto the stage. While a track plays, a new track stops it and loads stopped at the start (press PLAY to start it); a shader swaps on QUANT.
- **Click** an entry to select it; then ↑ / ↓ (or W / S) move the selection, ← / → (or A / D) load it, Delete removes it from the library.
- **Drag** an entry onto the deck to load it.
- **Add files** by dropping them anywhere (3.1.2.8), or with the add files button.
- **Open a set:** double-click (or double-tap) a set, or select it and press Enter: its songs show, in the set's order ('Set NAME: N tracks · double-click a track to play it'). Nothing loads and the music plays on. Double-click a song to play it; from then on PLAY NEXT, CONTINUOUS and AUTO MIX carry on through that set, even while you browse another. On PERFORM a double-click on a set only applies it (3.3.11).
- **Import a set:** drop a set (a zip, an `.omsset`, or files with one), or pick it with add files: it opens by itself, as a double-click would. With several, the first in the list opens. With nothing playing, the deck loads the set's first song.
- **Links:** on the website a set, a song or a shader has its own address and page (8.3). A set link opens with the set applied and its first song loaded; a song link loads that song with its visual; the first tap plays it (a browser rule). Bookmarks and shared links show the name.

An entry on the deck is tinted yellow. Website tracks are fetched when you load them, so the page opens quickly.

##### 3.1.2.8 Dropping files
Drop files or a folder anywhere in the app, on any tab: MP3s, their Music Understanding `.json`, `.wgsl` shaders, square cover images, `.m3u8` playlists, `.omsset` files and `.zip` files. While you drag, one overlay covers the window: "Drop files" and the types it takes. Everything goes into the LIBRARY (3.1.2.7), and the LIBRARY's summary is the last message in the bar.

What also loads onto a deck:
- **Nothing playing, on a one-deck tab** (PLAY, CREATE, HELP, ABOUT, LEARN, Pocket Rave): the deck loads the alphabetically first song of the drop (by title; a song with its `.json` first) with its own `.json` and cover, and the alphabetically first shader (at its newest `_V##`). The LIBRARY goes to ALL.
- **A song playing, or on PERFORM:** nothing loads; the drop goes into the LIBRARY only and the LIBRARY stays as it is. The song and its shader carry on. Load from the LIBRARY.

A drop applies no set (3.3.11).

**Zip files.** A zip is opened and taken in as if its files had been dropped as a folder, whatever the layout inside: songs with their `.json`, covers, shaders, sets from each `.omsset` and `.m3u8`, and the `.omsset`'s pairs. A zip with no `.omsset` or `.m3u8` becomes a set named after the zip. The message bar counts what was usable of what was found, for example 'NightSet: songs 2/2 · shaders 1/1 · covers 1/2 · sets 1/1 · pairs 1/2'.

A dropped cover image must be square. It replaces the MP3's own art until another track loads.

#### 3.1.3 VISUALS section
The live shader on the stage. The buttons sit on the right of the VISUALS header: **FOLLOW · PLAY NEXT · CONTINUOUS · SHUFFLE**, then Code, Pop Out, orientation and REC.

##### 3.1.3.1 FOLLOW and the visual list
- **FOLLOW** (a dot and an arrow), lit when you open the app: the visuals follow the music. Each song brings its paired shader, and in an AUTO MIX the next song's visual blends in with the music (3.1.2.2). While FOLLOW is on, the visual CONTINUOUS and SHUFFLE buttons show the music's, dimmed.
- **Press a visual button** and FOLLOW turns off: the visuals run their own list, the LIBRARY's shaders in their order (or shuffled):
  - **PLAY NEXT** (visual): the next shader in the list, now (on QUANT while music plays).
  - **CONTINUOUS** (visual): on, each song change brings the list's next shader (blended in during an AUTO MIX); off, the visual stays.
  - **SHUFFLE** (visual): the visual list in its own random order.
- **Press FOLLOW again** and the visuals follow the song pairs again from the next song.

##### 3.1.3.2 </> Code
Opens the shader code over the stage: **Apply · Copy · Export** and the editor. Edit or paste a complete shader, then **Apply**. **Copy** copies the code.

**Export** saves the code in the editor as a `.wgsl` in Downloads, as the next version of the loaded shader, with the current settings (3.1.3.7) written in as its defaults:
- The name is the loaded shader's name with its version one up: `_V11` becomes `_V12`, `_V09` becomes `_V10`. A name without a version gets `_V01`. The original file is never touched.
- After Export the deck holds that version: the next Export gives `_V13`, and a double-tap on a setting goes to the exported value. The editor shows the exported text.
- Drop the exported file later and the shader opens with the tuned look.

The line beside the buttons says what happened: applied, exported, copied, or "error, see stage".

Code is on every stage: PLAY, CREATE and each PERFORM deck (3.3.3).

##### 3.1.3.3 Pop Out
Opens the visual in its own window. Double-click that window for fullscreen. The picture renders at the window's size, so it stays sharp however big you make it; SHOUT OUT and the tagline sit on the picture.

##### 3.1.3.4 Orientation
Cycles the visual through 16:9, 1:1 and 9:16.

##### 3.1.3.5 ● REC
Records the visual with the track's music to a file (MP4, or WebM where MP4 is not offered), from the playhead, at the orientation's full export size: 1920 × 1080, 1080 × 1080 or 1080 × 1920. With SHOUT OUT on, the credits, the tagline and their shade are recorded as they show on the stage; off, the picture only.
- **Stopped, a block picked:** click a piano roll block while stopped, then REC. It records exactly that block and stops at its end. With LOOP on, the block loops and the recording runs until you press REC again.
- **Stopped, nothing picked:** records from the playhead to the end of the track. With LOOP on, it runs on until you press REC again.
- **A range picked** (3.1.4.3): REC jumps to its start and records it once; with LOOP on, it loops until you press REC again.
- **Playing:** records from where you are.

REC records live: a shader too heavy to draw every frame in time leaves frames out of the file.

Click REC again to stop early. The file downloads when the recording ends.

##### 3.1.3.6 Load a shader file
Drop a `.wgsl` file anywhere (3.1.2.8), load it from the LIBRARY, or **double-click** the visual to pick one. While music plays, the new shader swaps in on the next QUANT step, so the picture changes with the song; with nothing playing, or QUANT at None, at once. While it waits, the message bar says "on the next 1/4" (the QUANT value). Apply in the Code view stays immediate.

##### 3.1.3.7 Settings
**Blueprints:** sheet 10, SHADER SETTINGS; sheet 17, PLAY · DRAWERS.

A shader can declare settings: the values that tune its look (size, speed, colours). **Settings**, after Code on the header, shows only while the loaded shader declares settings. It opens the Settings drawer; Settings lights while it is open; click it again to close. The purple dot on the button glows while any setting is off the shader's default. **Shift+click** the button to put every setting back to the shader's default, without opening the drawer (on PLAY, Shift+Enter does the same from the keyboard).
- **On PLAY** it opens from the gear at the right end of the controls row, in the panel over the LIBRARY: the panel's full width, eight settings across, each column in its own outlined box, only as many rows as the shader uses. The VISUALS header has no Settings button on PLAY.
- **On CREATE** it slides down out of the Visual module.
- **On PERFORM** both decks' settings open from the gear in the panel strip (3.3.8): Deck A on the left, Deck B on the right, two across, four rows in view, more scrolling below.

**The rack.** 32 slots, 4 rows of 8, drawn on CREATE (on PLAY only the rows in use; on PERFORM two across). The standard settings fill the first rows; the shader's own settings start on a fresh row. A shader with no standard settings fills from slot 1. Unused slots show a dashed, dim knob and an empty value box. Each slot: a purple knob, the name (cut with "…" when it is long; the full name shows in the message bar) and the value box.

**Keys:** W A S D and the arrows move between the knobs and stay in the open drawer; W off its top row leaves. From the Settings button, with the drawer open, the next W A S D or arrow goes to its first knob.

**A number setting:**
- **Knob:** drag up or down across its range, in its steps; or select it and Shift+↑ / ↓ one step, Shift+← / → five steps. Double-tap = its default.
- **Value box:** click it, then ↑ / ↓ (or Shift+↑ / ↓) one step, or type a value and press Enter; Escape leaves. Double-click = its default.

**A colour setting** takes one slot:
- **Knob:** shows the colour; its pointer is the hue. Drag up or down = hue, or Shift+↑ / ↓ 5°, Shift+← / → 30°. Tap (or Enter) = the colour wheel at the foot of the drawer (hue around, saturation from the centre out, a bar beside it for value); tap again to close it. Double-tap = its default.
- **Value box:** type a hex (#RRGGBB) and press Enter. Double-click = its default.

Values are set live: the picture follows at once, with no recompile. They last for the session. Apply after an edit keeps a setting's value when its name, type and place are unchanged; a new or moved setting starts at its default. To keep a look, Export it from a Code view (3.1.3.2).

Each deck has its own settings. PLAY's deck's are the same on PLAY, CREATE and Pocket Rave; PERFORM's Deck A and Deck B have their own.

**The standard fourteen.** The template's default scene declares them, and a shader built on the template carries them. Row 1, the frame; row 2, clock, lanes and look:

| Row | Setting | Range, default | What it does |
|---|---|---|---|
| 1 | SCALE | 0.25 to 4, 1 | Zooms the whole frame |
| 1 | ROTATION | −180 to 180, 0 | Turns the whole frame, in degrees |
| 1 | OFFSET_X | −1 to 1, 0 | Moves the frame left / right, in half-heights |
| 1 | OFFSET_Y | −1 to 1, 0 | Moves the frame up / down, in half-heights |
| 1 | PIVOT_X | −1 to 1, 0 | Moves the centre that ROTATION and SCALE turn and zoom around, left / right; alone it changes nothing |
| 1 | PIVOT_Y | −1 to 1, 0 | The same, up / down |
| 1 | TILE | 1 to 8, 1 | Repeats the frame across and down; each tile shows the whole frame |
| 1 | TIME_OFFSET | 0 to 32 beats, 0 | Slides the motion along the music clock |
| 2 | SPEED | 0 to 4, 1 | How fast the shader moves on the music clock |
| 2 | REACT | 0 to 1, 1 | How strongly the Music Understanding lanes drive it |
| 2 | HUE | 0 to 1, 0.5 | Shifts the hue (0.5 = none) |
| 2 | SATURATION | 0 to 2, 1 | Colour strength (0 = grey, 1 = as is) |
| 2 | VALUE | 0 to 2, 1 | Brightness (1 = as is) |
| 2 | CONTRAST | 0 to 2, 1 | Contrast (1 = as is) |

##### 3.1.3.8 Shader names
A shader names itself in its own lines, under line 1 of the `.wgsl`, one line each:
- `// @title`: the name the app shows.
- `// @author`: one or more, comma-separated, as a track's artists (the source first, for example `Ducky3D, Wes Smith`).
- `// @type`: visualizer, asset, scene, story or decal.
- `// @desc`: one line, optional.

The version stays in the file name (`_V##`). The LIBRARY shows them (3.3.10), and the deck messages name the shader by its title. A shader without `@title` shows its file name without `OMS_Vizzie_Shader_` and `_V##` (for example "Starburst"). Write them when the shader is made: a new shader made from the template replaces the default scene's four lines with its own. Name the file `OMS_Vizzie_Shader_<Name>_V##`, underscores and no spaces, with `<Name>` the title in CamelCase.

#### 3.1.4 MUSIC UNDERSTANDING section

##### 3.1.4.1 Groups and lanes
Six groups (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS) holding twelve lanes: beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other. Each lane shows in its group's colour; beat is white. What each lane does to the picture depends on the shader loaded. Hover over a lane to see its live value in the message bar.

##### 3.1.4.2 Lane chips
Each lane is a chip. Click a chip (or select it and press Enter) to solo the lane; solos stack. Click a group's colour bar (or Enter) to solo the whole group. **SOLO**, at the right of the Music Understanding header, lights while any lane or group is soloed; click it to clear all solos.

##### 3.1.4.3 Piano roll
Each lane's music data moving through the centre playhead, counted in beats, at any tempo. It opens at 25 %, horizontal.
- **Drag** it to scrub.
- **Click** a block to cue to its start: a beat, bar, section, segment, phrase, key or pace change. While the track plays, the cue waits for the next QUANT step. These are your cue points, straight from Music Understanding; nothing needs saving.
- **LOOP on:** the clicked block loops (3.1.2.5).
- **Stopped:** the clicked block is picked: the playhead moves to its start, the block lights, and REC records exactly that block (3.1.3.5). Moving the playhead any other way, or PLAY, clears the pick.
- **A range:** click a section, segment or phrase block, then **Shift+click** another (in the same lane or another structure lane, before or after it): everything from the earlier start to the later end is picked. While playing with LOOP on, it loops at once. On PLAY the range stays, lit cyan across all three structure lanes, through scrubbing, PLAY and LOOP; REC renders it; Escape or a plain block click clears it.
- **Orientation** (a little cascade of bars on the Music Understanding header, left of the %): the piano roll horizontal or vertical.
- **Zoom** (the % field on the Music Understanding header, left of SOLO): click it, then Shift+↑ / ↓ through 0, 25, 50, 75 and 100. 0 is the closest view, 100 the whole song. Pinch, or ctrl + wheel on the roll, zooms too.

##### 3.1.4.4 Another track's Music Understanding
Each track has its own Music Understanding file, a `.json` made by the Sozo sidecar. Drop it anywhere while nothing plays (or double-click the cover or waveform and pick it): the piano roll, readout, cue points and visuals switch to that track, and TEMPO goes to its BPM. Load the track's MP3 the same way, before or after. If the audio and the `.json` are different lengths, the message bar tells you, so you can check they belong together.

#### 3.1.5 Message bar
At the bottom of the screen, on every tab: help in cyan, values in orange, errors in red (4).

### 3.2 CREATE tab
**Blueprints:** sheet 3, CREATE (DESKTOP).

Off the website only: the same deck, arranged for building shaders. The Visual on top (the header reads **Visual : Author**), with **Code** and **Settings** on its header (3.1.3.2, 3.1.3.7), then the music, the controls row (PLAY, CUE, LOOP, CHIPPY, dice, Music Visual Pair, zoom and orientation on the left; SOLO on the right), the Music Understanding chips, the piano roll and the authoring sections. The track and solos are the same as on PLAY. There is no LIBRARY, EQ, FX, PLAY NEXT, CONTINUOUS PLAY, SHUFFLE, AUTO MIX, SELECTA or FOLLOW, and the deck plays without effects.
- **CHIPPY** (the smiley after LOOP), on when CREATE opens: a chiptune made from the loaded song's Music Understanding plays along with the deck: the same tempo, key, beats and sections; kick, bass, chords and lead come and go with the song's drums, bass, vocals and energy. It never starts the deck by itself. Click to turn it on or off for the session. The **dice** beside it rolls a new tune over the same song (same key and sections), on the next bar while playing. Loading another song goes back to that song's own tune. If another app takes the sound (for example dictation on an iPad), CHIPPY goes quiet and picks up again where the song is.
- **Compact CREATE** (a portrait window, one 500 px tall or less, or compact picked by hand): the stage box stays 16:9 of its width (at most 60 % of the window's height) in every orientation; 1:1 and 9:16 sit centred in it, so nothing under the stage moves when you switch.
- **Music row:** the cover and the waveform, 40 px high, as on PLAY.
- **Music Understanding:** the same chips as PLAY and PERFORM (3.1.4.2): click a chip to solo the lane, click a group's colour bar to solo the group, SOLO clears. Every lane drives the shader at full unless solos mute it, as on PLAY and PERFORM, so a shader gets the same values on every tab.
- **Piano roll:** as on PLAY (3.1.4.3), with 4 bars in view at the closest zoom. It opens horizontal at 100 %, the whole song, and keeps that zoom when you load another track, 120 px high; the orientation button switches it to vertical and back.
- **Opens on BoxBot Squint**, walking in front of an orange floor that fills the bottom third of the frame and meets the purple back wall: an asset built to the asset standard. PLAY and PERFORM keep the default scene; a shader you load stays loaded.
- **Scroll lock** (padlock, on the Visual header left of orientation): lit when you open the app. The header, GLOBAL, the Visual row and the picture stay in place while MUSIC and everything below scrolls under them, so the picture is always in view. Click to turn it off and the page scrolls as before. In a window too short to leave room below, it acts as off.
- **Objects toggle:** one small tile per object, 24 across (12 on an iPad); the full name shows in the message bar.
- **GRID**, on when you open the app, follows the asset in metres (lines every metre and every 10 cm), with the ground line through the asset's base: the side-to-side axis in pink, the depth axis in green. **REF**, next to POINTS, shows a 1.8 m person standing on the ground line, to check the asset's size. GRID, GUIDES, POINTS and REF show only in CREATE, above the SHOUT OUT credits.

### 3.3 PERFORM tab
**Blueprints:** sheet 5, PERFORM; sheet 6, PERFORM · MIXER COLUMN; sheet 7, MUSIC CLOCK AND SIGNAL FLOW.

Two decks and a mixer, for playing visuals live to music. Shown only when the app is opened off the website.

#### 3.3.1 Layout
**DECK A · MIXER column · DECK B**, side by side, fitted to the window, under the global strip. The MIXER column holds three modules, top to bottom: the MIXER, the panel strip (ISO · EQ · FX · MODE · Settings) and the LIBRARY. PERFORM's Deck A and Deck B are its own, separate from PLAY's deck: a track, PLAY, shader or effect on one tab is not on the other. Opening PERFORM pauses PLAY, and leaving it pauses both decks.

#### 3.3.2 Global strip
**TEMPO · QUANT · PLAY · master position · Shaka · MASTER · DSP.**
- **TEMPO**: as on PLAY (3.1.1), following the MASTER deck's tempo changes in proportion; changing which deck is MASTER does not make it jump. Set by hand it holds; double-click goes back to the MASTER deck's tempo, following. PLAY and PERFORM each keep their own TEMPO.
- **QUANT**: click it, then Shift+↑ / ↓ (or scroll) through None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars. Double-click = 1/4. The same value as PLAY's. See 3.3.6.
- **PLAY** (master): pauses every playing deck at once; press again and they carry on from the same spot, in time. With nothing paused, it starts every deck from its playhead. No QUANT wait. **Spacebar** does the same on PERFORM. A deck's own PLAY clears what the master PLAY remembered.
- **Master position**: the session, in bars.beats.sixteenths. It starts at 1.1.1 with the first PLAY, counts while any deck plays, and holds while every deck is stopped. Double-click to go back to 1.1.1.
- **Shaka**: SHOUT OUT, as on PLAY (3.1.1).
- **MASTER**: the output level of the whole mix, after the ISOLATOR (3.3.7), before DSP. Click it, then Shift+↑ / ↓ for 1 dB, Shift+← / → for 0.1 dB, or scroll; double-click = 0 dB. From off (−∞) to +6 dB; it opens at 0 dB.
- **DSP**: the master compressor / limiter. DSP opens its panel, which slides down out of the strip's right end over the top of Deck B; DSP again or Escape closes it. Inside:
  - **Preset box**: click it, then Shift+↑ / ↓ through Off · Gentle · Medium · Aggressive · Limiter. It opens on Limiter, which acts only near clipping.
  - **THRESH** (−48 to 0 dB), **RATIO** (1:1 to 20:1) and **OUTPUT** (−12 to +12 dB): knobs, as the drawers' (drag, Shift+arrows, double-click = the default). Turning one sets the preset box to CUSTOM.
  - **GR**: the gain reduction, how hard the compressor is working now (orange, 0 to 12 dB).

The deck audio runs through one master bus: ISOLATOR, then MASTER, then DSP. The master bus acts on PERFORM only; on the other tabs it is neutral.

#### 3.3.3 A deck
Top to bottom:
1. **Header:** the deck name, the **lock**, **MASTER**, which lights while this deck sets the tempo (click it to make this deck MASTER, 3.3.5), and **</> Code**. A deck's Settings open from the panel strip's gear (3.3.8). The header's buttons are mouse only: the keyboard passes them by.
   - **Lock** (DECK LOCK), right of the deck name: click to lock (closed shackle) or unlock (open). Locked, no song can be loaded onto the deck while it plays, by any route (the LIBRARY, a drag, the arrow keys, a Twister or the deck's own pickers); the message bar says so. Unlocked, a song loaded onto a playing deck stops it and loads at the start, stopped. Shaders load any time, locked or not. It is off when you open the app and stays as you set it.
   - **</> Code** opens the deck's shader code over its stage: Apply · Copy · Export and the editor, as on PLAY (3.1.3.2). Apply compiles the edited code on this deck's stage. A new shader loaded on the deck shows in the open Code view. Code lights while open.
2. **Stage:** the deck's own shader, with its visual FX (3.3.9) and RGB (3.3.12). **Double-click** it to pick a `.wgsl`.
3. **Cover and waveform**, in a slim row. Click the cover for the song info line (title · artist · BPM · key); double-click the cover or the waveform to load an MP3 or its `.json`; click the waveform to cue (on QUANT while playing), drag it to scrub.
4. **PLAY · CUE · LOOP · Music Visual Pair · zoom · orientation · position ........ SOLO.** CUE, LOOP and Music Visual Pair work as on PLAY (3.1.2.5). The position is this deck's own place in its track. The roll opens at 25 % zoom, horizontal.
5. **Music Understanding:** each lane a chip in its group colour, without labels: click a chip (or Enter) to solo the lane. Click a group's colour bar to solo the group. Below, the piano roll: drag to scrub, click a block to cue to its start.

There is no REC or Pop Out on a deck; OUT has its own Pop Out (3.3.7).

#### 3.3.4 Loading a deck
- From the LIBRARY: drag an entry onto a deck (the deck shows "Drop to load"), or select it and press A or ← (Deck A), D or → (Deck B). See 3.3.10.
- The double-clicks in 3.3.3.

Files dropped on PERFORM go into the LIBRARY only (3.1.2.8); load them from there. A track loaded onto a playing deck stops it and loads stopped at the start (1.1.1), ready to play, unless the deck is locked (3.3.3). A song with a Music Visual Pair brings its shader to the deck too (3.1.2.5).

Deck A and Deck B start with the reference track and the default shader.

#### 3.3.5 Which deck sets the tempo
MASTER moves by itself:
- The playing deck that started first is MASTER and sets the tempo.
- MASTER hands over to a playing deck when the master pauses, or when its MUSIC goes to 0 or is killed and the other deck is playing with its MUSIC up. Bringing the old master's MUSIC back up does not take MASTER back.
- With nothing playing, MASTER goes to the deck that is up in the mix: a master whose MUSIC is down hands over to a deck whose MUSIC is up.

**Click** a deck's MASTER to pick it by hand. The pick holds until the next start or stop of a deck, or an MUSIC going up or down; then the automatic rules take over again.

The tempo never changes on a handover, so nothing jumps. A track loaded on a deck sets the tempo only when the other deck is not playing and this deck is MASTER; a playing deck is never retempoed by the other deck's load.

#### 3.3.6 Starting and cueing in time (QUANT)
- **PLAY** on a deck, while the other deck is playing, waits for the next QUANT step of the master grid, then starts this deck from the matching place in its own track, so the two land together. PLAY blinks while it waits; press it again to cancel.
- **A cue** on a playing deck (a click on a piano roll block or on the waveform, or CUE) waits for the next QUANT step, then jumps. A cued block fills orange while it waits.
- **A shader load** (from the LIBRARY, the picker or a drop) waits for the next QUANT step while music plays, then swaps. A second load while one waits replaces it. Apply in the Code view is immediate.
- **A track** loaded onto a playing deck does not wait: the deck stops and the new track loads stopped at 1.1.1 (3.3.4). Press PLAY to start it; with the other deck playing it lands on the next QUANT step.
- **FX kills** (3.3.9) land on the next QUANT step while anything plays. EQ, RGB, TRIM, ISOLATOR and mixer kills happen at once.

With QUANT at None, PLAY, cues and shader loads happen at once. QUANT works the same on PLAY and PERFORM.

#### 3.3.7 Mixer
**Blueprints:** sheet 6, PERFORM · MIXER COLUMN; sheet 7, MUSIC CLOCK AND SIGNAL FLOW.

- **OUT**: the two decks' visuals, with their visual FX and RGB, combined at their VISUAL levels in the visual mix mode (3.3.13).
- **Encoders**, four knobs without labels, left to right: deck A VISUAL, deck A MUSIC, deck B MUSIC, deck B VISUAL. The place and colour say which: VISUAL (purple) outside, MUSIC (cyan) inside; deck A left, deck B right. Hover, drag or Shift+arrows show the level in the message bar.
  - **VISUAL** is the deck's strength in OUT, 0 to 100 %. It opens at 0 %, so OUT is black until you bring a deck up.
  - **MUSIC** is the deck's volume, in dB: full left is silence (−∞ dB), full right 0 dB. It turns as the ear hears: 12 o'clock is −12 dB. It opens at silence. MUSIC acts on PERFORM; PLAY plays its deck at full.
  - Drag up or down for the level. Click selects the encoder (a purple ring on VISUAL, cyan on MUSIC), then Shift+↑ / ↓ (fine) or Shift+← / → (coarse). **Enter** kills it (VISUAL: the deck out of OUT; MUSIC: silence), Enter again restores it; a killed encoder dims and keeps its level. **Double-click** = the default (VISUAL 0 %, MUSIC silence), restored.
- **LINK**, the chain icon between each deck's two encoders (between A VISUAL and A MUSIC, and between B MUSIC and B VISUAL). On (white) when you open the app; click it, or Enter, to turn it off (grey) or on. Linked, VISUAL follows MUSIC exactly. Turning LINK on while VISUAL is somewhere else glides VISUAL to MUSIC over one beat, on the next QUANT step; MUSIC never moves, so the volume never jumps. Moving VISUAL unlinks, so the picture can go its own way mid mix. Each encoder keeps its own kill.
- **Meters**, two thin bars between the two MUSIC knobs: Deck A left, Deck B right. Each shows its deck's sound after MUSIC and its kill: green, yellow when loud, red at the top. Empty means the deck is sending no sound.
- **Shaka** (SHOUT OUT in OUT), left of Pop Out on the MIXER header, on when you open the app: click to take the credits and the tagline off OUT and its pop-out, for the audience, while the deck stages keep theirs; click again to bring them back. The global Shaka still rules: on turns this one on, off turns SHOUT OUT off everywhere.
- **Pop Out**, the small square at the right end of the MIXER header: opens OUT, the mix, in its own window, with SHOUT OUT and the tagline. Double-click that window for fullscreen.
- **ISOLATOR**, in its own drawer (3.3.8): three large **LOW · MID · HIGH** knobs, with the bands' curves drawn behind them, on the whole mix (split at 250 Hz and 2.5 kHz). Each runs from a full kill (left) through 0 dB (centre, the default) to +6 dB (right). Drag, Shift+arrows, click = select, **Enter** = kill / restore (true silence), double-click = 0 dB. PERFORM only.
- **Shift+M** selects deck A's VISUAL from anywhere on PERFORM; W A S D then move on through the MIXER column (3.3.8).

#### 3.3.8 ISO · EQ · FX · MODE · Settings
**Blueprints:** sheet 6, PERFORM · MIXER COLUMN.

The panel strip under the MIXER, left to right **ISO · EQ · FX · MODE · Settings**: ISO (three crossing curves) and Settings (a gear) are icons. Each opens its drawer, which slides down out of the strip over the LIBRARY; click the lit button again to close it, or another button to switch. One drawer is open at a time.
- **ISO:** the master isolator, LOW · MID · HIGH (3.3.7). Its cyan dots light while a band is off 0 dB or killed.
- **EQ:** the deck TRIMs, EQs and their RGB (3.3.12).
- **FX:** the deck effects (3.3.9).
- **MODE:** the visual mix mode, how the decks combine in OUT (3.3.13).
- **Settings** (gear): both decks' shader settings, Deck A left and Deck B right (3.1.3.7). Its purple dots light, left Deck A and right Deck B, while a setting is off its default; Shift+click resets by where it lands, as EQ and FX. The Twister's Settings knob opens it as before.

The EQ and FX drawers have four outlined columns, as the mixer above them: deck A's two on the left, deck B's two on the right, visual outside and audio inside.

**The dots** on EQ and FX, two each side, are those columns in the same order: deck A visual (purple), deck A audio (cyan), deck B audio (cyan), deck B visual (purple). A dot glows while anything in its column is off its default (a level moved, an effect turned up, a knob killed), and is dim when the column is all at default. It never blinks.

**Shift+click** EQ or FX to reset without opening the drawer: click the left third for Deck A, the middle for both decks, the right third for Deck B. EQ goes back to 0 dB and ×1.00 with the kills cleared; FX goes back to each effect's neutral with the kills cleared, and the picked effects stay. Hold Shift over the button and the message bar says what a click there resets. Shift+Enter on the selected button resets both decks.

**One kill rule** for every knob in the EQ and FX drawers, the ISOLATOR and the four mixer encoders:
- **Click** selects the knob. The selected knob shows a ring: purple on a visual control, cyan on an audio one.
- **Enter** kills the selected knob, or restores it if killed. A killed knob dims and keeps its position; restoring returns to it. FX kills land on the next QUANT step while anything plays (a ring while they wait); EQ, TRIM, RGB, ISOLATOR and mixer kills happen at once.
- **Double-click** = the default (the effect's default, 0 dB, ×1.00, VISUAL 0 %, MUSIC silence), restored.
- **Drag** and **Shift+arrows** change the level: Shift+↑ / ↓ fine, Shift+← / → coarse.

**Keyboard in the MIXER column** (the app's one flow, 3):
- **Shift+M** jumps to deck A's VISUAL, **Shift+A** / **Shift+B** to Deck A's / Deck B's PLAY, **Shift+L** to the LIBRARY's ALL, from anywhere on PERFORM.
- **W A S D**, the **arrows** and **Tab** move on from there: the ISOLATOR, the encoders and LINKs, the EQ · FX · MODE strip, the open drawer's controls, then the LIBRARY. Inside an open drawer W A S D and the arrows stay in its grid; only W from its top row leaves, to the strip, and W again goes to the encoders.
- **Enter** on a strip button opens or closes its drawer.
- **Tab** from the strip, with a drawer open, goes to the drawer's first control; Tab and Shift+Tab then step through it.
- **Escape** in a drawer goes back to its lit button.

The keys do nothing while typing in a field or the Code view, or with Ctrl, Cmd or Alt held. In the TEMPO field, digits type a tempo and W A S D, the arrows and the jump keys still move.

#### 3.3.9 FX
Each deck has four effect knobs, two for the music and two for the picture, in the FX drawer's four columns:

| | Deck A | | Deck B | |
|---|---|---|---|---|
| Row 1 | VFX1 | AFX1 | AFX1 | VFX1 |
| Row 2 | VFX2 | AFX2 | AFX2 | VFX2 |

AFX (cyan) are music effects; VFX (purple) are visual effects on the deck's picture, seen on its stage and in OUT. The column says the deck; the labels carry no A or B.
- **Knob:** drag up or down for the amount. Click selects it, then Shift+↑ / ↓ (fine) or Shift+← / → (coarse); Enter kills the effect, Enter again restores it (3.3.8). Kills and restores land on the next QUANT step. Double-click resets the effect to its default.
- **Effect box** (under the knob): click it, then Shift+↑ / ↓ or Shift+← / → to step through the bank. A new music effect starts off. A new visual effect keeps the amount, and while music plays with QUANT on it comes in on the next QUANT step (the knob shows it armed); several switches before the step: the last one comes in. A name too long for its box ends in "…"; the message bar shows it in full.

**Music FX bank:** Filter (centre off, left low-pass, right high-pass), Washout, Dubby, Delay, Reverb, Flanger, Phaser, Bitcrush. Defaults: AFX1 Filter, AFX2 Dubby. Delay, Dubby, Flanger and Phaser follow the TEMPO and the QUANT step.

**Visual FX bank:** RGB Split, Feedback, Glitch, Pixelate, Scanlines, Mirror, Kaleidoscope, VHS, Shake, Tone (centre off, left darker and softer, right brighter and sharper), Tile, Rotate, Zoom. Defaults: VFX1 RGB Split, VFX2 Feedback. RGB Split, Shake and Zoom kick on the deck's beats; Glitch tears on the QUANT grid; Feedback trails fade over one QUANT step; Kaleidoscope turns with the bar; Rotate turns at the tempo.

Music FX play on PERFORM and on PLAY (PLAY's deck has its own, 3.1.2.6). Effects and their settings last for the session.

#### 3.3.10 LIBRARY
Drop files, folders (subfolders included) or zip files anywhere in the app (3.1.2.8). The LIBRARY is the same on PLAY and PERFORM. It lists:
- **Tracks:** each MP3 that has its Music Understanding `.json` (same name, or the name the `.json` gives). An MP3 without its `.json`, or a `.json` without its MP3, is left out. A square cover image with the track's name goes with it.
- **Shaders:** one entry per shader name, at its highest `_V##` (names without a version: the newest file).

One message in the bar sums up what was added, skipped and ignored. Dropping the same name again replaces its entry.

**Header:** **ALL · MUSIC · VISUALS · SETS ........ save · X**, on one line.
- **ALL** shows the tracks and the shaders, **MUSIC** the tracks, **VISUALS** the shaders, **SETS** the sets (3.3.11).
- **Save** (an arrow down onto a line), left of X: saves an OMS set (3.3.11).
- **X**, at the far right, clears the LIBRARY: tracks, covers, shaders and sets. The list goes back to ALL. The decks keep what they have; a playing track plays on.

**Sort header:** the headings above the rows. Tracks show **TITLE · ARTIST · BPM · KEY**; VISUALS shows **TITLE · AUTHOR · VER · TYPE**. Click a heading to sort by it (▲ / ▼), click it again to reverse. It opens on TITLE, A to Z, alphanumeric (2 before 10). A row without the sorted value goes last. SHUFFLE on PLAY keeps its own order; the headings then show no arrow. A set applied can be sorted by its headings too; while it is sorted, a cyan dot at the right end of the headings puts the playlist order back (so does picking the set again).

**Names:** a track shows its MP3 tags: title and artist. Without a title tag, the file name; other formats (WAV, M4A and so on), the file name. BPM and KEY come from the track's Music Understanding; KEY is the key the song spends longest in (Em, F#m, C). A shader shows its `@title`, `@author`, version and `@type` (3.1.3.8). The same names show in the deck's song info and the message bar.

**Entries:** click to select (cyan border); the list then takes the keys: ↑ / ↓ (or W / S) move the selection and show its name in the message bar, A or ← loads it on Deck A, D or → on Deck B, Delete removes it from the library (a deck keeps what it has). ↑ or W on the top row goes up to the header's lit button; on the header, A / D (or ← / →) move along it and S (or ↓) goes down into the list. Or drag an entry onto a deck. A track loaded onto a playing deck stops it and loads stopped (3.3.4). An entry on a deck is tinted yellow.

The LIBRARY is what you dropped this session. Nothing is saved.

#### 3.3.11 SETS
A set is a playlist. Export one from your music player as `.m3u8` (Swinsian, for example) and drop it with the music, before or after. Each `.m3u8` becomes a set, named by its `#PLAYLIST:` line, or else its file name with underscores as spaces. A set dropped again under the same name replaces the old one. The message bar names the sets a drop adds and counts their tracks found in the library (for example "set Night Set added · 2 of 2 found"). A drop applies no set.

**SETS** shows the sets as LIBRARY rows, in alphabetical order: the set's name and, in grey, its tracks found in the library of its total (12/14). SETS is greyed with no sets.
- **Double-click** (double-tap) a set, or select it and press **Enter**, to apply it: the list goes to MUSIC with that set's tracks in the set's order, and MUSIC and SETS light. The applied set is cyan, with a cyan dot.
- Double-click or Enter on the applied set turns it off. On another set, it switches.
- A set stays applied through MUSIC and VISUALS and through loading a track or shader. **ALL** clears it, and so does a drop with nothing playing.
- On a set row, ← / → and Delete do nothing.

Sets are held for the session.

**A folder is a set.** Drop a folder of tracks (each MP3 with its Music Understanding `.json`) that has no `.m3u8` or `.omsset` in it, and it becomes a set named after the folder, its tracks A to Z by file name. Drop several folders and each becomes its own set.

**OMS sets** keep a set and its Music Visual Pairs in one `.omsset` file. Click **save** in the LIBRARY header: with a set applied, the file is named after the set; with none applied, the set is your paired songs and you name it (Enter = save, Escape = cancel). It goes to Downloads ("OMS set saved: … (Downloads)"). Drop it back in, alone or with your library, and the set and its pairs return. A pair whose shader is not in the LIBRARY is skipped and counted.

**Yodega** (on the website): the artist's own sets, the YoPacks, each song paired with its shader. On PLAY, double-click one and it plays through: each song brings its visual. Each pack has its own link (3.1.2.7). The demo album that used to sit beside them has gone for now; the reference song with its default shader stays the default.

#### 3.3.12 EQ
The EQ drawer: a TRIM and a 3-band EQ for each deck's music, and a TRIM and RGB, the visual EQ, for each deck's picture. Four columns, as the mixer: RGB outside (under the VISUAL encoders), EQ inside (under the MUSIC encoders):

| Row | Deck A RGB | Deck A EQ | Deck B EQ | Deck B RGB |
|---|---|---|---|---|
| 1 | TRIM | TRIM | TRIM | TRIM |
| 2 | BLUE | HIGH | HIGH | BLUE |
| 3 | GREEN | MID | MID | GREEN |
| 4 | RED | LOW | LOW | RED |

- **TRIM, audio** (cyan): the deck's input gain, before the EQ, from −15 dB (left) through 0 dB (centre, the default) to +15 dB (right). A kill takes it to −15 dB.
- **TRIM, visual** (purple): one gain on the deck's whole picture, before the RGB knobs: off (left), ×1.00 (centre, the default), ×1.33 (right). A kill takes it to off.
- **EQ** (cyan): HIGH, MID and LOW, each from −26 dB (left) through 0 dB (centre) to +6 dB (right). LOW is a low shelf at 70 Hz, MID a bell at 1 kHz, HIGH a high shelf at 13 kHz. Near the centre the knob snaps to 0 dB. A kill drops the band to −26 dB. The deck's music goes through TRIM, then LOW, MID and HIGH, then its music FX, then its MUSIC encoder.
- **RGB** (purple): a gain on that colour channel of the deck's picture. Left = the channel off, centre = ×1.00 (as is), right = ×1.33. A kill takes the channel to 0. It acts on the picture after the visual FX: the deck's stage and OUT both show it.
- The value box under each knob shows its level (0 dB, ×1.00). Drag, Shift+arrows, click, Enter and double-click as in 3.3.8; double-click = 0 dB or ×1.00. Kills happen at once.

The TRIMs, EQ and RGB act on PERFORM only; PLAY plays its deck without them. Levels last for the session. On a short window (below about 820 px tall) the bottom row of the drawer can be cut off.

#### 3.3.13 MODE
The MODE drawer: sixteen visual mix modes for OUT, four rows of four. Click one, or select it and press Enter: it changes at once. The mode in use is purple. A VISUAL at 0 takes its deck out in every mode. The mode lasts for the session.

| Button | Mode | OUT shows | The VISUAL knobs |
|---|---|---|---|
| MIX | MIX | The crossfade: both decks blended | Each deck at its VISUAL |
| NAM | NAM | Non-additive mix: the brighter pixel of the two; a crossfade with no dip at the middle | Each deck at its VISUAL |
| ADD | ADD | Both added: bright parts brighten, can go to white | Each deck at its VISUAL |
| SCRN | SCREEN | Both, brightening without blowing out | Each deck at its VISUAL |
| MULT | MULTIPLY | Deck B only where deck A is bright: A the window, B the view | Deck A the base at VISUAL A; VISUAL B how much of B goes over it; VISUAL A at 0 = B alone |
| OVER | OVERLAY | A double exposure: deck B's colours and shapes over deck A's contrast | As MULTIPLY |
| DIFF | DIFFERENCE | Dark where the decks match, bright and inverted where they differ | Each deck at its VISUAL |
| LUMA | LUMA | Deck A is the matte: deck B shows through A's bright parts, A's dark parts hide it | VISUAL B is B's strength; VISUAL A is how much matte (0 = B unmasked) |
| DARK | DARKEN | The darker pixel of the two | Each deck at its VISUAL; a deck at 0 = the other alone |
| SOFT | SOFT LIGHT | A gentle overlay: deck B tints deck A | As MULTIPLY |
| EXCL | EXCLUSION | A softer DIFFERENCE: greys where DIFFERENCE inverts | Each deck at its VISUAL |
| INVL | INV LUMA | LUMA reversed: deck B shows through deck A's dark parts, A's bright parts hide it | As LUMA |
| SUB | SUBTRACT | Deck B taken out of deck A: dark and graphic | Each deck at its VISUAL |
| DODGE | DODGE | Deck B brightens deck A: hot, glowing highlights | As MULTIPLY |
| BURN | BURN | Deck B darkens deck A: deep, saturated shadows | As MULTIPLY |
| COLOR | COLOR | Deck A's light and shapes in deck B's colours | As MULTIPLY |

MIX and ADD look the same while the two VISUAL levels add up to 100 % or less; past that, MIX shows the average and ADD the sum. With both decks on the same shader the modes look alike: load another shader on one deck to see them.

#### 3.3.14 Midi Fighter Twisters
**Blueprints:** sheet 12, HARDWARE PERFORM MAP.

PERFORM plays from two DJ TechTools Midi Fighter Twisters, one per deck, straight out of the box: no setup tool. Use Chrome (it has Web MIDI); the website has no PERFORM and asks for no MIDI. Plug both in, open PERFORM, then **press any knob on the LEFT Twister** (only Twisters are listened to; other MIDI devices, buses and apps are ignored): it becomes Deck A (MFA). Then press a knob on the RIGHT one for Deck B (MFB). The message bar asks for each. They stay paired until you reload the page, also if you unplug one and plug it back in.

The knobs are named by column A to D, left to right, and row 1 to 4, top to bottom, on each Twister. MFB is the mirror of MFA, so each deck's controls sit on the outside and the gains meet in the middle:

| Row | MFA (Deck A): A | B | C | D | MFB (Deck B): A | B | C | D |
|---|---|---|---|---|---|---|---|---|
| 1 | Library | WF Cue | Visual Gain | Music Gain | Music Gain | Visual Gain | WF Cue | Library |
| 2 | VFX1 | AFX1 | BLUE | HIGH | HIGH | BLUE | AFX1 | VFX1 |
| 3 | VFX2 | AFX2 | GREEN | MID | MID | GREEN | AFX2 | VFX2 |
| 4 | Settings | AMU | RED | LOW | LOW | RED | AMU | Settings |

- **Library** (MFA A1, MFB D1): turn to move down the LIBRARY list (the rows showing). Push to load the selected track onto that Twister's deck, stopped (a playing deck stops first). Push twice quickly on a stopped deck to load and play: it starts on the next QUANT step once the track is ready. On a playing deck a double push also just stops it and loads. Hold the knob down and turn to change the master tempo, 0.1 BPM per click, as far as you like; hold it for 1 s without turning to put the tempo back to the master deck's. Both Library knobs move the same selection, and turning one closes an open EQ, FX or MODE drawer so the LIBRARY shows.
- **WF Cue** (MFA B1, MFB C1): turn to pick a block of the song in the current lane: an orange outline on it in the piano roll, and the message bar says which ("Deck A cue · section 2 of 26 · bar 9.1"). Push to jump there on the next QUANT step; the block fills orange while it waits. The outline stays, so pushing again jumps back, like a cue point. Hold the knob down and turn to switch lane: sections, segments, phrases. Loading another track drops the outline.
- **Visual Gain** (MFA C1, MFB B1) and **Music Gain** (MFA D1, MFB A1): turn = the level; push = kill or restore. Push Visual Gain twice quickly to turn LINK on (VISUAL glides to MUSIC, 3.3.7).
- **EQ and FX** knobs: turn = the level, and the drawer opens so you see it. With the drawer closed, a push only opens it; with it open, push = kill or restore (FX on QUANT, as on screen).
- **Settings** (MFA A4, MFB D4): turn to open the deck's Settings drawer and move along its settings (an orange outline); turn back past the first to reach the Settings button. Push on a setting to change it (turn sets its value, push again to stop); push twice quickly to put that setting back to its default. On the Settings button, push closes the drawer and two quick pushes reset every setting.
- **AMU** (MFA B4, MFB C4): turn to move an orange outline along the deck's Music Understanding groups and lanes; push to solo or unsolo it. It closes the deck's Settings drawer, which covers the chips.

The rings show the app's values, cyan for sound and purple for picture, and follow any change you make on screen; the knob carries on from there. The side buttons do nothing. If a Twister slips to another bank (a middle side button pressed), Vizzie puts it straight back on bank 1. If the two Twisters report the same name and get crossed, the first turn fixes it ("turn again").

### 3.4 HELP, ABOUT and LEARN tabs

**HELP**: LET'S DO THIS, eight things to try, in two boxes. **ABOUT**: what Vizzie is, who made it, the license. **LEARN** opens the learning page on onemanshyo.com in a new tab.

## 4. Messages

The bar at the bottom of the screen. Everything the app has to tell you appears here, in three colours:
- **Cyan, help:** what a control is and its keys, while you point at it or click into it, and the live values of a lane or group.
- **Orange, values:** what just changed: playing, TEMPO, QUANT, a pair, a cue, an effect, a level, a setting, a file loaded or exported.
- **Red, errors:** something failed: a file Vizzie can't use, a track that won't decode, a cover that isn't square, a settings line the app cannot read, pop-out blocked, recording not supported.

When nothing needs saying, the bar is empty. Shader problems show in the visual itself instead: no WebGPU in the browser, or a mistake in the shader (the message gives the line number). Every message is listed in 6.

If hover help stops appearing after a click in Chrome, a browser extension may be holding the mouse; turn extensions off to check.

## 5. Pocket Rave (phones and tablets)
**Blueprints:** sheet 4, POCKET RAVE.

On the website, phones and tablets in portrait get Pocket Rave; phones stay in Pocket Rave in landscape too. Tablets in landscape get the full app. Code, pop-out, orientation, TEMPO, the LIBRARY, FX, the message bar and PERFORM are only in the full app. Pocket Rave plays PLAY's deck, with its EQ and effects, and is touch only.

### 5.1 Canvas view
Pocket Rave opens on the **Canvas view**: the shader fills the window under the header. **Tap** the shader to play or pause. **Double-tap** it, or tap the ONEMANSHYO header, for the **Controls view**.

### 5.2 Controls view
Under the tabs, full width, top to bottom: the **VISUAL** header with **orientation** and **REC**, the canvas (16:9), the **MUSIC** header with **PLAY NEXT · CONTINUOUS · SHUFFLE · EQ · FX · Settings**, the cover beside the waveform, the **MUSIC UNDERSTANDING** header, its lane buttons and roll, the status line (section · bar · BPM · key), the version line and PLUR. The view scrolls. There is no PLAY button: tap the canvas. Tap the ONEMANSHYO header to go back to the Canvas view.
- **Canvas:** tap to play or pause; double-tap to pick a `.wgsl` shader from your device.
- **Orientation and REC:** PLAY's own buttons (3.1.3.4, 3.1.3.5): one setting for both.
- **PLAY NEXT · CONTINUOUS · SHUFFLE · EQ · FX · Settings:** PLAY's own controls, in the same order, with the same dots; EQ, FX and Settings open over Music Understanding, one at a time; tap the lit button again, or go full frame, to close. With AUTO MIX on (turned on in PLAY), the waveform shows the mix zone as PLAY's does.
- **Cover:** tap to show or hide the song info over the waveform; double-tap to pick an MP3 from your device.
- **Waveform:** drag to move the playhead.
- **Lane buttons:** colour only, for STRUCTURE (section, segment, phrase) and INSTRUMENTS (drum, bass, vocal, other). Tap one to solo it.
- **Roll:** the same seven lanes, horizontal, scrolling with the playhead; the instrument lanes are lower than the structure lanes. Drag to scrub, tap a structure block to cue to its start, pinch to zoom.

### 5.3 Tabs and links
ABOUT is in the tabs; LEARN opens the website.

## 6. Message index

Every message the bar shows, as worded in this release. NAME stands for a file, track, set, lane, effect or setting name (a track: its title · artist; a shader: its title); N for a number. On PERFORM, deck controls start with "Deck A:" or "Deck B:".

### 6.1 Help

#### 6.1.1 App header and tabs

| # | Control | Message |
|---|---|---|
| 6.1.1.1 | Brand | ONEMANSHYO vizzie app |
| 6.1.1.2 | Version | App version |
| 6.1.1.3 | Tagline | Tagline on / off: scrolls across the top of the picture with SHOUT OUT · double-click = on / off · the red power light (top left) makes this and the header name editable: up to 75 characters each, this session |
| 6.1.1.4 | PERFORM tab | PERFORM: two decks and the mixer |
| 6.1.1.5 | PLAY tab | PLAY: music and visuals |
| 6.1.1.6 | ABOUT tab | ABOUT |
| 6.1.1.7 | LEARN tab | LEARN |
| 6.1.1.8 | onemanshyo.com link (ABOUT) | onemanshyo.com |
| 6.1.1.9 | CREATE tab | CREATE: author a shader to its music |
| 6.1.1.10 | HELP tab | HELP |
| 6.1.1.11 | LET'S DO THIS header (HELP) | LET'S DO THIS |

#### 6.1.2 PERFORM: global strip

| # | Control | Message |
|---|---|---|
| 6.1.2.1 | Master PLAY | Master PLAY: start every deck from its playhead (Space) / Master PAUSE: stop the whole mix at once (Space) / Master PLAY: resume the paused mix from the same spot (Space) |
| 6.1.2.2 | Master position | Master position: the session on the master clock, from the first PLAY; holds while every deck is stopped (bar.beat.sixteenth · double-click = 1.1.1) |
| 6.1.2.3 | TEMPO | Mix TEMPO follows the MASTER deck's tempo changes / Mix TEMPO set by hand: holds (click, then Shift+↑↓ ±1 BPM, Shift+←→ ±0.01 BPM, or type + Enter · double-click = the MASTER deck's tempo, following) |
| 6.1.2.4 | QUANT | QUANT: cues (roll blocks, waveform clicks) and PLAY wait for the next step · None = at once (Shift+↑↓ · scroll · double-click = 1/4) |
| 6.1.2.5 | MASTER | MASTER: the output level, after the isolator, before DSP (Shift+↑↓ ±1 dB · Shift+←→ ±0.1 dB · scroll · double-click = 0 dB) |
| 6.1.2.6 | DSP | DSP: the master output compressor / limiter (presets, THRESH, RATIO, OUTPUT) |
| 6.1.2.7 | DSP preset box | DSP preset Limiter (click, then Shift+↑↓: Off · Gentle · Medium · Aggressive · Limiter) |
| 6.1.2.8 | THRESH, RATIO, OUTPUT and their values | DSP THRESH -3.0 dB (drag · Shift+↑↓ ←→ · click = select · double-click = 0 dB) / DSP RATIO 20.0:1 (… double-click = 1.0:1) / DSP OUTPUT 0 dB (… double-click = 0 dB) |
| 6.1.2.9 | GR | DSP gain reduction: how hard the compressor is working now |
| 6.1.2.10 | Shaka (PERFORM, PLAY and CREATE strips) | SHOUT OUT: music and visual credits (on / off) |

#### 6.1.3 PERFORM: deck

| # | Control | Message |
|---|---|---|
| 6.1.3.1 | Deck header | DECK A: its stage, music, transport and Music Understanding (drop files anywhere: into the LIBRARY) |
| 6.1.3.2 | MASTER, on | Deck A: MASTER: this deck sets the tempo · click = make this deck master |
| 6.1.3.3 | MASTER, off | Deck A: Not master: the playing deck that started first sets the tempo (nothing playing: the deck up in the mix) · click = make this deck master |
| 6.1.3.4 | Music Visual Pair | Music Visual Pair on: TITLE + SHADER (click = unpair) / Music Visual Pair off (click = pair TITLE with SHADER) |
| 6.1.3.5 | Stage | Deck A: Stage: the deck's shader (double-tap = load a .wgsl · drop files anywhere: into the LIBRARY) |
| 6.1.3.6 | Cover | Deck A: Cover (tap = song info · double-tap = load an MP3) |
| 6.1.3.7 | Waveform | Deck A: Waveform (click = cue on QUANT · drag = scrub · double-tap = load an MP3) |
| 6.1.3.8 | PLAY | Play / Pause, then " · armed, waits for QUANT (press again = cancel)" or " · waits for QUANT when another deck plays" |
| 6.1.3.9 | CUE | CUE: back to the start of the track; while playing: CUE: back to the start of the track on QUANT, playing on (as a chip click) |
| 6.1.3.10 | LOOP | LOOP: off (chip clicks land on QUANT) / LOOP: armed: the track loops; click a chip to loop it (chip clicks land on QUANT) / LOOP: looping a chip (click it again = the whole track) (chip clicks land on QUANT) |
| 6.1.3.11 | SOLO | SOLO: lit while a lane or bus is soloed (press = clear all solos) |
| 6.1.3.12 | Position | Deck A: Arrangement position (bar.beat.sixteenth) |
| 6.1.3.13 | Zoom | Deck A: Piano roll zoom: 0 = closest (4 bars), 100 = the whole song (Shift+↑↓ 0 / 25 / 50 / 75 / 100 · ctrl + wheel, pinch on the roll) |
| 6.1.3.14 | Roll orientation | Deck A: Piano roll vertical / horizontal |
| 6.1.3.15 | Piano roll | Deck A: Piano roll (drag = scrub · click a block = cue to its start · Shift+click a second section / segment / phrase = the range between (PLAY: it stays until Esc or a plain chip click; REC renders it) · ctrl + wheel, pinch = zoom) |
| 6.1.3.16 | Lane chip | NAME · slot N · on / muted · live value (click = solo) |
| 6.1.3.17 | Bus | NAME bus · its lanes (solo the bus) |
| 6.1.3.18 | </> Code | Deck A: Shader code: show / hide |
| 6.1.3.20 | Apply (Code view) | Deck A: Apply the code to the stage |
| 6.1.3.21 | Copy (Code view) | Deck A: Copy the shader code |
| 6.1.3.22 | Export (Code view) | Deck A: Export: NAME_V12.wgsl to Downloads, the code with these settings as its defaults |
| 6.1.3.23 | Code editor | Deck A: Shader code (edit, then Apply) |
| 6.1.3.24 | Lock | Deck A LOCK on: no song loads while it plays, shaders still do (click = on / off) / Deck A LOCK off: a song loaded while it plays stops it and loads at 1.1.1 (click = on / off) |

Lane values: BEAT beat, beatPhase · BAR bar, barPhase · SECTION section n/N, progress · SEGMENT segment progress · PHRASE phrase n/N, progress · KEY mode, tonic · PACE pace · LOUDNESS momentary LUFS · DRUM, BASS, VOCAL, OTHER activity. Buses: RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS.

#### 6.1.4 PERFORM: MIXER

| # | Control | Message |
|---|---|---|
| 6.1.4.1 | MIXER header | MIXER: OUT and the four encoders (A VISUAL, A MUSIC, B MUSIC, B VISUAL) · Shift+M = into the mixer (Shift+A / Shift+B = into Deck A / Deck B, Shift+L = the LIBRARY), then W A S D or Tab |
| 6.1.4.2 | OUT | OUT: the mix of the decks' visuals at their VISUAL strengths |
| 6.1.4.3 | A VISUAL / B VISUAL | Deck A visual in OUT N% (drag · Shift+↑↓ ←→ · click = select · Enter = kill / restore · double-click = 0%); " · killed" while killed |
| 6.1.4.4 | A MUSIC / B MUSIC | Deck A music volume −N dB (drag · Shift+↑↓ ←→ · click = select · Enter = kill / restore · double-click = silence); " · killed" while killed |
| 6.1.4.5 | LINK | Deck A LINK on (click = off · linked: move MUSIC and VISUAL catches up, then follows · move VISUAL = unlinks) / Deck A LINK off (click = on · linked: move MUSIC and VISUAL catches up, then follows · move VISUAL = unlinks) |
| 6.1.4.6 | ISOLATOR knob and its label | Isolator LOW 0 dB (drag · Shift+↑↓ ←→ · click = select · Enter = kill / restore · double-click = 0 dB); MID and HIGH the same; " · killed" while killed |
| 6.1.4.7 | Pop Out | Pop Out OUT (the mix) to its own window · double-click it for fullscreen |
| 6.1.4.8 | Shaka (MIXER) | SHOUT OUT in OUT: the mixed output's credits (on / off) |

#### 6.1.5 PERFORM: EQ · FX · MODE

| # | Control | Message |
|---|---|---|
| 6.1.5.0 | ISO | ISOLATOR: the master isolator, LOW · MID · HIGH (W A S D move) |
| 6.1.5.1 | EQ | EQ: the deck EQs, TRIM · HIGH · MID · LOW, and their RGB, TRIM · BLUE · GREEN · RED (W A S D move) |
| 6.1.5.2 | FX | FX: the deck effects (W A S D move) |
| 6.1.5.3 | MODE | MODE: the visual mix mode, how the decks combine in OUT (W A S D move) |
| 6.1.5.3a | Settings (gear) | SETTINGS: the decks' shader settings, Deck A · Deck B (W A S D move) |
| 6.1.5.4 | Mode button | NAME: what it does, " (on)" on the mode in use; the sixteen are below |
| 6.1.5.5 | FX knob and its label | Deck A AFX1 · Filter N% (drag · Shift+↑↓ ←→ · click = select · Enter = kill / restore · double-click = reset); " · killed" while killed. Filter and Tone show LP / HP or dark / bright N%, or off |
| 6.1.5.6 | FX effect box | Deck A AFX1 effect · Filter (Shift+↑↓ ←→) |
| 6.1.5.7 | EQ knob, its label and value | Deck A EQ HIGH 0 dB (drag · Shift+↑↓ ←→ · click = select · Enter = kill / restore · double-click = 0 dB); " · killed" while killed |
| 6.1.5.8 | RGB knob, its label and value | Deck A RGB BLUE ×1.00 (drag · Shift+↑↓ ←→ · click = select · Enter = kill / restore · double-click = ×1.00); " · killed" while killed |
| 6.1.5.9 | Audio TRIM, its label and value | Deck A audio TRIM 0 dB (drag · Shift+↑↓ ←→ · click = select · Enter = kill / restore · double-click = 0 dB); " · killed" while killed |
| 6.1.5.10 | Visual TRIM, its label and value | Deck A visual TRIM ×1.00 (drag · Shift+↑↓ ←→ · click = select · Enter = kill / restore · double-click = ×1.00); " · killed" while killed |

Mode buttons (6.1.5.4):

| Button | Message |
|---|---|
| MIX | MIX: the crossfade: both decks at their VISUAL strengths, blended |
| NAM | NAM: non-additive mix: the brighter pixel of the two, no dip at the middle of a crossfade |
| ADD | ADD: both added: bright parts brighten, can go to white |
| SCRN | SCREEN: both, brightening without blowing out |
| MULT | MULTIPLY: deck B only where deck A is bright (A the window, B the view) |
| OVER | OVERLAY: a double exposure: deck B's colours and shapes over deck A's contrast |
| DIFF | DIFFERENCE: dark where the decks match, bright and inverted where they differ |
| LUMA | LUMA: deck A is the matte: deck B shows through A's bright parts, A's dark parts hide it; VISUAL A = how much matte |
| DARK | DARKEN: the darker pixel of the two |
| SOFT | SOFT LIGHT: a gentle overlay: deck B tints deck A |
| EXCL | EXCLUSION: a softer difference: greys where DIFFERENCE inverts |
| INVL | INV LUMA: deck A is the matte: deck B shows through A's dark parts, A's bright parts hide it; VISUAL A = how much matte |
| SUB | SUBTRACT: deck B taken out of deck A: dark and graphic |
| DODGE | DODGE: deck B brightens deck A: hot, glowing highlights |
| BURN | BURN: deck B darkens deck A: deep, saturated shadows |
| COLOR | COLOR: deck A's light and shapes in deck B's colours |

#### 6.1.6 PERFORM: LIBRARY

| # | Control | Message |
|---|---|---|
| 6.1.6.1 | LIBRARY header and list | LIBRARY · drop files: MP3, AMU .json, .wgsl, cover image, .m3u8 playlist, .omsset |
| 6.1.6.2 | ALL | Library: show music and shaders |
| 6.1.6.3 | MUSIC | Library: show music only |
| 6.1.6.4 | VISUALS | Library: show visuals only |
| 6.1.6.5 | SETS | Library: Set NAME · N sets · click to show (a set applied) / Library: N sets · click to show / Library: sets · drop an .m3u8 anywhere (no sets) |
| 6.1.6.6 | X | Library: clear everything (tracks, shaders, covers, playlists); the decks keep what they have |
| 6.1.6.7 | Sort header | Sort: click a heading · again = reverse / Set NAME: the playlist order · click a heading to sort / Set NAME: sorted · click a heading · again = reverse · the dot or pick the set again = the playlist order / SHUFFLE: a random order (PLAY) |
| 6.1.6.8 | Track entry | NAME (W S or ↑↓ · A or ← Deck A · D or → Deck B · Delete) |
| 6.1.6.9 | Shader entry | title · author — description (W S or ↑↓ · A or ← Deck A · D or → Deck B · Delete) |
| 6.1.6.10 | Set row | Set NAME: N of N tracks in the library · double-click or Enter = apply (on the applied set: = turn off) |
| 6.1.6.11 | Save (OMS set) | Save OMS set: NAME.omsset · the set NAME, N tracks · N Music Visual Pairs / Save OMS set: no set applied · the paired songs · N Music Visual Pairs |

#### 6.1.7 PLAY: music, controls, LIBRARY, FX and Visuals

| # | Control | Message |
|---|---|---|
| 6.1.7.1 | MUSIC header | MUSIC: cover, waveform and transport (drop files anywhere: into the LIBRARY) |
| 6.1.7.2 | VISUALS header | VISUALS: the shader on the stage |
| 6.1.7.3 | MUSIC UNDERSTANDING header | MUSIC UNDERSTANDING: the AMU lanes and buses (click = solo) and the piano roll |
| 6.1.7.4 | TEMPO | TEMPO follows the song (its own tempo, as recorded) / TEMPO held by the SELECTA (Post-mix maximum change), until a track loads or the next mix / TEMPO set by hand: holds until a track loads (click, then Shift+↑↓ ±1 BPM, Shift+←→ ±0.01 BPM, or type + Enter · double-click = follow the song again) |
| 6.1.7.5 | QUANT | as 6.1.2.4 |
| 6.1.7.6 | Position | Arrangement position (bar.beat.sixteenth) |
| 6.1.7.7 | PLAY, CUE, LOOP, Music Visual Pair, SOLO | as 6.1.3.8 to 6.1.3.11, 6.1.3.4 |
| 6.1.7.8 | Stage | Stage: the shader (double-tap = load a .wgsl · drop files anywhere: into the LIBRARY) |
| 6.1.7.9 | Cover | Cover (tap = song info · double-tap = load an MP3) |
| 6.1.7.10 | Waveform | Waveform (click = cue on QUANT · drag = scrub · double-tap = load an MP3) |
| 6.1.7.11 | Zoom | Piano roll zoom: 0 = closest, 100 = the whole song (Shift+↑↓ 0 / 25 / 50 / 75 / 100 · ctrl + wheel, pinch on the roll) |
| 6.1.7.12 | Roll orientation | Piano roll vertical / horizontal |
| 6.1.7.13 | Piano roll | as 6.1.3.15, without "Deck A:" |
| 6.1.7.14 | Lane chip (CREATE) | as 6.1.3.16 |
| 6.1.7.15 | Lane chip (PLAY) | as 6.1.3.16 |
| 6.1.7.16 | Bus | as 6.1.3.17 |
| 6.1.7.17 | Orientation | Orientation 16:9 / 1:1 / 9:16 |
| 6.1.7.18 | Pop Out | Pop Out the visual to its own window |
| 6.1.7.19 | REC | REC the visual from the playhead (a chip clicked while stopped = render that chip; LOOP on = loop it) · press again = stop and save |
| 6.1.7.20 | GLOBAL header | GLOBAL: tempo · QUANT · position |
| 6.1.7.21 | FX | FX: the deck effects |
| 6.1.7.21a | EQ | EQ: the deck EQ, TRIM · HIGH · MID · LOW, and its RGB, TRIM · BLUE · GREEN · RED |
| 6.1.7.22 | PLAY NEXT | PLAY NEXT: the next track, now |
| 6.1.7.23 | CONTINUOUS PLAY | CONTINUOUS PLAY: the next track plays at the end |
| 6.1.7.24 | SHUFFLE | SHUFFLE: the list in a random order |
| 6.1.7.24a | AUTO MIX | AUTO MIX: each song mixes into the next (the SELECTA mix zone, shaded on the waveform) |
| 6.1.7.24b | SELECTA | SELECTA: how AUTO MIX mixes (the knobs), and SELECTA recording (record in the panel) / SELECTA: turn AUTO MIX on to open its panel (SELECTA sets how AUTO MIX mixes) |
| 6.1.7.24c | SELECTA record | SELECTA recording: logs each mix and each knob or tempo change while AUTO MIX plays · stop writes the OMS set and adds it to the LIBRARY · the moves only, no audio |
| 6.1.7.24d | Dice (SELECTA header) | Dice: a new random seed for VIS FREQ chaos (its lines and shaders; CHIPPY's too) |
| 6.1.7.25 | FX knob and its label | AFX1 · Filter N% (drag · Shift+↑↓ ←→ · click = select · Enter = kill / restore · double-click = reset); " · killed" while killed |
| 6.1.7.26 | FX effect box | AFX1 effect · Filter (Shift+↑↓ ←→) |
| 6.1.7.27 | LIBRARY header and list | as 6.1.6.1 |
| 6.1.7.28 | ALL, MUSIC, VISUALS, SETS, X, sort header, set row | as 6.1.6.2 to 6.1.6.7, 6.1.6.10 |
| 6.1.7.29 | Track entry | NAME (W S or ↑↓ · Enter, A D, ←→ or double-click load · Delete) |
| 6.1.7.30 | Shader entry | title · author — description (W S or ↑↓ · Enter, A D, ←→ or double-click load · Delete) |
| 6.1.7.31 | Settings (gear) | SETTINGS: the shader settings |
| 6.1.7.32 | FOLLOW | FOLLOW: the visuals follow the song pairs; a visual button turns it off, FOLLOW again resumes from the next song |
| 6.1.7.33 | Visual PLAY NEXT | Visual PLAY NEXT: the next shader now (on QUANT while music plays) |
| 6.1.7.34 | Visual CONTINUOUS | Visual CONTINUOUS: the next shader at each song change (mixed in an audio AUTO MIX) |
| 6.1.7.35 | Visual SHUFFLE | Visual SHUFFLE: the visual list in its own random order |
| 6.1.7.36 | LIBRARY expand | LIBRARY: expand down over Music Understanding (more rows, e.g. for pairing) / LIBRARY: back to its place (or Esc) |
| 6.1.7.37 | Add files | Add files: MP3, AMU .json, .wgsl, cover image, .m3u8 playlist, .omsset, .zip (the same as a drop) |
| 6.1.7.38 | SELECTA knob | MIX POINT: which section line the mix sits on: before the last full section, or one or two sections earlier · drag up / down, or click = next, Shift+click = back, wheel or arrows step, double-click = default (MIX LENGTH, TEMPO AFTER MIX, MODE: each with its own line) |

#### 6.1.8 CREATE

CHIPPY: 'CHIPPY: chiptune from the loaded AMU (its tempo, key and sections), playing with the deck · click = on / off'. CHIPPY's dice: 'CHIPPY dice: a new random seed over the same AMU (same key, grid and sections) · lands on the next bar'.

| # | Control | Message |
|---|---|---|
| 6.1.8.1 | Visual header | VISUAL: the shader on the stage |
| 6.1.8.2 | Code | Shader code: show / hide |
| 6.1.8.3 | Code editor | Shader code (edit, then Apply) |
| 6.1.8.4 | Apply | Apply the code to the stage, preview only |
| 6.1.8.5 | Copy | Copy the shader code |
| 6.1.8.6 | Section headers | NAME (▾ = expand / collapse) |
| 6.1.8.7 | ▾ | Expand / collapse the section |
| 6.1.8.8 | GRID, GUIDES, POINTS | Grid overlay on / off (tap the stage = read a point); Guides and Points the same |
| 6.1.8.14 | REF | Reference person on / off: a 1.8 m person on the ground line, to check the asset is real size |
| 6.1.8.15 | Scroll lock | Scroll lock: keep the picture in place while Music and everything below scrolls (on at every load) |
| 6.1.8.9 | CRYPTOMATTE | CRYPTOMATTE: each object flat in its ID colour, on / off |
| 6.1.8.10 | ALL ON / ALL OFF | Objects: turn all on / Objects: turn all off |
| 6.1.8.11 | Object tile | Object NAME: on / off |
| 6.1.8.12 | Export | Export: NAME_V12.wgsl to Downloads, the code with these settings as its defaults |
| 6.1.8.13 | Settings | Settings: show / hide |

Code, Apply, Copy, Export and the editor are the same controls on PLAY.

#### 6.1.9 Settings drawer (every stage)

| # | Control | Message |
|---|---|---|
| 6.1.9.1 | Number knob and its label | NAME value · help · min to max (drag up / down · Shift+↑↓ ±step · Shift+←→ ±5 steps · double-tap = default) |
| 6.1.9.2 | Number value box | NAME value · help · min to max (click, then ↑↓ ±step, or type + Enter · double-click = default) |
| 6.1.9.3 | Colour knob and its label | NAME #RRGGBB · help (tap / Enter = colour wheel · drag up / down or Shift+arrows = hue · double-tap = #RRGGBB) |
| 6.1.9.4 | Colour value box | NAME #RRGGBB · help (type a hex + Enter · double-click = #RRGGBB) |
| 6.1.9.5 | Colour wheel | Colour wheel: hue around, saturation from the centre out · bar: value, black to full |
| 6.1.9.6 | Settings button | Settings: show / hide (dot lit: a setting is off its default · Shift+click = reset them all) |

The help after the value is the shader's own, from its declaration; without it the "· help" part is left out. On PERFORM each starts with "Deck A: " or "Deck B: ".

### 6.2 Values

| # | Event | Message |
|---|---|---|
| 6.2.1 | Master PLAY / PAUSE | Mix playing · Deck A + Deck B / Mix paused · PLAY resumes it from here |
| 6.2.2 | Deck PLAY / PAUSE | Playing · AMU clock + audio / Playing · AMU clock (no audio) / Paused |
| 6.2.3 | PLAY waiting | Deck A: Starts on the next 1/4 |
| 6.2.4 | PLAY cancelled | Deck A: Start cancelled |
| 6.2.5 | Waveform cue | Deck A: Cue · bar N.N · QUANT 1/4 |
| 6.2.6 | Block cue / loop | Deck A: Cue · NAME · bar N.N · QUANT 1/4 / Deck A: Loop · NAME · bar N.N |
| 6.2.7 | Loop released | Deck A: Loop released · the track loops |
| 6.2.8 | LOOP | Deck A: Loop off / Loop · the picked chip / Loop armed: the track loops · click a chip to loop it |
| 6.2.9 | Music Visual Pair | Deck A: Music Visual Pair on: TITLE + SHADER / Deck A: Music Visual Pair off |
| 6.2.10 | Solos cleared | Deck A: All solos cleared |
| 6.2.11 | TEMPO | TEMPO 124.00 BPM / TEMPO follows the song · 124.00 BPM (double-click) |
| 6.2.12 | QUANT | QUANT 1/4 |
| 6.2.13 | Master position reset | Master position 1.1.1 |
| 6.2.14 | Mixer encoder | Deck A audio · −12.0 dB / Deck A in OUT · 50%, with " · killed" while killed |
| 6.2.15 | FX knob | Deck A AFX1 · Filter N% (· killed) |
| 6.2.16 | FX kill / restore | Deck A AFX1 · kill on the next 1/4 / restore on the next 1/4; with QUANT at None or nothing playing, at once: Deck A AFX1 · Filter N% · killed |
| 6.2.17 | Zoom | Deck A: Piano roll N% |
| 6.2.18 | Roll orientation | Deck A: Piano roll horizontal / vertical |
| 6.2.19 | Orientation | Orientation 16:9 |
| 6.2.20 | Pop Out | Visual popped out, double-click it for fullscreen / OUT popped out, double-click it for fullscreen |
| 6.2.21 | REC saved | Recording saved (MP4) / Recording saved (WebM) / Chip rendered · recording saved |
| 6.2.22 | End of track | End of track, playhead reset |
| 6.2.23 | Shader loaded | Loaded NAME |
| 6.2.24 | MP3 loading | Loading NAME … / Loaded NAME · AMU driving the visual |
| 6.2.25 | AMU loaded | Loaded AMU NAME · N BPM · N sections · N bars |
| 6.2.26 | Cover loaded | Deck A: Cover NAME |
| 6.2.27 | Shader waiting for QUANT | Deck B: NAME on the next 1/4 |
| 6.2.28 | Library drop | Library: N tracks · N covers · N shaders · N files ignored, with skipped covers, the sets added and the applied set's count |
| 6.2.29 | Library entry removed | Library: removed NAME |
| 6.2.30 | Applied set's count | Playlist NAME: N found · N no AMU · N not found |
| 6.2.31 | Sets added | Library: set NAME added · N of N found / Library: N sets added · NAME N/N · NAME N/N |
| 6.2.32 | PLAY NEXT, empty LIBRARY | PLAY NEXT: no tracks in the LIBRARY |
| 6.2.33 | CONTINUOUS PLAY | Continuous play on / Continuous play off |
| 6.2.34 | SHUFFLE | Shuffle on / Shuffle off |
| 6.2.35 | FX knob reset | Deck A AFX1 · Filter N% (PLAY: AFX1 · Filter N%), at the default amount |
| 6.2.36 | Header rename | Header: type a name (Enter = keep · Esc = cancel · empty = ONEMANSHYO) / Header: NAME (this session) / Header unchanged |
| 6.2.37 | Mixer encoder kill / restore | Deck A audio · −12.0 dB · killed / Deck A audio · −12.0 dB · restored (VISUAL: Deck A in OUT · 50% …) |
| 6.2.38 | Shift+M | Mixer: W A S D, arrows or Tab move · Shift+arrows = level · Enter = kill / open · Escape = out of a drawer |
| 6.2.39 | EQ knob | Deck A EQ HIGH +6.0 dB / Deck A EQ LOW −26.0 dB / Deck A EQ MID 0 dB |
| 6.2.40 | RGB knob | Deck A RGB RED ×1.00 |
| 6.2.41 | EQ / RGB / TRIM kill / restore | Deck A EQ HIGH 0 dB · killed / Deck A EQ HIGH 0 dB · restored (RGB and TRIM the same) |
| 6.2.42 | Visual mix mode | Visual mix mode NAME: what it does (the texts in 6.1.5) |
| 6.2.43 | Setting, number | NAME value (Deck B: NAME value on PERFORM) |
| 6.2.44 | Setting, colour | NAME #RRGGBB (Deck B: NAME #RRGGBB on PERFORM) |
| 6.2.45 | Export | Exported NAME_V12.wgsl to Downloads (Deck B: Exported … on PERFORM) |
| 6.2.46 | Code view line | applied (PLAY and CREATE: applied (preview only)) / error, see stage / copied / copy failed / exported |
| 6.2.47 | Library cleared (X) | Library cleared · the decks keep what they have |
| 6.2.48 | CUE | Deck A: CUE · the start · QUANT 1/4 (playing) / Deck A: CUE · the start (paused) |
| 6.2.49 | Song switch | Deck A: Loading NAME … (switches on QUANT) / Deck A: NAME on the next 1/4 / Deck A: Playing NAME |
| 6.2.50 | Song switch cancelled (PLAY) | Deck A: Switch cancelled · the song plays on |
| 6.2.51 | Mixer encoder, LINK on | Deck A audio · −12.0 dB · LINK: VISUAL N% catching up / Deck A audio · −12.0 dB · LINK: VISUAL N% follows |
| 6.2.52 | LINK off by VISUAL | Deck A in OUT · N% · LINK off (VISUAL moved) |
| 6.2.53 | LINK click | the LINK help (6.1.4.5), with its new state |
| 6.2.54 | MASTER by hand | Deck A is MASTER (by hand; the next start, stop or MUSIC up / down hands it back to AUTO) |
| 6.2.55 | Audio / visual TRIM | Deck A audio TRIM +3.0 dB / Deck A visual TRIM ×1.00 |
| 6.2.56 | ISOLATOR | Isolator LOW +1.2 dB / Isolator LOW 0 dB · killed / Isolator LOW 0 dB · restored |
| 6.2.57 | MASTER field | MASTER −2.0 dB |
| 6.2.58 | DSP preset | DSP preset Aggressive |
| 6.2.59 | DSP knob | DSP THRESH -20.0 dB / DSP RATIO 4.0:1 / DSP OUTPUT +1.6 dB |
| 6.2.60 | Shift+A / Shift+B | Deck A: W A S D or Tab move · Enter = on / off |
| 6.2.61 | Shift+L | Library: W A S D, arrows or Tab move · in the list A / D load / Library: under the open drawer (EQ · FX · MODE); close it first |
| 6.2.62 | Header name / tagline while typing | Header: 31/75 (Enter = keep · Esc = cancel · empty = ONEMANSHYO) / Tagline: 18/75 (Enter = keep · Esc = cancel · empty = Music makes magic!) |
| 6.2.63 | Header name / tagline kept | Header: NAME (this session) / Header unchanged |
| 6.2.64 | Shift over EQ or FX | Shift+click: reset Deck A EQ / Shift+click: reset both decks FX |
| 6.2.65 | EQ or FX reset | EQ reset: Deck A to default / FX reset: both decks to default |
| 6.2.66 | Settings reset | Settings reset: every setting to the shader default (PERFORM: "Deck A: " first) |
| 6.2.67 | Twister not bound | MIDI: press a knob on the LEFT Twister (Deck A) / MIDI: press a knob on the RIGHT Twister (Deck B) |
| 6.2.68 | Twister bound | MIDI: Twister bound to Deck A · now press a knob on the RIGHT Twister (Deck B) / MIDI: Twister bound to Deck B |
| 6.2.69 | Twister WF Cue | Deck A cue · section 2 of 26 · bar 9.1 (push = jump on QUANT); SEGMENT or PHRASE in place of section after a lane switch |
| 6.2.70 | Twister Library | the row's help |
| 6.2.71 | Twister AMU | the group's or lane's help, then " · Twister: push = solo, double push = release all" |
| 6.2.72 | SHOUT OUT | SHOUT OUT on: music and visual credits / SHOUT OUT off |
| 6.2.73 | LINK glide | Deck A LINK on · VISUAL glides to MUSIC N% on the next 1/4, over one beat (at once: no "on the next" part) |
| 6.2.74 | Twister bank | MIDI: MFB slipped to bank 2 · back on bank 1 |
| 6.2.75 | Twister outputs crossed | MIDI: the two Twisters' outputs were crossed (same port name) · fixed, turn again |
| 6.2.76 | Twister EQ / FX push, drawer closed | EQ open · push again to kill / restore / FX open · push again to kill / restore |
| 6.2.77 | Twister tempo reset | MIDI: tempo reset to N (Library held 1 s) |
| 6.2.78 | Twister Settings, no settings | Deck A: no settings in this shader |
| 6.2.79 | Tagline line | Tagline on / Tagline off |
| 6.2.80 | PLAY FX reset | FX reset: every effect to neutral |
| 6.2.81 | Range cleared (PLAY) | Range cleared |
| 6.2.82 | Set order | Set NAME: the playlist order |
| 6.2.83 | OMS set saved | OMS set saved: NAME · N tracks · N Music Visual Pairs · set version N (Downloads) |
| 6.2.84 | OMS set name box | Save OMS set: name it · Enter = save · Escape = cancel |
| 6.2.85 | OMS set dropped | OMS set NAME: N Music Visual Pairs (N skipped, shader not in the LIBRARY), in the drop's summary |
| 6.2.86 | Set opened (PLAY) | Set NAME: N tracks · double-click a track to play it (since V1.7.0; was 'Set NAME: playing from its first track · continuous play on') |
| 6.2.87 | Set link | Set NAME ready · tap to play |
| 6.2.88 | Zip drop | NAME: songs u/f · shaders u/f · covers u/f · sets u/f · pairs u/f |
| 6.2.89 | AUTO MIX on / off | Auto mix on / Auto mix off |
| 6.2.90 | AUTO MIX coming | AUTO MIX: NAME comes in at bar N |
| 6.2.91 | AUTO MIX start | AUTO MIX: into NAME over N bars / AUTO MIX: into NAME (instant) · followed by '· the set's recorded transition' when a set's mix applies |
| 6.2.92 | AUTO MIX handover | AUTO MIX: NAME |
| 6.2.93 | AUTO MIX no beat mix | removed in V1.6.0 (every transition mixes) |
| 6.2.94 | AUTO MIX stopped | AUTO MIX: mix stopped |
| 6.2.95 | SELECTA picked | removed in V1.6.0 (the picker became the SELECTA knobs, 6.2.97) |
| 6.2.96 | Shaka (MIXER) | SHOUT OUT on in OUT / SHOUT OUT off in OUT · the decks keep theirs / SHOUT OUT is off (GLOBAL Shaka) |
| 6.2.97 | SELECTA knob | SELECTA · MIX LENGTH: 16 bars (from the next mix) |
| 6.2.98 | SELECTA recording on | SELECTA recording on: each mix and change is logged (the moves only, no audio) · stop writes the OMS set |
| 6.2.99 | SELECTA recording saved | SELECTA recording saved: NAME · … / Auto mix off · SELECTA recording saved: NAME |
| 6.2.100 | SELECTA recording, nothing logged | SELECTA recording off · nothing recorded |
| 6.2.101 | Dice | Dice: new seed N · VIS FREQ chaos replanned / · VIS FREQ is not on chaos (· CHIPPY too) |
| 6.2.102 | CHIPPY | CHIPPY on · N BPM · KEY · from the AMU / CHIPPY off |
| 6.2.103 | CHIPPY dice | CHIPPY: new seed N · same AMU · on the next bar |
| 6.2.104 | Song link | Song NAME ready · tap to play |
| 6.2.105 | Shader link | Shader NAME ready |
| 6.2.106 | Example song source | Ain't No Trick: streaming from jsDelivr (the site is blocked here) / Ain't No Trick: not reachable here (site and jsDelivr blocked), AMU only |
| 6.2.98 | LIBRARY expand | LIBRARY expanded / LIBRARY back |
| 6.2.99 | Visuals on their own list | Visuals on their own list (LIBRARY order) / (LIBRARY order, shuffled) |
| 6.2.100 | Visual PLAY NEXT | Visual PLAY NEXT: NAME / Visual PLAY NEXT: no other shader in the LIBRARY |
| 6.2.101 | Visual CONTINUOUS | Visual CONTINUOUS on / Visual CONTINUOUS off |
| 6.2.102 | Visual SHUFFLE | Visual SHUFFLE on / Visual SHUFFLE off |
| 6.2.103 | FOLLOW again | Visuals FOLLOW the song pairs from the next song |

A visual button pressed while FOLLOW is on adds 'Visuals on their own list · ' before its message.

### 6.3 Errors

| # | Event | Message |
|---|---|---|
| 6.3.1 | Shader compile | WGSL error in NAME, see stage |
| 6.3.2 | MP3 decode | Could not decode NAME, AMU clock still plays |
| 6.3.3 | Not an AMU file | Not a Sozo AMU file: NAME (reason) |
| 6.3.4 | Lengths differ | Audio and AMU lengths differ (N bars vs N bars): check the MP3 and JSON are the same track |
| 6.3.5 | Cover | Deck A: Cover NAME is W×H · a cover must be square / Deck A: Could not read NAME |
| 6.3.6 | Drop unreadable | Could not read the drop (reason) |
| 6.3.7 | Wrong file in a picker | Pick an audio file (mp3, m4a, wav…) or its AMU .json / Pick a .wgsl shader file |
| 6.3.8 | Library drop, nothing usable | Library: N files ignored … |
| 6.3.9 | Embedded track | Embedded track could not be read |
| 6.3.10 | Pop Out | Pop-out not supported in this browser / Pop-out blocked, allow popups for this page |
| 6.3.11 | REC | Recording not supported in this browser |
| 6.3.12 | Music Visual Pair | Deck A: Music Visual Pair: load a track and a shader first |
| 6.3.13 | GPU (on the stage) | WebGPU unavailable. Desktop needs a current Chrome, Edge, or Safari. / WebGPU unavailable (no adapter). / GPU device lost: reason / GPU error: reason / WGSL error line N: message |
| 6.3.14 | Settings line skipped | Settings: line N · NAME: reason, for each line that does not fit, joined by " · " ("Deck B: " in front on PERFORM). Reasons: name; settings[N].c; N is 0 to 15; a number is .x, .y, .z or .w; a colour is .xyz or .yzw; min max step default; color r g b; min below max; step above 0; default from min to max; name used twice; place used twice |
| 6.3.15 | Settings over the rack | Settings: N beyond the 32 slots not shown |
| 6.3.16 | DECK LOCK | Deck A is LOCKED while it plays: unlock it (lock icon) to load a song (shaders load any time) |
| 6.3.17 | Save OMS set | Save OMS set: apply a set or pair a song first |
| 6.3.18 | Set file not loaded | Set file NAME: not schema 2, not loaded |
| 6.3.19 | Link, no match | Link: no set named NAME on this site / Link: no song named NAME on this site / Link: no shader named NAME on this site |
| 6.3.20 | SELECTA recording refused | SELECTA recording: turn AUTO MIX on first (it records the AUTO MIX transitions) |
| 6.3.18 | Set link | Link: no set named NAME on this site |
| 6.3.19 | Zip | Could not read NAME (not a zip) |

## 7. Keyboard index
**Blueprints:** sheet 11, KEYBOARD · ONE FLOW.

The keys work on PLAY, PERFORM and CREATE, on the website and off it; Pocket Rave is touch only. They do nothing while typing in a field or the Code view, or with Ctrl, Cmd or Alt held; in the TEMPO field, digits type and the moving keys still move. Field and knob keys act on the selected control (click it, or move to it). Space is ignored while typing in a field.

| # | Key | Where | Action |
|---|---|---|---|
| 7.1 | W / A / S / D | PLAY, PERFORM, CREATE | Up / left / down / right to the nearest control that way: the tabs, global strip, deck controls, lane chips and group bars, mixer, LIBRARY, the open drawer. Nothing selected: the tab's first control. S from the tab bar: the tab's first control; W into the tab bar: the open tab |
| 7.2 | ↑ / ← / ↓ / → | PLAY, PERFORM, CREATE | The same as W / A / S / D |
| 7.3 | Tab / Shift+Tab | PLAY, PERFORM, CREATE | Next / previous control, in page order, over the same controls |
| 7.4 | Enter | A button, a tab, a lane chip or group bar | On / off: press the button, open the tab, solo the lane or group |
| 7.5 | Space | PERFORM | Master PLAY / PAUSE (the whole mix) |
| 7.6 | Space | PLAY, CREATE | PLAY / PAUSE the deck |
| 7.7 | Shift+A / Shift+B | PERFORM | Into Deck A / Deck B: its PLAY, from anywhere |
| 7.8 | Shift+M | PERFORM | Into the mixer: deck A's VISUAL, from anywhere |
| 7.9 | Shift+L | PLAY, PERFORM | Into the LIBRARY: its ALL, from anywhere (with an EQ, FX or MODE drawer open, the bar says to close it first) |
| 7.10 | digits + Enter | TEMPO (PLAY, PERFORM) | Set the tempo |
| 7.11 | Shift+↑ / ↓ | TEMPO | ±1 BPM |
| 7.12 | Shift+← / → | TEMPO | ±0.01 BPM |
| 7.13 | Escape | TEMPO | Leave the field |
| 7.14 | Shift+↑ / ↓ | QUANT (PLAY, PERFORM) | Next / previous step: None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars |
| 7.15 | Enter / Escape | QUANT | Leave the field |
| 7.16 | scroll | QUANT | Next / previous step |
| 7.17 | Shift+↑ / ↓ | MASTER (PERFORM) | ±1 dB |
| 7.18 | Shift+← / → | MASTER | ±0.1 dB |
| 7.19 | Enter / Escape | MASTER | Leave the field |
| 7.20 | scroll | MASTER | ±1 dB |
| 7.21 | Shift+arrows | DSP preset box (PERFORM) | Previous / next preset: Off, Gentle, Medium, Aggressive, Limiter |
| 7.22 | Escape | DSP panel | Close it (back to DSP) |
| 7.23 | Shift+↑ / ↓ | Piano roll zoom (every deck) | Zoom steps 0 / 25 / 50 / 75 / 100 % |
| 7.24 | Enter / Escape | Piano roll zoom | Leave the field |
| 7.25 | ctrl + wheel, pinch | Piano roll | Zoom |
| 7.26 | Shift+↑ / ↓ | FX knob | Amount ±1 % |
| 7.27 | Shift+← / → | FX knob | Amount ±5 % |
| 7.28 | Enter | FX knob | Kill / restore on QUANT |
| 7.29 | Escape | FX knob | PLAY: leave the knob. PERFORM: back to the FX button (7.43) |
| 7.30 | Shift+arrows | FX effect box | Previous / next effect in the bank |
| 7.31 | Enter / Escape | FX effect box | Leave the box (PERFORM: Escape goes back to the FX button) |
| 7.32 | Shift+↑ / ↓ | EQ, TRIM and RGB knob, ISOLATOR knob, DSP knob (PERFORM) | Level, fine |
| 7.33 | Shift+← / → | EQ, TRIM and RGB knob, ISOLATOR knob, DSP knob | Level, coarse |
| 7.34 | Enter | EQ, TRIM and RGB knob, ISOLATOR knob | Kill / restore, at once |
| 7.35 | Shift+↑ / ↓ | Mixer encoder (PERFORM) | Level, fine (VISUAL ±1 %) |
| 7.36 | Shift+← / → | Mixer encoder | Level, coarse (VISUAL ±5 %) |
| 7.37 | Enter | Mixer encoder | Kill / restore, at once |
| 7.38 | Escape | Mixer encoder | Leave the encoder |
| 7.39 | Enter | LINK (PERFORM) | Link on / off |
| 7.40 | Enter | EQ, FX or MODE button | Open / close its drawer |
| 7.41 | Tab | EQ, FX or MODE button, its drawer open | The drawer's first control |
| 7.42 | Enter | Mode button | Pick the visual mix mode |
| 7.43 | Escape | EQ, FX or MODE drawer | Back to the drawer's lit button |
| 7.44 | ↑ / ↓ or W / S | LIBRARY list | Select the previous / next row (its name in the message bar). On the top row: up to the header's lit button. On the last row: stays |
| 7.45 | A or ← | LIBRARY list | Load the row on Deck A (PLAY: on the deck) |
| 7.46 | D or → | LIBRARY list | Load the row on Deck B (PLAY: on the deck) |
| 7.47 | Enter | LIBRARY list, PLAY | Load the row, as its double-click (a track plays from the start) |
| 7.48 | Enter | LIBRARY set row | Apply the set / turn it off |
| 7.49 | Delete (Mac: delete) | LIBRARY list | Remove the row from the library (not a set row) |
| 7.50 | A / D or ← / → | LIBRARY header | Along the buttons (ALL, MUSIC, VISUALS, SETS, save, X; PLAY: ALL, MUSIC, VISUALS, SETS, expand, add files, Music Visual Pair, save, X) |
| 7.51 | S or ↓ | LIBRARY header | Down into the list |
| 7.52 | Enter | Header name or tagline (after a power light tap) | Keep it |
| 7.53 | Escape | Header name or tagline | Cancel |
| 7.54 | ↑ / ↓ or Shift+↑ / ↓ | Settings value box, a number | ± one step |
| 7.55 | type + Enter | Settings value box | Set the value (a number, or a hex for a colour) |
| 7.56 | Escape | Settings value box | Leave the box |
| 7.57 | W / A / S / D, arrows | Settings drawer | Between its knobs; the keys stay in the drawer (W off its top row leaves) |
| 7.58 | Shift+↑ / ↓ | Settings knob | ± one step (a colour: hue ±5°) |
| 7.59 | Shift+← / → | Settings knob | ± five steps (a colour: hue ±30°) |
| 7.60 | Enter | Settings colour knob | Open / close the colour wheel |
| 7.61 | Shift+Enter | EQ or FX button (PERFORM) | Reset both decks to default |
| 7.62 | Shift+Enter | Settings button (PLAY) | Every setting to the shader default |
| 7.63 | Escape | PLAY, a range picked | Clear the range (and its loop) |
| 7.64 | Shift+click (mouse) | A section, segment or phrase block, after a click on another | Pick or loop the range between |
| 7.65 | Shift+Enter | FX button (PLAY) | Every effect to neutral |
| 7.66 | ↑ / → or ↓ / ← | SELECTA knob (PLAY) | Next / previous step, from the next mix |
| 7.67 | Escape | PLAY, LIBRARY expanded | Bring the list back |

PERFORM's deck headers (lock, MASTER, Code, Settings) are mouse only: the keys pass them by, but with a Settings drawer open the next key from its button goes into the drawer. On PLAY they are in the flow. The Settings drawer's value boxes are fields.

## 8. Getting your content into Vizzie
**Blueprints:** sheet 18, SETS AND BEAM ME UP.

Two stages. **Prep** makes each file ready. **Beam Me Up** checks the prepped files and publishes them. Beam Me Up does not make AMU files and does not fix MP3s or tags: anything not prepped is refused, or shows up wrong.

### 8.1 Prep a song
In this order: tags, then the final name, then the AMU.

1. **Tags.** Title, artist, album, year, genre, track and the cover art; label and copyright when known. Vizzie shows the title, artist and cover from the file's own tags (MP3, ID3); without them it shows the file name (or the AMU's `file` name). Check with `ffprobe -show_entries format_tags "<song>.mp3"` and confirm the cover is there as an attached picture. A conversion drops tags: after converting (say `.m4a` to `.mp3`), copy the tags and cover from the source onto the new file without re-encoding the audio.
2. **Final name:** `<Title>_<Artist>_<BPM>BPM_<Catalog>.mp3`, for example `LikeYouDontKnow_DubleTime_170BPM_JRSR085.mp3`. Outside the artist's catalogue, the release year in place of the catalogue number: `ComeOnEileen_DexysMidnightRunners_106BPM_1982.mp3`.
3. **The AMU, with Sozo Sidecar V2,** on the song's final name. Run it from the song's folder with the bare file name: `sozo-sidecar "<song>.mp3" > "<song>_sozo_v2_AMU.json"`. When the BPM is not known yet, two passes: analyse to a temporary file and read `rhythm.bpm`, rename the song with that BPM, then analyse the renamed song for the final sidecar. Check that the sidecar's `file` field is the song's exact file name. A new name or a new format means a new sidecar. The song's BPM, key, length, beats and sections in Vizzie all come from the sidecar: without one, the song does not load.
4. **Cover:** embedded in the MP3, or a square image with the song's file name (`.png`, `.jpg`, `.webp`, `.gif`).
5. **Shaders** (`.wgsl`) from the authoring template (9). A shader can go up on its own. To publish songs as a set with their visuals, add a set file (`.omsset`, OMS set schema version 2); a partial set is fine.
6. **One folder per release** holding all of it, for example `YOPACK-0008_DrumAndBass/`.

### 8.2 Publish with Beam Me Up
Beam Me Up is the one way content reaches the Vizzie website. To publish, put the prepped folder in the published folder (`Library/Yodega/YoPacks/15_Published/`) and run Beam Me Up; to remove, take the folder out and run it again. Each run:
- checks every file against what Vizzie loads (a song with its AMU, an AMU that pairs with a song, a square cover with a song, a Vizzie shader, a schema 2 set file); a refused file is named with the reason and does not go up;
- makes the website's content folder equal to the published folder: new content goes up, removed content comes down;
- writes the website's list (`beammeup_index.json`) and a page for every set, song and shader;
- publishes, checks the live website (everything published is there, everything removed is gone) and gives back the links (8.3).
Running it again with nothing changed publishes nothing and checks the website again.

### 8.3 Links
| What | Link | Opens |
|---|---|---|
| A set | `vizzie.onemanshyo.com/?set=<set name>` | the set applied, its first song loaded with its visual |
| A song | `vizzie.onemanshyo.com/?song=<song file name>` | the song with its visual |
| A shader | `vizzie.onemanshyo.com/?shader=<shader name>` | the shader on the stage |

Each also has its own page, for example `vizzie.onemanshyo.com/yodega/YoPacks/YOPACK-0008_DrumAndBass/` for a set; bookmarks and shared links show its name. The first tap plays (a browser rule). A name that is not on the website shows 'Link: no set (song, shader) named NAME on this site'.

---

**END OF USER GUIDE**
