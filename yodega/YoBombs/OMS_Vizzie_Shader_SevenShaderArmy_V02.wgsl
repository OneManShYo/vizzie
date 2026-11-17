// OMS_Vizzie_Shader_SevenShaderArmy_V02.wgsl
// Seven Shader Army: background, triangle_01 … triangle_15 (tunnel zooming out from the centre), peppermint at the centre.
// Lanes: beat → background pulse · phrase → tunnel zoom · bass → wireframe · segment → peppermint stripe turn.
// Run date: 2026-10-14
// Current Unix Epoch: 1791991683
// Built from: OMS_Vizzie_ShaderTemplate_V06f · source: Seven Shader Army V14 (.oms, ONEMANSHYO BETA V5_6_09) · credit: White Stripes, Seven Nation Army
// Vizzie uniform contract (V0.4.0C): 9 x vec4 (36 floats). No image bindings.
struct U { v: array<vec4<f32>, 9>, };
@group(0) @binding(0) var<uniform> u: U;

struct VO { @builtin(position) pos: vec4<f32>, @location(0) uv: vec2<f32>, };
@vertex fn vs(@builtin(vertex_index) i: u32) -> VO {
  var q = array<vec2<f32>, 6>(vec2(-1.,-1.), vec2(1.,-1.), vec2(-1.,1.), vec2(-1.,1.), vec2(1.,-1.), vec2(1.,1.));
  var o: VO; o.pos = vec4(q[i], 0., 1.); o.uv = q[i]; return o;
}
fn f(i: u32) -> f32 { return u.v[i / 4u][i % 4u]; }

const TAU: f32 = 6.2831853;

// ---- SCENE (frame units: half-height = 1, y up) ----
// subject units = source units: the frame's short side = 1 subject unit (16:9 by height, 9:16 by width)
const SUBJECT_SCALE: f32 = 0.918;            // whole scene scale (source transform scale 0.918)
const SUBJECT_Y: f32 = -0.05;                // scene centre, subject units above frame centre (source shift 0.05 down)

// ---- OBJECT: background ----
const BG_COL = vec3(0., 0., 0.);             // rest colour
const BG_PULSE_COL = vec3(0.15, 0.15, 0.15); // pulse colour
const BG_PULSE: f32 = 1.0;                   // pulse amount at full gate 0 … 1

// ---- OBJECTS: triangle_01 … triangle_15 — nested equilateral triangles, point up, zooming outward ----
const TRI_COUNT: u32 = 15u;                  // layers
const TRI_MIN: f32 = 0.02;                   // smallest size (half side), subject units, at the centre
const TRI_MAX: f32 = 1.2;                    // largest size (half side), subject units, end of the zoom
const TRI_SHOWN_MAX: f32 = 0.6;              // layers at or above this size are not drawn
const TRI_BANDS: f32 = 9.0;                  // colour bands over the full depth (3 colours, 3 times)
const TRI_COL_A = vec3(1., 0., 0.);          // band colour 1
const TRI_COL_B = vec3(0., 0., 0.);          // band colour 2
const TRI_COL_C = vec3(1., 1., 1.);          // band colour 3
const ZOOM_PHRASES: f32 = 2.0;               // phrases per full zoom cycle
const EDGE_W: f32 = 0.011;                   // wireframe outline width, subject units (source 0.005 + 0.2 × 0.03)
const WIRE_AT: f32 = 0.5;                    // lane value at which the triangles switch to outlines

// ---- OBJECT: peppermint — centre disc, twisted stripes ----
const PEP_R: f32 = 0.125;                    // radius, subject units (diameter = 25% of the short side)
const PEP_STRIPES: f32 = 6.0;                // stripe pairs around the disc
const PEP_TWIST: f32 = 12.0;                 // stripe twist, radians per subject unit of radius
const PEP_SPIN: f32 = 0.38;                  // steady spin, radians per second (vizzie.time)
const PEP_COL_A = vec3(1., 0., 0.);          // stripe colour 1
const PEP_COL_B = vec3(1., 1., 1.);          // stripe colour 2

// equilateral triangle, point up, signed distance (negative inside) · size = half side
fn sdTri(p0: vec2<f32>, size: f32) -> f32 {
  let k = sqrt(3.);
  var q = vec2(abs(p0.x) - size, p0.y + size / k);
  if (q.x + k * q.y > 0.) { q = vec2(q.x - k * q.y, -k * q.x - q.y) / 2.; }
  q.x -= clamp(q.x, -2. * size, 0.);
  return -length(q) * sign(q.y);
}
// coverage of one signed distance over one pixel
fn cover(d: f32, px: f32) -> f32 { return 1. - smoothstep(-px, px, d); }
fn triCol(b: u32) -> vec3<f32> { return select(select(TRI_COL_C, TRI_COL_B, b == 1u), TRI_COL_A, b == 0u); }
fn triShow(i: u32) -> f32 { return 1.; }
fn pepShow() -> f32 { return 1.; }

@fragment fn fs(in: VO) -> @location(0) vec4<f32> {
  // ---- unpack (Vizzie contract): only what this shader uses ----
  let t = f(13u);                                          // vizzie.time
  let res = max(u.v[8].xy, vec2(1., 1.));                  // canvas resolution (px), slots 32–33
  let asp = res.x / res.y;
  let p = vec2(in.uv.x * asp, in.uv.y);                    // frame units, y up, half-height = 1
  let g_beat = f(0u); let g_seg = f(3u); let g_phr = f(4u); let g_bass = f(10u);   // lane gates
  let beatPhase = f(14u); let segP = f(18u); let phrP = f(19u); let phrI = f(21u); let bass = f(27u);

  // ---- framing: short side of the frame = 1 subject unit ----
  let k = 0.5 / min(1., asp) / SUBJECT_SCALE;              // frame units → subject units
  let a = p * k - vec2(0., SUBJECT_Y);                     // subject units
  let px = 2. / res.y * k;                                 // one pixel, subject units

  // ---- peppermint stripes (computed up front: screen-space derivative) ----
  let pr = length(a);
  let rot = t * PEP_SPIN + g_seg * segP * TAU / PEP_STRIPES;
  let st = sin((atan2(a.y, a.x) + pr * PEP_TWIST + rot) * PEP_STRIPES);
  let sw = max(fwidth(st), 1e-4);

  // ---- paint, back to front ----
  // background: black, pulses toward dark grey on the beat
  var col = mix(BG_COL, BG_PULSE_COL, clamp(g_beat * (1. - beatPhase) * BG_PULSE, 0., 1.));   // background
  // triangle_01 … triangle_15: largest first; each layer's depth runs 0 → 1 over the zoom cycle, then wraps to the centre
  let n = f32(TRI_COUNT);
  let sh = g_phr * (phrI + phrP) / ZOOM_PHRASES * n;
  let fr = fract(sh);
  let base = u32(floor(sh)) % TRI_COUNT;
  let wire = step(WIRE_AT, g_bass * bass);
  for (var s = 0u; s < TRI_COUNT; s++) {
    let dep = (n - 1. - f32(s) + fr) / n;                  // depth 0 (centre) … 1 (largest)
    let size = TRI_MIN * pow(TRI_MAX / TRI_MIN, dep);
    if (size >= TRI_SHOWN_MAX) { continue; }
    let id = (TRI_COUNT * 2u - 1u - s - base) % TRI_COUNT; // persistent layer: 0 = triangle_01
    let d = sdTri(a, size);
    let cv = mix(cover(d, px), cover(abs(d) - EDGE_W, px), wire) * triShow(id);
    col = mix(col, triCol(u32(floor(dep * TRI_BANDS)) % 3u), cv);
  }
  // peppermint: twisted stripes, steady spin on time
  let pc = mix(PEP_COL_B, PEP_COL_A, smoothstep(-sw, sw, st));
  col = mix(col, pc, cover(pr - PEP_R, px) * pepShow());   // peppermint
  return vec4(col, 1.);
}
