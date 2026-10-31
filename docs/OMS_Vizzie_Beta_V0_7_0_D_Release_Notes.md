# OMS Vizzie app [Beta V0.7.0] Release Notes

**Run date:** 2026-10-31  
**Current Unix Epoch:** 1793459152  
**Filename:** OMS_Vizzie_Beta_V0_7_0_D_Release_Notes.md  
**App Version:** Vizzie Beta V0.7.0  
**License:** GPL-3.0 (software); embed assets see ABOUT menu  
**Purpose:** User enhancements since V0.2.18c.  

---

## V0.7.0

- CREATE has two modes in one app. On the website it opens in PUBLIC. Opened anywhere else, it opens in AUTHORING, the shader authoring workspace that used to be a separate template. Click the VISUAL header to switch.
- TEMPO: set the tempo with − and +, or type a value. The audio, the visual and the piano roll all follow. The % shows the change from the track's own tempo; double-click the value to reset it. The range is half to one and a half times the track's tempo.
- KEY LOCK: keeps the pitch when you change the tempo, and keeps drum hits sharp. Off, the pitch moves with the tempo like a turntable.
- The music clock counts bars and beats. Visuals and audio stay locked to the beat at any tempo.
- Piano roll: switch it between vertical and horizontal. Zoom with − and + or pinch; the % shows how much of the song is in view. Drag it to scrub. Click a block to jump to its start; Music Understanding gives you cue points for beats, bars, sections, segments, phrases, key and pace. The window counts beats: 4 bars in AUTHORING, 8 bars in PUBLIC.
- Double-click the cover or the waveform to load an MP3, or the shader to load a `.wgsl`, on desktop as well as on phones. Drag and drop still works.
- The cover flips to the song info in every mode.
- Orientation now cycles 16:9, 1:1 and 9:16.
- Pocket Rave opens with the shader filling the frame. Tap the ONEMANSHYO header to switch between full frame and the normal view; a double tap on the shader in full frame does the same. In the normal view the cover sits beside the waveform.
- The default visual is the Music Understanding test tunnel, with Yobot Squint on top.
- For shader authors: `vizzie.time` now counts beats instead of seconds (uniform contract V0.4.0D). Shaders that move with `vizzie.time` need their speeds restated per beat.

---

## V0.6.0

- Pocket Rave: the song info is now a card showing the cover art. Tap it to flip to the song info; double-tap it to load an MP3 from your device.
- Pocket Rave: double-tap the shader to load a `.wgsl` file from your device. A single tap still plays and pauses.
- Pocket Rave: tap the Yobot at the bottom to fill the frame with the shader. Tap anywhere off the shader to come back.
- Pocket Rave: the ONEMANSHYO logo at the top opens onemanshyo.com.

---

## V0.5.0

- Click or drag on the waveform, on desktop or phone, to move the playhead. The shader follows. Works with or without audio loaded.
- The LEARN tab opens the learning page on onemanshyo.com in a new tab.

---

## V0.4.0

- WebGPU/WGSL is the only renderer. The original Canvas visual is removed.
- The former hidden Yo Lab is now the CREATE tab. The CREATE tab, the phone view and the pop-out all show the same shader.
- Load a shader by dropping a `.wgsl` file on the visual, or paste code into the editor and click Apply.
- Twelve Music Understanding lanes (beat, bar, section, segment, phrase, key, pace, loudness, drum, bass, vocal, other), each with an encoder: drag to set intensity, press to solo, double-click to reset. Click a bus header to solo the group.
- Scrolling piano roll of the music data under the controls.
- Drop an MP3 on the song info box to load it. Cover, title, artist, label, year and copyright are read from the file's tags.
- Record the visual with the track's audio to a video file (MP4 where supported, otherwise WebM).
- Switch the viewer between 16:9 and 9:16.
- Phones get Pocket Rave in both orientations: song info, the shader (tap to play), the waveform.
- Requires a WebGPU-capable browser: current Chrome, Edge or Safari on desktop; Safari on iOS/iPadOS 26 or later.

---

## V0.3.0

- Shaders receive raw Apple Music Understanding values: loudness in LUFS, pace, key at the playhead, beat and bar position.
- The "break" signal, which was a guess from section length, is removed.

---

**END OF RELEASE NOTES**
