# OMS Vizzie app [Beta V0.8.0] User Guide

**Run date:** 2026-10-31  
**Current Unix Epoch:** 1793469710  
**Filename:** OMS_Vizzie_Beta_V0_8_0_E_UserGuide_All.md  
**App Version:** Vizzie Beta V0.8.0  
**License:** GPL-3.0 (software); embed assets see ABOUT menu  
**Purpose:** How to use Vizzie.  

---

## 1. What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

## 2. Where to find Vizzie

Go to **vizzie.onemanshyo.com**, or open `OMS_Vizzie_Beta_V0_7_0.html` in a WebGPU-capable browser: current Chrome, Edge or Safari on desktop, or Safari on iOS/iPadOS 26+. The reference track's analysis is embedded, so it works immediately. On the website the example audio loads by itself; opened as a local file, load an audio file to hear it (drop it on the music row, or double-click the cover or the waveform).

## 3. Navigation

### 3.1 CREATE
The working surface. It has two modes:
- **PUBLIC**, on the website: Music and Visual side by side across the top, Music Understanding Controls underneath.
- **AUTHORING**, when the file is opened anywhere else: the Visual on top, then the music row, the transport, the Music Understanding Controls, the piano roll and the authoring sections for building shaders. Click the VISUAL header to switch between AUTHORING and PUBLIC (and on to Pocket Rave).

#### 3.1.1 Music

##### 3.1.1.1 Cover and song info
The cover shows the track's art. **Click** it to see the title, artist, label, year and copyright; click anywhere else or press Esc to close. **Double-click** it to pick an audio file or the track's Music Understanding `.json`. You can also drag either onto the music row.

##### 3.1.1.2 Waveform
The whole track with the playhead. **Click or drag** to move the playhead; the shader follows. **Double-click** to pick an audio file or its `.json`. Audio isn't needed to press PLAY: Vizzie runs from the embedded Apple Music Understanding analysis.

##### 3.1.1.3 PLAY / PAUSE
Starts and stops. **Spacebar** also toggles.

##### 3.1.1.4 LOOP
When lit, playback returns to the start and keeps going instead of stopping.

##### 3.1.1.5 TEMPO
The tile at the end of the transport (PLAY · LOOP · KEY LOCK · TEMPO). Sets the tempo. **−** and **+** step one BPM; click the value to type one. The audio, the visual and the piano roll all follow, locked to the beat. The % shows the change from the track's own tempo. **Double-click** the value to go back to the track's tempo. The range is half to one and a half times the track's tempo.

##### 3.1.1.6 KEY LOCK
The button beside LOOP. When lit, the pitch stays put as you change the tempo, and drum hits keep their snap. When off, the pitch moves with the tempo, like a turntable.

##### 3.1.1.7 Another track's Music Understanding
Each track has its own Music Understanding file, a `.json` made by the Sozo sidecar. Drop it on the music row (or double-click the cover or waveform and pick it): the piano roll, readout, cue points and visuals switch to that track, and TEMPO goes to its BPM. Load the track's MP3 the same way, before or after. If the audio and the `.json` are different lengths, the message bar tells you so you can check they belong together.

#### 3.1.2 Visual

The live shader. The buttons sit on the right of the Visual header.

##### 3.1.2.1 </> Code
Opens the shader code. Edit or paste a complete shader, then **Apply**. **Copy** copies the code.

##### 3.1.2.2 Pop Out
Opens the visual in its own window. Double-click that window for fullscreen.

##### 3.1.2.3 Orientation
Cycles the visual through 16:9, 1:1 and 9:16.

##### 3.1.2.4 ● Record
Records the visual with the track's audio to a video file; the timer shows the length. Click again to stop and download.

##### 3.1.2.5 Load a shader file
Drag a `.wgsl` file onto the visual, or **double-click** the visual to pick one.

#### 3.1.3 Music Understanding Controls

##### 3.1.3.1 Groups and lanes
Six groups (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS) holding twelve lanes: beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other. What each lane does to the picture depends on the shader loaded. Hover over a lane to see its live value in the message bar.

##### 3.1.3.2 Encoders
Drag up or down to set how strongly that lane drives the shader (0 to full). Press to solo the lane (clicking the lane chip does the same); solos stack. Double-click to reset to full.

##### 3.1.3.3 Group solo
Click a group header to solo the whole group.

##### 3.1.3.4 SOLO
On the right of the Music Understanding Controls header. Lights when anything is soloed; click to clear all.

##### 3.1.3.5 Piano roll
Each lane's music data moving through the centre playhead, counted in beats: 4 bars in view in AUTHORING, 8 bars in PUBLIC, at any tempo.
- **Drag** it to scrub.
- **Click** a block to jump to its start: a beat, bar, section, segment, phrase, key or pace change. These are your cue points, straight from Music Understanding; nothing needs saving.
- **Zoom** with − and + in the header, or pinch. The % shows how much of the song is in view; 100% is the whole song.
- The button beside SOLO switches the roll between vertical and horizontal.

### 3.2 ABOUT
What Vizzie is, who made it, the license.

### 3.3 LEARN
Opens the learning page on onemanshyo.com in a new tab.

## 4. Messages section

The bar at the bottom of the screen. Everything the app has to tell you appears here, in three colours:

### 4.1 Hints and values (cyan)
What mode you're in, and the live values of a lane or group while you hover over it.

### 4.2 Status (orange)
What just happened: playing, tempo, KEY LOCK, a cue, a file loaded, the visual popped out.

### 4.3 Errors (magenta)
Something failed: a file that isn't audio or `.wgsl`, a track that won't decode, pop-out blocked, recording not supported.

Shader problems show in the visual itself instead: no WebGPU in the browser, or a mistake in the shader (the message gives the line number).

## 5. Pocket Rave (mobile devices)

On the website, phones and tablets in portrait get Pocket Rave; phones stay in Pocket Rave in landscape too. Tablets in landscape get the full app. Code, pop-out, recording, TEMPO and the encoders are only in the full app.

### 5.1 Full frame
Pocket Rave opens with the shader filling the frame. **Tap** the shader to play or pause. **Double-tap** it, or tap the ONEMANSHYO header, for the normal view.

### 5.2 Normal view
Tabs, the shader, the cover beside the waveform, the version line, the Yobot and PLUR. Tap the ONEMANSHYO header to go back to full frame.
- **Shader:** tap to play or pause; double-tap to pick a `.wgsl` shader from your device.
- **Cover:** tap to see the song info over the waveform; double-tap to pick an MP3 from your device.
- **Waveform:** drag to move the playhead.

### 5.3 Tabs and links
ABOUT is in the tabs; LEARN opens the website.

---

**END OF USER GUIDE**
