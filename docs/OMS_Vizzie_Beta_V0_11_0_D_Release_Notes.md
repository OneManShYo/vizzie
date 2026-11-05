# OMS Vizzie app [Beta V0.11.0] Release Notes

**Run date:** 2026-11-05  
**Current Unix Epoch:** 1793912480  
**Document purpose:** User enhancements since V0.2.18c, newest first.  
**Filename:** OMS_Vizzie_Beta_V0_11_0_D_Release_Notes.md  

## About this document

Vizzie Beta V0.11.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## V0.11.0

- CREATE is now music and visuals: MUSIC on the left (cover, waveform, controls, LIBRARY), VISUALS on the right, and Music Understanding across the bottom, filling the window.
- The LIBRARY is always open on CREATE. On the website it lists the demo playlists (BIG WHEEL ENERGY); a playlist shows its tracks in its own order, title first. Double-click or double-tap a track to load and play it. Drop your own files on the LIBRARY to add them.
- FX on CREATE: two music effects and two visual effects for the deck. The visual effects show on the stage, in Pop Out and in REC.
- Double-click an FX knob to reset it to its default, on CREATE and PERFORM.
- PLAY NEXT, CONTINUOUS PLAY and SHUFFLE on CREATE. SHUFFLE puts the list in a random order and plays it in that order.
- SOLO and the piano roll zoom sit at the right of the Music Understanding header.
- Off the website, AUTHORING has its own tab, after PERFORM, for building shaders.
- A HELP tab with LET'S DO THIS: eight things to try.
- iPhone and iPad: the music plays when you tap PLAY, silent switch on or off. The website opens faster: songs and their analysis are fetched when you play them.
- The strip with the red power light and the jacks now frames the whole app. Tap the power light to put your own name in the header for the session.
- New colours: Purple People Eater, Barbie Pink, Green Slime, Yellow Man, Orange Julius, Goblin White and Red Hots. Each Music Understanding lane shows in its group's colour.

---

## V0.10.0

- QUANT is on CREATE's global strip too, next to TEMPO: one value shared with PERFORM.
- Cues wait for QUANT whenever the track is playing: a click on a piano roll block or on the waveform lands on the next step. With QUANT at None it jumps at once.
- Click the waveform to cue; drag it to scrub.
- LOOP is back, right after PLAY, on CREATE and on every PERFORM deck. On, the whole track loops. Click a piano roll block and that block loops instead; click it again to go back to the whole track.
- REC records from the playhead. Click a block while stopped, then REC: it records exactly that block and stops. With LOOP on, the block loops and the recording runs until you press REC again.
- The block that is looping or picked lights up on the piano roll.
- The song info line scrolls on every deck, in both CREATE modes, and stays until you click the cover again.
- CREATE on the website: a slim music row, the controls row, and the Music Understanding lanes as chips with their own piano roll, all beside the visual without scrolling.
- Drop files or whole folders on a deck: it takes the first MP3, Music Understanding `.json`, `.wgsl` and square cover image, and tells you what it ignored. Every drop zone shows the same simple "Drop files" hint.
- Drop a square cover image on a deck to use it as the track's cover.
- PERFORM: a master PLAY in the global strip pauses the whole mix and starts it again from the same spot. Spacebar does the same.
- PERFORM: each deck's Music Understanding lanes are chips: click to solo.
- PERFORM: the LIBRARY. Drop your gig folder on the MIXER column: every MP3 with its Music Understanding `.json`, every shader at its latest version, covers that share a track's name. Filter by ALL, MUSIC or SHADERS. Click an entry, then ← for Deck A or → for Deck B, ↑ / ↓ to move, Delete to remove; or drag it onto a deck.
- PERFORM: playlist QUEUE. Drop an `.m3u8` exported from your music player (Swinsian, for example) with the music, in either order, and QUEUE shows the library in the playlist's order.
- PERFORM: MODE · FX · EQ under the MIXER. MODE and FX slide a panel down over the LIBRARY.
- PERFORM: FX. Each deck has two music effects (Filter, Washout, Dubby, Delay, Reverb, Flanger, Phaser, Bitcrush) and two visual effects (RGB Split, Feedback, Glitch, Pixelate, Scanlines, Mirror, Kaleidoscope, VHS, Shake, Tone, Tile, Rotate, Zoom). Drag a knob for the amount; click it to kill or restore on QUANT; click the box under it and use the arrows to change the effect.
- New tagline: Music drives the vision ;)
- The Yobot icon is gone from the header and Pocket Rave.
- The user guide lists every message the bar shows and every keyboard shortcut.
- The V0.9.0 known issue with hover help came from a Chrome extension, not Vizzie. If hover help stops after a click in Chrome, check your browser extensions.

---

## V0.9.0

- A PERFORM tab, when the app is opened off the website: DECK A, the MIXER and DECK B side by side, fitted to the window. Deck A is the same deck as CREATE's; deck B is a second deck with its own track, shader, waveform, lanes and piano roll.
- PERFORM's global strip across the top: TEMPO, QUANT and the master position.
- QUANT: PLAY and cues wait for the next step of the master grid when another deck is playing. Steps: None, 1/4, 1/2, 1 Bar, 2 Bars, 4 Bars, 8 Bars. PLAY blinks while it waits; press again to cancel.
- The tempo follows the playing deck that started first; its MASTER indicator is lit. When it stops, another playing deck takes over. The tempo never jumps on a start, a stop or a handover.
- Master position: the session in bars.beats.sixteenths, counting from the first PLAY and holding while every deck is stopped. Double-click to go back to 1.1.1.
- OUT shows both decks blended at their VID levels (MIX). Four encoders: A VID, A AUD, B AUD, B VID. VID sets a deck's strength in OUT, AUD its volume. VID opens at the middle, AUD at zero.
- Each PERFORM deck: KEY LOCK and MASTER in its header; PLAY, the roll zoom, the roll orientation, the deck position and SOLO under the waveform; the cover and waveform in a slim row; the Music Understanding knobs without labels, the coloured knob is the lane, solo shows on the knob.
- PERFORM deck rolls open at 25 % zoom, horizontal.
- An MP3's own cover art shows on the PERFORM deck.
- Drop an MP3, its Music Understanding `.json` or a `.wgsl` anywhere on a deck, one to three files at once. While you drag, the deck shows where the drop goes and what it takes.
- TEMPO is one field in the global strip at the top of CREATE and PERFORM. Click it, then ↑ / ↓ for whole BPM, ← / → for hundredths, or type a value and press Enter. Double-click goes back to the master deck's own tempo.
- KEY LOCK is on when a deck opens.
- Every deck opens paused.
- The song info is one line: title · artist · BPM · key. If it is too long for its box it scrolls. The waveform still works under it: drag to seek, double-tap to load.
- The piano roll zoom is a field: click it, then ↑ / ↓ through 0, 25, 50, 75 and 100 (0 = closest, 100 = the whole song). Pinch and ctrl + wheel still zoom freely.
- PLAY / PAUSE keeps one width, so nothing beside it moves.
- CREATE: the global strip holds TEMPO and the position (bars.beats.sixteenths).
- CREATE: one controls row: PLAY, KEY LOCK, the roll zoom, the roll orientation and, at the far right, SOLO. LOOP is gone.
- CREATE: REC on a paused track records the whole track, start to end. On a playing track it records from where it is.
- CREATE on the website: the controls row sits under the music, and the cover and waveform are larger. The song info there stays the full panel (title, artist, label, year, copyright).
- The default Yobot Squint is sized as in the Halloween Bounce video.
- Known issue: hover help in the message bar can stop appearing in Chrome after switching to PERFORM. Clicking a control still shows its help.
- Known issue: on PERFORM, SOLO lights cyan; on CREATE it lights pink.

---

## V0.8.0

- KEY LOCK is now its own button beside LOOP, as on DJ hardware. The transport reads PLAY · LOOP · KEY LOCK · TEMPO.
- Load a track's Music Understanding file: drop its Sozo `.json` on the music row (or double-click the cover or waveform and pick it). The roll, readout, cue points and visuals switch to that track, and TEMPO goes to its BPM. Load its MP3 the same way, before or after; if the two lengths don't match, the message bar tells you.
- The readout shows the track's real key.
- For shader authors: the grid follows the shader's camera, in metres, stepping from 1 m / 10 cm down to 1 cm / 1 mm as the camera gets closer.
- For shader authors: everything is written in music time, bar.beat (62.1 = bar 62, beat 1).
- For shader authors: a shader file can pack its own song (MP3, cover, Music Understanding data), so it opens complete and can be shared as one file.

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
