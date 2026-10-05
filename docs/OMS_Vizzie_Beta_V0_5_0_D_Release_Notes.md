# OMS Vizzie app [Beta V0.5.0] Release Notes

**Run date:** 2026-10-05  
**Current Unix Epoch:** 1791240441  
**Filename:** OMS_Vizzie_Beta_V0_5_0_D_Release_Notes.md  
**App Version:** Vizzie Beta V0.5.0  
**License:** GPL-3.0 (software); embed assets see ABOUT menu  
**Purpose:** User enhancements since V0.2.18c.  

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
