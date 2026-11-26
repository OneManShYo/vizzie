// OMS_Vizzie_Shader_HyperbolicDisk_V03.wgsl
// @title Hyperbolic Disk
// @author Wes Smith, Claude, CodeParade [YouTube]
// @type visualizer
// @desc a {4,5} hyperbolic tiling in the Poincaré disk, in the OMS brand colours, turning on the bar
// Hyperbolic Disk: a regular {P,Q} tiling of the hyperbolic plane (P-sided tiles, Q at each corner), drawn by folding each pixel
// into the fundamental triangle (two mirror lines through the centre, one geodesic mirror circle). Three projections of the
// same tiling (PROJECTION): stereographic = Poincaré disk, gnomonic = Klein disk, orthographic = Gans plane clipped to the disk.
// Reference: CodeParade [YouTube], "Non-Euclidean Geometry Explained - Hyperbolica Devlog #1" (the stereographic hyperbolic panel).
// Loop: 4 bars
// Music (V03, every AMU lane, each gated by its knob x REACT):
//   beat: edges kick on the beat · bar: a quarter turn per bar, eased · section: palette shift, rings filled by its drums (span table)
//   segment: palette order (stride 1 or 5) · phrase: a Möbius drift along a geodesic, a new heading each phrase, 0 at phrase ends
//   key: tonic turns the tiling and shifts the palette, major turns counter-clockwise, minor clockwise · pace: the top third of the
//   song's pace adds a tile at every corner (Q + 1) · loudness: disk size (85-100%) and edge weight · drums: edge pulse on the beat
//   bass: Möbius slide, 0 at every bar line (BREATH) · vocal: the palette steps every beat while the vocal is in · other: a wobble
//   on the beat · build (the section before the loudest): rings grow through it and the disk spins up two turns · drop (the loudest
//   section, LUFS rank 1): every ring filled, tiles flip to the opposite colour in a checkerboard on alternate beats
// V01 (2026-11-21): first build, on OMS Vizzie [Beta V1.4.19a].
// V02 (2026-11-21, Wes): tiles in the exact brand colours at full strength: no opacity (HD_DIM and the vocal mapping removed), no fade
// toward the rim, whole rings only (the ring count rounded); the edges alone fade where tiles get smaller than a few pixels.
// V03 (2026-11-21, Wes): Apple Music Understanding maxed: every lane and the span tables drive it (Music above). Attribution: CodeParade [YouTube].
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
// ---- SETTINGS: this shader's own (Wes, 2026-11-21), settings[4] and settings[5], row 3 ----
// @setting P settings[4].x 3 8 1 4 | tiling: sides of each tile
// @setting Q settings[4].y 3 8 1 5 | tiling: tiles meeting at each corner; raised to the smallest hyperbolic value when 1/P + 1/Q >= 1/2
// @setting EDGE settings[4].z 0 0.1 0.005 0.03 | edge width, hyperbolic (the edges thin toward the rim)
// @setting BREATH settings[4].w 0 0.6 0.01 0.25 | bass: depth of the Möbius slide along a geodesic, back to centre at every bar line
// @setting PROJECTION settings[5].x 0 2 1 0 | 0 stereographic (Poincaré disk) · 1 gnomonic (Klein disk) · 2 orthographic (Gans plane, clipped to the disk)
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

// ================= VISUALIZER: hd_viz (R20) — reusable; everything below the harness line is authoring only =================
const TAU: f32 = 6.2831853;
const PI: f32 = 3.14159265;
const HD_MAX_FOLDS: i32 = 48;        // fold iterations; pixels that need more are at the rim and draw as the rim
const HD_GANS_SPAN: f32 = 3.0;       // PROJECTION 2: the Gans plane's half-width shown inside the disk
const HD_RINGS_MIN: f32 = 3.;        // rings of tiles filled in the quietest section (drums, normalised to the song)
const HD_RINGS_MAX: f32 = 6.;        // rings of tiles filled in the busiest section
const HD_RINGS_DROP: f32 = 12.;      // rings filled in the drop: all of them
const HD_BG_SHOW: f32 = 1.;          // objects (OBJECTS TOGGLE patches these in the preview only)
const HD_TILES_SHOW: f32 = 1.;
const HD_EDGES_SHOW: f32 = 1.;
const HD_BG_COL = vec3<f32>(0., 0., 0.);                    // background: black (the app's #000)
const HD_EDGE_COL = vec3<f32>(1., 1., 1.);                  // edges: Goblin White #FFFFFF
// tile fills: the OMS brand colours, one shade each
const HD_PAL = array<vec3<f32>, 6>(
  vec3<f32>(1.0000, 0.9412, 0.0000),   // Yellow Man #FFF000
  vec3<f32>(0.3961, 1.0000, 0.0000),   // Green Slime #65FF00
  vec3<f32>(0.8784, 0.1294, 0.5412),   // Barbie Pink #E0218A
  vec3<f32>(0.6980, 0.3020, 1.0000),   // Purple People Eater #B24DFF
  vec3<f32>(1.0000, 0.6471, 0.0000),   // Orange Julius #FFA500
  vec3<f32>(1.0000, 0.0000, 0.4314));  // Red Hots #FF006E

fn hd_rot(z: vec2<f32>, a: f32) -> vec2<f32> { let c = cos(a); let s = sin(a); return vec2(c * z.x - s * z.y, s * z.x + c * z.y); }
fn hd_cmul(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
// Möbius slide by s along the geodesic through the centre at heading th; returns the point and the local scale factor
fn hd_slide(z: vec2<f32>, s: f32, th: f32) -> vec3<f32> {
  let w = hd_rot(z, -th);
  let den = vec2(1., 0.) - s * w;
  let dd = max(dot(den, den), 1e-12);
  let num = w - vec2(s, 0.);
  let q = vec2(num.x * den.x + num.y * den.y, num.y * den.x - num.x * den.y) / dd;
  return vec3(hd_rot(q, th), (1. - s * s) / dd);
}
fn hd_cdiv(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> { return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / max(dot(b, b), 1e-12); }
// screen point in the unit disk -> Poincaré disk, by projection (0 stereographic, 1 gnomonic, 2 orthographic); w < 0 = outside
fn hd_toPoincare(d: vec2<f32>, proj: i32) -> vec2<f32> {
  let r2 = dot(d, d);
  if (proj == 1) { return d / (1. + sqrt(max(1. - r2, 0.))); }                       // Klein -> Poincaré
  if (proj == 2) { let g = d * HD_GANS_SPAN; return g / (1. + sqrt(1. + dot(g, g))); }   // Gans -> Poincaré
  return d;                                                                           // already Poincaré
}
// tile id: a stable hash of the tile's centre (hyperboloid coordinates, quantised)
fn hd_hash(c: vec2<f32>) -> f32 {
  let k = 1. - dot(c, c); let w = 2. * c / max(k, 1e-6);
  let q = floor(w * 4. + vec2(0.137, 0.291));
  return fract(sin(dot(q, vec2(127.1, 311.7))) * 43758.5453);
}

// hd_viz: the visualizer. d: point in the disk's own units (the disk is radius 1), y up · pix: one pixel in those units ·
// phase: loop phase 0-1 (4 bars) · returns colour. Reads the AMU lanes from the contract.
fn hd_viz(d0: vec2<f32>, pix0: f32, phase: f32) -> vec3<f32> {
  let REACT = settings[1].y;
  // ---- AMU, every lane (V03): gates x REACT ----
  let gBeat = f(0u) * REACT; let gBar = f(1u) * REACT; let gSec = f(2u) * REACT; let gSeg = f(3u) * REACT; let gPhr = f(4u) * REACT;
  let gKey = f(6u) * REACT; let gPace = f(7u) * REACT; let gLoud = f(8u) * REACT;
  let drum = f(26u) * f(9u) * REACT; let bass = f(27u) * f(10u) * REACT; let vocal = f(28u) * f(11u) * REACT; let other = f(29u) * f(12u) * REACT;
  let bars = phase * 4.;                                     // 0-4 through the loop
  let barPhase = fract(bars);
  let beatIdx = floor(phase * 16.);                          // beat in the loop, 0-15
  let beatPhase = fract(phase * 16.);
  let bp2 = (1. - beatPhase) * (1. - beatPhase);             // the beat's kick, 1 falling to 0
  let secP = f(17u); let phrP = f(19u);
  let secI = i32(f(20u)); let phrI = i32(f(21u)); let segI = i32(f(22u)); let paceI = i32(f(15u));
  let minor = f(23u) > 0.5; let tonic = f(30u);
  let loudN = clamp((f(24u) + 40.) / 34., 0., 1.) * gLoud;  // momentary LUFS, -40 to -6 as 0-1
  let sec = amuRow(0u, secI); let nxt = amuRow(0u, secI + 1); let pace = amuRow(4u, paceI);
  let drop = gSec > 0.5 && abs(sec.lvl.x - 1.) < 0.5;       // the loudest section (LUFS rank 1)
  let build = gSec > 0.5 && !drop && abs(nxt.lvl.x - 1.) < 0.5;   // the section before it
  var rings = round(mix(HD_RINGS_MIN, HD_RINGS_MAX, clamp(sec.norm.x, 0., 1.) * clamp(gSec, 0., 1.)));   // section drums x section gate, whole rings
  if (build) { rings = round(mix(HD_RINGS_MIN, HD_RINGS_MAX, secP)); }   // build: rings grow through the section
  if (drop) { rings = HD_RINGS_DROP; }                                   // drop: every ring

  // ---- tiling ----
  let P = max(round(settings[4].x), 3.);
  var Q = max(round(settings[4].y), 3.) + select(0., 1., pace.loud.w * clamp(gPace, 0., 1.) > 0.66);   // pace: the top third adds a tile at each corner
  if (1. / P + 1. / Q >= 0.5 - 1e-4) { Q = floor(2. * P / (P - 2.)) + 1.; }   // smallest hyperbolic Q for this P
  let A = PI / P; let B = PI / Q;
  let sA = sin(A); let cB = cos(B);
  let cd = 1. / sqrt(1. - sA * sA / (cB * cB));              // mirror circle: centre (cd, 0), radius cr, orthogonal to the unit circle
  let cr = sqrt(cd * cd - 1.);
  let C = vec2(cd, 0.);

  // ---- projection, and the pixel size in the Poincaré disk ----
  let proj = i32(round(clamp(settings[5].x, 0., 2.)));
  let dsz = mix(0.85, 1., loudN);                            // loudness: the disk's size
  let d = d0 / dsz; let pix = pix0 / dsz;
  var col = HD_BG_COL;
  if (HD_BG_SHOW < 0.5) { col = vec3(0.); }
  let rd = length(d);
  let rimCov = clamp((1. - rd) / pix + 0.5, 0., 1.);         // the disk, antialiased
  if (rimCov <= 0.) { return col; }
  var z = hd_toPoincare(d * min(1., (1. - 1e-4) / max(rd, 1e-6)), proj);
  let z1 = hd_toPoincare((d + vec2(pix, 0.)) * min(1., (1. - 1e-4) / max(length(d + vec2(pix, 0.)), 1e-6)), proj);
  var scale = length(z1 - z) / pix;                          // Poincaré units per disk unit, here
  var pz = pix * scale;                                      // one pixel, Poincaré units

  // ---- phrase: Möbius drift, a new heading each phrase (golden angle), 0 at phrase ends ----
  let sp = hd_slide(z, 0.35 * clamp(gPhr, 0., 1.) * sin(PI * clamp(phrP, 0., 1.)), f32(phrI) * 2.39996);
  z = sp.xy; pz = pz * sp.z;
  // ---- bass: Möbius slide along the x geodesic, 0 at every bar line ----
  let sb = hd_slide(z, clamp(settings[4].w * bass * sin(PI * barPhase), 0., 0.95), 0.);
  z = sb.xy; pz = pz * sb.z;

  // ---- turn: a quarter per bar (bar gate), key (tonic offset, mode sets the direction), other (wobble on the beat), build (two turns) ----
  let e = barPhase * barPhase * (3. - 2. * barPhase);
  let dir = select(1., -1., minor && gKey > 0.5);
  var turn = TAU * (floor(bars) + e) / 4. * clamp(gBar, 0., 1.);
  turn = turn + tonic / 12. * 2. * A * clamp(gKey, 0., 1.);
  turn = turn + other * 0.3 * sin(TAU * beatPhase);
  if (build) { turn = turn + 2. * TAU * secP * secP; }
  z = hd_rot(z, -dir * turn);

  // ---- fold into the fundamental triangle; record the steps to find the tile's centre ----
  var ops: array<u32, 48>;
  var n = 0; var inv = 0; var done = false;
  for (var i = 0; i < HD_MAX_FOLDS; i++) {
    var ang = atan2(z.y, z.x);
    let k = floor(ang / (2. * A));
    z = hd_rot(z, -k * 2. * A);                              // into the wedge 0 to 2A
    ang = atan2(z.y, z.x);
    var op = u32(i32(k) + 64);
    if (ang > A) { z = hd_rot(vec2(z.x, -z.y), 2. * A); op = op | 256u; }   // reflect across the line at angle A
    let q = z - C; let q2 = dot(q, q);
    if (q2 < cr * cr) {                                      // inside the mirror circle: invert, one tile nearer the centre
      let f2 = cr * cr / q2;
      z = C + q * f2; pz = pz * f2; inv = inv + 1; op = op | 512u;
      ops[i] = op; n = i + 1;
    } else { ops[i] = op; n = i + 1; done = true; break; }
  }
  if (!done) { return col; }                                 // too deep: the rim, drawn as background

  // ---- the tile's centre: the origin carried back through the steps ----
  var c = vec2(0., 0.);
  for (var j = n - 1; j >= 0; j--) {
    let op = ops[j];
    if ((op & 512u) != 0u) { let q = c - C; c = C + q * (cr * cr / max(dot(q, q), 1e-12)); }
    if ((op & 256u) != 0u) { c = hd_rot(vec2(c.x, -c.y), 2. * A); }   // the reflection is its own inverse (in the rotated frame)
    let k = f32(i32(op & 255u) - 64);
    c = hd_rot(c, k * 2. * A);
  }

  // ---- fill: brand colour per tile, the section shifts the palette; rings past the section's count stay unfilled ----
  var dcol = vec3(0.);
  let fine = clamp(1. - pz * 6., 0., 1.);                    // edges fade where tiles get smaller than a few pixels
  if (HD_TILES_SHOW > 0.5) {
    let stride = select(1u, 5u, gSeg > 0.5 && (max(segI, 0) % 2) == 1);   // segment: palette order (5 is coprime with 6)
    var shift = 0u;
    if (gSec > 0.5) { shift = shift + u32(max(secI, 0)); }                // section
    if (gKey > 0.5) { shift = shift + u32(tonic); }                       // key: the tonic
    if (vocal > 0.5) { shift = shift + u32(beatIdx); }                    // vocal in: step every beat
    if (drop && ((inv + i32(beatIdx)) % 2) == 1) { shift = shift + 3u; }  // drop: checkerboard flip to the opposite colour, alternate beats
    let idx = (u32(floor(hd_hash(c) * 6.)) * stride + shift) % 6u;
    let tileCol = HD_PAL[idx];
    let alpha = select(0., 1., f32(inv) <= rings);          // full strength inside the section's rings, none past them
    dcol = mix(dcol, tileCol, alpha);
  }
  // ---- edges: distance to the mirror circle, in the folded (hyperbolic) frame; drums pulse them on the beat ----
  if (HD_EDGES_SHOW > 0.5) {
    let de = length(z - C) - cr;
    let w = settings[4].z * mix(1., mix(0.6, 1.4, loudN), clamp(gLoud, 0., 1.)) * (1. + 1.5 * drum * bp2 + 0.6 * gBeat * bp2);   // loudness weight, drums and beat kick
    let ec = clamp((w - de) / max(pz, 1e-6) + 0.5, 0., 1.) * fine;
    dcol = mix(dcol, HD_EDGE_COL, ec);
  }
  return mix(col, dcol, rimCov);
}

// ================= AUTHORING HARNESS =================
const HD_FIT: f32 = 0.92;            // the disk's radius: 92% of the frame's half-height (or half-width, in portrait)

@fragment fn fs(in: VO) -> @location(0) vec4<f32> {
  let t = f(13u) * settings[1].x + settings[2].w;          // vizzie.time (beats) x SPEED + TIME_OFFSET
  let res = max(u.v[8].xy, vec2(1., 1.));                  // canvas resolution (px), slots 32–33
  let asp = res.x / res.y;
  let p0 = vec2(in.uv.x * asp, in.uv.y);                   // the canvas: frame units, y up, half-height = 1
  let ps = stdFrame(p0, asp);
  let pf = 2. / res.y / max(settings[0].x, 1e-3) * max(round(settings[2].z), 1.);   // one pixel in frame units (SCALE and TILE included)
  let R = HD_FIT * min(1., asp);                           // the disk's radius, frame units
  let phase = fract(max(t, 0.) / 16.);                     // Loop: 4 bars = 16 beats
  let col = stdGrade(hd_viz(ps / R, pf / R, phase));
  // [authoring overlay probe]
  return vec4(clamp(col, vec3(0.), vec3(1.)), 1.);
}
