# OMS Vizzie app [Beta V0.8.0] Claude Project Instructions

**Run date:** 2026-10-31  
**Current Unix Epoch:** 1793469710  
**Filename:** OMS_Vizzie_Beta_V0_8_0_Z_ClaudeProject_Instructions.md  
**App Version:** Vizzie Beta V0.8.0  
**License:** GPL-3.0 (software); embed assets see ABOUT menu  
**Purpose:** How Claude works with Wes in the Vizzie project.  

---

## CONTENTS

**1** What is Vizzie?  
**2** Product management (PM)  
&emsp;2.1 PM JSON  
&emsp;2.2 Packaging workflow  
**3** Working with the product owner  
&emsp;3.1 Proposals and reviews  
&emsp;3.2 Versioning, naming and iterations  
&emsp;3.3 Music time first  

---

# 1. What is Vizzie?

Vizzie is a self-contained HTML application that uses the Web Audio API, WebGPU and WGSL shaders to create music visualizers. The shaders are driven by 12 parameters of information from Apple's Music Understanding framework. The Music Understanding framework data is created by the Sozo sidecar utility app.

# 2. Product management (PM)

## 2.1 PM JSON

The PM record is `OMS#Vizzie#PM#<YYYYMMDD>#<epoch>.json`, shipped in the PM bundle with its rebuild script. It holds the PM rules, the product backlog and the context canon.

### 2.1.1 Product backlog items (BLOGs)

All work goes through the backlog as BLOGs. Write BLOGs into the PM JSON as work happens. Owner (Wes) closes items; Claude does not close on its own unless the go covered it. Every BLOG lists the builds that carried it.

Each BLOG has a `type` (epic, story or task) and `linked_blogs`, a symmetric list of related BLOGs; the direction (epic → story → task) comes from the types (PM rules 1.2). Example: BLOG0064 is the PERFORM epic; its stories include BLOG0071, whose tasks were BLOG0082 to BLOG0086.

## 2.2 Packaging workflow

Packaging follows the OMS suite packaging workflow, `OMS_Suite_PackagingWorkflow_20260906_1788700567.md`: versioning, iterations, filing, deliverables, PM bundles, git and deployment. It is the release process; do not re-derive it.

# 3. Working with the product owner

## 3.1 Proposals and reviews

Go in order, one item per block: **Problem:** line, line break, **Fix/Proposal:** line. No blobs of prose, no splitting one item across sections. Keep it short.

## 3.2 Versioning, naming and iterations

- major.minor.iteration. Iterations: `V0.3.01, 02 …`; letters (a/b/c) are throwaway in-session revisions; the finished item drops the letter and takes the next clean number. A full build/package ALWAYS rolls the MINOR; the iteration line becomes that release's Iterations.
- A new iteration number only when a new change starts; every revision of that same change moves the letter (`19a` → `19b`), never the number.
- App HTML: `OMS_Vizzie_Beta_V#_#_#.html` for a package, `OMS_Vizzie_Beta_V#_#_##[letter].html` for an iteration (e.g. `OMS_Vizzie_Beta_V0_4_01a.html`). Versions use dots in text/folders (`V0.5.0`), underscores inside underscore filenames.
- Shaders: `OMS_Vizzie_Shader_<Name>_V##.wgsl`, made with the Vizzie shader authoring workflow (`OMS_Vizzie_ShaderTemplate`, a paired `.html` + `.wgsl`). Library: `VIZZIE/App Folder/Library/Shaders/`, one folder per shader.
- Loose docs: underscore name + date + epoch (e.g. `OMS_Vizzie_Beta_V0_3_0_Shader_Contract_Normalization_<YYYYMMDD>_<epoch>.md`), with **Run date** and **Current Unix Epoch** lines under the title. PM bundle: `OMS#Vizzie#PM#Bundle#<YYYYMMDD>#<epoch>.zip`.
- Fresh `date +%s` on every reissue; never reuse a stamp.

## 3.3 Music time first

Vizzie is music-timing core: positions, windows, cues and the shader's `vizzie.time` are in bars and beats. Seconds appear only at the edge where the computer world needs them (decoded audio, browser clocks), and the conversion lives there. New features are built in beats, not converted from seconds. Positions are written bar.beat (62.1 = bar 62, beat 1); never ask whether a number is seconds (template RULES R11).

---

**END OF INSTRUCTIONS**
