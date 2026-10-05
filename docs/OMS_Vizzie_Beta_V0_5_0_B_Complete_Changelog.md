# OMS Vizzie app [Beta V0.5.0] Complete Changelog

**Run date:** 2026-10-05  
**Current Unix Epoch:** 1791240441  
**Filename:** OMS_Vizzie_Beta_V0_5_0_B_Complete_Changelog.md  
**App Version:** Vizzie Beta V0.5.0  
**License:** GPL-3.0 (software); embed assets see ABOUT menu  
**Purpose:** The readable version of the PM backlog: every closed BLOG, grouped by the release that packaged it, newest first, with the builds that carried it. Versions are major.minor.iteration; letters are in-session working revisions.  

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
