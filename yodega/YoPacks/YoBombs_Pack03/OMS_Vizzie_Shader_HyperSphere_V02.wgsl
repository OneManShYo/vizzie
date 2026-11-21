// OMS_Vizzie_Shader_HyperSphere_V02.wgsl
// @title Hyper Sphere
// @author Wes Smith, Claude, CodeParade [YouTube]
// @type visualizer
// @desc a mashup of Sphere Stereo and Hyper Stereo: an endless zoom, each world's centre tile holding the other
// Hyper Sphere: one {4,Q} tiling in stereographic projection whose curvature morphs: Q = 3 is the cube on the sphere (Spherical
// Stereo), Q = 4 the flat square grid, Q = 5 the hyperbolic {4,5} in the Poincaré disk (Hyperbolic Disk). The mirror circle is a
// generalised circle a|z|² - 2x + b = 0 through the fixed edge midpoint (HS_M, 0), so the centre tile keeps its size, and the
// curvature is k = -a / b: the disk's rim grows out to infinity as k reaches 0, then the plane closes up into the sphere.
// Mashup of OMS_Vizzie_Shader_SphericalStereo_V02 and OMS_Vizzie_Shader_HyperbolicDisk_V03.
// Reference: CodeParade [YouTube], "Non-Euclidean Geometry Explained - Hyperbolica Devlog #1".
// Zoom (V02): an endless zoom, like a Mandelbrot dive (a Droste loop): the centre tile of every world holds a round window
// (HS_WIN) onto the other world, HS_S times smaller; the view zooms in by HS_S every zoom cycle, so the window fills the frame and
// the picture is exactly where it started, one world deeper. Worlds alternate: sphere, hyperbolic, sphere, ... Never zooms out.
// Speed: one world per 4 bars, two per 4 bars in a section whose pace is in the song's top third.
// Loop: 4 bars (motion within a section; the dive and morph follow the sections)
// Music (every AMU lane, each gated by its knob x REACT): beat: edge kick · bar: the zoom cycle, a slow steady turn (a quarter
//   per 4 bars) · section: zoom speed (its pace), palette shift · segment: palette order · phrase: Möbius drift of each world's
//   tiles, new heading each phrase · key: tonic turn and palette shift, mode sets the turn direction · loudness: edge weight ·
//   drums: edge pulse · bass: Möbius slide (BREATH) · vocal: palette steps every beat · build: two turns · drop: checkerboard flip
// V01 (2026-11-21, Wes): first build, on OMS Vizzie [Beta V1.4.19a].
// V02 (2026-11-21, Wes): never zooms out: an endless zoom with each world's centre tile holding the other (replaces the dive and
// the curvature morph) · the per-beat twist removed (the other-lane wobble, and the eased quarter turn on every bar, now one steady
// quarter turn per 4 bars) · the loudness zoom removed.
// Run date: 2026-11-21
// Vizzie uniform contract (V0.5.0A): binding 0 = 9 x vec4 (36 floats); binding 1 = settings, 16 x vec4; binding 2 = AMU span tables. No image bindings.
struct U { v: array<vec4<f32>, 9>, };
@group(0) @binding(0) var<uniform> u: U;
@group(0) @binding(1) var<uniform> settings: array<vec4<f32>, 16>;

// ---- AMU SPAN TABLES (V1.3.28a): binding 2, one table per lane (0 section, 1 segment, 2 phrase, 3 bar, 4 pace) ----
struct AmuRow { pos: vec4<f32>, avg: vec4<f32>, norm: vec4<f32>, loud: vec4<f32>, rank: vec4<f32>, lvl: vec4<f32>, };
struct AmuTable { head: array<vec4<f32>, 4>, rows: array<AmuRow>, };
@group(0) @binding(2) var<storage, read> amuT: AmuTable;
fn amuRow(lane: u32, i: i32) -> AmuRow {   /* lane 0 to 4; i clamped to the lane's rows */
  let h = amuT.head[lane / 2u];
  let odd = (lane % 2u) == 1u;
  let first = select(h.x, h.z, odd);
  let n = select(h.y, h.w, odd);
  var r: AmuRow;
  if (n < 1.) { return r; }
  return amuT.rows[u32(first) + u32(clamp(i, 0, i32(n) - 1))];
}

// ---- SETTINGS: the template's standard fourteen (R13), settings[0] to settings[3] ----
// @setting SCALE settings[0].x 0.25 4 0.05 1 | zoom the whole frame
// @setting ROTATION settings[0].y -180 180 1 0 | turn the whole frame, degrees
// @setting OFFSET_X settings[0].z -1 1 0.01 0 | move the frame left / right, half-heights
// @setting OFFSET_Y settings[0].w -1 1 0.01 0 | move the frame up / down, half-heights
// @setting PIVOT_X settings[2].x -1 1 0.01 0 | centre of ROTATION and SCALE, left / right, half-heights
// @setting PIVOT_Y settings[2].y -1 1 0.01 0 | centre of ROTATION and SCALE, up / down, half-heights
// @setting TILE settings[2].z 1 8 1 1 | repeat the frame, tiles across and down
// @setting TIME_OFFSET settings[2].w 0 32 0.25 0 | slide the motion along the music clock, beats
// @setting SPEED settings[1].x 0 4 0.05 1 | how fast the shader moves on the music clock
// @setting REACT settings[1].y 0 1 0.05 1 | how strongly the AMU lanes drive it
// @setting HUE settings[1].z 0 1 0.01 0.5 | Hue/Saturation/Value node: hue (0.5 = none)
// @setting SATURATION settings[3].x 0 2 0.05 1 | Hue/Saturation/Value node: saturation (0 = grey, 1 = as is)
// @setting VALUE settings[1].w 0 2 0.05 1 | Hue/Saturation/Value node: value (1 = as is)
// @setting CONTRAST settings[3].y 0 2 0.05 1 | Bright/Contrast node: contrast (1 = as is)
// frame: TILE, then p' = rotate(-ROTATION) * (p - OFFSET - PIVOT) / SCALE + PIVOT · clock: vizzie.time × SPEED + TIME_OFFSET · lanes: every gate × REACT · last: the HSV node, then contrast
// ---- SETTINGS: this shader's own (Wes, 2026-11-21), settings[4], row 3 ----
// @setting EDGE settings[4].z 0 0.1 0.005 0.03 | edge width, in the tiling's own frame (the edges thin where tiles shrink)
// @setting BREATH settings[4].w 0 0.6 0.01 0.25 | bass: depth of the Möbius slide, back to centre at every bar line
fn stdFrame(p0: vec2<f32>, asp: f32) -> vec2<f32> {
  let n = max(round(settings[2].z), 1.); let hf = vec2(asp, 1.);
  var p = p0; if (n > 1.) { p = (fract((p0 * n + hf) / (2. * hf)) * 2. - 1.) * hf; }   // TILE: each tile shows the whole frame
  let piv = settings[2].xy; let a = -settings[0].y * 0.01745329; let c = cos(a); let s = sin(a);
  let q = (p - settings[0].zw - piv) / max(settings[0].x, 1e-3);
  return vec2(c * q.x - s * q.y, s * q.x + c * q.y) + piv; }
fn stdHSV(c: vec3<f32>) -> vec3<f32> {   // Blender's Hue/Saturation/Value node: hue shift (0.5 = none), saturation, value
  let mx = max(c.r, max(c.g, c.b)); let mn = min(c.r, min(c.g, c.b)); let d = mx - mn; var h = 0.;
  if (d > 1e-6) { if (mx == c.r) { h = (c.g - c.b) / d; } else if (mx == c.g) { h = (c.b - c.r) / d + 2.; } else { h = (c.r - c.g) / d + 4.; } h = fract(h / 6.); }
  let s = clamp(select(0., d / mx, mx > 1e-6) * settings[3].x, 0., 1.); let hh = fract(h + settings[1].z - 0.5); let vv = mx * settings[1].w;
  let p = abs(fract(vec3(hh) + vec3(1., 2. / 3., 1. / 3.)) * 6. - 3.); return vv * mix(vec3(1.), clamp(p - 1., vec3(0.), vec3(1.)), s); }
fn stdGrade(c: vec3<f32>) -> vec3<f32> {   // the colour nodes: HUE, SATURATION, VALUE, then CONTRAST (standard settings)
  return max((stdHSV(c) - 0.5) * settings[3].y + 0.5, vec3(0.)); }

struct VO { @builtin(position) pos: vec4<f32>, @location(0) uv: vec2<f32>, };
@vertex fn vs(@builtin(vertex_index) i: u32) -> VO {
  var q = array<vec2<f32>, 6>(vec2(-1.,-1.), vec2(1.,-1.), vec2(-1.,1.), vec2(-1.,1.), vec2(1.,-1.), vec2(1.,1.));
  var o: VO; o.pos = vec4(q[i], 0., 1.); o.uv = q[i]; return o;
}
fn f(i: u32) -> f32 { return u.v[i / 4u][i % 4u]; }

// ================= VISUALIZER: hs_viz (R20) — reusable; everything below the harness line is authoring only =================
const TAU: f32 = 6.2831853;
const PI: f32 = 3.14159265;
const HS_A: f32 = 0.78539816;       // PI / 4: square tiles (P = 4, fixed: the dive's tile step is a symmetry only for even P)
const HS_M: f32 = 0.3;              // the edge midpoint, plane units: the centre tile's size in every geometry
const HS_Q_SPHERE: f32 = 3.;        // {4,3}: the cube
const HS_Q_HYPER: f32 = 5.;         // {4,5}
const HS_MAX_FOLDS: i32 = 32;        // fold iterations (V02: 48 -> 32, lighter on the GPU; deeper pixels are rim-small anyway)
const HS_S: f32 = 12.;               // each world is this many times smaller than the one around it
const HS_WIN: f32 = 0.25;           // the window onto the next world: radius in plane units (inside the centre tile, edge midpoint HS_M)
const HS_DEPTH: i32 = 3;            // worlds drawn below the outermost
const HS_LEVEL_BEATS: f32 = 16.;    // one world per 4 bars
const HS_LEVEL_BEATS_FAST: f32 = 8.;   // two per 4 bars in a section whose pace is in the song's top third
const HS_BG_SHOW: f32 = 1.;         // objects (OBJECTS TOGGLE patches these in the preview only)
const HS_TILES_SHOW: f32 = 1.;
const HS_EDGES_SHOW: f32 = 1.;
const HS_WINDOW_SHOW: f32 = 1.;
const HS_BG_COL = vec3<f32>(0., 0., 0.);                    // background (outside the hyperbolic disk): black
const HS_EDGE_COL = vec3<f32>(1., 1., 1.);                  // edges: Goblin White #FFFFFF
// tile fills: the OMS brand colours, one shade each, full strength
const HS_PAL = array<vec3<f32>, 6>(
  vec3<f32>(1.0000, 0.9412, 0.0000),   // Yellow Man #FFF000
  vec3<f32>(0.3961, 1.0000, 0.0000),   // Green Slime #65FF00
  vec3<f32>(0.8784, 0.1294, 0.5412),   // Barbie Pink #E0218A
  vec3<f32>(0.6980, 0.3020, 1.0000),   // Purple People Eater #B24DFF
  vec3<f32>(1.0000, 0.6471, 0.0000),   // Orange Julius #FFA500
  vec3<f32>(1.0000, 0.0000, 0.4314));  // Red Hots #FF006E

fn hs_bg() -> vec3<f32> {   // the background object (outside the hyperbolic disk)
  if (HS_BG_SHOW < 0.5) { return vec3(0.); }
  return HS_BG_COL;
}
fn hs_rot(z: vec2<f32>, a: f32) -> vec2<f32> { let c = cos(a); let s = sin(a); return vec2(c * z.x - s * z.y, s * z.x + c * z.y); }
fn hs_cmul(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
fn hs_cdiv(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> { return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / max(dot(b, b), 1e-12); }
fn hs_conj(z: vec2<f32>) -> vec2<f32> { return vec2(z.x, -z.y); }
// the tiling for vertex angle B: mirror a|z|² - 2x + b = 0 through (HS_M, 0); returns (a, b, curvature k)
fn hs_geom(B: f32) -> vec3<f32> {
  let sA = sin(HS_A); let cB = cos(B);
  let a = (cB - sA) / (HS_M * cB);
  let b = HS_M * (2. - a * HS_M);
  return vec3(a, b, -a / b);
}
// geodesic move: sends 0 to s along heading th, in curvature k; returns the point and the local scale factor
fn hs_move(z: vec2<f32>, s: f32, th: f32, k: f32) -> vec3<f32> {
  let w = hs_rot(z, -th);
  let den = vec2(1., 0.) - k * s * w;
  let q = hs_cdiv(w + vec2(s, 0.), den);
  return vec3(hs_rot(q, th), (1. + k * s * s) / max(dot(den, den), 1e-12));
}
// zoom level (worlds travelled since the song's start): each section adds its length / its level beats, so the speed changes
// at section starts without a jump
fn hs_level(secI: i32, inSec: f32, gate: bool) -> f32 {
  if (!gate) { return max(f32(u.v[3].y), 0.) / HS_LEVEL_BEATS; }   // section gate off: steady, vizzie.time / level beats
  var L = 0.;
  for (var i = 0; i < 256; i++) {
    if (i >= secI) { break; }
    let r = amuRow(0u, i);
    L = L + r.pos.y / select(HS_LEVEL_BEATS, HS_LEVEL_BEATS_FAST, r.loud.w > 0.66);
  }
  let c = amuRow(0u, secI);
  return L + inSec / select(HS_LEVEL_BEATS, HS_LEVEL_BEATS_FAST, c.loud.w > 0.66);
}

// one world: the {4,Q} tiling at plane point z (pixel pz), its tiles moved by the music; level = the world's depth (palette)
struct HsMus { gBeat: f32, gSec: f32, gSeg: f32, gPhr: f32, gKey: f32, gLoud: f32, drum: f32, bass: f32, vocal: f32,
  barPhase: f32, beatIdx: f32, bp2: f32, phrP: f32, secI: i32, phrI: i32, segI: i32, tonic: f32, loudN: f32, drop: bool, };
fn hs_world(z0: vec2<f32>, pz0: f32, Q: f32, level: i32, M: HsMus) -> vec3<f32> {
  let gBeat = M.gBeat; let gSec = M.gSec; let gSeg = M.gSeg; let gKey = M.gKey; let gLoud = M.gLoud;
  let drum = M.drum; let vocal = M.vocal; let beatIdx = M.beatIdx; let bp2 = M.bp2; let secI = M.secI; let segI = M.segI;
  let tonic = M.tonic; let loudN = M.loudN; let drop = M.drop;
  let G = hs_geom(PI / Q);
  let ga = G.x; let gb = G.y; let k = G.z;
  var z = z0; var pz = pz0;
  var rimCov = 1.;
  if (k < -1e-5) {                                           // hyperbolic: the disk's rim at 1 / sqrt(-k)
    let rim = 1. / sqrt(-k);
    rimCov = clamp((rim - length(z)) / pz + 0.5, 0., 1.);
    if (rimCov <= 0.) { return hs_bg(); }
    z = z * min(1., rim * (1. - 1e-4) / max(length(z), 1e-6));
  }
  // ---- the tiles drift under the window: phrase (new heading each phrase, 0 at its ends), bass (0 at every bar line) ----
  let lim = 0.9 / sqrt(max(abs(k), 1e-6));
  let mp = hs_move(z, min(0.35 * HS_M * 3. * clamp(M.gPhr, 0., 1.) * sin(PI * clamp(M.phrP, 0., 1.)), lim), f32(M.phrI) * 2.39996, k);
  z = mp.xy; pz = pz * mp.z;
  let mb = hs_move(z, min(settings[4].w * HS_M * 3. * M.bass * sin(PI * M.barPhase), lim), 0., k);
  z = mb.xy; pz = pz * mb.z;

  // ---- fold into the fundamental triangle (the origin's side of the mirror); record the steps ----
  var C = 0.; var r2 = 0.;
  let circ = abs(ga) > 1e-5;
  if (circ) { C = 1. / ga; r2 = C * C - gb / ga; }
  var ops: array<u32, 32>;
  var n = 0; var inv = 0; var done = false;
  for (var i = 0; i < HS_MAX_FOLDS; i++) {
    var ang = atan2(z.y, z.x);
    let kk = floor(ang / (2. * HS_A));
    z = hs_rot(z, -kk * 2. * HS_A);                          // into the wedge 0 to 2A
    ang = atan2(z.y, z.x);
    var op = u32(i32(kk) + 64);
    if (ang > HS_A) { z = hs_rot(hs_conj(z), 2. * HS_A); op = op | 256u; }   // reflect across the line at angle A
    n = i + 1;
    if (ga * dot(z, z) - 2. * z.x + gb < 0.) {               // past the mirror: reflect, one tile nearer the centre
      if (circ) { let q = z - vec2(C, 0.); let f2 = r2 / max(dot(q, q), 1e-12); z = vec2(C, 0.) + q * f2; pz = pz * f2; }
      else { z = vec2(gb - z.x, z.y); }
      inv = inv + 1; op = op | 512u; ops[i] = op;
    } else { ops[i] = op; done = true; break; }
  }
  if (!done) { return vec3(0.); }

  // ---- the tile's centre, the origin carried back through the steps in homogeneous form (n / d): the cube's far face is at infinity ----
  var hn = vec2(0., 0.); var hd = vec2(1., 0.);
  for (var j = n - 1; j >= 0; j--) {
    let op = ops[j];
    if ((op & 512u) != 0u) {
      let cn = hs_conj(hn); let cdn = hs_conj(hd);
      if (circ) { hn = C * cn + (r2 - C * C) * cdn; hd = cn - C * cdn; }
      else { hn = gb * cdn - cn; hd = cdn; }
    }
    if ((op & 256u) != 0u) { hn = hs_rot(hs_conj(hn), 2. * HS_A); hd = hs_conj(hd); }
    hn = hs_rot(hn, f32(i32(op & 255u) - 64) * 2. * HS_A);
    let l = max(length(hn), length(hd)); hn = hn / l; hd = hd / l;
  }
  let far = dot(hd, hd) < 1e-6 * dot(hn, hn);
  var qd = 0u;
  if (inv > 0 && !far) {
    let ca = atan2(hs_cmul(hn, hs_conj(hd)).y, hs_cmul(hn, hs_conj(hd)).x);
    qd = u32(floor((ca + HS_A + 0.1234 + TAU) / (2. * HS_A))) % 4u;   // which quarter the tile's centre is in
  }
  var base = 0u;
  if (inv > 0) { base = 1u + (u32(inv - 1) * 4u + qd) % 5u; }  // centre 0 · the cube's sides 1-4 · its far face 5

  // ---- fill: brand colour per tile, full strength; AMU shifts the palette ----
  var dcol = vec3(0.);
  if (HS_TILES_SHOW > 0.5) {
    let stride = select(1u, 5u, gSeg > 0.5 && (max(segI, 0) % 2) == 1);   // segment: palette order (5 is coprime with 6)
    var shift = 0u;
    if (gSec > 0.5) { shift = shift + u32(max(secI, 0)); }                // section
    if (gKey > 0.5) { shift = shift + u32(tonic); }                       // key: the tonic
    if (vocal > 0.5) { shift = shift + u32(beatIdx); }                    // vocal in: step every beat
    if (drop && ((inv + i32(beatIdx)) % 2) == 1) { shift = shift + 3u; }  // drop: checkerboard flip to the opposite colour, alternate beats
    shift = shift + u32(level) * 2u;                                     // each world its own palette offset
    let tileCol = HS_PAL[(base * stride + shift) % 6u];
    dcol = tileCol;
  }
  // ---- edges: distance to the mirror in the folded frame; loudness weight, drums and beat kick; they fade where tiles shrink ----
  if (HS_EDGES_SHOW > 0.5) {
    let F = ga * dot(z, z) - 2. * z.x + gb;
    let de = F / max(length(2. * ga * z - vec2(2., 0.)), 1e-6);
    let w = settings[4].z * HS_M * 3. * mix(1., mix(0.6, 1.4, loudN), clamp(gLoud, 0., 1.)) * (1. + 1.5 * drum * bp2 + 0.6 * gBeat * bp2);
    let fine = clamp(1. - pz * 6., 0., 1.);
    let ec = clamp((w - de) / max(pz, 1e-6) + 0.5, 0., 1.) * fine;
    dcol = mix(dcol, HS_EDGE_COL, ec);
  }
  return mix(hs_bg(), dcol, rimCov);
}

// hs_viz: the visualizer. p: point on the frame, y up, the frame's half-height = 1 · pix: one pixel in those units ·
// phase: loop phase 0-1 (4 bars) · returns colour. Reads the AMU lanes and span tables from the contract.
fn hs_viz(p: vec2<f32>, pix: f32, phase: f32) -> vec3<f32> {
  let REACT = settings[1].y;
  // ---- AMU, every lane: gates x REACT ----
  var M: HsMus;
  M.gBeat = f(0u) * REACT; let gBar = f(1u) * REACT; M.gSec = f(2u) * REACT; M.gSeg = f(3u) * REACT; M.gPhr = f(4u) * REACT;
  M.gKey = f(6u) * REACT; let gPace = f(7u) * REACT; M.gLoud = f(8u) * REACT;
  M.drum = f(26u) * f(9u) * REACT; M.bass = f(27u) * f(10u) * REACT; M.vocal = f(28u) * f(11u) * REACT;
  M.barPhase = fract(phase * 4.);
  M.beatIdx = floor(phase * 16.);                            // beat in the loop, 0-15
  let beatPhase = fract(phase * 16.);
  M.bp2 = (1. - beatPhase) * (1. - beatPhase);               // the beat's kick, 1 falling to 0
  let secP = f(17u); M.phrP = f(19u);
  M.secI = i32(f(20u)); M.phrI = i32(f(21u)); M.segI = i32(f(22u));
  let minor = f(23u) > 0.5; M.tonic = f(30u);
  M.loudN = clamp((f(24u) + 40.) / 34., 0., 1.) * M.gLoud;  // momentary LUFS, -40 to -6 as 0-1
  let sec = amuRow(0u, M.secI); let nxt = amuRow(0u, M.secI + 1);
  M.drop = M.gSec > 0.5 && abs(sec.lvl.x - 1.) < 0.5;       // the loudest section (LUFS rank 1)
  let build = M.gSec > 0.5 && !M.drop && abs(nxt.lvl.x - 1.) < 0.5;   // the section before it

  // ---- the zoom: L worlds travelled; the outermost world drawn is floor(L), zoomed in by HS_S ^ fract(L) ----
  let inSec = clamp(secP, 0., 1.) * sec.pos.y;               // beats into the section
  let L = hs_level(M.secI, inSec, M.gSec > 0.5 && gPace > 0.5);
  let L0 = floor(L);
  let zs = HS_SPAN * pow(HS_S, -(L - L0));
  var z = p * zs;
  var pz = pix * zs;

  // ---- turn (the whole view, about the window): steady, a quarter per 4 bars (bar gate), key (tonic offset, mode sets direction), build (two turns) ----
  let dir = select(1., -1., minor && M.gKey > 0.5);
  let beats = max(f(13u) * settings[1].x + settings[2].w, 0.);   // vizzie.time x SPEED + TIME_OFFSET: the turn runs on, no reset at the loop
  var turn = TAU * beats / 64. * clamp(gBar, 0., 1.);
  turn = turn + M.tonic / 12. * 2. * HS_A * clamp(M.gKey, 0., 1.);
  if (build) { turn = turn + 2. * TAU * secP * secP; }
  z = hs_rot(z, -dir * turn);

  // ---- through the windows: each window is the next world, HS_S times smaller ----
  var d = 0;
  for (var i = 0; i < HS_DEPTH; i++) {
    if (length(z) >= HS_WIN) { break; }
    z = z * HS_S; pz = pz * HS_S; d = d + 1;
  }
  let level = i32(L0) + d;
  let Q = select(HS_Q_SPHERE, HS_Q_HYPER, (level % 2) == 1);   // worlds alternate: sphere, hyperbolic, ...
  var col = hs_world(z, pz, Q, level, M);
  // ---- the window's rim, in the world around it: Goblin White, the edge width ----
  if (HS_WINDOW_SHOW > 0.5 && d < HS_DEPTH) {
    let w = settings[4].z * HS_M * 3. * mix(1., mix(0.6, 1.4, M.loudN), clamp(M.gLoud, 0., 1.)) * (1. + 1.5 * M.drum * M.bp2 + 0.6 * M.gBeat * M.bp2);
    let de = length(z) - HS_WIN;
    let ec = clamp((w - abs(de)) / max(pz, 1e-6) + 0.5, 0., 1.) * clamp(1. - pz * 6., 0., 1.);
    col = mix(col, HS_EDGE_COL, ec);
  }
  return col;
}

// ================= AUTHORING HARNESS =================
const HS_SPAN: f32 = 1.25;           // the frame's half-height in plane units: the {4,5} disk (rim 1.16) fits; the cube's far face shows in the corners
// the zoom loop closes when the window (HS_WIN x HS_S = 3 plane units, 2.4 half-heights) covers the frame's corners (16:9: 2.04 half-heights)

@fragment fn fs(in: VO) -> @location(0) vec4<f32> {
  let t = f(13u) * settings[1].x + settings[2].w;          // vizzie.time (beats) x SPEED + TIME_OFFSET
  let res = max(u.v[8].xy, vec2(1., 1.));                  // canvas resolution (px), slots 32–33
  let asp = res.x / res.y;
  let p0 = vec2(in.uv.x * asp, in.uv.y);                   // the canvas: frame units, y up, half-height = 1
  let ps = stdFrame(p0, asp);
  let pf = 2. / res.y / max(settings[0].x, 1e-3) * max(round(settings[2].z), 1.);   // one pixel in frame units (SCALE and TILE included)
  let phase = fract(max(t, 0.) / 16.);                     // Loop: 4 bars = 16 beats
  let col = stdGrade(hs_viz(ps, pf, phase));
  // [authoring overlay probe]
  return vec4(clamp(col, vec3(0.), vec3(1.)), 1.);
}
