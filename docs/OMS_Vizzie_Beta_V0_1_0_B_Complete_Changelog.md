# OMS Vizzie [Beta V0.1.0] — COMPLETE CHANGELOG

**Run date:** 2026-09-20
**Unix Epoch:** 1789910858
**App Version:** Vizzie Beta V0.1.0
**License:** GPL-3.0 (software)
**Purpose:** Full version history of Vizzie, newest first. Published as V0.1.0; the third digit marks a feature, letters mark in-session working revisions.

---

## V0.1.0 — First published release

The first public release of Vizzie, published to vizzie.onemanshyo.com. Packages the entire V0.0.x development line (BLOG0001–0023): the AMU-driven visual, session-view vertical timeline, waveform, solo, full distinct color system, transport (loop + end reset), native-resolution pop-out, and the MUSIC / ABOUT / LEARN tabs. Also in this release:
- **LEARN tab simplified (V0_0_21a/21b).** Stripped to a single General statement pointing to the learn section on onemanshyo.com, with a clear CLICK HERE button; the inline resource lists now live on the website.

Everything below is the V0.0.x development history, newest first.

---

## The V0.0.x development line

Vizzie's origin line, built in a single extended session and its follow-ups. Grouped by feature (the numbered iteration), newest first.

### 20 — Pop-out corner icon (V0.1.0)
- Replaced the text pop-out button overlaying the visual with a small, subtle expand icon in the top-right corner (50% opacity, brightens on hover). Same pop-out-window behavior.

### 19 — Color system (V0_0_19a → 19d)
- **Rainbow bus headers.** The six group headers colored ROY-G-B-V (RHYTHM red, STRUCTURE orange, KEY yellow, PACE green, LOUDNESS blue, INSTRUMENTS violet), indigo skipped, and restyled as solid-filled pills with dark knocked-out text — a distinct tier above the outlined lane chips.
- **Distinct lane palette.** Replaced the ad-hoc lane colors (which collided — key/other identical, two greens, two yellows, dark-on-black mud) with 12 bright, pairwise-distinct hues + white for beat.
- **Every parameter has a visual element.** Gave section, segment, pace, loudness, and key real bold, color-matched elements in the visualizer (loudness meter ring, pace gauge, section arc+wedge, key wheel) so soloing any of the 13 isolates a clearly visible colored thing; matched visual colors to their lane columns.

### 18 — Loop (V0_0_18a)
- Added a LOOP control in the transport (after PLAY); when on, playback returns to the start and keeps going instead of stopping at the end.

### 17 — End-of-track reset (V0_0_17a)
- When a loaded track finishes, the playhead returns to zero and the transport resets to PLAY, so spacebar (or the button) restarts it from the top.

### 13 — The visual + solo (V0_0_13a → 13f)
- **Rectangular full-canvas visual.** Replaced the small centered circle with a circle whose diameter tracks the canvas WIDTH, so it fills the frame and overflows top/bottom — a wheel seen through the viewport — keeping the flat Canvas-2D aesthetic. Every one of the 13 AMU parameters is a concentric, color-matched layer: beat pulse/dots, bar spokes, section arc, phrase satellites, segment counter-ring, pace outer energy ring, loudness driving the whole-field breathing radius, key tint ring + label, and four instrument-activity rings.
- **Distinct 13-color palette.** Replaced ad-hoc hexes (several too close to tell apart) with 12 hues spaced evenly (~17°+) around the wheel plus white for beat; OMS chrome cyan preserved, section param given a distinct brighter cyan.
- **Solo, centralized.** Click a column chip to solo one parameter, a group header to solo a whole bus; solos are additive (stack multiple), each toggles independently, and a master SOLO button in the transport lights when any is active and clears all at once. Soloed elements keep color; everything else goes monochrome dark-gray but keeps moving. Rebuilt onto ONE `SOLO` module (single source of truth) after a scattered first cut misbehaved.
- *Fixed:* the solo bug — logic had been spread across ~6 functions with two mismatched id vocabularies (the visual keyed `rhythm.beats` while solo keyed the lane id `beats`), so visual mutes silently never matched. One module, one canonical id per parameter, all consumers routed through it.

### 11 — Session-view vertical timeline (V0_0_11a)
- Converted the horizontal timeline to a vertical, Ableton-Session-View / tracker layout: the 13 parameters became columns under a top group-header row, time runs top→bottom, the playhead is a horizontal line sweeping down, and scrubbing is vertical (snaps to bar). Vertical scroll removes the left/right screen-space limit and matches the OMS/tracker orientation.

### 10 — Waveform view (V0_0_10a → 10c)
- Added a **waveform** section above the timeline in its own container. A dimmed illustrative envelope shows before audio loads (with a centered "upload audio to view waveform" box); on upload it decodes the file and draws the real RMS waveform (pow-0.7 compression, blue bars), bar-aligned, playhead synced to the AMU clock.
- Slimmed the transport (removed the UPLOAD AUDIO button; the waveform box is now the click-to-upload target) and swapped section order so WAVEFORM sits above TRANSPORT.

### 9 — App surface: INFO, data, messaging, tabs (V0_0_9a → 9k)
- **Full V2 AMU data** drives every lane: section/segment/phrase blocks, key span, pace step curve, loudness LUFS curve, and per-stem (drum/bass/vocal/other) activity curves + ranges. *Fixed:* a field-name mismatch (`rhythm.bpm` vs `beatsPerMinute`) that made every plot coordinate NaN and blanked the lanes.
- **INFO section** in the OMS summary layout — a song box (cover art + title/artist/label/released/links/copyright, from the Sozo sidecar viewer) and the live visual in its own box. (A middle monitor box was added then removed as redundant with the timeline, leaving two boxes.)
- **OMS message system** — hover hints (cyan), action messages (orange), errors (magenta); every section label, control, and lane wired.
- **UX polish** — spacebar play/pause, VISUAL tab renamed MUSIC, inline status text removed (it lives in the message bar), and an ABOUT tab/panel adapted from the Chippy structure.

### 6 — OMS design system (V0_0_6a)
- Rebuilt inside the shared OMS design system (from the Chippy V1.16.0 bundle): the `.app` shell, header with the Yobot squint logo + favicon, tab bar, cyan `.sec-hdr` section dividers, transport strip, chart frame, and the message-bar footer. Dropped the standalone parameter pills.

### 5 — Timeline (V0_0_5a → 5c)
- A full-width timeline below the visual: AMU structure blocks + bar ticks + playhead, drag to scrub (snaps to bar). Grew from a single strip into the multi-lane parameter grid that later became the columns.

### 1–4 — Origin (V0_0_1a → 4b)
- The core: an AMU-driven visual in one self-contained HTML, the clock riding the musical timeline (self-advancing with a chiptune metronome when no audio is loaded, or riding uploaded audio). Every AMU field wired to a distinct visual element. An early per-parameter pill readout (later replaced by the timeline).

---

**END OF CHANGELOG**
