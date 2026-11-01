# OMS Vizzie app [Beta V0.9.0] Claude Project Instructions

**Run date:** 2026-11-01  
**Current Unix Epoch:** 1793543222  
**Document purpose:** Instructions to Claude for working on the Vizzie project.  
**Filename:** OMS_Vizzie_Beta_V0_9_0_Z_ClaudeProject_Instructions.md  

## About this document

Vizzie Beta V0.9.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

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
- The Message System follows Dojo's (OMS App System Reference): `showMessage(text,type,onClick)` is the only channel for user feedback; no browser tooltips.
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
- Use the design system (C 12, values in Y 11), never a one-off style: buttons hug their labels and never change size with state; 8 px between neighbouring controls; one field style; one standard line; domain colours visual `#aa00ff`, audio `#00d4ff`; same gesture, same result everywhere.

# 6. PM

- All work goes through the backlog as BLOGs (epic → story → task, linked). Write them as work happens, with Wes's words and test results in the notes, and list every build that carried them.
- Only Wes closes a BLOG. Parked work stays open, marked parked with the reason.
- Every release follows the OMS suite packaging workflow, `OMS#Suite#PackagingWorkflow#20260906#1788700567.md` (in the Claude project): versioning, filing, deliverables, PM bundles, git and deployment. Follow it as written; do not re-derive it.
- The packaging workflow and the PM bundle are never published or pushed.

# 7. Talking to Wes

- Proposals and reviews: one numbered item each, **Problem:** then **Proposal:** on separate lines. Short.
- Describe first; ask only the questions that are needed, in plain text, never a trailing list.
- A remark is commentary, not an instruction. "Is there a way to…" is a discussion, not a go.
- Plain words. No marketing language, no editorializing, no em dashes in docs.
- Docs describe only what is in the release, never planned work.

# 8. Commands, files and git

- Wes runs every command himself. Give one pasteable block that starts with `printf '\033[3J\033[H\033[2J';`. Never offer to reach his local files.
- File into the build tree only when he asks for a cleanup.
- Never push on your own. The PM bundle, workflow docs and blueprints are never pushed.

---

**END OF INSTRUCTIONS**
