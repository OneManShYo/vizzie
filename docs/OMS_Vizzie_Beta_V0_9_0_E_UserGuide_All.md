# OMS Vizzie app [Beta V0.9.0] User Guide

**Run date:** 2026-11-01  
**Current Unix Epoch:** 1793543222  
**Document purpose:** How to use Vizzie.  
**Filename:** OMS_Vizzie_Beta_V0_9_0_E_UserGuide_All.md  

## About this document

Vizzie Beta V0.9.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## CONTENTS

**1** What is Vizzie?  
**2** Where to find Vizzie  
**3** Tabs  
**4** CREATE  
&emsp;4.1 Two modes  
&emsp;4.2 Global strip  
&emsp;4.3 Music  
&emsp;4.4 Controls row  
&emsp;4.5 Visual  
&emsp;4.6 Music Understanding  
&emsp;4.7 Another track's Music Understanding  
**5** PERFORM  
&emsp;5.1 Layout  
&emsp;5.2 Global strip  
&emsp;5.3 A deck  
&emsp;5.4 Loading a deck  
&emsp;5.5 Which deck sets the tempo  
&emsp;5.6 Starting and cueing in time (QUANT)  
&emsp;5.7 Mixer  
**6** ABOUT and LEARN  
**7** Messages  
**8** Pocket Rave (phones and tablets)  

---

## 1. What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

Everything in Vizzie counts in music time: bars and beats. A position written 62.1 is bar 62, beat 1; 62.1.3 is bar 62, beat 1, third sixteenth.

## 2. Where to find Vizzie

Go to **vizzie.onemanshyo.com**, or open `OMS_Vizzie_Beta_V0_9_0.html` in a WebGPU-capable browser: current Chrome, Edge or Safari on desktop, or Safari on iOS / iPadOS 26 or later. The reference track's analysis is embedded, so it works immediately. On the website the example audio loads by itself; opened as a local file, load an audio file to hear it (drop it on the deck, or double-click the cover or the waveform).

## 3. Tabs

**CREATE · PERFORM · ABOUT · LEARN.** CREATE opens. PERFORM shows only when the app is opened off the website (as a local file, for example).

## 4. CREATE

The working surface: one deck, its shader on the stage, and the Music Understanding controls that drive it.

### 4.1 Two modes
- **PUBLIC**, on the website: the music and its controls row on the left, the Visual on the right, the Music Understanding controls underneath.
- **AUTHORING**, when the file is opened anywhere else: the Visual on top, then the music, the controls row, the Music Understanding controls, the piano roll and the authoring sections for building shaders. Click the VISUAL header to switch between AUTHORING and PUBLIC (and on to Pocket Rave).

### 4.2 Global strip
The thin strip across the top: settings you set and leave.
- **TEMPO.** Click it, then ↑ / ↓ for one BPM, ← / → for a hundredth of a BPM, or type a value and press Enter. Double-click goes back to the track's own tempo (or, if PERFORM's deck B is playing and has become MASTER, to deck B's). The audio, the visual and the piano roll all follow, locked to the beat. The range is half to one and a half times the track's tempo.
- **Position.** Where you are in the track, in bars.beats.sixteenths. It turns red while REC records.

### 4.3 Music

#### 4.3.1 Cover and song info
The cover shows the track's art. **Click** it to see the song info over the waveform; click it again, click elsewhere or press Esc to close it. **Double-click** the cover to pick an audio file or the track's Music Understanding `.json`.
- In AUTHORING the song info is one line: title · artist · BPM · key. If it is longer than its box it scrolls.
- In PUBLIC it is the full panel: title, artist, label, year and copyright.

The waveform keeps working while the song info is showing.

#### 4.3.2 Waveform
The whole track with the playhead. **Click or drag** to move the playhead; the shader follows. **Double-click** to pick an audio file or its `.json`. Audio isn't needed to press PLAY: Vizzie runs from the embedded Music Understanding analysis.

#### 4.3.3 Dropping files
Drag an MP3, its Music Understanding `.json` or a `.wgsl` shader anywhere onto the deck, one to three at once. While you drag, the deck shows where the drop goes and what it takes.

### 4.4 Controls row
**PLAY · KEY LOCK · zoom · orientation ........ SOLO**
- **PLAY / PAUSE** starts and stops. **Spacebar** does the same on CREATE. At the end of the track the playhead goes back to the start and stops.
- **KEY LOCK**, on when you open the app: the pitch stays put as you change the tempo, and drum hits keep their snap. Off, the pitch moves with the tempo, like a turntable.
- **Zoom** (the % field): how much of the song the piano roll shows. Click it, then ↑ / ↓ through 0, 25, 50, 75 and 100. 0 is the closest view, 100 the whole song.
- **Orientation**: the piano roll vertical or horizontal.
- **SOLO** lights while any lane or group is soloed. Click it to clear all solos.

### 4.5 Visual
The live shader on the stage. The buttons sit on the right of the Visual header.

#### 4.5.1 </> Code
Opens the shader code. Edit or paste a complete shader, then **Apply**. **Copy** copies the code.

#### 4.5.2 Pop Out
Opens the visual in its own window. Double-click that window for fullscreen.

#### 4.5.3 Orientation
Cycles the visual through 16:9, 1:1 and 9:16.

#### 4.5.4 ● REC
Records the visual with the track's audio to a video file. On a paused track it starts from the beginning and stops by itself at the end. On a playing track it records from where you are. Click again to stop early. The file downloads when the recording ends.

#### 4.5.5 Load a shader file
Drag a `.wgsl` file onto the deck, or **double-click** the visual to pick one.

### 4.6 Music Understanding

#### 4.6.1 Groups and lanes
Six groups (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS) holding twelve lanes: beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other. What each lane does to the picture depends on the shader loaded. Hover over a lane to see its live value in the message bar.

#### 4.6.2 Encoders
Drag up or down to set how strongly that lane drives the shader (0 to full). Press to solo the lane (clicking the lane chip does the same); solos stack. Double-click to reset to full.

#### 4.6.3 Group solo
Click a group header to solo the whole group.

#### 4.6.4 Piano roll
Each lane's music data moving through the centre playhead, counted in beats: 4 bars in view in AUTHORING, 8 bars in PUBLIC at the closest zoom, at any tempo.
- **Drag** it to scrub.
- **Click** a block to jump to its start: a beat, bar, section, segment, phrase, key or pace change. These are your cue points, straight from Music Understanding; nothing needs saving.
- **Zoom** with the zoom field in the controls row, or pinch, or ctrl + wheel on the roll.

### 4.7 Another track's Music Understanding
Each track has its own Music Understanding file, a `.json` made by the Sozo sidecar. Drop it on the deck (or double-click the cover or waveform and pick it): the piano roll, readout, cue points and visuals switch to that track, and TEMPO goes to its BPM. Load the track's MP3 the same way, before or after. If the audio and the `.json` are different lengths, the message bar tells you, so you can check they belong together.

## 5. PERFORM

Two decks and a mixer, for playing visuals live to music. Shown only when the app is opened off the website.

### 5.1 Layout
**DECK A · MIXER · DECK B**, side by side, fitted to the window, under the global strip. Deck A is the same deck as CREATE's: the track, solos and knobs you set on one tab are there on the other.

### 5.2 Global strip
- **TEMPO**: as on CREATE (4.2). Double-click goes back to the tempo of the deck that is MASTER.
- **QUANT**: click it, then ↑ / ↓ (or scroll) through None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars. Double-click = 1/4. See 5.6.
- **Master position**: the session, in bars.beats.sixteenths. It starts at 1.1.1 with the first PLAY, counts while any deck plays, and holds while every deck is stopped. Double-click to go back to 1.1.1.

### 5.3 A deck
Top to bottom:
1. **Header:** the deck name, **KEY LOCK**, and **MASTER**, which lights while this deck sets the tempo (5.5).
2. **Stage:** the deck's own shader. **Double-click** it to pick a `.wgsl`.
3. **Cover and waveform**, in a slim row. Click the cover for the song info line (title · artist · BPM · key); double-click the cover or the waveform to load an MP3 or its `.json`; drag the waveform to seek, with or without the song info showing.
4. **PLAY · zoom · orientation · position ........ SOLO.** The position is this deck's own place in its track. The roll opens at 25 % zoom, horizontal.
5. **Music Understanding:** the knobs, in their group colours, without labels: each coloured knob is a lane (drag = amount, press = solo, double-click = full). Click a group's colour bar to solo the group. A soloed lane is outlined in its colour; the others dim. Below, the piano roll: drag to scrub, click a block to cue to its start.

There is no Code, REC or LOOP on PERFORM.

### 5.4 Loading a deck
Drop an MP3, its Music Understanding `.json` or a `.wgsl` anywhere on the deck, one to three files at once, or use the double-clicks above. Deck B starts with the reference track and the default shader.

### 5.5 Which deck sets the tempo
The playing deck that started first is MASTER and sets the tempo. When it stops and the other deck is still playing, that deck becomes MASTER. With nothing playing, MASTER stays where it was. A deck that starts never changes the tempo, so nothing jumps.

### 5.6 Starting and cueing in time (QUANT)
When the other deck is playing:
- **PLAY** waits for the next QUANT step of the master grid, then starts this deck from the matching place in its own track, so the two land together. PLAY blinks while it waits; press it again to cancel.
- **A cue** (a click on a piano roll block) waits the same way, then jumps.

With QUANT at None, or when no other deck is playing, PLAY and cues happen at once.

### 5.7 Mixer
- **OUT**: the two decks' visuals blended at their VID levels (MIX).
- **Encoders**, A VID · A AUD · B AUD · B VID. VID (purple) is the deck's strength in OUT; AUD (cyan) is its volume. Drag up or down; double-click = 0. VID opens at the middle, so OUT shows both decks; AUD opens at 0.
- ADD, SCREEN, CUT, LIBRARY and QUEUE are shown but do nothing.

## 6. ABOUT and LEARN

**ABOUT**: what Vizzie is, who made it, the license. **LEARN** opens the learning page on onemanshyo.com in a new tab.

## 7. Messages

The bar at the bottom of the screen. Everything the app has to tell you appears here, in three colours:
- **Cyan, help:** what a control is and its keys, while you point at it or click into it, and the live values of a lane or group.
- **Orange, values:** what just changed: playing, TEMPO, QUANT, KEY LOCK, a cue, a file loaded.
- **Magenta, errors:** something failed: a file that isn't audio, `.json` or `.wgsl`, a track that won't decode, pop-out blocked, recording not supported.

When nothing needs saying, the bar is empty. Shader problems show in the visual itself instead: no WebGPU in the browser, or a mistake in the shader (the message gives the line number).

## 8. Pocket Rave (phones and tablets)

On the website, phones and tablets in portrait get Pocket Rave; phones stay in Pocket Rave in landscape too. Tablets in landscape get the full app. Code, pop-out, recording, TEMPO, the encoders and PERFORM are only in the full app.

### 8.1 Full frame
Pocket Rave opens with the shader filling the frame. **Tap** the shader to play or pause. **Double-tap** it, or tap the ONEMANSHYO header, for the normal view.

### 8.2 Normal view
Tabs, the shader, the cover beside the waveform, the version line, the Yobot and PLUR. Tap the ONEMANSHYO header to go back to full frame.
- **Shader:** tap to play or pause; double-tap to pick a `.wgsl` shader from your device.
- **Cover:** tap to see the song info over the waveform; double-tap to pick an MP3 from your device.
- **Waveform:** drag to move the playhead.

### 8.3 Tabs and links
ABOUT is in the tabs; LEARN opens the website.

---

**END OF USER GUIDE**
