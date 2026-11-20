// OMS_Vizzie_Shader_TunnelDot_V12 · visualizer
// @title Tunnel Dot
// @author ItsWesSmithYo, Claude, Shadertoy
// @type visualizer
// @desc black and white stripes rushing into a square pyramid tunnel toward a red medallion that spins, pumps on the beat with the drums and bends the walls with the bass, flat, hard edged
// Source: Shadertoy w3BSRd "Tunnel Dot" (header: Geometric Pyramid Tunnel Shader, Inspired by black and white striped pyramid with red endpoint), GLSL, converted to WGSL on the Vizzie contract.
// Loop: 16 bars
// Size: 2 m frame height; the tunnel fills the whole frame at any shape (16:9, 1:1, 9:16), its mouth the frame's own proportions; red dot 0.23 m across, extruded 5 cm, with a 2 cm wide, 2 cm thick line along y across its diameter, at 16:9 and 1:1, scaled to the frame's short side
// Run date: 2026-11-14
// Current Unix Epoch: 1794686409
// Built from: OMS_Vizzie_Shader_TunnelDot_V11, on OMS_Vizzie_Beta_V1_3_25a (template carried by the app)
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

// ======== VISUALIZER: td_viz(frame point, short-side point, loop phase 0 to 1) ========
// V02: the tunnel fills the frame at any shape. n = the frame point, -1 to 1 on both axes (the mouth takes the frame's proportions);
// s = the point in halves of the frame's short side (round things: the dot scales with the short side, never cut off).
// V05: no feathering or gradients anywhere: every edge is hard, with one pixel of anti-aliasing only; flat colours.
// Loop: 16 bars (30 s at 128 BPM). Per loop: stripes 24 passes (exact, as the source); depth breathing 1 cycle; dot_01 and line_01 turn clockwise 1 per bar on vizzie.barPhase (V08: line vertical on every bar's downbeat, e.g. 1.1.1).
const TD_WHITE = vec3<f32>(1.0, 1.0, 1.0);    // stripes_01: source white (on black)
const TD_RED = vec3<f32>(1.0, 0.0, 0.0);      // dot_01: source red
const TD_GREY = vec3<f32>(0.5, 0.5, 0.5);     // background: source grey
const TD_EDGE: f32 = 0.8;     // V02: the frame edge sits at the source's pyramid 0.8, where its edge fade starts: stripes to the edge, no grey in frame
const TD_ROUND: f32 = 0.5333; // V02: source units per short-side half (the source mouth's half-height 0.667 x TD_EDGE): the dot keeps its size to the tunnel
// dot_01 (V03, V04): a plastic medallion: a flat disc, half V02's size so it sits further back, hard edged, extruded 5 cm.
// V04: orthographic, face on: only the face shows; the 5 cm depth and the side wall colour are kept for positioning later.
const TD_DOT_R: f32 = 0.1172;     // radius, short-side halves (= m at 16:9 and 1:1): 0.23 m across, 50% of V02's 0.47 m
const TD_DOT_DEPTH: f32 = 0.05;   // extrusion, short-side halves (= m at 16:9 and 1:1): 5 cm
const TD_DOT_SIDE_COL = vec3<f32>(0.55, 0.0, 0.0);   // side wall: TD_RED in shade (not seen face on; for positioning later)
// line_01 (V06): a bar on the dot's face, along y through its centre, as long as the dot's diameter (2 x TD_DOT_R)
const TD_LINE_W: f32 = 0.02;      // width, short-side halves (= m at 16:9 and 1:1): 2 cm
const TD_LINE_DEPTH: f32 = 0.02;  // thickness (extrusion), short-side halves: 2 cm (not seen face on; for positioning later)
const TD_LINE_COL = vec3<f32>(0.0, 0.0, 0.0);   // black
const TD_BG_SHOW: f32 = 1.;
const TD_STRIPES_SHOW: f32 = 1.;
const TD_DOT_SHOW: f32 = 1.;
const TD_LINE_SHOW: f32 = 1.;
// Proximity (V09): line_01's axis, carried out through the tunnel walls as it turns, bends stripes_01 near it (as Geometry Proximity driving a displace)
const TD_BEND: f32 = 0.15;        // the walls pushed outward by this fraction on the line's axis (negative = inward)
const TD_BASS_ON: f32 = 0.5;     // V10: proximity only while the bass (AMU instrument activity) is over this
const TD_AMU_EASE: f32 = 0.05;   // V12: the AMU switches ease in over this much lane value: 0.50 to 0.55 (bass and drums)
const TD_BEND_W: f32 = 0.3;       // reach either side of the axis, as the sine of the angle from it (0.3 = about 17 degrees); the bend eases to 0 at the edge
// Pump (V11): dot_01 and line_01 scale up on each beat and settle back through it, only while the drums are over TD_DRUM_ON
const TD_PUMP: f32 = 0.2;         // scale added on the beat (0.2 = 20% bigger), easing back to 1 by the next beat
const TD_DRUM_ON: f32 = 0.5;      // pump only while the drums (AMU instrument activity) are over this
const TD_SPIN_PER_BAR: f32 = 1.;  // V07: dot_01 and line_01 turn clockwise in the xy plane about the dot's centre, whole turns per bar; V08: on vizzie.barPhase, so the line is vertical on every downbeat
fn td_viz(n: vec2<f32>, s: vec2<f32>, ph: f32, aa: f32, bp: f32, bass: f32, bt: f32, drum: f32) -> vec3<f32> {   // bp: vizzie.barPhase, 0 on the bar's downbeat (V08) · aa: one pixel, short-side halves (V03: hard dot edge) · bass: the bass lane (V10) · bt: vizzie.beatPhase, drum: the drum lane (V11)
  let pyr = max(abs(n.x), abs(n.y)) * TD_EDGE;                                      // V02: square rings in frame proportions (was the source's x 1.2, y 1.5)
  let persp = 0.5 + 0.5 * (sin(ph * TAU) * 0.2 + 0.8);                              // depth breathing: 1 per loop
  let sa = bp * TD_SPIN_PER_BAR * TAU;                                               // V08: spin angle, clockwise, 0 (line vertical) on each downbeat (was the loop phase x 16)
  let sp = vec2(cos(sa) * s.x - sin(sa) * s.y, sin(sa) * s.x + cos(sa) * s.y);      // the point in the medallion's own space (turning the point back = the medallion clockwise)
  let prox = (1. - smoothstep(0., TD_BEND_W, abs(sp.x) / max(length(sp), 1e-4))) * smoothstep(TD_BASS_ON, TD_BASS_ON + TD_AMU_EASE, bass);   // V09: proximity to the line's axis, 1 on it, 0 past TD_BEND_W · V10: only while bass > TD_BASS_ON · V12: eased in from 0.50 to 0.55
  let pyrB = pyr / (1. + TD_BEND * prox);                                           // V09: the walls bent: a ring near the axis sits TD_BEND further out
  let sv = 1. / pyrB * persp + ph * 24.;                                            // 24 passes per loop, inward (V09: on the bent walls)
  let stripes = clamp((0.25 - abs(fract(sv + 0.25) - 0.5)) / max(fwidth(sv), 1e-4) + 0.5, 0., 1.);   // V05: white where fract > 0.5, hard edge (was a 0.4 to 0.6 fade)
  let pump = 1. + TD_PUMP * (1. - bt) * (1. - bt) * smoothstep(TD_DRUM_ON, TD_DRUM_ON + TD_AMU_EASE, drum);   // V11: up on the beat, settling back through it; only while drum > TD_DRUM_ON · V12: eased in from 0.50 to 0.55
  let mp = sp / pump; let maa = aa / pump;                                          // V11: the medallion's own space, pumped (dot and bar together)
  let face = smoothstep(TD_DOT_R + maa, TD_DOT_R - maa, length(mp));               // dot_01 face: hard edge, one pixel of anti-aliasing
  let line = smoothstep(maa, -maa, max(abs(mp.x) - TD_LINE_W * 0.5, abs(mp.y) - TD_DOT_R));   // line_01: the bar, hard edge
  let edge = clamp((1. - pyr) / max(fwidth(pyr), 1e-4) + 0.5, 0., 1.);            // V05: the tunnel mouth, hard edge at the source's pyramid 1 (was a 0.8 to 1 fade)
  var color = mix(vec3(0.), TD_WHITE, stripes * TD_STRIPES_SHOW);                  // stripes_01
  color = mix(color, TD_RED, face * TD_DOT_SHOW);                                  // dot_01: face
  color = mix(color, TD_LINE_COL, line * TD_LINE_SHOW);                            // line_01
  color = mix(TD_GREY * TD_BG_SHOW, color, edge);                                  // background beyond the tunnel mouth (outside the frame unless SCALE < 1)
  return color; }

// ======== AUTHORING HARNESS: the full shader around td_viz ========
// Camera: flat, head-on; 2 m across the frame height; the tunnel fills the frame (V02).
const TD_FRAME_H: f32 = 2.;
const TD_LOOP_BEATS: f32 = 64.;  // Loop: 16 bars x 4 beats
@fragment fn fs(in: VO) -> @location(0) vec4<f32> {
  let t = f(13u) * settings[1].x + settings[2].w;          // vizzie.time (beats) x SPEED + TIME_OFFSET
  let res = max(u.v[8].xy, vec2(1., 1.));                  // canvas resolution (px), slots 32 to 33
  let asp = res.x / res.y;
  let p = stdFrame(vec2(in.uv.x * asp, in.uv.y), asp);     // frame units, y up, half-height = 1 · standard settings: TILE, SCALE, ROTATION, OFFSET, PIVOT
  let n = p / vec2(asp, 1.);                                // V02: the frame, -1 to 1 on both axes (16:9, 1:1, 9:16 alike)
  let s = p / min(asp, 1.);                                 // V02: halves of the frame's short side
  let ph = fract(t / TD_LOOP_BEATS);                      // loop phase (R20)
  let aa = max(fwidth(length(s)), 1e-4);                   // V03: one pixel, short-side halves
  let bp = f(16u);                                          // V08: vizzie.barPhase (slot 16), the readout's position in the bar
  let bass = f(27u) * f(10u) * settings[1].y;              // V10: amu bass activity (slot 27) x the bass lane's gate (slot 10, solo / knob) x REACT
  let bt = f(14u);                                          // V11: vizzie.beatPhase (slot 14), 0 on the beat
  let drum = f(26u) * f(9u) * settings[1].y;               // V11: amu drum activity (slot 26) x the drum lane's gate (slot 9, solo / knob) x REACT
  var col = td_viz(n, s, ph, aa, bp, bass, bt, drum);
  col = stdHSV(col);   // standard settings: HUE, SATURATION, VALUE
  col = max((col - 0.5) * settings[3].y + 0.5, vec3(0.));   // standard setting: CONTRAST
  // [authoring overlay probe]
  return vec4(clamp(col, vec3(0.), vec3(1.)), 1.);
}
