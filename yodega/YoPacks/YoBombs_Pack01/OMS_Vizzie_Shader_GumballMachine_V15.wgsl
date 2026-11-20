// OMS_Vizzie_Shader_GumballMachine_V15 · visualizer
// @title Gumball Machine
// @author ItsWesSmithYo, Claude, Shadertoy
// @type visualizer
// @desc three solid rings round the centre on Green Slime, the centre pumping like a speaker cone on the beat while the drums play; lit balls burst out of each ring and roll across the canvas, fading by the end: zone_01 (Orange Julius) on every section, zone_02 (Barbie Pink) on every segment, zone_03 (Purple People Eater) on every phrase
// Source: Shadertoy t3BSRd "Tunnel Shell" (header: Shader inspired by warm-to-cool circular tunnel gradient), GLSL, converted to WGSL on the Vizzie contract.
// Loop: 64 bars
// Size: 2 m frame height (the source frame, -1 to 1 high, 1 unit = 1 m); tunnel about 2 m across
// Run date: 2026-11-14
// Current Unix Epoch: 1794706801
// Built from: OMS_Vizzie_Beta_V1_3_28a (template carried by the app)
// V09: effect CC Ball Action pasted in drop-in from OMS_Vizzie_Shader_Effects_CCBallAction_BoxBotSquint_V02 (EFFECT COMMON verbatim); zone_01 is its subject (hook fx_source); zone_02, zone_03 and the background stay flat behind the balls.
// V15: the ball count builds through the song, START_BALLS in the first section to MAX_BALLS in the last (section index over the song's section count, AMU span tables); in the song's highest-pace span (pace level 1) all three rings pump on the beat. Check strip now shows how far through the song's sections it is.
// V14: the number of balls in every burst follows the current section's drums (AMU span tables, drums norm): MIN_BALLS in the song's quietest section to MAX_BALLS in its busiest. Temporary check strip along the bottom: the section's drums norm.
// V13: zone_01 pumps like the centre of a speaker on every beat while drum activity is over 0.5 (PUMP).
// V12: the rings stay solid and the balls burst out of them (a set number of balls per ring, BALL_COUNT, in place of a ball on every grid cell), for speed.
// V11: the balls fade out by the end of their section; zone_02 bursts on every segment and zone_03 on every phrase (the burst pasted three times, hooks fx_source_1 to _3).
// V10: CC Ball Action's beat motion replaced by a new effect section, Ball Action section burst (fx_ballburst, written to the drop-in rules, not yet in the Effects library): the balls burst out of zone_01 on every new AMU section and roll across the canvas.
// Vizzie uniform contract (V0.5.0A): binding 0 = 9 x vec4 (36 floats); binding 1 = settings, 16 x vec4: the template's standard fourteen (settings[0] to settings[3]), Ball Action burst's four (settings[4]) PUMP (settings[5].x) and MAX_BALLS (settings[5].y); binding 2 = the AMU span tables (V1.3.28a). No image bindings.
struct U { v: array<vec4<f32>, 9>, };
@group(0) @binding(0) var<uniform> u: U;
@group(0) @binding(1) var<uniform> settings: array<vec4<f32>, 16>;

// ---- AMU SPAN TABLES (V1.3.28a, BLOG0203): binding 2, worked out by the app from the loaded AMU (any song), one table per lane ----
// lanes: 0 section, 1 segment, 2 phrase, 3 bar, 4 pace · current index: section slot 20 u.v[5].x, segment slot 22 u.v[5].z,
//   phrase slot 21 u.v[5].y, bar slot 5 u.v[1].y, pace slot 15 u.v[3].w
// row: pos = start (beats), length (beats), index, rows in lane · avg = drum, bass, vocal, other averaged over the span (0-1)
//   norm = the same scaled to this song's range in the lane (0-1) · loud = LUFS, LUFS norm, pace, pace norm
//   rank = drum, bass, vocal, other rank in the lane (1 = highest) · lvl = LUFS rank, pace level (1 = highest), pace levels in the song, 0
// head: [0] section first row, rows, segment first, rows · [1] phrase first, rows, bar first, rows · [2] pace first, rows · [3] song length (beats), bpm
// example: let row = amuRow(0u, i32(u.v[5].x)); let balls = mix(20., 400., row.norm.x);   /* ball count follows this section's drums */
//          let nxt = amuRow(0u, i32(u.v[5].x) + 1); let buildUp = nxt.norm.x > 0.9 && row.norm.x < 0.5;   /* the section before a big one */
//          let songP = u.v[3].y / max(amuT.head[3].x, 1.);   /* progress through the song, 0-1 */
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

// ---- SETTINGS: the template's standard fourteen (R13), settings[0] to settings[3]: rows 1 and 2 of the rack ----
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
// ---- SETTINGS: Ball Action burst, settings[4], row 3: shared by all three zones ----
// @setting START_BALLS settings[4].x 0 400 1 5 | Ball Action: balls that burst out of each ring in the song's first section
// @setting BALL_SIZE settings[4].y 2 60 1 16 | Ball Action: ball diameter, pixels at 1080p
// @setting BURST_DISTANCE settings[4].z 0 3 0.05 1 | Ball Action: how far each ball rolls over its section / segment / phrase, canvas widths (x that lane x REACT)
// @setting BURST_HEIGHT settings[4].w 0 2 0.05 0.5 | Ball Action: how far the balls pop up toward the camera at the burst (ball grows), x ball size
// ---- SETTINGS: zone_01 and Ball Action, settings[5], row 4 ----
// @setting PUMP settings[5].x 0 0.5 0.01 0.15 | zone_01 on each beat while drum activity is over 0.5 (x drum lane x REACT), and all three rings on each beat in the song's highest pace (x pace lane x REACT): how far they pump out, x their radius
// @setting MAX_BALLS settings[5].y 0 400 1 240 | Ball Action: balls that burst out of each ring in the song's last section
// frame: TILE, then p' = rotate(-ROTATION) * (p - OFFSET - PIVOT) / SCALE + PIVOT · clock: vizzie.time x SPEED + TIME_OFFSET · last: the HSV node, then contrast
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

struct VO { @builtin(position) pos: vec4<f32>, @location(0) uv: vec2<f32>, };
@vertex fn vs(@builtin(vertex_index) i: u32) -> VO {
  var q = array<vec2<f32>, 6>(vec2(-1.,-1.), vec2(1.,-1.), vec2(-1.,1.), vec2(-1.,1.), vec2(1.,-1.), vec2(1.,1.));
  var o: VO; o.pos = vec4(q[i], 0., 1.); o.uv = q[i]; return o;
}
fn f(i: u32) -> f32 { return u.v[i / 4u][i % 4u]; }

const TAU: f32 = 6.2831853;

// ======== VISUALIZER: sh_viz(point in metres, loop phase 0 to 1) ========
// Loop: 64 bars. The rings stay solid; balls burst out of zone_01 on each AMU section, zone_02 on each segment, zone_03 on each phrase; each burst fades out by its end.
const SH_ZONE1_COL = vec3<f32>(1.0000, 0.6471, 0.0000);   // zone_01: Orange Julius #FFA500
const SH_ZONE2_COL = vec3<f32>(0.8784, 0.1294, 0.5412);   // zone_02: Barbie Pink #E0218A
const SH_ZONE3_COL = vec3<f32>(0.6980, 0.3020, 1.0000);   // zone_03: Purple People Eater #B24DFF
const SH_BG = vec3<f32>(0.3961, 1.0000, 0.0000);          // background: Green Slime #65FF00
const SH_ZONE1_R: f32 = 0.3;     // zone_01 outer radius at rest, metres
const SH_PUMP_DRUM: f32 = 0.5;   // zone_01 pumps only while drum activity is over this
const SH_ZONE2_R: f32 = 0.5;     // zone_02 outer radius, metres
const SH_ZONE3_R: f32 = 0.8;     // zone_03 outer radius, metres
const SH_BG_SHOW: f32 = 1.;      // background
const SH_ZONE1_SHOW: f32 = 1.;   // zone_01: core, 0 to 0.3 m
const SH_ZONE2_SHOW: f32 = 1.;   // zone_02: middle, 0.3 to 0.5 m
const SH_ZONE3_SHOW: f32 = 1.;   // zone_03: outer, 0.5 to 0.8 m
var<private> shR1: f32 = 0.3;    // zone_01 outer radius now, metres (the pumps; set in fs)
var<private> shR2: f32 = 0.5;    // zone_02 outer radius now
var<private> shR3: f32 = 0.8;    // zone_03 outer radius now
fn sh_back() -> vec3<f32> {                                       // background
  return SH_BG * SH_BG_SHOW; }
fn sh_zones(uv: vec2<f32>) -> vec4<f32> {                         // the zones at uv (metres): colour, coverage
  let d = length(uv);
  // ---- zone_01 to zone_03: hard-edged rings, flat colours; past 0.8 m nothing (the background shows) ----
  var zc = SH_BG; var zs = 0.;
  if (d < shR1) { zc = SH_ZONE1_COL; zs = SH_ZONE1_SHOW; }          // zone_01
  else if (d < shR2) { zc = SH_ZONE2_COL; zs = SH_ZONE2_SHOW; }     // zone_02
  else if (d < shR3) { zc = SH_ZONE3_COL; zs = SH_ZONE3_SHOW; }     // zone_03
  return vec4(zc, zs); }
fn sh_viz(uv: vec2<f32>, ph: f32) -> vec3<f32> {                  // the picture without the effect
  let z = sh_zones(uv);
  return mix(sh_back(), z.rgb, z.a); }


// ======== EFFECT COMMON (R21 proposal): once per shader, shared by every effect pasted in ========
// An effect is a section of fx_ functions. It never names its subject: it reads the picture only through the host's hook
//   fn fx_source(p: vec2<f32>, fw: f32) -> vec4<f32>      // the picture at point p: straight (not premultiplied) rgb, coverage 0 to 1
// fw is the footprint: the size of one output pixel at p, in p's space (effects that magnify or squeeze pass it larger or smaller, for clean edges).
// Effects that move time also need  fn fx_source_at(p, fw, dt)  (the picture dt beats from now); Light Rays needs  fn fx_cover(p, fw)  (a cheap version: coverage, and the colour light takes passing through; black blocks).
// No effect reads settings, uniforms or the clock: the host passes the controls (one struct per effect), the time, and the subject (FxSubject).
// An effect returns rgb and coverage (Light Rays: light to add); the host composites it over its own background, then grades.
// Stacking: WGSL has no function pointers or recursion, so give each stage its own hook name when pasting (fx_source_1, fx_source_2, ...).
struct FxSubject {
  bmin: vec2<f32>,       // the subject's resting box in p's space: everything fx_source can draw lies inside it
  bmax: vec2<f32>,
  half: vec2<f32>,       // half the canvas in p's space (frame units: aspect, 1)
  px: f32,               // one output pixel in p's space
};

// ======== EFFECT: Ball Action burst (new, after CC Ball Action), drop-in. Needs fx_source (pasted three times here: fx_source_1 to _3). ========
// A set number of lit balls (shaded as CC Ball Action) start at random points on the subject. At the start of each section (or segment, or phrase:
// the host chooses) they grow out of it, pop up toward the camera (grow) and land, then roll outward from the subject's centre in their own
// random directions, bouncing off the canvas edges, slowing to a stop and fading out by the end. The subject itself is the host's to draw.
// The host passes the progress (0 to 1) and a seed that changes each time. Cost: one pass over the balls per pixel.
const FX_BB_MAX: i32 = 400;                                 // most balls
struct FxBallBurst {
  count: f32,            // balls
  size: f32,             // ball diameter, in p's units
  distance: f32,         // how far a ball rolls, canvas widths
  height: f32,           // pop toward the camera at the burst, x ball size
  progress: f32,         // 0 at the burst to 1 at the end (the host drives it)
  seed: f32,             // new starts and directions each time it changes
  amount: f32,           // 0 = no burst, 1 = full burst
};
fn fx_bbHash(c: vec2<f32>) -> vec3<f32> {
  var p3 = fract(vec3(c.x, c.y, c.x) * vec3(0.1031, 0.1030, 0.0973));
  p3 += dot(p3, p3.yxz + 33.33); return fract((p3.xxy + p3.yxx) * p3.zyx); }
fn fx_bbFold(x: f32, hh: f32) -> f32 {                     // bounce inside -hh to hh
  let w = 4. * hh; let m = (x + hh) - w * floor((x + hh) / w);
  return 2. * hh - abs(m - 2. * hh) - hh; }
fn fx_ballburst_1(p: vec2<f32>, k: FxBallBurst, s: FxSubject) -> vec4<f32> {
  let pr = clamp(k.progress, 0., 1.);
  let fade = 1. - smoothstep(0.6, 1., pr);                  // gone by the end
  let n = min(i32(round(k.count)), FX_BB_MAX);
  if (fade <= 0. || n <= 0 || k.amount <= 0.) { return vec4(0.); }
  let roll = 1. - pow(1. - pr, 3.);                         // fast at the burst, slowing to a stop at the end
  let grow = smoothstep(0., 0.04, pr);                      // the balls grow out of the subject
  let lift = k.height * sin(3.14159265 * clamp(pr / 0.1, 0., 1.));   // pop up toward the camera and land in the first tenth
  let rad = 0.5 * k.size * grow * (1. + lift);
  if (rad <= 0.) { return vec4(0.); }
  let ctr = 0.5 * (s.bmin + s.bmax); let bs = s.bmax - s.bmin; let rs = max(0.5 * max(bs.x, bs.y), 1e-4);
  let hb = max(s.half - vec2(rad), vec2(1e-3));
  let Dmax = k.distance * k.amount * 2. * s.half.x * roll;
  var best = -1.; var bestC = vec2(0.); var bestN = vec3(0.); var bestCov = 0.;
  for (var i = 0; i < n; i++) {
    let r0 = fx_bbHash(vec2(f32(i) + 0.5, k.seed * 17.31 + 3.7));      // where it starts
    let rn = fx_bbHash(vec2(f32(i) + 0.5, k.seed * 17.31 + 91.1));     // where it goes
    let c0 = s.bmin + r0.xy * bs;
    let dir = normalize((c0 - ctr) / rs + (rn.xy * 2. - 1.) * 1.2 + vec2(1e-4, 0.));
    let q = c0 + dir * Dmax * (0.3 + 0.7 * rn.z);
    let P = vec2(fx_bbFold(q.x, hb.x), fx_bbFold(q.y, hb.y));
    let d = length(p - P);
    if (d > rad + s.px) { continue; }
    if (r0.z <= best) { continue; }                         // which ball is on top where two overlap
    if (fx_source_1(c0, s.px).a <= 0.5) { continue; }      // only balls that start on the subject
    best = r0.z; bestC = c0;
    let e = (p - P) / rad; bestN = vec3(e, sqrt(max(1. - dot(e, e), 0.)));
    bestCov = clamp((rad - d) / s.px + 0.5, 0., 1.);
  }
  if (best < 0.) { return vec4(0.); }
  let bc = fx_source_1(bestC, s.px).rgb;                    // the ball's colour: the picture where it started
  let L = normalize(vec3(-0.5, 0.6, 0.8));
  let dif = max(dot(bestN, L), 0.); let spec = pow(max(dot(reflect(-L, bestN), vec3(0., 0., 1.)), 0.), 24.);
  return vec4(bc * (0.3 + 0.7 * dif) + 0.25 * spec, bestCov * fade); }
fn fx_ballburst_2(p: vec2<f32>, k: FxBallBurst, s: FxSubject) -> vec4<f32> {
  let pr = clamp(k.progress, 0., 1.);
  let fade = 1. - smoothstep(0.6, 1., pr);                  // gone by the end
  let n = min(i32(round(k.count)), FX_BB_MAX);
  if (fade <= 0. || n <= 0 || k.amount <= 0.) { return vec4(0.); }
  let roll = 1. - pow(1. - pr, 3.);                         // fast at the burst, slowing to a stop at the end
  let grow = smoothstep(0., 0.04, pr);                      // the balls grow out of the subject
  let lift = k.height * sin(3.14159265 * clamp(pr / 0.1, 0., 1.));   // pop up toward the camera and land in the first tenth
  let rad = 0.5 * k.size * grow * (1. + lift);
  if (rad <= 0.) { return vec4(0.); }
  let ctr = 0.5 * (s.bmin + s.bmax); let bs = s.bmax - s.bmin; let rs = max(0.5 * max(bs.x, bs.y), 1e-4);
  let hb = max(s.half - vec2(rad), vec2(1e-3));
  let Dmax = k.distance * k.amount * 2. * s.half.x * roll;
  var best = -1.; var bestC = vec2(0.); var bestN = vec3(0.); var bestCov = 0.;
  for (var i = 0; i < n; i++) {
    let r0 = fx_bbHash(vec2(f32(i) + 0.5, k.seed * 17.31 + 3.7));      // where it starts
    let rn = fx_bbHash(vec2(f32(i) + 0.5, k.seed * 17.31 + 91.1));     // where it goes
    let c0 = s.bmin + r0.xy * bs;
    let dir = normalize((c0 - ctr) / rs + (rn.xy * 2. - 1.) * 1.2 + vec2(1e-4, 0.));
    let q = c0 + dir * Dmax * (0.3 + 0.7 * rn.z);
    let P = vec2(fx_bbFold(q.x, hb.x), fx_bbFold(q.y, hb.y));
    let d = length(p - P);
    if (d > rad + s.px) { continue; }
    if (r0.z <= best) { continue; }                         // which ball is on top where two overlap
    if (fx_source_2(c0, s.px).a <= 0.5) { continue; }      // only balls that start on the subject
    best = r0.z; bestC = c0;
    let e = (p - P) / rad; bestN = vec3(e, sqrt(max(1. - dot(e, e), 0.)));
    bestCov = clamp((rad - d) / s.px + 0.5, 0., 1.);
  }
  if (best < 0.) { return vec4(0.); }
  let bc = fx_source_2(bestC, s.px).rgb;                    // the ball's colour: the picture where it started
  let L = normalize(vec3(-0.5, 0.6, 0.8));
  let dif = max(dot(bestN, L), 0.); let spec = pow(max(dot(reflect(-L, bestN), vec3(0., 0., 1.)), 0.), 24.);
  return vec4(bc * (0.3 + 0.7 * dif) + 0.25 * spec, bestCov * fade); }
fn fx_ballburst_3(p: vec2<f32>, k: FxBallBurst, s: FxSubject) -> vec4<f32> {
  let pr = clamp(k.progress, 0., 1.);
  let fade = 1. - smoothstep(0.6, 1., pr);                  // gone by the end
  let n = min(i32(round(k.count)), FX_BB_MAX);
  if (fade <= 0. || n <= 0 || k.amount <= 0.) { return vec4(0.); }
  let roll = 1. - pow(1. - pr, 3.);                         // fast at the burst, slowing to a stop at the end
  let grow = smoothstep(0., 0.04, pr);                      // the balls grow out of the subject
  let lift = k.height * sin(3.14159265 * clamp(pr / 0.1, 0., 1.));   // pop up toward the camera and land in the first tenth
  let rad = 0.5 * k.size * grow * (1. + lift);
  if (rad <= 0.) { return vec4(0.); }
  let ctr = 0.5 * (s.bmin + s.bmax); let bs = s.bmax - s.bmin; let rs = max(0.5 * max(bs.x, bs.y), 1e-4);
  let hb = max(s.half - vec2(rad), vec2(1e-3));
  let Dmax = k.distance * k.amount * 2. * s.half.x * roll;
  var best = -1.; var bestC = vec2(0.); var bestN = vec3(0.); var bestCov = 0.;
  for (var i = 0; i < n; i++) {
    let r0 = fx_bbHash(vec2(f32(i) + 0.5, k.seed * 17.31 + 3.7));      // where it starts
    let rn = fx_bbHash(vec2(f32(i) + 0.5, k.seed * 17.31 + 91.1));     // where it goes
    let c0 = s.bmin + r0.xy * bs;
    let dir = normalize((c0 - ctr) / rs + (rn.xy * 2. - 1.) * 1.2 + vec2(1e-4, 0.));
    let q = c0 + dir * Dmax * (0.3 + 0.7 * rn.z);
    let P = vec2(fx_bbFold(q.x, hb.x), fx_bbFold(q.y, hb.y));
    let d = length(p - P);
    if (d > rad + s.px) { continue; }
    if (r0.z <= best) { continue; }                         // which ball is on top where two overlap
    if (fx_source_3(c0, s.px).a <= 0.5) { continue; }      // only balls that start on the subject
    best = r0.z; bestC = c0;
    let e = (p - P) / rad; bestN = vec3(e, sqrt(max(1. - dot(e, e), 0.)));
    bestCov = clamp((rad - d) / s.px + 0.5, 0., 1.);
  }
  if (best < 0.) { return vec4(0.); }
  let bc = fx_source_3(bestC, s.px).rgb;                    // the ball's colour: the picture where it started
  let L = normalize(vec3(-0.5, 0.6, 0.8));
  let dif = max(dot(bestN, L), 0.); let spec = pow(max(dot(reflect(-L, bestN), vec3(0., 0., 1.)), 0.), 24.);
  return vec4(bc * (0.3 + 0.7 * dif) + 0.25 * spec, bestCov * fade); }

// ======== AUTHORING HARNESS: the full shader; each zone is the subject of its own burst ========
// Camera: flat, head-on; SH_FRAME_H metres across the frame height (the source frame: -1 to 1 high).
const SH_FRAME_H: f32 = 2.;
const SH_LOOP_BEATS: f32 = 256.;  // Loop: 64 bars x 4 beats
var<private> fxAsp: f32;                                   // canvas aspect
fn stdFrameInv(q: vec2<f32>) -> vec2<f32> {                // back through stdFrame (SCALE, ROTATION, OFFSET, PIVOT; not TILE)
  let piv = settings[2].xy; let a = settings[0].y * 0.01745329; let c = cos(a); let s = sin(a); let d = q - piv;
  return vec2(c * d.x - s * d.y, s * d.x + c * d.y) * settings[0].x + settings[0].zw + piv; }
fn shZoneAt(p: vec2<f32>, r0: f32, r1: f32) -> vec4<f32> { // the zones at canvas point p, only between r0 and r1 metres
  let uv = stdFrame(p, fxAsp) * SH_FRAME_H * 0.5; let d = length(uv);
  if (d < r0 || d >= r1) { return vec4(0.); }
  return sh_zones(uv); }
fn fx_source_1(p: vec2<f32>, fw: f32) -> vec4<f32> { return shZoneAt(p, 0., shR1); }            // the hook: zone_01
fn fx_source_2(p: vec2<f32>, fw: f32) -> vec4<f32> { return shZoneAt(p, shR1, shR2); }    // the hook: zone_02
fn fx_source_3(p: vec2<f32>, fw: f32) -> vec4<f32> { return shZoneAt(p, shR2, shR3); }    // the hook: zone_03
fn shSubject(rm: f32, asp: f32, px: f32) -> FxSubject {    // a zone's resting box on the canvas (outer radius rm metres)
  let r = rm * 2. / SH_FRAME_H;                            // frame units
  let k0 = stdFrameInv(vec2(-r, -r)); let k1 = stdFrameInv(vec2(r, -r)); let k2 = stdFrameInv(vec2(-r, r)); let k3 = stdFrameInv(vec2(r, r));
  var s: FxSubject; s.bmin = min(min(k0, k1), min(k2, k3)); s.bmax = max(max(k0, k1), max(k2, k3));
  s.half = vec2(asp, 1.); s.px = px; return s; }
@fragment fn fs(in: VO) -> @location(0) vec4<f32> {
  let res = max(u.v[8].xy, vec2(1., 1.));                  // canvas resolution (px), slots 32 to 33
  let asp = res.x / res.y;
  let p0 = vec2(in.uv.x * asp, in.uv.y);                   // the canvas: frame units, y up, half-height = 1
  let pix = 2. / res.y;                                    // one pixel in frame units
  fxAsp = asp;
  let REACT = settings[1].y;
  // zone_01 pump: like a speaker cone, out on each beat and back (beatPhase, slot 14), only while drum activity (slot 26) is over 0.5; drum lane gate (slot 9) x REACT
  let beatPush = settings[5].x * pow(1. - f(14u), 3.);    // PUMP, out on each beat and back (beatPhase, slot 14)
  let pump = beatPush * step(SH_PUMP_DRUM, f(26u)) * f(9u) * REACT;   // zone_01: drum activity (slot 26) over 0.5 x drum lane gate (slot 9)
  let paceRow = amuRow(4u, i32(u.v[3].w));                 // this pace span's row of the AMU span tables (pace index, slot 15)
  let topPace = select(0., 1., paceRow.lvl.y > 0.5 && paceRow.lvl.y < 1.5);   // pace level 1 = the song's highest pace
  let ringPump = beatPush * topPace * f(7u) * REACT;       // all three rings: pace lane gate (slot 7)
  shR1 = SH_ZONE1_R * (1. + max(pump, ringPump));
  shR2 = SH_ZONE2_R * (1. + ringPump);
  shR3 = SH_ZONE3_R * (1. + ringPump);
  var k: FxBallBurst;                                      // shared controls (row 3)
  let secN = amuT.head[0].y;                               // the song's section count (AMU span tables)
  let songSec = clamp(u.v[5].x / max(secN - 1., 1.), 0., 1.);   // 0 in the first section to 1 in the last (section index, slot 20)
  k.count = mix(settings[4].x, settings[5].y, songSec);    // START_BALLS to MAX_BALLS, a step up every section
  k.size = settings[4].y / 540.;                           // BALL_SIZE, frame units (1080 px = 2)
  k.distance = settings[4].z; k.height = settings[4].w;
  var col = sh_viz(stdFrame(p0, asp) * SH_FRAME_H * 0.5, 0.);   // background and the solid rings
  // zone_03 on the phrase: phrase progress (slot 19), phrase index (slot 21), phrase lane gate (slot 4) x REACT
  var k3 = k; k3.progress = f(19u); k3.seed = f(21u); k3.amount = f(4u) * REACT;
  let fx3 = fx_ballburst_3(p0, k3, shSubject(shR3, asp, pix)); col = mix(col, fx3.rgb, fx3.a);
  // zone_02 on the segment: segment progress (slot 18); no segment index in the contract, so the seed follows the section and phrase indexes; segment lane gate (slot 3) x REACT
  var k2 = k; k2.progress = f(18u); k2.seed = f(20u) * 31.7 + f(21u) * 7.3 + 0.5; k2.amount = f(3u) * REACT;
  let fx2 = fx_ballburst_2(p0, k2, shSubject(shR2, asp, pix)); col = mix(col, fx2.rgb, fx2.a);
  // zone_01 on the section: section progress (slot 17), section index (slot 20), section lane gate (slot 2) x REACT
  var k1 = k; k1.progress = f(17u); k1.seed = f(20u); k1.amount = f(2u) * REACT;
  let fx1 = fx_ballburst_1(p0, k1, shSubject(shR1, asp, pix)); col = mix(col, fx1.rgb, fx1.a);
  col = stdHSV(col);   // standard settings: HUE, SATURATION, VALUE
  col = max((col - 0.5) * settings[3].y + 0.5, vec3(0.));   // standard setting: CONTRAST
  // TEMPORARY check strip (test, remove after): white along the bottom 3% of the frame, as far across as the section is through the song's sections
  if (in.uv.y < -0.94 && in.uv.x * 0.5 + 0.5 < songSec) { col = vec3(1.); }
  // [authoring overlay probe]
  return vec4(clamp(col, vec3(0.), vec3(1.)), 1.);
}
