# OMS Vizzie app [Beta V1.7.0] Claude Project Instructions

**Run date:** 2026-11-26  
**Current Unix Epoch:** 1795695763  
**Document purpose:** Instructions to Claude for working on the Vizzie project.  
**Filename:** OMS_Vizzie_Beta_V1_7_0_Z_ClaudeProject_Instructions.md  

## About this document

Vizzie Beta V1.7.0. License: GPL-3.0 (software); embedded assets, see the ABOUT menu.

---

## CONTENTS

**1** Start here  
**2** Core systems  
**3** Music time  
**4** Versions and builds  
**5** Looks and the design system  
**6** PM  
**7** Working with the product owner  
**8** Commands, files and git  

---

# 1. Start here

You are working on Vizzie, a single self-contained HTML app (Web Audio, WebGPU, WGSL) whose shaders are driven by Apple Music Understanding data. A human product owner leads the work.

- The bundle you were given is the source of truth: the app HTML, these docs and the PM JSON. Never work from memory, from an older build or from a reconstruction.
- Read A for what is in the bundle, C for how the app works, Y for where things are (identifiers, values), and the PM JSON for the backlog.
- If you do not have the latest build or a change made in another chat, ask for it. Do not guess.

# 2. Core systems

- CORTEX: the master music clock and the Message System; since V1.5.01d (BLOG0368) the AUTO MIX audio core is locked with the clock (C 2.1.3a): it changes only on the product owner's go on a written spec, after the regression baseline. Critical: the uniform contract and the WGSL runtime (C 1.2, Y 1.2).
- A change to any of them cascades through the whole app. Touch them only when the work names them, and follow their reference (C 2, Y 2).
- The Message System follows Dojo's (OMS App System Reference): `showMessage(text,type,onClick)` is the only channel for user feedback; no browser tooltips. Every message is listed in E 6 and every key in E 7; a new control, message or key goes into those tables in the same build. A control without help is a defect.
- Help text is the name and its file types or keys only. No prose, no made-up hints, no text placed in empty UI space.
- The uniform contract changes only through its reserved slots or an additive binding, never by renaming or reshuffling (binding 2, the AMU span tables, V1.3.28a, used slots 5, 15 and 22).
- Deck controls are one shared code for every deck. Fix the component, never a copy.
- One behaviour, one code path: before adding a special case for one surface, source or loader, route it through the code that already does it. If it cannot be shared, the notes say why.
- Everything starts in Vizzie (public, GPL) unless it cannot be built there; Mezcla is the native version and ports from Vizzie. Bugs Mezcla finds come back through the product owner.
- Hardware (two Midi Fighter Twisters, C 8.15, F sheet 12): MIDI carries frequent performance actions; a push that opens a drawer changes nothing; no double push where the first push would cause a dropout; MFB mirrors MFA. A hardware report is reproduced on the build it was found in, with a test shaped like the device, before it is fixed. Twister changes are drawn on a grid with MFA / MFB column-row names.
- AUTO MIX runs the mix and makes no mixing choices; the SELECTA's numbered parameters decide it (C 7.10). A product owner statement about one SELECTA's value is that SELECTA's parameter, never an AUTO MIX, clock or app rule (BLOG0365). Parameter IDs are numbers with a fixed meaning: never renumber or reuse one; a new parameter takes a new ID. When proposing a change to a table of parameters or values, show the full current table first.
- A load onto a playing deck stops it and loads stopped at 1.1.1; Vizzie does no hot load (an HTML limit; Mezcla does it).
- Tab names (V1.4.22a): PLAY (was CREATE), CREATE (was AUTHORING, its mode AUTHOR), PERFORM. Code names are unchanged (`lab`, `author`, `public`, `authoring`), and older code comments use the old names.
- Three decks, one global, as Ableton's channels: PLAY's deck (PLAY, CREATE, Pocket Rave), PERFORM Deck A and PERFORM Deck B each have their own track, audio, play state, shader and FX; tempo, clock, QUANT and the master bus are global. Nothing passes between decks except through the global layer.
- Performance: optimize the shader before changing the app. A slow or dropping shader is fixed in the shader first (work a value out once per frame or pixel, not per loop; binary search over span-table rows; bound every stage and piece); an app change (an offline render, the clock's step cap) is not made just because it can be (the StarshipGo finding, BLOG0323, BLOG0324).
- The music never bends to the picture: the audio clock is the clock of record. Steering (`steerDeck`, BLOG0084) keeps each deck's audio on the clock; during an AUTO MIX it is off for both decks (AUTO MIX Lock, C 7.10). A clock change is tested on the product owner's Mac before it is kept: headless tests do not show what Chrome does to the visuals there (V1.4.27a, pulled).

# 3. Music time

- Positions, windows, cues and `vizzie.time` are in bars and beats. Write positions as bar.beat (62.1) or bars.beats.sixteenths (62.1.3).
- Seconds exist only at the edge (decoded audio, browser clocks), with the conversion there. Build new features in beats.
- Never use seconds in replies, constants or comments, and never ask whether a number is seconds.
- Rule R24 (template, V1.3.32a, 32b): every animation in a shader (motion, cycles, loops, pulses, decays, spawns, camera moves, colour changes, reveals) moves on AMU and music time: `vizzie.time` in beats, beat and bar phase, section, segment and phrase, the gates and lanes, the span tables. Never seconds, minutes, frame counts or a free-running clock, and beats are never converted to seconds. Every timing is a ratio of the music clock (the beat, a subdivision, or a polyrhythm across beat, bar or phrase) that realigns and never drifts.
- Never swap in real-world maths on your own because it might look better: say so and ask. An exception exists only when a limitation is discussed with the product owner and agreed, and it is written into the shader's NOTES.
- Selection by the music (the busiest sections, what comes next, a count that follows each section) reads the span tables (R23, C 2.2.6), never bar positions or one song's numbers, so one shader works on every song.

# 4. Versions and builds

- major.minor.iteration. A full package always rolls the minor.
- Every iteration build carries a letter (V1.1.06a). One piece of work, one iteration number; letters are revisions of that same work (19a → 19b). New work takes the next number.
- A build already handed over is never renamed or re-issued: a numbering mistake is fixed going forward.
- Numbers only go forward. Never go back to an earlier number or build a revision on top of a later one.
- Build each iteration from the previous iteration's HTML with a script that fails if a replacement does not match exactly once.
- Test headless before handing over (layout, sizes, gaps, behaviour, page errors). Say what you tested and what you could not.
- Every build ships with its notes MD and an updated PM bundle.
- Fresh `date +%s` on every reissue.

# 5. Looks and the design system

- The product owner decides every look. You do the technical part. When a look is not specified, ask how it should look before building; a new or changed UI is mocked first and built after the go.
- A new or changed drawer, panel or control is checked against C 12 and Y 11 before it is handed over (knob modules, spacing, labels): the design system is Claude's to hold, not the product owner's to catch (BLOG0379).
- Labels are short (four or five letters where they can be); the full name is in the message bar.
- Change nothing that was not asked for: no new features, values, fills, colours, sizes, spacing, wording or styles. Colours have reasons.
- A fix touches only what it names. End every build's notes with "Nothing else changed", and make it true.
- If you had to make a technical call to finish a requested change, say so in the notes.
- Use the design system (C 12, values in Y 11), never a one-off style: buttons hug their labels and never change size with state; 8 px between neighbouring controls; one field style; one standard line; domain colours visual Purple People Eater `#B24DFF`, audio `#00d4ff`; same gesture, same result everywhere.
- Colours: the product owner's key colours first (C 12.7): Purple People Eater `#B24DFF`, Barbie Pink `#E0218A`, Green Slime `#65FF00`, Yellow Man `#FFF000`, Orange Julius `#FFA500`, Goblin White `#FFFFFF`, Red Hots `#FF006E`. One shade of each colour in the app: never add a second pink, green, purple or yellow; a dim form is the same colour at lower opacity. Use the product owner's names for them. Shader WGSL colours are not part of the app's colours.

# 6. PM

- All work goes through the backlog as BLOGs (epic → story → task, linked). Write them as work happens, with the product owner's words and test results in the notes, and list every build that carried them.
- Only the product owner closes a BLOG. Status words are open, closed and parked; nothing else (no 'later', no 'optional', no 'waiting on', no 'new'). When BLOGs are put to the product owner, each shows its number, title and a one-line description of what it is.
- Show backlog work as a hierarchy grouped by module, and always write a BLOG as its number followed by its name.
- A PM recap is made by the product owner's script, never by hand: `python3 OMS_Suite_PM_Recap.py <PM JSON> "Vizzie" "OMS Vizzie" "<build>"`, as the Suite PM Recap doc sets it (`OMS#Suite#PM#Recap#<date>#<epoch>.md`, the newest): SUMMARY, then BACKLOG with its filter, then one table per area and module with the columns BLOG | Title | Description | BIC | Status. Tables, no bullets, never a narrative. Every BLOG carries its BIC (ball in court: whose move it is; empty when closed). At a release review the PM item is this recap.
- "Done" from the product owner on a BLOG means close it, in the same bundle.
- The PM JSON is the record of the product. Never delete a version of it: every rebuild writes a new file beside the old one, the old one stays, and the new bundle is handed to the product owner as soon as it is written. Chain commands with `set -o pipefail` so a failed step stops the chain.
- Every release follows the OMS suite packaging workflow, `OMS#Suite#PM#PackagingWorkflow#<date>#<epoch>.md` (the newest one): versioning, filing, deliverables, blueprints, PM bundles, git and deployment. Follow it as written; do not re-derive it.
- The Suite PM is a set of reference docs kept offline, outside the project: not instructions, available on request. They include the packaging workflow and the Suite authoring guides for content, music and visuals, all named `OMS#Suite#PM#<Name>#<date>#<epoch>.md` (the newest of a name wins). When something is not in the project docs, ask the product owner whether a Suite PM doc covers it before guessing.
- A release does every pre-packaging step (the workflow's §4A, blueprints included) before the product owner reviews anything, then one review, one item at a time, before the push. File and bundle names come only from the workflow's templates; never invent one.
- "Push" alone never means the fast push (the workflow's §6.5). When features changed since the last tag, or the product owner asks for the deliverable with the push, it is the full roll as the next minor.
- Never published or pushed, by name (two kinds):
  1. Suite PM docs: `OMS#Suite#PM#<Name>#<date>#<epoch>.md`, any `<Name>` (the packaging workflow, `OMS#Suite#PM#PackagingWorkflow#<date>#<epoch>.md`, is one).
  2. The app's PM bundle: `OMS_<App>_PM_JSON_Bundle_<date>_<epoch>.zip`, the same pattern for every app; for Vizzie `OMS_Vizzie_PM_JSON_Bundle_<date>_<epoch>.zip`, with `OMS_Vizzie_PM_JSON_<date>_<epoch>.json` and `OMS_Vizzie_PM_rebuild.py` inside it.
  Only the release bundle goes to the Pub: the app as `index.html` and the Deliverables (A to F, Y, Z) in `docs/`, beside the site's `examples/` and `yodega/` folders; a roll never writes to `yodega/`.
- Beam Me Up (BLOG0403; Yodega, BLOG0326): the product owner's own content (sets, songs with their AMUs, shaders, playlists) reaches the site's `yodega/` folder only through Beam Me Up, one command: `python3 "<Suite>/VIZZIE/App/BeamMeUp/beam_me_up.py" <published folder> --write --push` (plan alone without `--write`). It checks every file against the app's rules, mirrors the published folder into `yodega/` (removed there means removed live), writes `yodega/beammeup_index.json` and a page per set, song and shader, pushes content only (YP-0001 and up, from git log) and checks the live site on every run, every file ever removed included. Content only, never an app build, one-way, `examples/` untouched.
- Security audit and coverage results go in chat only, never into a file.
- Never change the product owner's system (workflow rules, naming, numbering, folders) unasked. When something slips through, it is fixed going forward and written into the PM JSON rules as a rule, so it is not done again; there is no change log. Every full build opens a documentation BLOG listing what changed in the docs.
- Sets have one file format, OMS set schema version 2 (C 8.10); only schema 2 loads, nothing is converted, and every OMS tool writes it. Mezcla follows Vizzie.

# 7. Working with the product owner

- Proposals and reviews: one numbered item each, **Problem:** then **Proposal:** on separate lines. Short.
- Describe first; ask only the questions that are needed, in plain text, never a trailing list.
- When he asks to discuss, discuss: no build until he says go.
- A remark is commentary, not an instruction. "Is there a way to…" is a discussion, not a go.
- Plain words. No marketing language, no editorializing, no em dashes in docs.
- Docs describe only what is in the release, never planned work.
- Words: music and visual, never video, VID or AUD (BLOG0301).
- Do not make up what the product owner means by a word or a name: ask.
- When naming a part of the app in an explanation, give its code name and the BLOG and build that brought it in, and say whether it is existing or new; draw the structure (a tree, or a table of existing and new) before explaining a change to it.
- When the product owner is on an iPad he cannot download: hold files until he asks for them.
- A change is for PLAY only unless the product owner names another tab. 'Link' names PERFORM's mixer LINK and Ableton Link only.
- A statement is not widened into a rule: one value for one case stays one value for one case.

# 8. Commands, files and git

- The product owner runs every command himself. Give one pasteable block that starts with `clear && printf '\e[3J'`. A block that works in a repo or folder starts by changing to that folder's full path and runs only if that worked; never assume the terminal is where an earlier block left it. Deliverables for the product owner (builds, notes, PM bundles) go in `~/Downloads` itself or straight into the build tree. Claude's own working files go under `~/Downloads/zClaude/<project>/`, never loose in Downloads. A production tool (one the product owner keeps running, such as Beam Me Up) lives under the app, where its feature belongs: `<Suite>/<APP>/App/<Feature>/`, with a README; never under `zClaude`. The archive folder is `zArchive` (lowercase z, capital A). The `#BeamMeUp` folder is an inbox like Downloads: Vizzie files in it are filed to the same places; nothing is copied into it and nothing else in it is listed. Never the Desktop. Never offer to reach his local files.
- A message that hands over files opens with a line saying there is a download; the file cards can come at the end.
- Commands never open files, apps or browsers (no `open`); testing a build is his step, in Chrome.
- Filing follows the packaging workflow (its 3.5 and 3.8): the newest build and the newest PM bundle stay in Downloads for the product owner and are also filed; older ones are filed (copy, compare, then remove the Downloads copy only when identical). A filing block checks the files are there before it moves anything. It moves only this roll's own files (`OMS_Vizzie_Beta_*` iterations, `OMS_Vizzie_PM_JSON_Bundle_*` bundles) that were made in the chat doing the filing; general PM docs, other apps' files and anything else in Downloads stay where they are.
- A push block ends at `git push`. Checking the deploy is a separate command.
- Song names: title first, then artist.
- In code, a note in the middle of a line is `/* */`, never `//` (a `//` swallows the rest of the line: BLOG0304).
- Never push on your own. The PM bundle and workflow docs are never pushed. The blueprints are published as F from V1.0.0 on: `_F_Blueprints.html`, the editable source, and `_F_Blueprints.pdf`, printed from it. Revise the HTML, then re-print the PDF.

---

**END OF INSTRUCTIONS**
