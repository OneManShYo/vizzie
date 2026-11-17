// OMS_Vizzie_Shader_Starburst_V37.wgsl
// Starburst (red, black, white): a black panel of radial white / red streaks on a red field.
// Source: reference photo supplied by Wes (2026-10-05).
// Run date: 2026-10-05
// Current Unix Epoch: 1791228627
// Template: OMS_Vizzie_ShaderTemplate_V0_1_0a
// V37 = inside of the open mouth is streaks_02's red (was the cups/eyes yellow).
// The frame follows later.
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
const DEG: f32 = 0.01745329;

// ---- SCENE (frame units: half-height = 1, y up · n = frame-relative, −1 … 1 on both axes) ----
// subject units = the reference photo's frame: its half-height = 1 (the panel is placed as it sits in the photo)
const SUBJECT_HEIGHT: f32 = 1.0;             // photo height as a fraction of frame height (16:9: panel as large as in the photo)
const FIT_WIDTH: f32 = 0.90;                 // 9:16: the panel never wider than this fraction of frame width
const SUBJECT_ASPECT: f32 = 0.953;           // the panel's projected half-width, subject units (from the photo fit)
const SUBJECT_Y: f32 = 0.;                   // subject centre, frame units above frame centre
const CAM_F: f32 = 4.0;                      // camera: focal distance, subject units (≈ 28° vertical field of view; V05–V14: 2.0)

// ---- OBJECT: background (gradient; colours are medians sampled from the photo's red field) ----
const BG_TL = vec3(0.855, 0.208, 0.267);     // top-left red, slightly pink (≈ #DA3544)
const BG_BR = vec3(0.953, 0.149, 0.129);     // bottom-right red, saturated (≈ #F32621)
const BG_HOT = vec3(0.988, 0.196, 0.227);    // glow, brightest red right of centre (≈ #FC323A)
const BG_SHADE = vec3(0.533, 0.067, 0.059);  // corner shade, bottom-right (≈ #88110F)
const GLOW_POS = vec2(0.70, 0.10);           // glow centre, n units (x of half-width, y of half-height)
const GLOW_R: f32 = 1.20;                    // glow falloff radius, frame units
const SHADE_POS = vec2(1.00, -1.00);         // shade centre, n units (bottom-right corner)
const SHADE_R: f32 = 0.45;                   // shade falloff radius, frame units
const SHADE_AMT: f32 = 0.60;                 // shade strength 0 … 1
// ---- OBJECT: tablet (the floating screen) — a thin box in 3D, seen through CAM_F ----
// Rest pose fitted to the photo's panel corners (TL 325,366 · TR 1525,144 · BR 1674,1036 · BL 450,1314 px; fit within 21 px of 1,480)
const TABLET_POS = vec2(0.028, 0.043);       // centre, subject units
const TABLET_HALF_H: f32 = 0.6285;           // half-height, subject units
const TABLET_ASPECT: f32 = 1.333;            // width / height (4:3, from the fit)
const TABLET_DEPTH: f32 = 0.028;             // thickness, subject units (≈ 15 px on a 1080 px-tall 16:9 frame)
const TABLET_ROLL: f32 = 0.;                 // degrees, counter-clockwise in the frame · 0 = upright (photo fit: 10.49)
const TABLET_YAW: f32 = -3.25;               // degrees, turn about its vertical axis at rest (start angle of the section turn)
const TABLET_PITCH: f32 = 0.;                // degrees, tip about its horizontal axis · 0 = upright (photo fit: 1.90)
const TABLET_COL = vec3(0.275, 0.188, 0.235); // screen and back: black (photo median, lifted by the red light ≈ #46303C)
const TABLET_EDGE = vec3(0.455, 0.196, 0.255); // side edges (photo median of the visible edge ≈ #74323F)
const TABLET_RIM: f32 = 0.037;               // tablet_frame: rim width on the front, tablet units (≈ 20 px on a 1080 px-tall 16:9 frame)
const TABLET_SCREEN_COL = vec3(0.03, 0.03, 0.035); // tablet_screen: near black
const STREAKS_01_COL = vec3(0.957, 0.945, 0.980); // streaks_01 colour: white (photo median ≈ #F4F1FA)
// streaks_01: wide tapered strokes in tablet screen units (x ±0.838, y ±0.6285, y up), traced from the photo's screen (unwarped by the rest-pose fit)
const STREAKS_01_N: u32 = 10u;
const STREAKS_01 = array<vec4<f32>, 10>(   // start x, y → end x, y
  vec4(-0.3303, 0.6098, 0.0042, 0.1429),
  vec4(0.1378, 0.5847, 0.1275, 0.1855),
  vec4(0.7195, 0.5869, 0.3116, 0.1667),
  vec4(-0.5341, 0.5495, -0.0537, 0.0935),
  vec4(0.8135, 0.4350, 0.2329, 0.0512),
  vec4(-0.8031, 0.2260, -0.1139, 0.0018),
  vec4(0.7862, -0.0490, 0.4803, -0.0489),
  vec4(0.2675, -0.0912, 0.7986, -0.3320),
  vec4(-0.1231, -0.1626, -0.7915, -0.4647),
  vec4(-0.0346, -0.1906, -0.3911, -0.5712)
);
const STREAKS_01_W = array<vec2<f32>, 10>(  // half-width at start, at end
  vec2(0.0353, 0.0078),
  vec2(0.0190, 0.0050),
  vec2(0.0229, 0.0060),
  vec2(0.0141, 0.0061),
  vec2(0.0358, 0.0078),
  vec2(0.0346, 0.0112),
  vec2(0.0233, 0.0113),
  vec2(0.0099, 0.0133),
  vec2(0.0119, 0.0377),
  vec2(0.0057, 0.0206)
);
const STREAKS_03_COL = vec3(1.0, 0.85, 0.10); // streaks_03 colour: yellow for now (in the photo these are white)
const STREAKS_03_HALF_W: f32 = 0.0042;         // streaks_03: one even half-width for every stroke (photo median), screen units
// streaks_03: thin strokes of even width, start x, y → end x, y, tablet screen units, traced from the photo
const STREAKS_03_N: u32 = 58u;
const STREAKS_03 = array<vec4<f32>, 58>(
  vec4(-0.0709, 0.5854, -0.0250, 0.4547),
  vec4(0.0808, 0.3238, 0.0430, 0.5849),
  vec4(0.1902, 0.5846, 0.1747, 0.3629),
  vec4(0.3302, 0.5854, 0.2003, 0.2256),
  vec4(0.3945, 0.5857, 0.2735, 0.3160),
  vec4(-0.0140, 0.5714, 0.0772, 0.1651),
  vec4(-0.3875, 0.5552, -0.1470, 0.2821),
  vec4(-0.1520, 0.5352, -0.0215, 0.2846),
  vec4(0.2235, 0.4689, 0.1926, 0.2987),
  vec4(0.3588, 0.3948, 0.2660, 0.2265),
  vec4(-0.0182, 0.3560, 0.0758, 0.1049),
  vec4(0.4112, 0.3493, 0.1538, 0.0264),
  vec4(-0.3701, 0.3194, -0.1149, 0.1155),
  vec4(-0.7014, 0.3110, -0.2595, 0.1125),
  vec4(-0.4705, 0.3118, -0.4075, 0.2636),
  vec4(0.1610, 0.3090, 0.1374, 0.0559),
  vec4(-0.0663, 0.2994, -0.0095, 0.2044),
  vec4(0.2289, 0.2332, 0.1772, 0.1150),
  vec4(-0.1263, 0.2248, 0.0677, 0.0324),
  vec4(-0.3110, 0.1831, 0.0186, 0.0164),
  vec4(0.2777, 0.1377, 0.2384, 0.0976),
  vec4(0.0999, 0.1341, 0.1114, 0.0244),
  vec4(0.3360, 0.0863, 0.2697, 0.0566),
  vec4(0.3775, 0.0519, 0.1868, -0.0052),
  vec4(-0.6110, 0.0135, -0.6516, 0.0106),
  vec4(-0.6123, 0.0128, -0.5253, 0.0046),
  vec4(-0.5298, 0.0083, -0.2851, -0.0085),
  vec4(-0.0513, -0.0074, 0.0776, -0.0190),
  vec4(0.3583, -0.0052, 0.2496, -0.0227),
  vec4(0.1386, -0.0360, 0.2164, -0.0673),
  vec4(-0.0748, -0.0494, -0.5747, -0.0893),
  vec4(0.2837, -0.0567, 0.3422, -0.0690),
  vec4(0.1041, -0.0595, 0.0945, -0.1002),
  vec4(0.0573, -0.0674, -0.0159, -0.1233),
  vec4(-0.0164, -0.0716, -0.1782, -0.1213),
  vec4(0.1413, -0.0770, 0.1886, -0.1854),
  vec4(0.1252, -0.0847, 0.1930, -0.5105),
  vec4(0.0941, -0.1023, 0.0722, -0.1959),
  vec4(-0.2094, -0.1112, -0.6563, -0.2090),
  vec4(0.0592, -0.1118, -0.2395, -0.5322),
  vec4(0.1844, -0.1189, 0.3141, -0.2699),
  vec4(-0.2649, -0.1820, -0.4103, -0.2410),
  vec4(0.2753, -0.1879, 0.3332, -0.2332),
  vec4(-0.6606, -0.2108, -0.6983, -0.2154),
  vec4(0.2324, -0.2270, 0.3525, -0.4087),
  vec4(0.0878, -0.2294, 0.0555, -0.5570),
  vec4(0.0316, -0.2350, -0.1034, -0.5816),
  vec4(0.0681, -0.2434, 0.0115, -0.5081),
  vec4(0.2118, -0.2431, 0.2927, -0.4585),
  vec4(-0.4286, -0.2480, -0.5337, -0.2904),
  vec4(0.1352, -0.2485, 0.1497, -0.5794),
  vec4(-0.1647, -0.2648, -0.5268, -0.5184),
  vec4(-0.0300, -0.2898, -0.1845, -0.5857),
  vec4(0.1110, -0.3177, 0.0991, -0.5846),
  vec4(-0.1765, -0.3595, -0.2081, -0.3960),
  vec4(0.0227, -0.4116, -0.0216, -0.5849),
  vec4(0.2338, -0.4167, 0.2763, -0.5640),
  vec4(0.2953, -0.4771, 0.3138, -0.5342)
);
const STREAKS_02_COL = vec3(0.835, 0.294, 0.380); // streaks_02 colour: red (photo median ≈ #D54B61)
const STREAKS_02_COL_TO = STREAKS_01_COL;    // bar: streaks_02 fades toward this (white) at mid-bar
const STREAKS_03_COL_TO = STREAKS_02_COL;    // bar: streaks_03 fades toward this (red) at mid-bar
// streaks_02: strokes in tablet screen units, traced from the photo's screen (red strokes clear of streaks_01)
const STREAKS_02_N: u32 = 17u;
const STREAKS_02 = array<vec4<f32>, 17>(   // start x, y → end x, y
  vec4(0.5219, 0.5806, 0.4046, 0.4050),
  vec4(-0.7882, 0.5608, -0.5286, 0.3619),
  vec4(-0.3274, 0.5555, -0.1470, 0.3232),
  vec4(0.1203, 0.5492, 0.1208, 0.3919),
  vec4(-0.5321, 0.5112, -0.4319, 0.4215),
  vec4(0.7938, 0.4956, 0.5049, 0.2752),
  vec4(0.5154, 0.4864, 0.4229, 0.3658),
  vec4(0.8064, 0.3276, 0.3430, 0.0888),
  vec4(-0.7937, 0.1572, -0.2687, 0.0311),
  vec4(0.7909, 0.1192, 0.6451, 0.0854),
  vec4(0.5950, 0.1220, 0.4197, 0.0653),
  vec4(-0.7877, 0.0249, -0.6527, 0.0225),
  vec4(0.6885, 0.0004, 0.3995, -0.0215),
  vec4(0.6014, -0.2145, 0.6553, -0.2357),
  vec4(-0.3236, -0.2872, -0.7946, -0.5329),
  vec4(-0.5580, -0.3021, -0.7927, -0.3950),
  vec4(0.0495, -0.4252, 0.0356, -0.5795)
);
const STREAKS_02_W = array<vec2<f32>, 17>(  // half-width at start, at end
  vec2(0.0092, 0.0067),
  vec2(0.0175, 0.0087),
  vec2(0.0131, 0.0088),
  vec2(0.0076, 0.0044),
  vec2(0.0050, 0.0049),
  vec2(0.0160, 0.0130),
  vec2(0.0083, 0.0074),
  vec2(0.0189, 0.0164),
  vec2(0.0189, 0.0071),
  vec2(0.0183, 0.0153),
  vec2(0.0153, 0.0122),
  vec2(0.0157, 0.0044),
  vec2(0.0139, 0.0096),
  vec2(0.0058, 0.0065),
  vec2(0.0073, 0.0189),
  vec2(0.0138, 0.0179),
  vec2(0.0070, 0.0189)
);
const STREAKS_CENTRE = vec2(0.1136, -0.0444); // vanishing point of all streaks, screen units (least-squares crossing of the traced strokes)
const STREAKS_BIRTH: f32 = 0.03;             // a stroke is born with its outer end this far from STREAKS_CENTRE (screen units)
const STREAKS_EXIT: f32 = 1.25;              // …and is gone once its inner end is this far out (past every screen corner)
const STREAKS_WIDTH_GROW: f32 = 0.5;         // width grows as (zoom)^0.5 while the stroke comes forward (1 = full perspective)
const STREAKS_01_SPEED: f32 = 1.0;           // flights per segment, per stroke (whole numbers keep every segment seamless)
const STREAKS_02_SPEED: f32 = 2.0;
const STREAKS_03_SPEED: f32 = 3.0;
const STREAKS_VAR: f32 = 0.10;               // each stroke's speed within its group: ±10%, fixed per stroke · start times spread per stroke
// ---- OBJECT: yobot_squint — Yobot Squint base model on the tablet's back face ----
// Source: OMS_Vizzie_Shader_YobotSquint_Base_White_V02-webgpu.wgsl (angled eyes from YB_S_OG_07_MouthMods.blend on the shared
// Yobot body): outline loops, exact vertices, corners kept — 306 points. Drawn static (no bob, throb, blink, glance or jaw).
const YB_COL = vec3(0.92, 0.92, 0.92);       // white, as in the source
const YB_SCALE: f32 = 0.5475;                // logo units → back-face units (logo ~1.83 wide → 60% of the back's width)
const YB_POS = vec2(0., 0.);                 // centre on the back face, back-face units
const YB_BEAT_PULSE: f32 = 0.05;             // beat: headphones grow this much on the beat (+5%) …
const YB_BEAT_DECAY: f32 = 6.0;              // … then settle back, exp(−beatPhase × 6)
const YB_CUP_VOCAL_COL = STREAKS_03_COL;     // vocal: the cups (openings inside the headphones) fill with this while the vocal is on (streaks_03's yellow)
const YB_VOCAL_ON_LO: f32 = 0.0;             // vocal activity at which the cups start to fill …
const YB_VOCAL_ON_HI: f32 = 0.1;             // … and are fully coloured (any vocal = on; quick in and out)
const YB_VOCAL_JAW: f32 = 0.03;              // vocal: widest mouth opening (logo units ≈ 9 px at 1080p; V34–V35: 0.12)
const YB_VOCAL_LO: f32 = 0.25;               // vocal level range for the mouth (Color Ramp style): at or below this the mouth stays shut …
const YB_VOCAL_HI: f32 = 0.65;               // … at or above this it opens to YB_VOCAL_JAW on each flap
const YB_FLAPS_PER_BEAT: f32 = 2.0;          // mouth open-and-shut cycles per beat while singing (2 = every half-beat)
const YB_ACCENT_WEAK: f32 = 0.6;             // cadence: flaps on beats 2 and 4 open this much of beats 1 and 3
const YB_LEAD_LO: f32 = 0.20;                // vocal lead = vocal ÷ (vocal + mean of drum, bass, other): at or below this the mouth opens YB_LEAD_MIN …
const YB_LEAD_HI: f32 = 0.55;                // … at or above this, fully (Ain't No Trick while singing: ≈ 0.18 … 0.58)
const YB_LEAD_MIN: f32 = 0.4;
const YB_MOUTH_COL = STREAKS_02_COL;         // inside of the open mouth: streaks_02's red #D54B61
const YB_MOUTH_SEAM_Y: f32 = -0.4997;        // seam between the dome and the mouth piece (logo units)
const YB_MOUTH_GAP_CX: f32 = -0.0005;        // mouth gap centre x (mouth piece spans −0.5699 … 0.5689)
const YB_MOUTH_GAP_HW: f32 = 0.5694;         // mouth gap half-width
const YB_JAW_DROP: f32 = 0.0;                // beat: how far the mouth drops (logo units) · 0 = still (V20–V23: 0.034 ≈ 10 px at 1080p)
const YB_EYEA = vec2(-0.2390, -0.2710);
const YB_EYEB = vec2(0.2196, -0.2606);
var<private> YB_P: array<vec2<f32>, 306> = array<vec2<f32>, 306>(
  vec2(-0.59242,-0.42455), vec2(-0.58314,-0.46187), vec2(-0.57109,-0.49966), vec2(0.57009,-0.49966), vec2(0.58214,-0.46189),
  vec2(0.59142,-0.42457), vec2(0.59829,-0.38673), vec2(0.60370,-0.33558), vec2(0.60492,-0.29679), vec2(0.60316,-0.25028),
  vec2(0.59260,-0.17493), vec2(0.57766,-0.11695), vec2(0.55727,-0.06136), vec2(0.53174,-0.00844), vec2(0.50138,0.04147),
  vec2(0.46650,0.08810), vec2(0.42740,0.13111), vec2(0.38438,0.17021), vec2(0.33776,0.20510), vec2(0.28784,0.23546),
  vec2(0.23493,0.26098), vec2(0.17933,0.28137), vec2(0.12136,0.29631), vec2(0.06131,0.30550), vec2(-0.00050,0.30864),
  vec2(-0.06232,0.30550), vec2(-0.12237,0.29631), vec2(-0.18034,0.28137), vec2(-0.23594,0.26098), vec2(-0.28885,0.23546),
  vec2(-0.33877,0.20510), vec2(-0.38539,0.17021), vec2(-0.43856,0.12071), vec2(-0.47664,0.07677), vec2(-0.51042,0.02929),
  vec2(-0.53960,-0.02140), vec2(-0.56387,-0.07502), vec2(-0.58292,-0.13124), vec2(-0.59646,-0.18976), vec2(-0.60416,-0.25028),
  vec2(-0.60579,-0.30975), vec2(-0.60254,-0.36122), vec2(-0.42339,-0.14188), vec2(-0.37050,-0.14934), vec2(-0.32064,-0.16166),
  vec2(-0.27411,-0.17777), vec2(-0.23121,-0.19663), vec2(-0.19224,-0.21719), vec2(-0.12728,-0.25924), vec2(-0.08162,-0.29553),
  vec2(-0.05453,-0.32085), vec2(-0.09804,-0.33534), vec2(-0.12684,-0.34729), vec2(-0.16747,-0.37991), vec2(-0.19072,-0.39348),
  vec2(-0.20381,-0.39800), vec2(-0.21786,-0.40022), vec2(-0.23287,-0.39954), vec2(-0.24883,-0.39536), vec2(-0.26572,-0.38709),
  vec2(-0.28030,-0.37690), vec2(-0.30347,-0.35293), vec2(-0.31248,-0.33963), vec2(-0.32644,-0.31158), vec2(-0.35109,-0.23296),
  vec2(-0.36547,-0.20198), vec2(-0.37768,-0.18294), vec2(-0.39778,-0.15926), vec2(-0.41111,-0.14814), vec2(0.43123,-0.13933),
  vec2(0.37485,-0.15244), vec2(0.32046,-0.17006), vec2(0.26860,-0.19110), vec2(0.21983,-0.21449), vec2(0.17471,-0.23915),
  vec2(0.09765,-0.28799), vec2(0.04188,-0.32903), vec2(0.00790,-0.35716), vec2(0.05704,-0.35206), vec2(0.09533,-0.35250),
  vec2(0.10737,-0.35641), vec2(0.14112,-0.37551), vec2(0.16265,-0.38082), vec2(0.17622,-0.38178), vec2(0.21038,-0.37885),
  vec2(0.23151,-0.37435), vec2(0.25757,-0.36618), vec2(0.27865,-0.35620), vec2(0.29535,-0.34474), vec2(0.30827,-0.33212),
  vec2(0.31801,-0.31865), vec2(0.33031,-0.29045), vec2(0.34297,-0.23798), vec2(0.35240,-0.21795), vec2(0.36502,-0.19889),
  vec2(0.37958,-0.18081), vec2(0.40284,-0.15767), vec2(0.41783,-0.14630), vec2(-0.56991,-0.49966), vec2(-0.56637,-0.51421),
  vec2(-0.56037,-0.52765), vec2(-0.55218,-0.53973), vec2(-0.54205,-0.55019), vec2(-0.53025,-0.55877), vec2(-0.51703,-0.56522),
  vec2(-0.50264,-0.56928), vec2(-0.48734,-0.57069), vec2(0.49410,-0.57021), vec2(0.51602,-0.56511), vec2(0.52923,-0.55867),
  vec2(0.54103,-0.55011), vec2(0.55116,-0.53967), vec2(0.55935,-0.52761), vec2(0.56536,-0.51419), vec2(0.56892,-0.49966),
  vec2(-0.91724,-0.19101), vec2(-0.91333,-0.22643), vec2(-0.90431,-0.25715), vec2(-0.89032,-0.28056), vec2(-0.87664,-0.29173),
  vec2(-0.86516,-0.33679), vec2(-0.84825,-0.37805), vec2(-0.83099,-0.40573), vec2(-0.80946,-0.42976), vec2(-0.79259,-0.44340),
  vec2(-0.77062,-0.45665), vec2(-0.74002,-0.47044), vec2(-0.71264,-0.47995), vec2(-0.67677,-0.48948), vec2(-0.64999,-0.49438),
  vec2(-0.61401,-0.49796), vec2(-0.58333,-0.49838), vec2(-0.59982,-0.44079), vec2(-0.60934,-0.39088), vec2(-0.61515,-0.33285),
  vec2(-0.61520,-0.27033), vec2(-0.61272,-0.23824), vec2(-0.60624,-0.19266), vec2(-0.59704,-0.15044), vec2(-0.58577,-0.11172),
  vec2(-0.55967,-0.04525), vec2(-0.53957,-0.00549), vec2(-0.52147,0.02514), vec2(-0.57496,0.04190), vec2(-0.55614,0.11580),
  vec2(-0.53258,0.10934), vec2(-0.48444,0.16692), vec2(-0.45230,0.19917), vec2(-0.42373,0.22462), vec2(-0.39124,0.25037),
  vec2(-0.35478,0.27573), vec2(-0.28497,0.31527), vec2(-0.22082,0.34259), vec2(-0.15141,0.36407), vec2(-0.11389,0.37250),
  vec2(-0.06980,0.37958), vec2(-0.00217,0.38459), vec2(0.06664,0.37979), vec2(0.13775,0.36711), vec2(0.18034,0.35568),
  vec2(0.21989,0.34253), vec2(0.28404,0.31521), vec2(0.35385,0.27567), vec2(0.39031,0.25030), vec2(0.42280,0.22455),
  vec2(0.45137,0.19911), vec2(0.48350,0.16685), vec2(0.53165,0.10927), vec2(0.55521,0.11573), vec2(0.57415,0.04131),
  vec2(0.52147,0.02475), vec2(0.53957,-0.00588), vec2(0.55967,-0.04563), vec2(0.58577,-0.11211), vec2(0.59704,-0.15083),
  vec2(0.60624,-0.19305), vec2(0.61272,-0.23862), vec2(0.61520,-0.27071), vec2(0.61515,-0.33324), vec2(0.60934,-0.39127),
  vec2(0.59982,-0.44118), vec2(0.58333,-0.49877), vec2(0.61401,-0.49835), vec2(0.64999,-0.49477), vec2(0.67677,-0.48987),
  vec2(0.71264,-0.48033), vec2(0.74002,-0.47082), vec2(0.77062,-0.45704), vec2(0.79259,-0.44378), vec2(0.80946,-0.43015),
  vec2(0.83099,-0.40611), vec2(0.84825,-0.37844), vec2(0.86516,-0.33718), vec2(0.87578,-0.29255), vec2(0.89032,-0.28094),
  vec2(0.90431,-0.25754), vec2(0.91333,-0.22681), vec2(0.91740,-0.18212), vec2(0.91502,-0.14649), vec2(0.90780,-0.11183),
  vec2(0.89563,-0.08036), vec2(0.88471,-0.06226), vec2(0.86406,-0.04110), vec2(0.84275,-0.03033), vec2(0.83107,-0.00887),
  vec2(0.81650,0.01100), vec2(0.79859,0.02840), vec2(0.78824,0.03588), vec2(0.76847,0.04630), vec2(0.74242,0.05404),
  vec2(0.71491,0.05700), vec2(0.69131,0.05687), vec2(0.65513,0.14818), vec2(0.68046,0.15775), vec2(0.66096,0.19294),
  vec2(0.62473,0.24876), vec2(0.58274,0.30264), vec2(0.54077,0.34815), vec2(0.49084,0.39391), vec2(0.43247,0.43821),
  vec2(0.38287,0.46944), vec2(0.32286,0.50047), vec2(0.25727,0.52701), vec2(0.19766,0.54543), vec2(0.12854,0.56053),
  vec2(0.06705,0.56852), vec2(-0.00153,0.57154), vec2(-0.06798,0.56858), vec2(-0.12947,0.56060), vec2(-0.19860,0.54550),
  vec2(-0.26890,0.52322), vec2(-0.33133,0.49703), vec2(-0.38381,0.46950), vec2(-0.43340,0.43828), vec2(-0.49177,0.39398),
  vec2(-0.54170,0.34821), vec2(-0.58367,0.30271), vec2(-0.62566,0.24882), vec2(-0.66190,0.19301), vec2(-0.68139,0.15782),
  vec2(-0.65606,0.14824), vec2(-0.69210,0.05728), vec2(-0.71492,0.05738), vec2(-0.74243,0.05442), vec2(-0.76847,0.04669),
  vec2(-0.78824,0.03627), vec2(-0.79859,0.02878), vec2(-0.81650,0.01139), vec2(-0.83107,-0.00849), vec2(-0.84275,-0.02995),
  vec2(-0.86406,-0.04071), vec2(-0.88471,-0.06188), vec2(-0.90024,-0.08997), vec2(-0.91075,-0.12275), vec2(-0.91634,-0.15798),
  vec2(-0.68062,-0.40712), vec2(-0.70309,-0.40205), vec2(-0.72360,-0.39425), vec2(-0.74975,-0.37998), vec2(-0.76915,-0.36605),
  vec2(-0.78207,-0.35474), vec2(-0.78879,-0.32105), vec2(-0.79436,-0.27502), vec2(-0.79607,-0.23329), vec2(-0.79465,-0.19691),
  vec2(-0.78904,-0.15446), vec2(-0.78041,-0.11876), vec2(-0.77011,-0.08967), vec2(-0.75443,-0.05803), vec2(-0.73894,-0.03596),
  vec2(-0.69102,-0.03615), vec2(-0.65460,-0.04067), vec2(-0.63369,-0.04885), vec2(-0.62874,-0.05493), vec2(-0.62807,-0.05855),
  vec2(-0.65113,-0.13007), vec2(-0.66435,-0.19856), vec2(-0.66974,-0.24850), vec2(-0.67217,-0.29500), vec2(-0.67221,-0.34980),
  vec2(-0.66882,-0.40788), vec2(0.66878,-0.40866), vec2(0.67197,-0.35820), vec2(0.67247,-0.30978), vec2(0.67084,-0.26486),
  vec2(0.66652,-0.21585), vec2(0.65517,-0.14756), vec2(0.64138,-0.09673), vec2(0.62835,-0.06145), vec2(0.62874,-0.05532),
  vec2(0.63773,-0.04672), vec2(0.66138,-0.03972), vec2(0.69842,-0.03617), vec2(0.73840,-0.03616), vec2(0.75443,-0.05842),
  vec2(0.77011,-0.09006), vec2(0.78278,-0.12745), vec2(0.79078,-0.16482), vec2(0.79543,-0.20899), vec2(0.79589,-0.24711),
  vec2(0.79296,-0.29027), vec2(0.78264,-0.35456), vec2(0.76352,-0.37080), vec2(0.74172,-0.38527), vec2(0.72360,-0.39464),
  vec2(0.70309,-0.40244)
);
const SECTION_TURNS: f32 = 0.5;              // section: turns about its own vertical axis per section (one turn every 2 sections) · 0 = paused
const LIGHT = vec3(-0.30, 0.40, -1.00);      // light direction, toward the light (from the camera side, upper left)

fn rotX(v: vec3<f32>, a: f32) -> vec3<f32> { let c = cos(a); let s = sin(a); return vec3(v.x, c * v.y - s * v.z, s * v.y + c * v.z); }
fn rotY(v: vec3<f32>, a: f32) -> vec3<f32> { let c = cos(a); let s = sin(a); return vec3(c * v.x + s * v.z, v.y, -s * v.x + c * v.z); }
fn rotZ(v: vec3<f32>, a: f32) -> vec3<f32> { let c = cos(a); let s = sin(a); return vec3(c * v.x - s * v.y, s * v.x + c * v.y, v.z); }
// tablet space → world: spin about its own vertical axis, then the rest pose (pitch → yaw → roll)
fn toWorld(v: vec3<f32>, spin: f32) -> vec3<f32> { return rotZ(rotY(rotX(rotY(v, spin), TABLET_PITCH * DEG), TABLET_YAW * DEG), TABLET_ROLL * DEG); }
fn toTablet(v: vec3<f32>, spin: f32) -> vec3<f32> { return rotY(rotX(rotY(rotZ(v, -TABLET_ROLL * DEG), -TABLET_YAW * DEG), -TABLET_PITCH * DEG), -spin); }
// tapered capsule: radius ra at a → rb at b (negative inside)
fn capT(p: vec2<f32>, a: vec2<f32>, b: vec2<f32>, ra: f32, rb: f32) -> f32 {
  let pa = p - a; let ba = b - a;
  let h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
  return length(pa - ba * h) - mix(ra, rb, h);
}
// ---- streaks: back → front. Each stroke flies on its own: born at STREAKS_CENTRE (outer end STREAKS_BIRTH out), it grows
// exponentially (even speed in depth) along its own ray until its inner end passes STREAKS_EXIT, off every screen edge,
// then waits off screen and starts again. One flight per cycle; each stroke has its own start time (spread over the cycle)
// and its own speed (±STREAKS_VAR: a faster stroke covers more depth per cycle and so leaves sooner). No fading.
fn h1(n: f32) -> f32 { return fract(sin(n * 12.9898 + 4.1414) * 43758.5453); }
fn inside(d: f32) -> f32 { return select(0., 1., d < 0.); }
// one stroke at cycle position g (0..1 of its group): signed distance on screen, screen units
fn fly(lp: vec2<f32>, a: vec2<f32>, b: vec2<f32>, ra: f32, rb: f32, g: f32, seed: f32) -> f32 {
  let la = length(a - STREAKS_CENTRE); let lb = length(b - STREAKS_CENTRE);
  let k0 = STREAKS_BIRTH / max(max(la, lb), 1e-4);                     // zoom at birth
  let kx = STREAKS_EXIT / max(min(la, lb), 1e-3);                       // zoom at which it has left the screen
  let span = log(kx / k0) / (1. - STREAKS_VAR) * (1. + STREAKS_VAR * (2. * h1(seed) - 1.));   // ±10% speed; slowest still leaves
  let f = fract(g + h1(seed + 0.5));                                     // own start time
  let k = k0 * exp(span * f);                                            // zoom now
  let q = STREAKS_CENTRE + (lp - STREAKS_CENTRE) / k;                    // back into the stroke's photo position
  let pa = q - a; let ba = b - a;
  let hh = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
  return length(pa - ba * hh) * k - mix(ra, rb, hh) * pow(k, STREAKS_WIDTH_GROW);
}
fn cov01(lp: vec2<f32>, g: f32) -> f32 {
  var c = 0.;
  for (var i = 0u; i < STREAKS_01_N; i++) {
    let s = STREAKS_01[i]; let r = STREAKS_01_W[i];
    c = max(c, inside(fly(lp, s.xy, s.zw, r.x, r.y, g, f32(i) + 100.)));
  }
  return c;
}
fn cov02(lp: vec2<f32>, g: f32) -> f32 {
  var c = 0.;
  for (var i = 0u; i < STREAKS_02_N; i++) {
    let s = STREAKS_02[i]; let r = STREAKS_02_W[i];
    c = max(c, inside(fly(lp, s.xy, s.zw, r.x, r.y, g, f32(i) + 200.)));
  }
  return c;
}
fn cov03(lp: vec2<f32>, g: f32) -> f32 {
  var c = 0.; let r = STREAKS_03_HALF_W;
  for (var i = 0u; i < STREAKS_03_N; i++) {
    let s = STREAKS_03[i];
    c = max(c, inside(fly(lp, s.xy, s.zw, r, r, g, f32(i) + 300.)));
  }
  return c;
}
// yobot_squint: signed distance to one closed contour (negative inside) + outward gradient (from the source shader)
fn ybPoly(p: vec2<f32>, s: i32, n: i32, mn: vec2<f32>, mx: vec2<f32>) -> vec3<f32> {
  let c = (mn + mx) * 0.5; let hb = (mx - mn) * 0.5;
  let q = abs(p - c) - hb;
  let bd = length(max(q, vec2(0.)));
  if (bd > 0.12) { return vec3(bd, normalize(p - c)); }
  var dmin = 1e9; var cl = vec2(0.); var inn = false;
  var j = s + n - 1;
  for (var i = s; i < s + n; i++) {
    let a = YB_P[j]; let b = YB_P[i];
    let e = b - a; let t = clamp(dot(p - a, e) / dot(e, e), 0., 1.); let qq = a + e * t; let dd = dot(p - qq, p - qq);
    if (dd < dmin) { dmin = dd; cl = qq; }
    if (((b.y > p.y) != (a.y > p.y)) && (p.x < (a.x - b.x) * (p.y - b.y) / (a.y - b.y) + b.x)) { inn = !inn; }
    j = i;
  }
  let d = sqrt(dmin); let sg = select(1., -1., inn);
  return vec3(d * sg, (p - cl) / max(d, 1e-6) * sg);
}
fn ybMax(a: vec3<f32>, b: vec3<f32>) -> vec3<f32> { return select(b, a, a.x > b.x); }
fn ybMin(a: vec3<f32>, b: vec3<f32>) -> vec3<f32> { return select(b, a, a.x < b.x); }
// whole mascot: dome minus eyes, plus mouth, plus headphones minus cup openings (logo units, y up)
// throb = headphones scale about the logo centre (1 = rest); jaw = how far the mouth piece drops (0 = rest), as in the source shader
fn yobot(ph: vec2<f32>, throb: f32, jaw: f32) -> vec4<f32> {   // x = head (dome, mouth), y = headphones, z = cups (openings), w = eyes (openings)
  var head = ybPoly(ph, 0, 42, vec2(-0.6058, -0.4997), vec2(0.6049, 0.3086));
  let dA = ybPoly(ph, 42, 27, vec2(-0.4234, -0.4002), vec2(-0.0545, -0.1419));
  let dB = ybPoly(ph, 69, 29, vec2(0.0079, -0.3818), vec2(0.4312, -0.1393));
  head = ybMax(ybMax(head, -dA), -dB);
  head = ybMin(head, ybPoly(ph + vec2(0., jaw), 98, 17, vec2(-0.5699, -0.5707), vec2(0.5689, -0.4997)));
  let pp = ph / throb;
  var hp = ybPoly(pp, 115, 140, vec2(-0.9172, -0.4988), vec2(0.9174, 0.5715));
  let cups = ybMin(ybPoly(pp, 255, 26, vec2(-0.7961, -0.4079), vec2(-0.6281, -0.0360)), ybPoly(pp, 281, 25, vec2(0.6284, -0.4087), vec2(0.7959, -0.0362)));
  hp = ybMax(hp, -cups);
  return vec4(head.x, hp.x * throb, cups.x * throb, min(dA.x, dB.x));
}
struct Hit { hit: f32, face: f32, shade: f32, lp: vec2<f32>, };
// ray / box: hit 0|1, face (0 screen, 1 back, 2 edge), shade 0..1, lp = hit point on the face, tablet units
fn tablet(a: vec2<f32>, spin: f32) -> Hit {
  let c = vec3(TABLET_POS, 0.);                            // centre of the box
  let o = toTablet(vec3(0., 0., -CAM_F) - c, spin);       // camera, tablet space
  let d = toTablet(vec3(a, CAM_F), spin);                 // ray through this point of the image plane
  let bx = vec3(TABLET_ASPECT * TABLET_HALF_H, TABLET_HALF_H, TABLET_DEPTH * 0.5);
  let inv = 1. / select(d, vec3(1e-6), abs(d) < vec3(1e-6));
  let t1 = (-bx - o) * inv; let t2 = (bx - o) * inv;
  let tn3 = min(t1, t2); let tf3 = max(t1, t2);
  let tn = max(max(tn3.x, tn3.y), tn3.z); let tf = min(min(tf3.x, tf3.y), tf3.z);
  if (tn > tf || tf < 0.) { return Hit(0., 0., 0., vec2(0.)); }
  var nl = vec3(0., 0., -sign(d.z)); var face = 0.;       // entry face normal, tablet space
  if (tn == tn3.x) { nl = vec3(-sign(d.x), 0., 0.); face = 2.; }
  else if (tn == tn3.y) { nl = vec3(0., -sign(d.y), 0.); face = 2.; }
  else { face = select(1., 0., nl.z < 0.); }               // −z faces the camera at rest: the screen
  let nw = toWorld(nl, spin);
  let sh = 0.6 + 0.4 * max(dot(nw, normalize(LIGHT)), 0.);
  return Hit(1., face, sh, (o + d * tn).xy);
}

// colour ramp on the diagonal (like Blender's Color Ramp: two stops, BG_TL → BG_BR), coordinate −1 top-left … 1 bottom-right
const RAMP_POS: f32 = 0.0;                   // ramp centre (midpoint between the two stops) at rest
const RAMP_WIDTH: f32 = 1.0;                 // half the distance between the stops (1.0 = the V02 look)
const RAMP_SWING: f32 = 0.6;                 // phrase: how far the stops slide toward bottom-right at mid-phrase
// Gabor texture (Blender: Gabor Texture → Color Ramp → mixed over the background): sparse sum of Gabor kernels
// (Gaussian × cosine). Laid out around GABOR_CENTRE in log-polar space (distance as log, angle around the circle), so the
// grain runs radially and the pattern grows toward the edges; sliding it along the log-distance axis makes it flow
// outward from the centre forever, with no seam and no fading.
const GABOR_CENTRE = vec2(0.14, 0.0);        // frame units: where the grain flows out from (the starburst centre at the tablet's rest pose)
const GABOR_ANG_CELLS: f32 = 44.0;           // cells around the full circle (whole number: the pattern closes up all the way round)
const GABOR_IMPULSES: i32 = 4;               // kernels per cell
const GABOR_FREQ: f32 = 3.2;                 // stripes per cell, across the grain
const GABOR_RADIUS: f32 = 0.84;              // kernel size, cells
const GABOR_ANISO: f32 = 0.25;               // random turn per kernel off the radial direction (radians ≈ ±14°)
const GABOR_FLOW: f32 = 0.5;                 // outward drift, cells per second (vizzie.time) · ≈ 7% further out each second
const GABOR_DARK = vec3(0.45, 0.06, 0.09);   // Color Ramp: dark stop
const GABOR_DARK_BASS = vec3(0.5, 0.5, 0.5);  // bass: the dark stop goes toward this at full bass activity: mid grey #808080 (V26: #BF2630)
const GABOR_LO: f32 = 0.30;                  // Color Ramp: dark stop position (0..1)
const GABOR_HI: f32 = 0.70;                  // Color Ramp: light stop position (light stop = the background colour)
const GABOR_AMT: f32 = 1.0;                  // texture strength 0 … 1
const GABOR_DRUM_SIZE: f32 = 0.6;            // drum: grain grows by up to this much at full drum activity (+60%)
fn gh(p: vec3<f32>) -> f32 { return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453); }
fn gabor(p: vec2<f32>, t: f32, sz: f32) -> f32 {   // sz = grain size (1 = rest)
  let d0 = p - GABOR_CENTRE;
  let kk = GABOR_ANG_CELLS / 6.2831853;
  let g = vec2(log(max(length(d0), 1e-4)) * kk - GABOR_FLOW * t, atan2(d0.y, d0.x) * kk);   // (out, around), cells
  let ci = floor(g);
  var v = 0.;
  for (var dy = -1; dy <= 1; dy++) {
    for (var dx = -1; dx <= 1; dx++) {
      let c = ci + vec2(f32(dx), f32(dy));
      let cw = vec2(c.x, c.y - GABOR_ANG_CELLS * floor(c.y / GABOR_ANG_CELLS));   // wrap around the circle for the random values
      for (var k = 0; k < GABOR_IMPULSES; k++) {
        let kf = f32(k);
        let q = c + vec2(gh(vec3(cw, kf)), gh(vec3(cw, kf + 17.)));               // kernel centre, cells
        let ang = GABOR_ANISO * (2. * gh(vec3(cw, kf + 31.)) - 1.);
        let d = g - q;
        let rad = GABOR_RADIUS * sz;
        let env = exp(-3.14159265 * dot(d, d) / (rad * rad));
        v += env * cos(6.2831853 * GABOR_FREQ / sz * dot(d, vec2(-sin(ang), cos(ang))) + 6.2831853 * gh(vec3(cw, kf + 53.)));
      }
    }
  }
  return clamp(0.5 + 0.25 * v, 0., 1.);
}

@fragment fn fs(in: VO) -> @location(0) vec4<f32> {
  // ---- unpack (Vizzie contract): only what this shader uses ----
  let gSec = f(2u);                                        // gate: section (knob)
  let secI = f(20u); let secP = f(17u);                    // vizzie.sectionIndex, vizzie.sectionProgress
  let gSeg = f(3u); let segP = f(18u);                     // gate: segment (knob), vizzie.segmentProgress 0..1
  let gBar = f(1u); let barP = f(16u);                     // gate: bar (knob), vizzie.barPhase 0..1
  let gBeat = f(0u); let beatP = f(14u);                   // gate: beat (knob), vizzie.beatPhase 0..1
  let gDrum = f(9u); let drum = f(26u);                    // gate: drum (knob), amu drum activity 0..1 (raw)
  let gsz = 1. + GABOR_DRUM_SIZE * drum * gDrum;           // drum: Gabor grain size
  let gBass = f(10u); let bass = f(27u);                   // gate: bass (knob), amu bass activity 0..1 (raw)
  let gdark = mix(GABOR_DARK, GABOR_DARK_BASS, bass * gBass);   // bass: lightens the pattern's dark
  let hit = exp(-beatP * YB_BEAT_DECAY) * gBeat;           // beat envelope: 1 on the beat → settles
  let throb = 1. + YB_BEAT_PULSE * hit;                    // beat: headphones +5% → settle
  let gVoc = f(11u); let vocal = f(28u);                   // gate: vocal (knob), amu vocal activity 0..1 (raw)
  let cupf = smoothstep(YB_VOCAL_ON_LO, YB_VOCAL_ON_HI, vocal) * gVoc;   // vocal: how full the cups and eyes are (0 = open)
  let flap = sin(3.14159265 * fract(beatP * YB_FLAPS_PER_BEAT));   // 0 on the grid → open → 0, YB_FLAPS_PER_BEAT times per beat
  let beatInBar = floor(barP * 4.);                        // 0 … 3 (4/4)
  let accent = select(YB_ACCENT_WEAK, 1., fract(beatInBar * 0.5) < 0.25);   // beats 1 and 3 full, 2 and 4 weaker
  let lead = vocal / (vocal + (drum + bass + f(29u)) / 3. + 1e-3);         // how much the vocal leads the mix (f(29) = amu other)
  let leadAmt = mix(YB_LEAD_MIN, 1., smoothstep(YB_LEAD_LO, YB_LEAD_HI, lead));
  let jaw = YB_JAW_DROP * hit + YB_VOCAL_JAW * smoothstep(YB_VOCAL_LO, YB_VOCAL_HI, vocal) * flap * accent * leadAmt * gVoc;   // mouth: beat drop (off) + vocal flap
  let cf = sin(3.14159265 * barP) * gBar;                  // bar: colour fade, 0 → 1 at mid-bar → 0, sine ease
  let c2 = mix(STREAKS_02_COL, STREAKS_02_COL_TO, cf);
  let c3 = mix(STREAKS_03_COL, STREAKS_03_COL_TO, cf);
  let gPhr = f(4u);                                        // gate: phrase (knob)
  let phrP = f(19u);                                       // vizzie.phraseProgress 0..1
  let res = max(u.v[8].xy, vec2(1., 1.));                  // canvas resolution (px), slots 32–33
  let asp = res.x / res.y;
  let p = vec2(in.uv.x * asp, in.uv.y);                    // frame units, y up, half-height = 1
  let n = in.uv;                                           // −1 … 1 on both axes, y up
  let k = vec2(asp, 1.);                                   // n → frame units

  // ---- framing: height fit, capped by width on narrow frames ----
  let s = min(SUBJECT_HEIGHT, FIT_WIDTH * asp / SUBJECT_ASPECT);
  let a = (p - vec2(0., SUBJECT_Y)) / s;                   // subject units
  let aa = 2. / res.y / s;                                 // one pixel in subject units

  // ---- paint, back to front ----
  // background: colour ramp on the diagonal, glow right of centre, corner shade
  // phrase: the ramp's stops slide toward bottom-right and back, sine ease across each phrase
  let rc = RAMP_POS + RAMP_SWING * sin(3.14159265 * phrP) * gPhr;
  var col = mix(BG_TL, BG_BR, smoothstep(rc - RAMP_WIDTH, rc + RAMP_WIDTH, (n.x - n.y) * 0.5));
  col = mix(col, BG_HOT, 1. - smoothstep(0., GLOW_R, length((n - GLOW_POS) * k)));
  col = mix(col, BG_SHADE, SHADE_AMT * (1. - smoothstep(0., SHADE_R, length((n - SHADE_POS) * k))));
  // Gabor texture → Color Ramp (GABOR_DARK … background colour)
  col = mix(col, mix(gdark, col, smoothstep(GABOR_LO, GABOR_HI, gabor(p, f(13u), gsz))), GABOR_AMT);   // f(13) = vizzie.time

  // tablet: section → turns about its own vertical axis, continuous across sections (sections elapsed = index + progress)
  let spin = TAU * SECTION_TURNS * (secI + secP) * gSec;
  // streaks: segment → back to front, one zoom step per segment
  let f1 = segP * gSeg * STREAKS_01_SPEED;                 // cycle position of each group (each stroke adds its own start)
  let f2 = segP * gSeg * STREAKS_02_SPEED;
  let f3 = segP * gSeg * STREAKS_03_SPEED;
  let px = 2. / res.y / s;                                 // one pixel, subject units
  var tc = vec3(0.); var cov = 0.;                         // 2 × 2 samples per pixel for clean edges (box and streaks)
  for (var j = 0; j < 4; j++) {
    let off = (vec2(f32(j % 2), f32(j / 2)) - 0.5) * 0.5 * px;
    let hb = tablet(a + off, spin);
    if (hb.hit > 0.) {
      var base = select(TABLET_COL, TABLET_EDGE, hb.face > 1.5);
      if (hb.face < 0.5) {                                 // front: tablet_frame rim, tablet_screen inset; streaks on the screen only
        let sq = abs(hb.lp) - vec2(TABLET_ASPECT * TABLET_HALF_H - TABLET_RIM, TABLET_HALF_H - TABLET_RIM);
        let scr = select(0., 1., max(sq.x, sq.y) < 0.);    // 1 = inside tablet_screen
        base = mix(base, TABLET_SCREEN_COL, scr);
        base = mix(base, c2, cov02(hb.lp, f2) * scr);
        base = mix(base, c3, cov03(hb.lp, f3) * scr);
        base = mix(base, STREAKS_01_COL, cov01(hb.lp, f1) * scr);
      }
      if (hb.face > 0.5 && hb.face < 1.5) {                // back face: yobot_squint, mirrored in x so it reads the right way round from behind
        let yp = (vec2(-hb.lp.x, hb.lp.y) - YB_POS) / YB_SCALE;
        let yb = yobot(yp, throb, jaw);
        if (yb.z < 0.) { base = mix(base, YB_CUP_VOCAL_COL, cupf); }   // cups: open (tablet back) or filled while the vocal is on
        if (yb.w < 0.) { base = mix(base, YB_CUP_VOCAL_COL, cupf); }   // eyes: same
        let gq = abs(yp - vec2(YB_MOUTH_GAP_CX, YB_MOUTH_SEAM_Y - jaw * 0.5)) - vec2(YB_MOUTH_GAP_HW, jaw * 0.5 + 0.004);
        if (jaw > 1e-4 && max(gq.x, gq.y) < 0.) { base = YB_MOUTH_COL; }   // inside of the open mouth: streaks_02 red
        if (yb.y < 0.) { base = YB_COL; }                   // headphones
        if (yb.x < 0.) { base = YB_COL; }                   // head on top
      }
      tc += base * hb.shade; cov += 0.25;
    }
  }
  if (cov > 0.) { col = mix(col, tc / (cov * 4.), cov); }
  return vec4(col, 1.);
}
