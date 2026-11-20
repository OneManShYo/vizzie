// OMS_Vizzie_Shader_TunnelOfOz_Twin_V01 · visualizer
// @title Tunnel of Oz Twin
// @author ItsWesSmithYo, Claude
// @type visualizer
// @desc two twelve-armed spirals of Barbie Pink and Green Slime turning against each other, crossed into a lattice of diamonds winding into the centre around a split dot; the pink ripples with the drums; each section a purple marble rolls out along a green arm, leaving fairy dust; dot_01's clone blasts into particles at each section's start
// Spawned from OMS_Vizzie_Shader_TunnelOfOz_Shadertoy_V14 (Wes Smith): one of four (Twin, Rings, Pinwheel, Zigzag), Claude's styling on the same palette and parts (bands_01, bands_02, dot_01, dot_02, dust_01, dot_01_clone), Wes 2026-11-19.
// Loop: 32 bars
// Size: 2 m frame height (the source frame, 1 unit high, taken as 2 m); spiral turns 0.17 m apart; dot_01 0.23 m across, extruded 5 cm, split in half; dot_02 0.044 m across
// Run date: 2026-11-19
// Current Unix Epoch: 1795103649
// Built from: OMS_Vizzie_Shader_TunnelOfOz_Shadertoy_V14, on OMS_Vizzie_Beta_V1_4_03a (template carried by the app)
// Vizzie uniform contract (V0.5.0A): binding 0 = 9 x vec4 (36 floats); binding 1 = settings, 16 x vec4: the template's standard fourteen (settings[0] to settings[3]). No image bindings.
struct U { v: array<vec4<f32>, 9>, };
@group(0) @binding(0) var<uniform> u: U;
@group(0) @binding(1) var<uniform> settings: array<vec4<f32>, 16>;

// ---- SETTINGS: the template's standard fourteen (R13), settings[0] to settings[3]: rows 1 and 2 of the rack. No settings of its own. ----
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

// V11: CC Scatterize on dot_01 at the start of each section: the effect pasted in unchanged from OMS_Vizzie_Shader_Effects_CCScatterize_BoxBotSquint_V02
// (EFFECT COMMON + EFFECT: CC Scatterize, drop-in); this shader is its host: fx_source = dot_01, the controls driven by the section progress.
const OZ_SCAT_P: f32 = 0.125;      // the scatter runs over the first 1/8 of each section (one bar of an 8-bar section): from the downbeat the clone blasts out and its particles dissipate, gone by 1/8 (V14)
const OZ_SCAT_MAX: f32 = 0.12;     // the spread at the end of the blast (V14), source units (about 24 cm; dot_01 is 0.23 m across)
const OZ_DOT_CLONE_SHOW: f32 = 1.;   // dot_01_clone (V13): dot_01 drawn a second time, through CC Scatterize, over dot_01, which stays whole
const OZ_SCAT_SIZE: f32 = 0.004;   // particle size, source units (about 8 mm), fixed through the blast (V14)
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

// ======== EFFECT: CC Scatterize (After Effects Simulation > CC Scatterize), drop-in. Needs fx_source. ========
struct FxScatterize {
  scatter: f32,          // how far the particles spread, in p's units
  right: f32,            // swirl of the particles on the subject's right, degrees (more toward the edge)
  left: f32,             // swirl on its left, degrees
  size: f32,             // particle size, in p's units
};
fn fx_scHash(c: vec2<f32>) -> vec3<f32> {
  var p3 = fract(vec3(c.x, c.y, c.x) * vec3(0.1031, 0.1030, 0.0973));
  p3 += dot(p3, p3.yxz + 33.33); return fract((p3.xxy + p3.yxx) * p3.zyx); }
fn fx_scatterize(p: vec2<f32>, k: FxScatterize, s: FxSubject) -> vec4<f32> {
  let ps = max(k.size, 1e-4);
  let cell = floor(p / ps); let cc = (cell + 0.5) * ps;
  let h = fx_scHash(cell);
  let sr = sqrt(h.x) * k.scatter; let sa = h.y * 6.28318;
  let side = clamp((cc.x - 0.5 * (s.bmin.x + s.bmax.x)) / max(0.5 * (s.bmax.x - s.bmin.x), 1e-4), -1., 1.);   // -1 the subject's left edge, 1 its right
  let tw = select(k.left * -side, k.right * side, side >= 0.) * h.z * 0.01745329;
  let ct = cos(tw); let st = sin(tw);
  let src = vec2(ct * cc.x + st * cc.y, -st * cc.x + ct * cc.y) + sr * vec2(cos(sa), sin(sa));   // where the particle came from
  let c = fx_source(src, s.px);
  if (c.a > 0.5) { return c; }                              // a particle only where it came from the subject
  return vec4(0.); }

// ======== HOST for CC Scatterize: dot_01 as the effect's subject ========
var<private> ozTh: f32;            // dot_01's split-line turn now, set in oz_viz before the effect is called
fn fx_source(p: vec2<f32>, fw: f32) -> vec4<f32> {   // the hook: dot_01 at p, flat, split, straight colour + coverage
  let m = smoothstep(OZ_DOT_R + fw, OZ_DOT_R - fw, length(p));
  let sy = cos(ozTh) * p.y - sin(ozTh) * p.x;
  return vec4(mix(OZ_BANDS_01_COL, OZ_BANDS_02_COL, smoothstep(-fw, fw, sy)), m); }

fn oz_hash(n: f32) -> f32 { return fract(sin(n * 127.1) * 43758.5453); }   // V10: a fixed random number per speck and twinkle step

// ======== VISUALIZER (Twin): oz_viz(source point, loop phase 0 to 1) ========
// Source units: the frame is 1 high, centred. Loop: 32 bars (60 s at 128 BPM).
// Per loop: the spiral winds in 32 times, once per bar (V07; was 30, as the source); wobble 2 and 10 (whole cycles, about 5% faster than the source).
// V06: design system colours, fixed: bands_01 Barbie Pink, bands_02 Green Slime, dot_01 Orange Julius (the colour cycle and its palette taken out).
// V05: no effects: the colour sweep, depth darkening and pulse are taken out; band edges hard (one pixel); every object one flat colour per frame.
// dot_01 (V04, was glow_01): a flat disc at the centre, hard edged, extruded 5 cm; drawn over the picture.
// V07: split in half by a line through its centre, turning once per bar with the spiral, horizontal on every downbeat (bar.1).
// Each half takes the colour opposite the band it touches: the half against bands_01 (Barbie Pink) is Green Slime, the half against bands_02 (Green Slime) is Barbie Pink.
const OZ_BANDS_01_COL = vec3<f32>(0.8784314, 0.1294118, 0.5411765);   // bands_01: Barbie Pink #E0218A
const OZ_BANDS_02_COL = vec3<f32>(0.3960784, 1.0, 0.0);               // bands_02: Green Slime #65FF00
const OZ_DOT_R: f32 = 0.0586;     // radius, source units (1 = the 2 m frame height): 0.23 m across
const OZ_DOT_DEPTH: f32 = 0.025;  // extrusion, source units: 5 cm (flat, head-on: not seen; kept for positioning later)
// V08: drum ripple on bands_01: when drum activity (AMU lane drum) is above OZ_DRUM_GATE, a wave runs along bands_01's edges (like a Wave Texture driving a displace)
const OZ_DRUM_GATE: f32 = 0.5;    // drum activity above this starts the ripple; it reaches full strength at 1
const OZ_RIPPLE_AMT: f32 = 0.06;  // full-strength ripple: the edges move up to this fraction of a spiral turn (about 1 cm; turns are 0.17 m apart)
const OZ_RIPPLE_ARMS: f32 = 8.;   // waves around the circle
const OZ_RIPPLE_RINGS: f32 = 40.; // waves along the radius, per source unit
const OZ_RIPPLE_PER_LOOP: f32 = 128.;   // the wave runs outward 128 times per loop: once per beat
// V09: dot_02: a small dot, 1/8 of dot_01, that comes out from behind dot_01 at the start of each section and rolls out along the middle of bands_02
// over the section (AMU section progress), all the way to the frame's corner, turning with the spiral
const OZ_DOT_02_COL = vec3<f32>(0.6980392, 0.3019608, 1.0);   // dot_02: Purple People Eater #B24DFF (V10)
const OZ_DOT_02_R: f32 = 0.0586 / 8. * 1.5;              // radius, source units: 1.5 x V09's 1/8 of dot_01 (V10: 0.044 m across; a band is 0.083 m wide)
const OZ_DOT_02_SHOW: f32 = 1.;
// V10: dust_01: fairy dust left behind dot_02 along its path: small specks, smallest at the far end, scattered a little across the path, twinkling on and off on the music clock
const OZ_DUST_COL = vec3<f32>(0.6980392, 0.3019608, 1.0);     // Purple People Eater #B24DFF
const OZ_DUST_N: i32 = 12;          // specks in the trail
const OZ_DUST_GAP: f32 = 0.012;     // spacing along the path, source units (about 2.4 cm)
const OZ_DUST_SIZE: f32 = 0.35;     // the nearest speck's radius, of dot_02's; each one further back smaller
const OZ_DUST_SPREAD: f32 = 0.02;   // scatter across the path, source units (about 4 cm, inside the band)
const OZ_DUST_TICKS: f32 = 512.;    // twinkle steps per loop: every 16th note
const OZ_DUST_SHOW: f32 = 1.;
const OZ_WINDS: f32 = 32.;                    // V07: spiral windings per loop: one per bar, so the dot's split line meets the bands on every downbeat
const OZ_BANDS_01_SHOW: f32 = 1.;
const OZ_BANDS_02_SHOW: f32 = 1.;
const OZ_DOT_SHOW: f32 = 1.;
// Twin: a second spiral, the other way round, crossed with the first (exclusive or)
fn oz_viz(c: vec2<f32>, ph: f32, aa: f32, drum: f32, sec: vec3<f32>) -> vec3<f32> {   // aa: one pixel, source units (V04: the dot's hard edge) · drum: the ripple's strength 0 to 1 (V08) · sec (V09): section progress 0 to 1, its gate, the radius where dot_02 leaves the frame
  let d = length(c);
  let a = atan2(c.y, c.x);
  var spiral = d * 12. + a / TAU - ph * OZ_WINDS - OZ_DOT_R * 12.;              // the first spiral, as V14 (the marble rolls along it)
  spiral += sin(d * 10. + ph * 10. * TAU) * (sin(ph * 2. * TAU) * 0.05);            // wobble
  let rip = sin(a * OZ_RIPPLE_ARMS + d * OZ_RIPPLE_RINGS - ph * OZ_RIPPLE_PER_LOOP * TAU) * OZ_RIPPLE_AMT * drum;   // the drum ripple, as V14
  let spiral2 = d * 12. - a / TAU * 12. - ph * OZ_WINDS * 0.5;                     // Twin: the second spiral, twelve arms the other way round, half as fast
  let s1 = clamp((0.25 - abs(fract(spiral + rip) - 0.25)) / max(aa * 12., 1e-5) + 0.5, 0., 1.); let s2 = clamp((0.25 - abs(fract(spiral2 + rip) - 0.25)) / max(fwidth(spiral2), 1e-5) + 0.5, 0., 1.);
  let b01 = s1 + s2 - 2. * s1 * s2;                                                // Twin: bands_01 where exactly one spiral's band is (exclusive or): diamonds
  let bands = 1. - b01;                                                            // bands_02 fills the rest, so its edges follow the ripple
  let b1 = OZ_BANDS_01_COL;                                                        // bands_01: Barbie Pink, flat (V06)
  let b2 = OZ_BANDS_02_COL;                                                        // bands_02: Green Slime, flat (V06)
  var col = mix(b1 * OZ_BANDS_01_SHOW, b2 * OZ_BANDS_02_SHOW, bands);               // bands_01 (b1), bands_02 (b2): the two sets of spirals
  let rr = mix(OZ_DOT_R - OZ_DOT_02_R, sec.z + OZ_DOT_02_R, sec.x);                 // dot_02 (V09): its radius over the section, from behind dot_01 to past the frame corner
  let wob2 = sin(rr * 10. + ph * 10. * TAU) * (sin(ph * 2. * TAU) * 0.05);          // the spiral's wobble at that radius
  let a2 = TAU * (0.75 - (rr - OZ_DOT_R) * 12. + ph * OZ_WINDS - wob2);            // the angle where bands_02's middle line (fract 0.75) crosses that radius
  let m2 = smoothstep(OZ_DOT_02_R + aa, OZ_DOT_02_R - aa, length(c - rr * vec2(cos(a2), sin(a2)))) * sec.y;   // dot_02: the disc, hard edge, x the section gate
  var md = 0.;                                                                     // dust_01 (V10): the trail behind dot_02
  let tick = floor(ph * OZ_DUST_TICKS);
  for (var i = 1; i <= OZ_DUST_N; i++) {
    let fi = f32(i);
    let ri = rr - fi * OZ_DUST_GAP / (max(rr, OZ_DOT_R) * 12. * TAU);              // back along the path by fi x OZ_DUST_GAP
    let wi = sin(ri * 10. + ph * 10. * TAU) * (sin(ph * 2. * TAU) * 0.05);
    let ai = TAU * (0.75 - (ri - OZ_DOT_R) * 12. + ph * OZ_WINDS - wi);              // on bands_02's middle line, as dot_02
    let q = (ri + (oz_hash(fi + tick * 13.) - 0.5) * OZ_DUST_SPREAD) * vec2(cos(ai), sin(ai));   // scattered across the path
    let si = OZ_DOT_02_R * OZ_DUST_SIZE * (1. - (fi - 1.) / f32(OZ_DUST_N));        // smaller further back
    let on = step(0.35, oz_hash(fi * 7.3 + tick));                                 // twinkle: each speck on or off per 16th note
    md = max(md, smoothstep(si + aa, si - aa, length(c - q)) * on);
  }
  col = mix(col, OZ_DUST_COL, md * sec.y * OZ_DUST_SHOW);                          // dust_01, under dot_02
  col = mix(col, OZ_DOT_02_COL, m2 * OZ_DOT_02_SHOW);                              // dot_02, under dot_01
  ozTh = ph * OZ_WINDS * TAU;                                                      // V07: the split line's turn, counterclockwise with the spiral, 0 (horizontal) on each downbeat
  let d1 = fx_source(c, aa);                                                       // dot_01: the disc, hard edge; half against bands_01 (above the line on a downbeat) Green Slime, half against bands_02 Barbie Pink
  let dotm = d1.a; let dcol = d1.rgb;
  var km = 0.; var kcol = dcol;                                                    // dot_01_clone (V13): nothing outside the scatter
  let sx = sec.x / OZ_SCAT_P;                                                      // V12: through the scatter, 0 on the section's downbeat, 1 at 1/8 of the section
  if (sx < 1. && sec.y > 0.) {                                                     // V14: the blast: one way out, no return
    let ps = OZ_SCAT_SIZE;                                                         // particle size, fixed, so each particle keeps its place in the grid while it drops out
    var k: FxScatterize; k.scatter = OZ_SCAT_MAX * (1. - (1. - sx) * (1. - sx)); k.right = 0.; k.left = 0.; k.size = ps;   // spread: 0 on the downbeat, flying out fast then slowing
    var sb: FxSubject; sb.bmin = vec2(-OZ_DOT_R); sb.bmax = vec2(OZ_DOT_R); sb.half = vec2(1.); sb.px = aa;
    let e = fx_scatterize(c, k, sb);                                               // CC Scatterize on dot_01_clone (V13: dot_01 itself stays whole)
    let keep = step(oz_hash(dot(floor(c / ps), vec2(1.7, 113.3))), 1. - sx);      // dissipate: each particle drops out at its own moment, all gone by the end
    km = e.a * keep * sec.y; kcol = e.rgb;
  }
  col = mix(col, dcol, dotm * OZ_DOT_SHOW);                                        // dot_01, always whole
  col = mix(col, kcol, km * OZ_DOT_CLONE_SHOW);                                    // dot_01_clone: its particles, over dot_01
  return col; }

// ======== AUTHORING HARNESS: the full shader around oz_viz ========
// Camera: flat, head-on; 1 source unit across the frame height (2 m).
const OZ_FRAME_H: f32 = 2.;
const OZ_LOOP_BEATS: f32 = 128.;  // Loop: 32 bars x 4 beats
@fragment fn fs(in: VO) -> @location(0) vec4<f32> {
  let t = f(13u) * settings[1].x + settings[2].w;          // vizzie.time (beats) x SPEED + TIME_OFFSET
  let res = max(u.v[8].xy, vec2(1., 1.));                  // canvas resolution (px), slots 32 to 33
  let asp = res.x / res.y;
  let p = stdFrame(vec2(in.uv.x * asp, in.uv.y), asp);     // frame units, y up, half-height = 1 · standard settings: TILE, SCALE, ROTATION, OFFSET, PIVOT
  let uv = p * 0.5;   // the source's centred uv (1 unit = the frame height)
  let ph = fract(t / OZ_LOOP_BEATS);                      // loop phase (R20)
  let aa = max(round(settings[2].z), 1.) / (res.y * max(settings[0].x, 1e-3));   // one pixel in source units (TILE and SCALE)
  let drum = clamp((f(26u) - OZ_DRUM_GATE) / (1. - OZ_DRUM_GATE), 0., 1.) * f(9u) * settings[1].y;   // V08: drum activity above the gate, 0 to 1, x the drum lane knob x REACT
  let sec = vec3(f(17u), clamp(f(2u) * settings[1].y, 0., 1.), 0.5 * sqrt(asp * asp + 1.));   // V09: section progress, the section lane knob x REACT, the frame corner in source units
  var col = oz_viz(uv, ph, aa, drum, sec);
  col = stdHSV(col);   // standard settings: HUE, SATURATION, VALUE
  col = max((col - 0.5) * settings[3].y + 0.5, vec3(0.));   // standard setting: CONTRAST
  // [authoring overlay probe]
  return vec4(clamp(col, vec3(0.), vec3(1.)), 1.);
}
