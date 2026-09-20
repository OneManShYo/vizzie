# OMS Vizzie [Beta V0.1.0] — CLAUDE PROJECT INSTRUCTIONS

**Run date:** 2026-09-20
**Unix Epoch:** 1789910858
**App Version:** Vizzie Beta V0.1.0
**License:** GPL-3.0 (software)

How an AI (or dev) should work in the Vizzie project. Read this first. These rules were learned the hard way; follow them.

## WHAT VIZZIE IS
A single-file, browser-native, MUSIC-driven visualizer — the visual sibling of the OMS suite (with Chippy, Dojo, Sozo). Spelled **Vizzie** (V-I-Z-Z-I-E), the Cycling 74 Max/MSP spelling — always this spelling for the app. It reads an AMU sidecar and draws to the musical clock, as a circular visual and a vertical session-view timeline.

## CORE PRINCIPLES (do not violate)
- **AMU is the clock. Period.** Timing comes from the AMU musical timeline (bars/beats/sections), never frame count, rAF deltas as a time source, or RMS/FFT audio energy. If you reach for FFT/RMS/frame-time to drive visuals, you are wrong — start from AMU. "Audio-driven" = audio-played, not audio-timed.
- **Single file, zero dependencies.** No external fonts, frameworks, libraries, or network calls. All code and assets inline; runs offline from one HTML file. Only audio is uploaded at runtime. This is the app's identity — non-negotiable.
- **The visual is downstream.** It draws whatever the clock says. Frames are how it draws; music is what it reads.
- **One source of truth for shared state.** The solo bug came from logic scattered across many functions with drifting id vocabularies. Cross-cutting behavior (solo, and later the mapping contract) lives in ONE module that everyone routes through, with ONE canonical id per parameter (the lane id). Do not re-scatter it.
- **Read the code (and the OMS design system) before acting.** No guessing. Open it and look.
- **Follow the OMS Design System.** Inherit the shared tokens/classes (Chippy bundle): `.app`, `.header`, `.tabbar`, `.sec-hdr`, `.transport`, `.btn`, `#chartWrap`, `.summary`, `.message-bar`. Section headers are cyan `#00d4ff` and reserved for chrome; do NOT hand-roll parallel styles.
- **Color palette is deliberate.** The 13 parameter colors are chosen for maximum distinctness (hues spread around the wheel + white for beat). Timeline column and visual element share one color per parameter. Don't reintroduce near-duplicate hues.
- **The deliverable is the 7-doc A–Z bundle** (A_Deliverables, B_Complete_Changelog, C_Developer_Documentation, D_Release_Notes, E_UserGuide_All, Y_ClaudeProject_SystemReference, Z_ClaudeProject_Instructions) + the app HTML, inside a `V#.#.#_Deliverables/` folder. PM material (JSON + rebuild.py) is a SEPARATE hashtag-named bundle, never mixed in.
- **Verify before handing over.** Render the build in a real headless browser and screenshot it before presenting; do not ship blind. Layout/blank-canvas/id-mismatch bugs are caught by looking.

## THE C/Y SPLIT
C = "how it works" (prose, teaching). Y = "where is it" (identifier + one-line + pointer to C). Never let them drift into two competing copies. Explanation lives in C; identifiers live in Y.

## VERSIONING (OMS scheme)
- major.minor.iteration. The **3rd digit is a FEATURE**; **letters on the 3rd digit** (a/b/c…) are in-session working revisions to get that feature right. A NEW feature gets a new number, not a letter. The number only advances when Wes downloads/accepts. A full build/package ALWAYS rolls the MINOR (never packages on a lettered iteration); the last iteration seeds the new version and the prior iterations become its Iterations.
- App HTML uses underscores: `OMS_Vizzie_Beta_V#_#_#[letter].html`. Loose docs + bundle zips: build-tree artifacts = underscores (`..._Deliverables.zip`); loose viewable/PM docs = hashtags (`OMS#Vizzie#PM#...`).
- ITERATE the Unix epoch on every reissue (fresh `date +%s`); never reuse a stamp.

## PLATFORM REALITY
- iPad/iOS Safari has NO WebGPU — WGSL must be tested on MacBook Pro + desktop Chrome. Canvas 2D is the everywhere-portable renderer.
- iOS blocks running local HTML in Safari (file:// sandbox). Test on the Mac, or deliver the standalone HTML so Wes can launch it in the Claude UI on iPad.
- Deliver bundle files (zip) + the standalone HTML via the file interface — not the "publish artifact" flow.

## OPEN / NEXT
- Re-analyze more tracks with the full V2 AMU palette for real per-instrument data beyond the reference track.
- WGSL renderer (desktop Chrome primary).
- The contract/normalization layer ("any visual × any song") — a frozen normalized uniform set the visual reads instead of raw AMU; also the HTML↔Max portability boundary.
- User-facing AMU→visual mapping surface.

---

**END OF INSTRUCTIONS**
