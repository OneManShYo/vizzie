// OMS_Vizzie_Shader_TunnelTubes_Comet_V01 · visualizer
// @title Tunnel Tubes Comet
// @author ItsWesSmithYo, Claude
// @type visualizer
// @desc Comet: five balls per ring instead of 25, bigger heads with long tails that thin and fade (TT_COMET_TAIL), speeds rounded to multiples of five steps per loop (TT_COMET_STEPS); otherwise as V13: five concentric circular tracks, flat front view (ortho) before the song's first pace change, after its last, and whenever the pace is at its lowest level; otherwise each tumbling round the x-axis at its own rate (up to 2, 3, 4, 5, 6 turns per loop, polyrhythm positioning, only in the song's highest-pace sections), swinging round the z-axis with each segment (orthographic), in the OMS colours, brightest at the centre to darkest outside: Yellow Man, Green Slime, Orange Julius, Purple People Eater, Barbie Pink, each with 25 glowing balls racing round and trailing light, on black; balls on rings 1 to 4 swell and brighten with drum, bass, vocal and other
// Spawned from OMS_Vizzie_Shader_TunnelTubes_Shadertoy_V13 (Wes Smith): one of four (Comet, Dash, Atom, Breathe), Claude's styling on the same palette and parts (background, ring_01 to ring_05), Wes 2026-11-19.
// Loop: 8 bars
// Lanes: ring_01 balls = drum, ring_02 = bass, ring_03 = vocal, ring_04 = other (size and brightness x1 to x2, each x its lane knob x REACT); ring_05 none
// Motion: each track tumbles round the x-axis (pitch) on its own: ring_01 to ring_05 at 2, 3, 4, 5, 6 turns per loop (polyrhythm); all five flat together on the loop downbeat
// Motion: ortho hold: all five lie flat, front view (no tumble, no swing), before the first pace change, from the last pace change, and in every span at the lowest pace level (span tables, lane 4); eased over TT_ORTHO_EASE beats at each pace change; balls keep running and reacting
// Motion: polyrhythm positioning only in the highest-pace sections (span tables, binding 2: the section row's pace level = 1) x section lane knob x REACT; other sections: locked as one disc at 2 turns; eased in or out over the first TT_SPREAD_EASE beats of each section
// Motion: they swing back and forth round the z-axis (Blender Z, up; yaw) once per AMU segment: TT_YAW_DEG x sin(segment progress), x segment lane knob x REACT
// Size: 2 m frame height (the source frame, 1 unit high, taken as 2 m); orthographic front view: the tracks are true circles, 1 unit = 1 unit on both axes at any aspect
// Run date: 2026-11-19
// Current Unix Epoch: 1795106125
// Built from: OMS_Vizzie_Shader_TunnelTubes_Shadertoy_V13, on OMS_Vizzie_Beta_V1_4_03a (template carried by the app)
// Vizzie uniform contract (V0.5.0A): binding 0 = 9 x vec4 (36 floats); binding 1 = settings, 16 x vec4: the template's standard fourteen (settings[0] to settings[3]). binding 2 = the AMU span tables (V1.3.28a), read-only storage. No image bindings.
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

// ======== VISUALIZER (Comet): tt_viz(source point, loop phase 0 to 1) ========
// Source units: the frame is 1 high, centred; orthographic front view (V03): x and y on the same scale, tracks are circles. Loop: 8 bars (15 s at 128 BPM).
// Each ring of 25 balls looks the same after 1/25 turn, so each layer's speed (1, 0.85, 0.7, 0.55, 0.4 rad/s) is rounded to a whole number of ball steps per loop: 60, 51, 42, 33, 24 (each within 0.6%).
// Optimised: a layer's trails are skipped where the pixel is outside that layer's track band on the plane (they add nothing there); balls are drawn on screen, round, at any tilt.
const TT_STEPS = array<f32, 5>(60., 51., 42., 33., 24.);
const TT_C1 = vec3<f32>(1.0000, 0.9412, 0.0000);   // ring_01: Yellow Man #FFF000 (OMS key colour; luminance 0.836)
const TT_C2 = vec3<f32>(0.3961, 1.0000, 0.0000);   // ring_02: Green Slime #65FF00 (OMS key colour; luminance 0.743)
const TT_C3 = vec3<f32>(1.0000, 0.6471, 0.0000);   // ring_03: Orange Julius #FFA500 (OMS key colour; luminance 0.482)
const TT_C4 = vec3<f32>(0.6980, 0.3020, 1.0000);   // ring_04: Purple People Eater #B24DFF (OMS key colour; luminance 0.22)
const TT_C5 = vec3<f32>(0.8784, 0.1294, 0.5412);   // ring_05: Barbie Pink #E0218A (OMS key colour; luminance 0.188)
const TT_RING_SHOW: f32 = 1.;
const TT_TUMBLE = array<f32, 5>(2., 3., 4., 5., 6.);   // ring_01 to ring_05: turns round the x-axis per loop (whole numbers keep the loop seamless and realign every ring on the downbeat)
const TT_SPREAD_EASE: f32 = 4.;   // beats to ease polyrhythm positioning in or out at a section change (1 bar)
const TT_ORTHO_EASE: f32 = 4.;   // beats to ease into or out of the ortho hold at a pace change (1 bar)
const TT_YAW_DEG: f32 = 60.;      // z-axis swing, degrees each way, once per segment
const TT_COMET_STEPS = array<f32, 5>(60., 50., 40., 35., 25.);   // Comet: ball steps per loop, multiples of 5 so five balls loop seamlessly (within 4% of V13's speeds)
const TT_COMET_TAIL: f32 = 1.15;   // Comet: tail length, radians behind the head
fn tt_viz(uv: vec2<f32>, ph: f32, yaw: f32, spread: f32, mo: f32) -> vec3<f32> {
  var steps = TT_COMET_STEPS;
  var cols = array<vec3<f32>, 5>(TT_C1, TT_C2, TT_C3, TT_C4, TT_C5);
  var color = vec3(0.);                                                            // background: black
  var turns = TT_TUMBLE;
  let cz = cos(yaw); let sz = sin(yaw);                                            // z-axis swing (yaw), shared by all rings, after each ring's tumble
  for (var layer = 0; layer < 5; layer++) {
    let R = 0.2 + f32(layer) * 0.14;
    let ta = ph * TAU * mix(turns[0], turns[layer], spread);                       // this ring's tumble round the x-axis (pitch), orthographic: locked with ring_01 (spread 0) to its own whole turns per loop (spread 1)
    let c = mix(1., cos(ta), mo); let s = sin(ta) * mo;                             // ortho hold: mo 0 = flat, front (eased by flattening, not by spinning back)
    let cs = select(min(c, -1e-3), max(c, 1e-3), c >= 0.);                         // never divide by 0 edge-on
    let dy = uv.y / cs;
    let d = vec2((uv.x - dy * s * sz) / max(cz, 1e-3), dy);                        // the point on this ring's plane under this pixel
    let lu = length(d);
    let pa = atan2(d.y, d.x);
    let lc = cols[layer];
    var add = vec3(0.);
    let band = abs(lu - R) < 0.03;                                                 // inside this layer's track band (on the plane)
    let spin = ph * steps[layer] * TAU / 25.;
    var lv = 0.;                                                                   // lane level: ring_01 drum, ring_02 bass, ring_03 vocal, ring_04 other; ring_05 none
    if (layer < 4) { lv = clamp(f(26u + u32(layer)) * f(9u + u32(layer)) * settings[1].y, 0., 1.); }   // level x lane knob x REACT
    let bs = 1. + lv;                                                              // ball size and brightness, x1 (silent) to x2 (full)
    for (var i = 0; i < 5; i++) {                                                  // Comet: five balls per ring, each with a long tail
      let ang = f32(i) / 5. * TAU + spin;
      let bp = vec2(cos(ang), sin(ang)) * R;
      var ball = smoothstep(0.017 * bs, 0.008 * bs, length(uv - vec2(bp.x * cz + bp.y * s * sz, bp.y * c))) * bs * 1.3;   // the head, round on screen; swells with the lane
      if (band) {
        let ad = (atan2(bp.y, bp.x) - pa + PI * 3.) - TAU * floor((atan2(bp.y, bp.x) - pa + PI * 3.) / TAU) - PI;
        if (ad > 0. && ad < TT_COMET_TAIL) {                                       // the tail, flat on the plane, thinning and fading behind the head
          let lf = 1. - ad / TT_COMET_TAIL;
          ball += smoothstep(0.003 + 0.016 * lf, 0.001, abs(lu - length(bp))) * lf * lf * 0.95;
        }
      }
      add += lc * ball;
    }
    add += lc * 0.15 * smoothstep(0.004, 0.002, abs(lu - R));   // track outline, flat on the plane
    color += add * TT_RING_SHOW;                                                   // ring_01 to ring_05
  }
  color = min(color, vec3(1.));
  return pow(color, vec3(0.8)); }

// ======== AUTHORING HARNESS: the full shader around tt_viz ========
// ortho hold: a pace span is held flat if it is the song's first span (before the first pace change), its last (from the last change), or at the lowest pace level
fn ttMoving(r: AmuRow) -> f32 {
  let first = r.pos.z < 0.5; let last = r.pos.z > r.pos.w - 1.5; let lowest = r.lvl.y >= r.lvl.z;
  return select(1., 0., first || last || lowest || r.pos.w < 1.5); }
// Camera: flat, head-on; 1 source unit across the frame height (2 m).
const TT_FRAME_H: f32 = 2.;
const TT_LOOP_BEATS: f32 = 32.;  // Loop: 8 bars x 4 beats
@fragment fn fs(in: VO) -> @location(0) vec4<f32> {
  let t = f(13u) * settings[1].x + settings[2].w;          // vizzie.time (beats) x SPEED + TIME_OFFSET
  let res = max(u.v[8].xy, vec2(1., 1.));                  // canvas resolution (px), slots 32 to 33
  let asp = res.x / res.y;
  let p = stdFrame(vec2(in.uv.x * asp, in.uv.y), asp);     // frame units, y up, half-height = 1 · standard settings: TILE, SCALE, ROTATION, OFFSET, PIVOT
  let uv = p * 0.5;   // the source's uv: centred, 1 unit = the frame height, same scale on x and y (orthographic front)
  let ph = fract(t / TT_LOOP_BEATS);                      // loop phase (R20)
  let yaw = sin(TAU * f(18u)) * TT_YAW_DEG * 0.01745329 * f(3u) * settings[1].y;   // segment progress (slot 18): back and forth once per segment, x segment knob x REACT
  let sec = i32(f(20u));                                    // current section index (slot 20)
  let rw = amuRow(0u, sec); let rp = amuRow(0u, sec - 1);   // this section's row and the last one's (span tables, lane 0)
  let topNow = select(0., 1., rw.lvl.y == 1.); let topLast = select(0., 1., rp.lvl.y == 1.);   // highest pace level in the song (row.lvl.y, 1 = highest)
  let spread = mix(topLast, topNow, smoothstep(0., TT_SPREAD_EASE, f(13u) - rw.pos.x)) * f(2u) * settings[1].y;   // polyrhythm positioning on or off, eased over the section's first beats, x section knob x REACT
  let pi = i32(f(15u));                                   // current pace span index (slot 15)
  let pc = amuRow(4u, pi); let pp = amuRow(4u, pi - 1);   // this pace span and the one before (span tables, lane 4)
  let mo = mix(ttMoving(pp), ttMoving(pc), smoothstep(0., TT_ORTHO_EASE, f(13u) - pc.pos.x));   // 0 = ortho hold (flat, front), 1 = moving; eased from the last pace span's state
  var col = tt_viz(uv, ph, yaw * mo, spread, mo);
  col = stdHSV(col);   // standard settings: HUE, SATURATION, VALUE
  col = max((col - 0.5) * settings[3].y + 0.5, vec3(0.));   // standard setting: CONTRAST
  // [authoring overlay probe]
  return vec4(clamp(col, vec3(0.), vec3(1.)), 1.);
}
