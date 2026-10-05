# OMS Vizzie app [Beta V0.5.0] User Guide

**Run date:** 2026-10-05  
**Current Unix Epoch:** 1791240441  
**Filename:** OMS_Vizzie_Beta_V0_5_0_E_UserGuide_All.md  
**App Version:** Vizzie Beta V0.5.0  
**License:** GPL-3.0 (software); embed assets see ABOUT menu  
**Purpose:** How to use Vizzie.  

---

## 1. What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

## 2. Where to find Vizzie

Go to **vizzie.onemanshyo.com**, or open `OMS_Vizzie_Beta_V0_5_0.html` in a WebGPU-capable browser: current Chrome, Edge or Safari on desktop, or Safari on iOS/iPadOS 26+. The reference track's analysis is embedded, so it works immediately. On the website the example audio loads by itself; opened as a local file, drop an audio file on the song info box to hear it.

## 3. Navigation

### 3.1 CREATE
The working surface. Music and Visual sit side by side across the top: Music on the left, Visual on the right. Music Understanding Controls runs underneath.

#### 3.1.1 Music

##### 3.1.1.1 Song info
Cover, title, artist, label, year and copyright, read from the MP3's tags. **Drag an audio file onto this box** to load it. Click the cover to see it large; click or press Esc to close.

##### 3.1.1.2 Waveform
The track's waveform with the playhead. **Click or drag on it to move the playhead**; the shader follows. Shows a dim placeholder until audio loads. Audio isn't needed to press PLAY: Vizzie runs from the embedded Apple Music Understanding analysis, and the waveform fills in once audio is loaded.

##### 3.1.1.3 PLAY / PAUSE
Starts and stops. With no audio, the music timeline still runs on its own. **Spacebar** also toggles.

##### 3.1.1.4 LOOP
When lit, playback returns to the start and keeps going instead of stopping.

#### 3.1.2 Visual

The live shader. The buttons sit on the right of the Visual header.

##### 3.1.2.1 </> Code
Opens the shader code. Edit or paste, then **Apply**. Paste a whole shader or just the fragment; Vizzie works out which. **Copy** copies the code.

##### 3.1.2.2 Pop Out
Opens the visual in its own window. Double-click that window for fullscreen.

##### 3.1.2.3 Orientation
Switches the visual between 16:9 and 9:16.

##### 3.1.2.4 ● Record
Records the visual with the track's audio to a video file; the timer shows the length. Click again to stop and download.

##### 3.1.2.5 Load a shader file
Drag a `.wgsl` file onto the visual.

#### 3.1.3 Music Understanding Controls

##### 3.1.3.1 Groups and lanes
Six groups (RHYTHM, STRUCTURE, KEY, PACE, LOUDNESS, INSTRUMENTS) holding twelve lanes: beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other. What each lane does to the picture depends on the shader loaded.

##### 3.1.3.2 Encoders
Drag up or down to set how strongly that lane drives the shader (0 to full). Press to solo the lane (clicking the lane chip does the same); solos stack. Double-click to reset to full.

##### 3.1.3.3 Group solo
Click a group header to solo the whole group.

##### 3.1.3.4 SOLO
On the right of the Music Understanding Controls header. Lights when anything is soloed; click to clear all.

##### 3.1.3.5 Piano roll
Below the encoders: each lane's music data scrolling through the centre playhead.

### 3.2 ABOUT
What Vizzie is, who made it, the license.

### 3.3 LEARN
Opens the learning page on onemanshyo.com in a new tab.

## 4. Messages section

The bar at the bottom of the screen. Everything the app has to tell you appears here, in three colours:

### 4.1 Hints (cyan)
Hover over or focus any control to see what it does.

### 4.2 Status (orange)
What just happened: playing, loop on, solos cleared, a file loaded, the visual popped out.

### 4.3 Errors (magenta)
Something failed: pop-out blocked, recording not supported, a file that isn't audio, a bad file.

Shader problems show in the visual itself instead: no WebGPU in the browser, or a mistake in the shader (the message gives the line number).

## 5. Pocket Rave (mobile devices)

Phones and tablets in portrait get Pocket Rave. Tablets in landscape get the full app; phones stay in Pocket Rave in landscape too (the screen is too short for the full app). Pocket Rave shows song info, the live shader (**tap it to play/pause**; the border turns magenta while playing), and the waveform (drag on it to move the playhead). ABOUT is in the tabs at the top; LEARN opens the website. Code, pop-out, recording and the encoders are only in the full app.

---

**END OF USER GUIDE**
