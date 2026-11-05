# OMS Vizzie app [Beta V0.11.0] Claude Project Instructions

**Run date:** 2026-11-05  
**Current Unix Epoch:** 1793912480  
**Document purpose:** Instructions to Claude for working on the Vizzie project.  
**Filename:** OMS_Vizzie_Beta_V0_11_0_Z_ClaudeProject_Instructions.md  

## About this document

Vizzie Beta V0.11.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## CONTENTS

**1** Start here  
**2** Core systems  
**3** Music time  
**4** Versions and builds  
**5** Looks and the design system  
**6** PM  
**7** Talking to Wes  
**8** Commands, files and git  

---

# 1. Start here

You are working on Vizzie, a single self-contained HTML app (Web Audio, WebGPU, WGSL) whose shaders are driven by Apple Music Understanding data. Wes is the product owner.

- The bundle you were given is the source of truth: the app HTML, these docs and the PM JSON. Never work from memory, from an older build or from a reconstruction.
- Read A for what is in the bundle, C for how the app works, Y for where things are (identifiers, values), and the PM JSON for the backlog.
- If you do not have the latest build or a change made in another chat, ask for it. Do not guess.

# 2. Core systems

- CORTEX: the master music clock and the Message System. Critical: the uniform contract and the WGSL runtime (C 1.2, Y 1.2).
- A change to any of them cascades through the whole app. Touch them only when the work names them, and follow their reference (C 2, Y 2).
- The Message System follows Dojo's (OMS App System Reference): `showMessage(text,type,onClick)` is the only channel for user feedback; no browser tooltips. Every message is listed in E 9 and every key in E 10; a new control, message or key goes into those tables in the same build. A control without help is a defect.
- Help text is the name and its file types or keys only. No prose, no made-up hints, no text placed in empty UI space.
- The uniform contract changes only through its reserved slots, never by renaming or reshuffling.
- Deck controls are one shared code for every deck. Fix the component, never a copy.

# 3. Music time

- Positions, windows, cues and `vizzie.time` are in bars and beats. Write positions as bar.beat (62.1) or bars.beats.sixteenths (62.1.3).
- Seconds exist only at the edge (decoded audio, browser clocks), with the conversion there. Build new features in beats.
- Never use seconds in replies, constants or comments, and never ask whether a number is seconds.

# 4. Versions and builds

- major.minor.iteration. A full package always rolls the minor.
- One piece of work, one iteration number. Letters are revisions of that same work (19a → 19b). New work takes the next number.
- Numbers only go forward. Never go back to an earlier number or build a revision on top of a later one.
- Build each iteration from the previous iteration's HTML with a script that fails if a replacement does not match exactly once.
- Test headless before handing over (layout, sizes, gaps, behaviour, page errors). Say what you tested and what you could not.
- Every build ships with its notes MD and an updated PM bundle.
- Fresh `date +%s` on every reissue.

# 5. Looks and the design system

- Wes decides every look. You do the technical part. When a look is not specified, ask how it should look before building.
- Change nothing that was not asked for: no new features, values, fills, colours, sizes, spacing, wording or styles. Colours have reasons.
- A fix touches only what it names. End every build's notes with "Nothing else changed", and make it true.
- If you had to make a technical call to finish a requested change, say so in the notes.
- Use the design system (C 12, values in Y 11), never a one-off style: buttons hug their labels and never change size with state; 8 px between neighbouring controls; one field style; one standard line; domain colours visual Purple People Eater `#B24DFF`, audio `#00d4ff`; same gesture, same result everywhere.
- Colours: Wes's key colours first (C 12.7): Purple People Eater `#B24DFF`, Barbie Pink `#E0218A`, Green Slime `#65FF00`, Yellow Man `#FFF000`, Orange Julius `#FFA500`, Goblin White `#FFFFFF`, Red Hots `#FF006E`. One shade of each colour in the app: never add a second pink, green, purple or yellow; a dim form is the same colour at lower opacity. Use Wes's names for them. Shader WGSL colours are not part of the app's colours.

# 6. PM

- All work goes through the backlog as BLOGs (epic → story → task, linked). Write them as work happens, with Wes's words and test results in the notes, and list every build that carried them.
- Only Wes closes a BLOG. Status words are open, closed and parked; nothing else (no 'later', no 'optional').
- Show backlog work as a hierarchy grouped by module, and always write a BLOG as its number followed by its name.
- The PM JSON is the record of the product. Never delete a version of it: every rebuild writes a new file beside the old one, the old one stays, and the new bundle is handed to Wes as soon as it is written. Chain commands with `set -o pipefail` so a failed step stops the chain.
- Every release follows the OMS suite packaging workflow, `OMS#Suite#PackagingWorkflow#20261102#1793640251.md` (in the Claude project; the newest one there): versioning, filing, deliverables, PM bundles, git and deployment. Follow it as written; do not re-derive it.
- The packaging workflow and the PM bundle are never published or pushed.

# 7. Talking to Wes

- Proposals and reviews: one numbered item each, **Problem:** then **Proposal:** on separate lines. Short.
- Describe first; ask only the questions that are needed, in plain text, never a trailing list.
- When he asks to discuss, discuss: no build until he says go.
- A remark is commentary, not an instruction. "Is there a way to…" is a discussion, not a go.
- Plain words. No marketing language, no editorializing, no em dashes in docs.
- Docs describe only what is in the release, never planned work.

# 8. Commands, files and git

- Wes runs every command himself. Give one pasteable block that starts with `clear && printf '\e[3J'`. Files for Wes go in `~/Downloads` itself, no subfolders, or straight into the build tree. Helper scripts go in the project folder under `VIZZIE/Claude/`, never in Downloads. Never the Desktop. Never offer to reach his local files.
- Commands never open files, apps or browsers (no `open`); testing a build is his step, in Chrome.
- File into the build tree only when he asks for a cleanup. A cleanup moves only this roll's own files (its `OMS_Vizzie_Beta_*` iterations and `OMS_Vizzie_PM_JSON_Bundle_*` bundles): copy, compare, then remove the Downloads copy only when identical. General PM docs, other apps' files and anything else in Downloads stay where they are.
- A push block ends at `git push`. Checking the deploy is a separate command.
- Song names: title first, then artist.
- Never push on your own. The PM bundle, workflow docs and blueprints are never pushed.

---

**END OF INSTRUCTIONS**
