// OMS_Vizzie_Shader_TunnelFunOne_V04 · visualizer
// @title Tunnel Fun One
// @author ItsWesSmithYo, Claude, Shadertoy
// @type visualizer
// @desc a black and white line tunnel rushing toward the viewer, rotating and twisting, its web played by the bass and its flash rings by the drums, with moire, grain, scanlines and a vignette
// Source: Shadertoy wX23Ry "Tunnel Fun One" (header: Rotating & Twisting Black and White Tunnel Shader), GLSL, converted to WGSL on the Vizzie contract.
// Loop: 32 bars
// Size: 2 m frame height (the source frame, -1 to 1 high, 1 unit = 1 m); V03: the tunnel fills the whole frame at any shape (16:9, 1:1, 9:16), the vignette in the frame's own proportions
// Run date: 2026-11-14
// Current Unix Epoch: 1794687319
// Built from: OMS_Vizzie_Shader_TunnelFunOne_V03, on OMS_Vizzie_Beta_V1_3_25a (template carried by the app)
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

const PI: f32 = 3.1415927;
const TAU: f32 = 6.2831853;

// ======== VISUALIZER: tf_viz(point in metres, loop phase 0 to 1, screen uv 0 to 1, resolution, frame point -1 to 1 on both axes) ========
// V03: the tunnel stays round (scaled by the short side, as the source); only the vignette takes the frame's proportions, so it fills 16:9, 1:1 and 9:16 alike.
// Loop: 32 bars (60 s at 128 BPM). The tunnel rushes in 30 times per loop (exact, as the source). The other motions are multiples of 0.1 rad/s and make whole cycles about 5% faster:
// rotation 3 turns, twist and brightness 5, line sway 7, ring pulse and flash drift 20.
const TF_WHITE = vec3<f32>(1.0, 1.0, 1.0);    // source white
const TF_LOOP_S: f32 = 60.;                   // source seconds per loop for the tunnel rush (32 bars at 128 BPM)
const TF_LINES_SHOW: f32 = 1.;
const TF_MOIRE_SHOW: f32 = 1.;
const TF_FLASH_SHOW: f32 = 1.;
const TF_GRAIN_SHOW: f32 = 1.;
const TF_VIG_R: f32 = 1.414;  // V03: vignette reach in frame half-sizes, in the frame's own proportions: 1.414 = black only at the very corners, the tunnel to every edge; 1 = black at the four edge centres, as the source at 1:1
// V04 lanes: lines_01 strength = bass, flash_01 strength = drum (each: AMU instrument activity x that lane's gate x REACT, 0 to 1)
fn tf_viz(p0: vec2<f32>, ph: f32, suv: vec2<f32>, res: vec2<f32>, nf: vec2<f32>, bass: f32, drum: f32) -> vec3<f32> {
  let w = ph * TAU;                                                                // 1 cycle per loop = 0.1 rad/s in the source
  let ang = w * 3.;                                                                // rotation: 3 turns per loop
  let p = mat2x2<f32>(cos(ang), -sin(ang), sin(ang), cos(ang)) * p0;               // the source's mat2 (same column order)
  let r = length(p);
  var a = atan2(p.y, p.x);
  let tunnel = 1. / (r + 0.5);
  a += r * (sin(w * 5.) * 2.);                                                     // twist
  let z = fract(tunnel + ph * TF_LOOP_S * 0.5);                                    // rush: 30 per loop
  var radial = abs(fract((a + r * sin(w * 7.)) / PI * 24. * 0.5) - 0.5);
  radial = smoothstep(0., 0.02, radial);
  let pulse = sin(w * 20.) * 0.1 + 0.9;
  let circ = smoothstep(0., 0.02, abs(fract(z * 15. * pulse) - 0.5));
  let lines = min(radial, circ);
  // the source's wave pattern (computed but never used): left out
  var col = vec3(0.);                                                              // background: black
  let li = (1. - lines) * z * 2.5;
  let bright = sin(w * 5.) * 0.2 + 0.8;
  col = mix(col, TF_WHITE * bright, bass * li * TF_LINES_SHOW);                // lines_01 (V04: x bass)
  let moire = sin(p.x * 40.) * sin(p.y * 40.) * 0.5 + 0.5;
  col = mix(col, TF_WHITE * moire, 0.05 * (1. - z) * TF_MOIRE_SHOW);               // moire_01
  let flash = step(0.98, sin(z * 30. + w * 20.));
  col = mix(col, TF_WHITE, flash * drum * 0.15 * TF_FLASH_SHOW);                // flash_01 (V04: x drum)
  col += vec3(fract(sin(dot(suv, vec2(12.9898, 78.233)) * 43758.5453)) * 0.03) * TF_GRAIN_SHOW;   // grain_01 (screen space)
  col = mix(col, vec3(0.), sin(suv.y * res.y * 1.5) * 0.05);                       // scanlines (screen pixels, as the source)
  col *= smoothstep(TF_VIG_R, 0.2 * TF_VIG_R, length(nf));                          // vignette (V03: in frame proportions, reaching the corners; was the short-side point, reach 1)
  return col; }

// ======== AUTHORING HARNESS: the full shader around tf_viz ========
// Camera: flat, head-on; TF_FRAME_H metres across the frame height (the source frame: -1 to 1 high).
const TF_FRAME_H: f32 = 2.;
const TF_LOOP_BEATS: f32 = 128.;  // Loop: 32 bars x 4 beats
@fragment fn fs(in: VO) -> @location(0) vec4<f32> {
  let t = f(13u) * settings[1].x + settings[2].w;          // vizzie.time (beats) x SPEED + TIME_OFFSET
  let res = max(u.v[8].xy, vec2(1., 1.));                  // canvas resolution (px), slots 32 to 33
  let asp = res.x / res.y;
  let p = stdFrame(vec2(in.uv.x * asp, in.uv.y), asp);     // frame units, y up, half-height = 1 · standard settings: TILE, SCALE, ROTATION, OFFSET, PIVOT
  let uv = p * select(1., 1. / asp, asp < 1.);   // the source's p: (2 fragCoord - resolution) / min(width, height)
  let ph = fract(t / TF_LOOP_BEATS);                      // loop phase (R20)
  let nf = p / vec2(asp, 1.);                              // V03: the frame, -1 to 1 on both axes (16:9, 1:1, 9:16 alike)
  let bass = f(27u) * f(10u) * settings[1].y;              // V04: amu bass activity (slot 27) x the bass lane's gate (slot 10, solo / knob) x REACT
  let drum = f(26u) * f(9u) * settings[1].y;               // V04: amu drum activity (slot 26) x the drum lane's gate (slot 9, solo / knob) x REACT
  var col = tf_viz(uv, ph, in.uv * 0.5 + 0.5, res, nf, bass, drum);
  col = stdHSV(col);   // standard settings: HUE, SATURATION, VALUE
  col = max((col - 0.5) * settings[3].y + 0.5, vec3(0.));   // standard setting: CONTRAST
  // [authoring overlay probe]
  return vec4(clamp(col, vec3(0.), vec3(1.)), 1.);
}
