# OMS Vizzie app [Beta V0.11.0] User Guide

**Run date:** 2026-11-05  
**Current Unix Epoch:** 1793912480  
**Document purpose:** How to use Vizzie.  
**Filename:** OMS_Vizzie_Beta_V0_11_0_E_UserGuide_All.md  

## About this document

Vizzie Beta V0.11.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## CONTENTS

**1** What is Vizzie?  
**2** Where to find Vizzie  
**3** Tabs  
**4** CREATE  
&emsp;4.1 Layout  
&emsp;4.2 Global strip  
&emsp;4.3 Music  
&emsp;4.4 Controls row  
&emsp;4.5 LIBRARY  
&emsp;4.6 FX  
&emsp;4.7 Visuals  
&emsp;4.8 Music Understanding  
&emsp;4.9 Another track's Music Understanding  
&emsp;4.10 AUTHORING  
**5** PERFORM  
&emsp;5.1 Layout  
&emsp;5.2 Global strip  
&emsp;5.3 A deck  
&emsp;5.4 Loading a deck  
&emsp;5.5 Which deck sets the tempo  
&emsp;5.6 Starting and cueing in time (QUANT)  
&emsp;5.7 Mixer  
&emsp;5.8 MODE · FX · EQ  
&emsp;5.9 FX  
&emsp;5.10 LIBRARY  
&emsp;5.11 Playlist QUEUE  
**6** HELP, ABOUT and LEARN  
**7** Messages  
**8** Pocket Rave (phones and tablets)  
**9** Message index  
&emsp;9.1 Help  
&emsp;9.2 Values  
&emsp;9.3 Errors  
**10** Keyboard index  

---

## 1. What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

Everything in Vizzie counts in music time: bars and beats. A position written 62.1 is bar 62, beat 1; 62.1.3 is bar 62, beat 1, third sixteenth.

Vizzie saves nothing. Your gig folder is the set: the MP3s, their Music Understanding `.json` files, the `.wgsl` shaders, cover images and playlists. Drop it in and play.

## 2. Where to find Vizzie

Go to **vizzie.onemanshyo.com**, or open `OMS_Vizzie_Beta_V0_11_0.html` in a WebGPU-capable browser: current Chrome, Edge or Safari on desktop, or Safari on iOS / iPadOS 26 or later. The reference track's analysis is embedded, so it works immediately. On the website the example audio loads by itself and the LIBRARY lists the demo playlists; opened as a local file, load an audio file to hear it (drop it on the deck, or double-click the cover or the waveform).

On iPhone and iPad, Safari plays the music when you tap PLAY, with the silent switch on or off.

## 3. Tabs

**CREATE · PERFORM · AUTHORING · HELP · ABOUT · LEARN.** On the website: **CREATE · HELP · ABOUT · LEARN**, and CREATE opens. PERFORM and AUTHORING show only when the app is opened off the website (as a local file, for example), and then AUTHORING opens.

Above the header is the strip with the red power light and five jacks, on every tab. **Tap the power light** to type your own name in place of ONEMANSHYO: Enter keeps it, Esc cancels, an empty name puts ONEMANSHYO back. Up to 24 characters. It lasts until you reload the page.

## 4. CREATE

Music and visuals: one deck, its shader on the stage, the LIBRARY, effects, and the Music Understanding that drives it all.

### 4.1 Layout
- **GLOBAL** on top: the global strip (4.2).
- **MUSIC** on the left: the cover and waveform, the controls row, and the LIBRARY below them.
- **VISUALS** on the right: the stage, with Code, Pop Out, orientation and REC on its header.
- **Music Understanding** across the bottom, full width, filling the window down to the message bar.

### 4.2 Global strip
The thin strip under the GLOBAL header: settings you set and leave. **TEMPO · QUANT · position.**
- **TEMPO.** Click it, then ↑ / ↓ for one BPM, ← / → for a hundredth of a BPM, or type a value and press Enter. Double-click goes back to the track's own tempo (or, if PERFORM's deck B is playing and has become MASTER, to deck B's). The audio, the visual and the piano roll all follow, locked to the beat. The range is half to one and a half times the track's tempo.
- **QUANT.** The same value as on PERFORM (5.6): cues and PLAY wait for the next step. Click it, then ↑ / ↓ or scroll; double-click = 1/4.
- **Position.** Where you are in the track, in bars.beats.sixteenths. It turns pink while REC records.

### 4.3 Music

#### 4.3.1 Cover and song info
The cover shows the track's art. **Click** it to show the song info over the waveform: one line, title · artist · BPM · key, scrolling. It stays until you click the cover again. **Double-click** the cover to pick an audio file or the track's Music Understanding `.json`.

The waveform keeps working while the song info is showing.

#### 4.3.2 Waveform
The whole track with the playhead.
- **Click** to cue to that place. While the track plays, the cue waits for the next QUANT step; with QUANT at None, or when stopped, it jumps at once.
- **Drag** to scrub.
- **Double-click** to pick an audio file or its `.json`.

Audio isn't needed to press PLAY: Vizzie runs from the embedded Music Understanding analysis.

#### 4.3.3 Dropping files
Drag files or a folder onto the deck (anywhere but the LIBRARY): an MP3, its Music Understanding `.json`, a `.wgsl` shader, a square cover image. The deck takes the first of each type and ignores the rest; the message bar counts what it ignored. While you drag, the deck shows "Drop files" and the types it takes. Files dropped on the LIBRARY go into the LIBRARY instead (4.5).

A dropped cover image must be square. It replaces the MP3's own art until another track loads.

### 4.4 Controls row
**PLAY · LOOP · KEY LOCK · orientation · PLAY NEXT · CONTINUOUS PLAY · SHUFFLE ........ FX**
- **PLAY / PAUSE** starts and stops. **Spacebar** does the same.
- **LOOP**, off when you open the app. On, the whole track loops. Click a piano roll block while LOOP is on and that block loops instead (the jump lands on QUANT); click the lit block again to go back to the whole track. Off, the track stops at its end and the playhead goes back to the start.
- **KEY LOCK**, on when you open the app: the pitch stays put as you change the tempo, and drum hits keep their snap. Off, the pitch moves with the tempo, like a turntable.
- **Orientation**: the piano roll vertical or horizontal.
- **PLAY NEXT** (next-track icon): the next track in the LIBRARY list, as it is shown, plays from the start now. After the last track it goes back to the first.
- **CONTINUOUS PLAY** (playlist icon): on, when a track ends (LOOP off) the next track in the list plays from the start.
- **SHUFFLE** (crossed arrows): on, the LIBRARY list is put in a random order, with the playing track first and still playing; PLAY NEXT and CONTINUOUS PLAY then follow that order, as streaming players do. Off, the list goes back to its own order.
- **FX** opens the effects (4.6).

CONTINUOUS PLAY and SHUFFLE light cyan while on. The piano roll zoom and SOLO are on the Music Understanding header (4.8).

### 4.5 LIBRARY
The same LIBRARY as PERFORM's (5.10), always open under the controls row. On the website it lists the demo playlists, one button each after SHADERS (for example BIG WHEEL ENERGY), and opens on the first; a playlist shows its tracks in its own order, title first, then artist.
- **Double-click** (or double-tap) a track: it loads and plays from the start. A shader loads onto the stage.
- **Click** an entry to select it; then ↑ / ↓ move the selection, ← or → loads it, Delete removes it from the library.
- **Drag** an entry onto the deck to load it.
- **Drop** files or a folder on the LIBRARY to add them: MP3s with their Music Understanding `.json`, shaders, cover images, an `.m3u8` playlist (QUEUE, 5.11).
- **Filters:** ALL · QUEUE · MUSIC · SHADERS, then the demo playlists.

An entry on the deck is tinted yellow. Website tracks are fetched when you load them, so the page opens quickly.

### 4.6 FX
**FX** slides a panel down over the LIBRARY; click FX again to close it. Four knobs: **AFX1** over **AFX2** (music, cyan) and **VFX1** over **VFX2** (visual, purple) to the right. They are deck A's effects, the same as PERFORM's deck A (5.9).
- **Knob:** drag up or down for the amount. Click it, then ↑ / ↓ (fine) or ← / → (coarse). Click or press Enter to kill the effect; again to restore it. Kills land on the next QUANT step while the track plays. **Double-click** resets the effect to its default.
- **Effect box** (under the knob): click it, then the arrows step through the bank.

The music effects play on CREATE; the visual effects show on the stage, in Pop Out and in REC. AUTHORING plays without effects.

### 4.7 Visuals
The live shader on the stage. The buttons sit on the right of the VISUALS header.

#### 4.7.1 </> Code
Opens the shader code. Edit or paste a complete shader, then **Apply**. **Copy** copies the code.

#### 4.7.2 Pop Out
Opens the visual in its own window. Double-click that window for fullscreen.

#### 4.7.3 Orientation
Cycles the visual through 16:9, 1:1 and 9:16.

#### 4.7.4 ● REC
Records the visual with the track's audio to a video file, from the playhead.
- **Stopped, a block picked:** click a piano roll block while stopped, then REC. It records exactly that block and stops at its end. With LOOP on, the block loops and the recording runs until you press REC again.
- **Stopped, nothing picked:** records from the playhead to the end of the track. With LOOP on, it runs on until you press REC again.
- **Playing:** records from where you are.

Click REC again to stop early. The file downloads when the recording ends.

#### 4.7.5 Load a shader file
Drag a `.wgsl` file onto the deck, or **double-click** the visual to pick one.

### 4.8 Music Understanding

#### 4.8.1 Groups and lanes
Six groups (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS) holding twelve lanes: beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other. Each lane shows in its group's colour; beat is white. What each lane does to the picture depends on the shader loaded. Hover over a lane to see its live value in the message bar.

#### 4.8.2 Lane chips
Each lane is a chip. Click a chip to solo the lane; solos stack. Click a group's colour bar to solo the whole group. **SOLO**, at the right of the Music Understanding header, lights while any lane or group is soloed; click it to clear all solos.

#### 4.8.3 Piano roll
Each lane's music data moving through the centre playhead, counted in beats, at any tempo. It opens at 25 %, horizontal.
- **Drag** it to scrub.
- **Click** a block to cue to its start: a beat, bar, section, segment, phrase, key or pace change. While the track plays, the cue waits for the next QUANT step. These are your cue points, straight from Music Understanding; nothing needs saving.
- **LOOP on:** the clicked block loops (4.4).
- **Stopped:** the clicked block is picked: the playhead moves to its start, the block lights, and REC records exactly that block (4.7.4). Moving the playhead any other way, or PLAY, clears the pick.
- **Zoom** (the % field on the Music Understanding header, left of SOLO): click it, then ↑ / ↓ through 0, 25, 50, 75 and 100. 0 is the closest view, 100 the whole song. Pinch, or ctrl + wheel on the roll, zooms too.

### 4.9 Another track's Music Understanding
Each track has its own Music Understanding file, a `.json` made by the Sozo sidecar. Drop it on the deck (or double-click the cover or waveform and pick it): the piano roll, readout, cue points and visuals switch to that track, and TEMPO goes to its BPM. Load the track's MP3 the same way, before or after. If the audio and the `.json` are different lengths, the message bar tells you, so you can check they belong together.

### 4.10 AUTHORING
Off the website only: the same deck, arranged for building shaders. The Visual on top, then the music, the controls row **PLAY · LOOP · KEY LOCK · zoom · orientation ........ SOLO**, the full Music Understanding controls, the piano roll and the authoring sections. The track and solos are the same as on CREATE. There is no LIBRARY, FX, PLAY NEXT, CONTINUOUS PLAY or SHUFFLE, and the deck plays without effects.
- **Encoders:** each lane has one. Drag up or down to set how strongly that lane drives the shader (0 to full). Press to solo the lane (clicking the lane chip does the same); solos stack. Double-click to reset to full. Click a group header to solo the group.
- **Piano roll:** as on CREATE (4.8.3), with 4 bars in view at the closest zoom. It opens vertical at 0 %.

## 5. PERFORM

Two decks and a mixer, for playing visuals live to music. Shown only when the app is opened off the website.

### 5.1 Layout
**DECK A · MIXER column · DECK B**, side by side, fitted to the window, under the global strip. The MIXER column holds three modules, top to bottom: the MIXER, the panel strip (MODE · FX · EQ) and the LIBRARY. Deck A is the same deck as CREATE's: the track, solos and effects you set on one tab are there on the other.

### 5.2 Global strip
**TEMPO · QUANT · PLAY · master position.**
- **TEMPO**: as on CREATE (4.2). Double-click goes back to the tempo of the deck that is MASTER.
- **QUANT**: click it, then ↑ / ↓ (or scroll) through None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars. Double-click = 1/4. The same value as CREATE's. See 5.6.
- **PLAY** (master): pauses every playing deck at once; press again and they carry on from the same spot, in time. With nothing paused, it starts every deck from its playhead. No QUANT wait. **Spacebar** does the same on PERFORM. A deck's own PLAY clears what the master PLAY remembered.
- **Master position**: the session, in bars.beats.sixteenths. It starts at 1.1.1 with the first PLAY, counts while any deck plays, and holds while every deck is stopped. Double-click to go back to 1.1.1.

### 5.3 A deck
Top to bottom:
1. **Header:** the deck name, **KEY LOCK**, and **MASTER**, which lights while this deck sets the tempo (5.5).
2. **Stage:** the deck's own shader, with its visual FX (5.9). **Double-click** it to pick a `.wgsl`.
3. **Cover and waveform**, in a slim row. Click the cover for the song info line (title · artist · BPM · key); double-click the cover or the waveform to load an MP3 or its `.json`; click the waveform to cue (on QUANT while playing), drag it to scrub.
4. **PLAY · LOOP · zoom · orientation · position ........ SOLO.** LOOP works as on CREATE (4.4). The position is this deck's own place in its track. The roll opens at 25 % zoom, horizontal.
5. **Music Understanding:** each lane a chip in its group colour, without labels: click a chip to solo the lane. Click a group's colour bar to solo the group. Below, the piano roll: drag to scrub, click a block to cue to its start.

There is no Code, REC or Pop Out on PERFORM.

### 5.4 Loading a deck
- Drop files or a folder anywhere on the deck: the first MP3, Music Understanding `.json`, `.wgsl` and square cover image are taken (4.3.3). Drop a new track on a playing deck to switch to it.
- From the LIBRARY: drag an entry onto a deck, or select it and press ← (Deck A) or → (Deck B). See 5.10.
- The double-clicks in 5.3.

Deck B starts with the reference track and the default shader.

### 5.5 Which deck sets the tempo
The playing deck that started first is MASTER and sets the tempo. When it stops and the other deck is still playing, that deck becomes MASTER. With nothing playing, MASTER stays where it was. A deck that starts never changes the tempo, so nothing jumps.

### 5.6 Starting and cueing in time (QUANT)
- **PLAY** on a deck, while the other deck is playing, waits for the next QUANT step of the master grid, then starts this deck from the matching place in its own track, so the two land together. PLAY blinks while it waits; press it again to cancel.
- **A cue** on a playing deck (a click on a piano roll block or on the waveform) waits for the next QUANT step, then jumps.
- **FX kills** (5.9) land on the next QUANT step while anything plays.

With QUANT at None, PLAY and cues happen at once. QUANT works the same on CREATE and PERFORM.

### 5.7 Mixer
- **OUT**: the two decks' visuals, with their visual FX, blended at their VID levels (MIX).
- **Encoders**, A VID · A AUD · B AUD · B VID. VID (purple) is the deck's strength in OUT; AUD (cyan) is its volume. Drag up or down; double-click = 0. VID opens at the middle, so OUT shows both decks; AUD opens at 0.

### 5.8 MODE · FX · EQ
The panel strip under the MIXER. **MODE** and **FX** each open a panel that slides down out of the strip over the LIBRARY; click the button again to close it. One panel is open at a time.
- **MODE:** how the decks combine in OUT. MIX is on. ADD, SCREEN and CUT are shown but do nothing.
- **FX:** the deck effects (5.9).
- **EQ** is shown but does nothing.

### 5.9 FX
Each deck has four effect knobs, two for the music and two for the picture:

| | Deck A | | Deck B | |
|---|---|---|---|---|
| Row 1 | VFX1 | AFX1 | AFX1 | VFX1 |
| Row 2 | VFX2 | AFX2 | AFX2 | VFX2 |

AFX (cyan) are music effects; VFX (purple) are visual effects on the deck's picture, seen on its stage and in OUT.
- **Knob:** drag up or down for the amount. Click it, then ↑ / ↓ (fine) or ← / → (coarse). Click or press Enter to kill the effect; again to restore it. Kills and restores land on the next QUANT step. Double-click resets the effect to its default.
- **Effect box** (under the knob): click it, then ↑ / ↓ or ← / → to step through the bank. A new effect starts off.

**Music FX bank:** Filter (centre off, left low-pass, right high-pass), Washout, Dubby, Delay, Reverb, Flanger, Phaser, Bitcrush. Defaults: AFX1 Filter, AFX2 Dubby. Delay, Dubby, Flanger and Phaser follow the TEMPO and the QUANT step.

**Visual FX bank:** RGB Split, Feedback, Glitch, Pixelate, Scanlines, Mirror, Kaleidoscope, VHS, Shake, Tone (centre off, left darker and softer, right brighter and sharper), Tile, Rotate, Zoom. Defaults: VFX1 RGB Split, VFX2 Feedback. RGB Split, Shake and Zoom kick on the deck's beats; Glitch tears on the QUANT grid; Feedback trails fade over one QUANT step; Kaleidoscope turns with the bar; Rotate turns at the tempo.

Music FX play on PERFORM and on CREATE (deck A). Effects and their settings last for the session.

### 5.10 LIBRARY
Drop files or folders (subfolders included) on the MIXER column (on CREATE, on the LIBRARY). The LIBRARY is the same on both tabs. It lists:
- **Tracks:** each MP3 that has its Music Understanding `.json` (same name, or the name the `.json` gives). An MP3 without its `.json`, or a `.json` without its MP3, is left out. A square cover image with the track's name goes with it.
- **Shaders:** one entry per shader name, at its highest `_V##` (names without a version: the newest file).

One message in the bar sums up what was added, skipped and ignored. Dropping the same name again replaces its entry.

**Filters:** ALL · QUEUE (5.11) · MUSIC · SHADERS, and on the website the demo playlists (4.5).

**Entries:** click to select (cyan border); the list then takes the keys: ↑ / ↓ move the selection, ← loads it on Deck A, → on Deck B, Delete removes it from the library (a deck keeps what it has). Or drag an entry onto a deck. An entry on a deck is tinted yellow.

The LIBRARY is what you dropped this session. Nothing is saved.

### 5.11 Playlist QUEUE
Export a playlist from your music player as `.m3u8` (Swinsian, for example) and drop it with the music, before or after, on the MIXER column or CREATE's LIBRARY. **QUEUE** lights up: on, the LIBRARY shows the playlist's tracks in the playlist's order, and the ALL / MUSIC / SHADERS filters still apply. A second playlist replaces the first. The message bar counts the songs queued, those without their `.json`, and those not found in the library. Click QUEUE again to switch it off. The playlist is held for the session; Vizzie writes no playlist.

## 6. HELP, ABOUT and LEARN

**HELP**: LET'S DO THIS, eight things to try, in two boxes. **ABOUT**: what Vizzie is, who made it, the license. **LEARN** opens the learning page on onemanshyo.com in a new tab.

## 7. Messages

The bar at the bottom of the screen. Everything the app has to tell you appears here, in three colours:
- **Cyan, help:** what a control is and its keys, while you point at it or click into it, and the live values of a lane or group.
- **Orange, values:** what just changed: playing, TEMPO, QUANT, KEY LOCK, a cue, an effect, a file loaded.
- **Red, errors:** something failed: a file Vizzie can't use, a track that won't decode, a cover that isn't square, pop-out blocked, recording not supported.

When nothing needs saying, the bar is empty. Shader problems show in the visual itself instead: no WebGPU in the browser, or a mistake in the shader (the message gives the line number). Every message is listed in 9.

If hover help stops appearing after a click in Chrome, a browser extension may be holding the mouse; turn extensions off to check.

## 8. Pocket Rave (phones and tablets)

On the website, phones and tablets in portrait get Pocket Rave; phones stay in Pocket Rave in landscape too. Tablets in landscape get the full app. Code, pop-out, recording, TEMPO, the LIBRARY, FX, the encoders and PERFORM are only in the full app. Pocket Rave plays without effects.

### 8.1 Full frame
Pocket Rave opens with the shader filling the frame. **Tap** the shader to play or pause. **Double-tap** it, or tap the ONEMANSHYO header, for the normal view.

### 8.2 Normal view
Tabs, the shader, the cover beside the waveform, the version line and PLUR. Tap the ONEMANSHYO header to go back to full frame.
- **Shader:** tap to play or pause; double-tap to pick a `.wgsl` shader from your device.
- **Cover:** tap to show or hide the song info over the waveform; double-tap to pick an MP3 from your device.
- **Waveform:** drag to move the playhead.

### 8.3 Tabs and links
ABOUT is in the tabs; LEARN opens the website.

## 9. Message index

Every message the bar shows, as worded in this release. NAME stands for a file, track, lane or effect name; N for a number. On PERFORM, deck controls start with "Deck A:" or "Deck B:".

### 9.1 Help

#### 9.1.1 App header and tabs

| # | Control | Message |
|---|---|---|
| 9.1.1.1 | Brand | ONEMANSHYO vizzie app |
| 9.1.1.2 | Version | App version |
| 9.1.1.3 | Tagline | Music drives the vision: the AMU of the song drives the shader |
| 9.1.1.4 | PERFORM tab | PERFORM: two decks and the mixer |
| 9.1.1.5 | CREATE tab | CREATE: music and visuals |
| 9.1.1.6 | ABOUT tab | ABOUT |
| 9.1.1.7 | LEARN tab | LEARN |
| 9.1.1.8 | onemanshyo.com link (ABOUT) | onemanshyo.com |
| 9.1.1.9 | AUTHORING tab | AUTHORING: author a shader to its music |
| 9.1.1.10 | HELP tab | HELP |
| 9.1.1.11 | LET'S DO THIS header (HELP) | LET'S DO THIS |

#### 9.1.2 PERFORM: global strip

| # | Control | Message |
|---|---|---|
| 9.1.2.1 | Master PLAY | Master PLAY: start every deck from its playhead (Space) |
| 9.1.2.2 | Master position | Arrangement position (bar.beat.sixteenth) |
| 9.1.2.3 | TEMPO | Master tempo (↑↓ ±1 BPM, ←→ ±0.01 BPM, or type + Enter · double-click = the MASTER deck's BPM) |
| 9.1.2.4 | QUANT | QUANT: cues (roll blocks, waveform clicks) and PLAY wait for the next step · None = at once (↑↓ · scroll · double-click = 1/4) |

#### 9.1.3 PERFORM: deck

| # | Control | Message |
|---|---|---|
| 9.1.3.1 | Deck header | DECK A: its stage, music, transport and Music Understanding (drop MP3, AMU .json or .wgsl anywhere on the deck) |
| 9.1.3.2 | MASTER, on | Deck A: MASTER: this deck sets the tempo |
| 9.1.3.3 | MASTER, off | Deck A: Not master: the playing deck that started first sets the tempo |
| 9.1.3.4 | KEY LOCK | KEY LOCK: hold the pitch while the tempo changes: on / off |
| 9.1.3.5 | Stage | Deck A: Stage: the deck's shader (double-tap = load a .wgsl · drop MP3, AMU .json or .wgsl on the deck) |
| 9.1.3.6 | Cover | Deck A: Cover (tap = song info · double-tap = load an MP3) |
| 9.1.3.7 | Waveform | Deck A: Waveform (click = cue on QUANT · drag = scrub · double-tap = load an MP3) |
| 9.1.3.8 | PLAY | Play / Pause, then " · armed, waits for QUANT (press again = cancel)" or " · waits for QUANT when another deck plays" |
| 9.1.3.9 | LOOP | LOOP: off (chip clicks land on QUANT) / LOOP: armed: the track loops; click a chip to loop it (chip clicks land on QUANT) / LOOP: looping a chip (click it again = the whole track) (chip clicks land on QUANT) |
| 9.1.3.10 | SOLO | SOLO: lit while a lane or bus is soloed (press = clear all solos) |
| 9.1.3.11 | Position | Deck A: Arrangement position (bar.beat.sixteenth) |
| 9.1.3.12 | Zoom | Deck A: Piano roll zoom: 0 = closest (4 bars), 100 = the whole song (↑↓ 0 / 25 / 50 / 75 / 100 · ctrl + wheel, pinch on the roll) |
| 9.1.3.13 | Roll orientation | Deck A: Piano roll vertical / horizontal |
| 9.1.3.14 | Piano roll | Deck A: Piano roll (drag = scrub · click a block = cue to its start · ctrl + wheel, pinch = zoom) |
| 9.1.3.15 | Lane chip | NAME · slot N · on / muted · live value (click = solo) |
| 9.1.3.16 | Bus | NAME bus · its lanes (solo the bus) |

Lane values: BEAT beat, beatPhase · BAR bar, barPhase · SECTION section n/N, progress · SEGMENT segment progress · PHRASE phrase n/N, progress · KEY mode, tonic · PACE pace · LOUDNESS momentary LUFS · DRUM, BASS, VOCAL, OTHER activity. Buses: RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS.

#### 9.1.4 PERFORM: MIXER

| # | Control | Message |
|---|---|---|
| 9.1.4.1 | MIXER header | MIXER: OUT and the four encoders (A VID, A AUD, B AUD, B VID) |
| 9.1.4.2 | OUT | OUT: the mix of the decks' video at their VID strengths |
| 9.1.4.3 | A VID / B VID | Deck A video in OUT N% (drag up / down · double-click = 0) |
| 9.1.4.4 | A AUD / B AUD | Deck A audio volume N% (drag up / down · double-click = 0) |

#### 9.1.5 PERFORM: MODE · FX · EQ

| # | Control | Message |
|---|---|---|
| 9.1.5.1 | MODE | MODE: how the decks combine in OUT |
| 9.1.5.2 | FX | FX: the deck effects |
| 9.1.5.3 | EQ | EQ: later |
| 9.1.5.4 | MIX | MIX: weighted blend of the decks at their VID strengths (on) |
| 9.1.5.5 | ADD, SCREEN, CUT | ADD: later / SCREEN: later / CUT: later |
| 9.1.5.6 | FX knob and its label | Deck A AFX1 · Filter N% (drag · ↑↓ ←→ · click / Enter = kill · double-click = reset); " · killed" while killed |
| 9.1.5.7 | FX effect box | Deck A AFX1 effect · Filter (↑↓ ←→) |

#### 9.1.6 PERFORM: LIBRARY

| # | Control | Message |
|---|---|---|
| 9.1.6.1 | LIBRARY header and list | LIBRARY · drop files: MP3, AMU .json, .wgsl, cover image, .m3u8 playlist |
| 9.1.6.2 | ALL | Library: show music and shaders |
| 9.1.6.3 | MUSIC | Library: show music only |
| 9.1.6.4 | SHADERS | Library: show shaders only |
| 9.1.6.5 | QUEUE, no playlist | QUEUE: drop an .m3u8 playlist on the MIXER |
| 9.1.6.6 | QUEUE, playlist | QUEUE: playlist NAME, in its order (on / off) |
| 9.1.6.7 | Entry | NAME (↑↓ · ← Deck A · → Deck B · Delete) |
| 9.1.6.8 | Demo playlist (website) | Library: show NAME, in its order |

#### 9.1.7 CREATE: music, controls, LIBRARY, FX and Visuals

| # | Control | Message |
|---|---|---|
| 9.1.7.1 | MUSIC header | MUSIC: cover, waveform and transport (drop MP3, AMU .json, .wgsl or a square cover image on the deck) |
| 9.1.7.2 | VISUALS header | VISUALS: the shader on the stage |
| 9.1.7.3 | MUSIC UNDERSTANDING header | MUSIC UNDERSTANDING: the AMU lanes and buses (click = solo) and the piano roll |
| 9.1.7.4 | TEMPO | Master tempo (click, then ↑↓ ±1 BPM, ←→ ±0.01 BPM, or type + Enter · double-click = the MASTER deck's BPM) |
| 9.1.7.5 | QUANT | as 9.1.2.4 |
| 9.1.7.6 | Position | Arrangement position (bar.beat.sixteenth) |
| 9.1.7.7 | PLAY, LOOP, KEY LOCK, SOLO | as 9.1.3.8 to 9.1.3.10 |
| 9.1.7.8 | Stage | Stage: the shader (double-tap = load a .wgsl · drop MP3, AMU .json or .wgsl on the deck) |
| 9.1.7.9 | Cover | Cover (tap = song info · double-tap = load an MP3) |
| 9.1.7.10 | Waveform | Waveform (click = cue on QUANT · drag = scrub · double-tap = load an MP3) |
| 9.1.7.11 | Zoom | Piano roll zoom: 0 = closest, 100 = the whole song (↑↓ 0 / 25 / 50 / 75 / 100 · ctrl + wheel, pinch on the roll) |
| 9.1.7.12 | Roll orientation | Piano roll vertical / horizontal |
| 9.1.7.13 | Piano roll | Piano roll (drag = scrub · click a block = cue to its start · ctrl + wheel, pinch = zoom) |
| 9.1.7.14 | Lane cell (AUTHORING) | NAME · slot N · knob N% · on / muted · live value (drag = amount, click = solo, double-click = 100%) |
| 9.1.7.15 | Lane chip (CREATE) | as 9.1.3.15 |
| 9.1.7.16 | Bus | NAME bus · its lanes at their levels (solo the bus) |
| 9.1.7.17 | Orientation | Orientation 16:9 / 1:1 / 9:16 |
| 9.1.7.18 | Pop Out | Pop Out the visual to its own window |
| 9.1.7.19 | REC | REC the visual from the playhead (a chip clicked while stopped = render that chip; LOOP on = loop it) · press again = stop and save |
| 9.1.7.20 | GLOBAL header | GLOBAL: tempo · QUANT · position |
| 9.1.7.21 | FX | FX: the deck effects |
| 9.1.7.22 | PLAY NEXT | PLAY NEXT: the next track, now |
| 9.1.7.23 | CONTINUOUS PLAY | CONTINUOUS PLAY: the next track plays at the end |
| 9.1.7.24 | SHUFFLE | SHUFFLE: the list in a random order |
| 9.1.7.25 | FX knob and its label | AFX1 · Filter N% (drag · ↑↓ ←→ · click / Enter = kill · double-click = reset); " · killed" while killed |
| 9.1.7.26 | FX effect box | AFX1 effect · Filter (↑↓ ←→) |
| 9.1.7.27 | LIBRARY header and list | as 9.1.6.1 |
| 9.1.7.28 | ALL, MUSIC, SHADERS, demo playlists | as 9.1.6.2 to 9.1.6.4, 9.1.6.8 |
| 9.1.7.29 | QUEUE, no playlist | QUEUE: drop an .m3u8 playlist on the LIBRARY |
| 9.1.7.30 | Entry | NAME (↑↓ · ←→ or double-click load · Delete) |

#### 9.1.8 AUTHORING

| # | Control | Message |
|---|---|---|
| 9.1.8.1 | Visual header | VISUAL: the shader on the stage |
| 9.1.8.2 | Code | Shader code: show / hide |
| 9.1.8.3 | Code editor | Shader code (edit, then Apply) |
| 9.1.8.4 | Apply | Apply the code to the stage, preview only |
| 9.1.8.5 | Copy | Copy the shader code |
| 9.1.8.6 | Section headers | NAME (▾ = expand / collapse) |
| 9.1.8.7 | ▾ | Expand / collapse the section |
| 9.1.8.8 | GRID, GUIDES, POINTS | Grid overlay on / off (tap the stage = read a point); Guides and Points the same |
| 9.1.8.9 | CRYPTOMATTE | CRYPTOMATTE: each object flat in its ID colour, on / off |
| 9.1.8.10 | ALL ON / ALL OFF | Objects: turn all on / Objects: turn all off |
| 9.1.8.11 | Object tile | Object NAME: on / off |

### 9.2 Values

| # | Event | Message |
|---|---|---|
| 9.2.1 | Master PLAY / PAUSE | Mix playing · Deck A + Deck B / Mix paused · PLAY resumes it from here |
| 9.2.2 | Deck PLAY / PAUSE | Playing · AMU clock + audio / Playing · AMU clock (no audio) / Paused |
| 9.2.3 | PLAY waiting | Deck A: Starts on the next 1/4 |
| 9.2.4 | PLAY cancelled | Deck A: Start cancelled |
| 9.2.5 | Waveform cue | Deck A: Cue · bar N.N · QUANT 1/4 |
| 9.2.6 | Block cue / loop | Deck A: Cue · NAME · bar N.N · QUANT 1/4 / Deck A: Loop · NAME · bar N.N |
| 9.2.7 | Loop released | Deck A: Loop released · the track loops |
| 9.2.8 | LOOP | Deck A: Loop off / Loop · the picked chip / Loop armed: the track loops · click a chip to loop it |
| 9.2.9 | KEY LOCK | Deck A: KEY LOCK on: pitch held / KEY LOCK off: pitch follows the tempo |
| 9.2.10 | Solos cleared | Deck A: All solos cleared |
| 9.2.11 | TEMPO | TEMPO 124.00 BPM |
| 9.2.12 | QUANT | QUANT 1/4 |
| 9.2.13 | Master position reset | Master position 1.1.1 |
| 9.2.14 | Mixer encoder | Deck A audio · N% / Deck A in OUT · N% |
| 9.2.15 | FX knob | Deck A AFX1 · Filter N% (· killed) |
| 9.2.16 | FX kill / restore | Deck A AFX1 · kill on the next 1/4 / restore on the next 1/4 |
| 9.2.17 | Zoom | Deck A: Piano roll N% |
| 9.2.18 | Roll orientation | Deck A: Piano roll horizontal / vertical |
| 9.2.19 | Orientation | Orientation 16:9 |
| 9.2.20 | Pop Out | Visual popped out, double-click it for fullscreen |
| 9.2.21 | REC saved | Video saved (MP4) / Video saved (WebM) / Chip rendered · recording saved |
| 9.2.22 | End of track | End of track, playhead reset |
| 9.2.23 | Shader loaded | Loaded NAME |
| 9.2.24 | MP3 loading | Loading NAME … / Loaded NAME · AMU driving the visual |
| 9.2.25 | AMU loaded | Loaded AMU NAME · N BPM · N sections · N bars |
| 9.2.26 | Cover loaded | Deck A: Cover NAME |
| 9.2.27 | Deck drop, extra files | Deck A: Loaded NAME + NAME · N more files ignored (a deck takes one of each type) |
| 9.2.28 | Library drop | Library: N tracks · N covers · N shaders · N files ignored, with skipped covers and the playlist count |
| 9.2.29 | Library entry removed | Library: removed NAME |
| 9.2.30 | Playlist | Playlist NAME: N queued · N no AMU · N not found |
| 9.2.31 | QUEUE | QUEUE on · Playlist NAME: … / QUEUE off |
| 9.2.32 | PLAY NEXT, empty LIBRARY | PLAY NEXT: no tracks in the LIBRARY |
| 9.2.33 | CONTINUOUS PLAY | Continuous play on / Continuous play off |
| 9.2.34 | SHUFFLE | Shuffle on / Shuffle off |
| 9.2.35 | FX knob reset | Deck A AFX1 · Filter N% (CREATE: AFX1 · Filter N%), at the default amount |
| 9.2.36 | Header rename | Header: type a name (Enter = keep · Esc = cancel · empty = ONEMANSHYO) / Header: NAME (this session) / Header unchanged |

### 9.3 Errors

| # | Event | Message |
|---|---|---|
| 9.3.1 | Shader compile | WGSL error in NAME, see stage |
| 9.3.2 | MP3 decode | Could not decode NAME, AMU clock still plays |
| 9.3.3 | Not an AMU file | Not a Sozo AMU file: NAME (reason) |
| 9.3.4 | Lengths differ | Audio and AMU lengths differ (N bars vs N bars): check the MP3 and JSON are the same track |
| 9.3.5 | Cover | Deck A: Cover NAME is W×H · a cover must be square / Deck A: Could not read NAME |
| 9.3.6 | Drop unreadable | Deck A: Could not read the drop (reason) / Library: could not read the drop (reason) |
| 9.3.7 | Wrong file on a deck | Drop an MP3, its AMU .json, a .wgsl or a square cover image |
| 9.3.8 | Wrong file in a picker | Pick an audio file (mp3, m4a, wav…) or its AMU .json / Pick a .wgsl shader file |
| 9.3.9 | Library drop, nothing usable | Library: N files ignored … |
| 9.3.10 | Embedded track | Embedded track could not be read |
| 9.3.11 | Pop Out | Pop-out not supported in this browser / Pop-out blocked, allow popups for this page |
| 9.3.12 | REC | Recording not supported in this browser |
| 9.3.13 | KEY LOCK | KEY LOCK needs AudioWorklet, not available in this browser |
| 9.3.14 | GPU (on the stage) | WebGPU unavailable. Desktop needs a current Chrome, Edge, or Safari. / WebGPU unavailable (no adapter). / GPU device lost: reason / GPU error: reason / WGSL error line N: message |

## 10. Keyboard index

Field keys act only while that field has focus (click it first). Space is ignored while typing in a field.

| # | Key | Where | Action |
|---|---|---|---|
| 10.1 | Space | PERFORM | Master PLAY / PAUSE (the whole mix) |
| 10.2 | Space | CREATE, AUTHORING | PLAY / PAUSE the deck |
| 10.3 | ↑ / ↓ | TEMPO (CREATE, PERFORM) | ±1 BPM |
| 10.4 | ← / → | TEMPO | ±0.01 BPM |
| 10.5 | type + Enter | TEMPO | Set the tempo |
| 10.6 | Escape | TEMPO | Leave the field |
| 10.7 | ↑ / ↓ | QUANT (CREATE, PERFORM) | Next / previous step: None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars |
| 10.8 | Enter / Escape | QUANT | Leave the field |
| 10.9 | ↑ / ↓ | Piano roll zoom (every deck) | Zoom steps 0 / 25 / 50 / 75 / 100 % |
| 10.10 | Enter / Escape | Piano roll zoom | Leave the field |
| 10.11 | ↑ / ↓ | FX knob | Amount ±1 % |
| 10.12 | ← / → | FX knob | Amount ±5 % |
| 10.13 | Enter | FX knob | Kill / restore on QUANT |
| 10.14 | Escape | FX knob | Leave the knob |
| 10.15 | ↑ ← / ↓ → | FX effect box | Previous / next effect in the bank |
| 10.16 | Enter / Escape | FX effect box | Leave the box |
| 10.17 | ↑ / ↓ | LIBRARY list | Select the previous / next entry |
| 10.18 | ← | LIBRARY list | Load the entry on Deck A |
| 10.19 | → | LIBRARY list | Load the entry on Deck B (CREATE: on the deck) |
| 10.20 | Delete (Mac: delete) | LIBRARY list | Remove the entry from the library |
| 10.21 | scroll | QUANT | Next / previous step |
| 10.22 | ctrl + wheel, pinch | Piano roll | Zoom |
| 10.23 | Enter | Header name (after a power light tap) | Keep the name |
| 10.24 | Escape | Header name | Cancel |

---

**END OF USER GUIDE**
