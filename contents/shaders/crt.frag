/**
 * crt.frag
 * --------
 * Handles all CRT and post-processing effects.
 * 
 * Presets:
 * 0: Passthrough (only applies brightness boost)
 * 1: ZFast CRT
 * 2: Easymode CRT
 * 3: CRT-Geom
 * 4: Royale-Lite CRT
 *
 * Post-Effects:
 * - Scanline Jitter
 * - Chromatic Aberration (RGB Shift)
 * - Barrel Warp (Screen Curvature)
 * - Bloom / Halation
 * - Phosphor Mask (RGB Slot Mask)
 * - RF Noise
 */
#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 resolution;
    vec4 u_crtParams1; // x=preset, y=warp, z=bloom, w=rgbShift
    vec4 u_crtParams2; // x=noise, y=jitter, z=maskStrength, w=brightnessBoost
    vec4 u_bgColor;    // rgb=bgColor
    float u_time;
};

layout(binding = 1) uniform sampler2D source;

const vec2 PAL_RES = vec2(320.0, 256.0);
const float PI = 3.14159265;

// ── Shared helpers ──

vec2 applyWarp(vec2 uv, float strength) {
    vec2 c = uv * 2.0 - 1.0;
    float r2 = dot(c, c);
    return (c * (1.0 + strength * r2)) * 0.5 + 0.5;
}

float boundsCheck(vec2 uv) {
    return step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
}

// ── Preset 1: ZFast-CRT ──

vec4 zfastCRT(vec2 uv, vec2 res) {
    const float BRIGHTBOOST  = 1.05;
    const float LOWLUMSCAN   = 0.055;
    const float HILUMSCAN    = 0.16;
    const float MASK_DARK    = 0.25;
    const float MASK_FADE    = 0.4;
    const float BLURSCALEX   = 0.45;

    vec2 texSize = PAL_RES;
    vec2 invDims = 1.0 / texSize;

    // Quilez-style sharpening
    vec2 p = uv * texSize;
    vec2 i = floor(p) + 0.5;
    vec2 f = p - i;
    p = (i + 4.0 * f * f * f) * invDims;
    p.x = mix(p.x, uv.x, BLURSCALEX);

    float Y  = f.y * f.y;
    float YY = Y * Y;

    // Fine 2-pixel aperture mask
    float pixelX = uv.x * res.x;
    float mask = 1.0 + float(fract(floor(pixelX) * -0.5) < 0.5) * -MASK_DARK;

    vec3 colour = texture(source, p).rgb;

    float scanLineWeight  = BRIGHTBOOST - LOWLUMSCAN * (Y - 2.05 * YY);
    float scanLineWeightB = 1.0 - HILUMSCAN * (YY - 2.8 * YY * Y);

    float maskFade = 0.3333 * MASK_FADE;
    vec3 result = colour.rgb * mix(scanLineWeight * mask, scanLineWeightB, dot(colour.rgb, vec3(maskFade)));

    return vec4(result, 1.0);
}

// ── Preset 2: Easymode ──

vec4 easymodeCRT(vec2 uv, vec2 res) {
    const float HALATION       = 0.08;
    const float MASK_STRENGTH  = 0.35;
    const float SCANLINE_MIN   = 1.5;
    const float SCANLINE_MAX   = 1.5;
    const float BRIGHTBOOST    = 1.08;
    const float GAMMA_INPUT    = 2.4;
    const float GAMMA_OUTPUT   = 2.2;

    float palPixelSize = res.y / PAL_RES.y;
    float sceneW = res.x / max(palPixelSize, 0.0001);
    vec2 sceneRes = vec2(sceneW, PAL_RES.y);
    vec2 p = floor(uv * sceneRes);

    // Base colour with gamma
    vec3 col = texture(source, uv).rgb;
    col = pow(col, vec3(GAMMA_INPUT));

    // 3-tap horizontal halation approximation
    float dx = 1.0 / res.x;
    vec3 colL = pow(texture(source, uv + vec2(-dx, 0.0)).rgb, vec3(GAMMA_INPUT));
    vec3 colR = pow(texture(source, uv + vec2( dx, 0.0)).rgb, vec3(GAMMA_INPUT));
    float lum = dot(col, vec3(0.2126, 0.7152, 0.0722));
    vec3 halation = (colL + col + colR) / 3.0 * lum * HALATION;
    col = col + halation;

    // Scanline: brightness-weighted beam width
    float scanPos = fract(uv.y * PAL_RES.y);
    float scanDist = scanPos - 0.5;
    float beamWidth = mix(SCANLINE_MIN, SCANLINE_MAX, lum);
    float scanWeight = exp(-scanDist * scanDist * beamWidth * beamWidth * 4.0);

    col *= scanWeight * BRIGHTBOOST;

    // Aperture-grille phosphor mask (RGB vertical stripes)
    float maskIdx = mod(p.x, 3.0);
    vec3 phosphor = vec3(0.75);
    phosphor.r += MASK_STRENGTH * (1.0 - step(0.5, abs(maskIdx - 0.0)));
    phosphor.g += MASK_STRENGTH * (1.0 - step(0.5, abs(maskIdx - 1.0)));
    phosphor.b += MASK_STRENGTH * (1.0 - step(0.5, abs(maskIdx - 2.0)));
    col *= phosphor;

    // Gamma output
    col = pow(max(col, vec3(0.0)), vec3(1.0 / GAMMA_OUTPUT));

    return vec4(col, 1.0);
}

// ── Preset 3: Geom ──

vec4 geomCRT(vec2 uv, vec2 res, float warpOn) {
    const float CRT_GAMMA     = 2.2;
    const float MONITOR_GAMMA = 2.2;
    const float CORNERSIZE    = 0.03;
    const float CORNERSMOOTH  = 1000.0;
    const float DOTMASK       = 0.25;
    const float SCANLINE_W    = 0.3;
    const float LUM           = 0.0;

    // Use actual screen resolution for horizontal Lanczos (NOT PAL_RES — that caused moiré)
    // but use PAL_RES.y for vertical scanline count (256 authentic CRT scanlines)
    vec2 texSize = vec2(res.x, PAL_RES.y);
    vec2 invTexSize = 1.0 / texSize;

    // Barrel distortion curvature
    vec2 xy = uv;
    if (warpOn > 0.5) {
        xy = applyWarp(uv, 0.085);
    }

    float bounds = boundsCheck(xy);
    vec2 uvSafe = clamp(xy, vec2(0.0), vec2(0.999999));

    // Corner rounding
    vec2 cornerCoord = min(xy, 1.0 - xy);
    vec2 cdist = vec2(CORNERSIZE);
    vec2 coff = max(cdist - cornerCoord, vec2(0.0));
    float cornerDist = length(coff);
    float corner = clamp((CORNERSIZE - cornerDist) * CORNERSMOOTH, 0.0, 1.0);

    // Lanczos2 horizontal resampling at screen-pixel boundaries
    vec2 ratio = uvSafe * texSize - 0.5;
    vec2 uvFrac = fract(ratio);
    vec2 snapUv = (floor(ratio) + 0.5) * invTexSize;

    vec4 coeffs = PI * vec4(1.0 + uvFrac.x, uvFrac.x, 1.0 - uvFrac.x, 2.0 - uvFrac.x);
    coeffs = max(abs(coeffs), vec4(0.00001));
    coeffs = 2.0 * sin(coeffs) * sin(coeffs * 0.5) / (coeffs * coeffs);
    coeffs /= dot(coeffs, vec4(1.0));

    vec2 one = invTexSize;

    // Sample current and next scanline with Lanczos2 horizontal filtering
    vec4 col = clamp(
        texture(source, snapUv + vec2(-one.x, 0.0)) * coeffs.x +
        texture(source, snapUv)                      * coeffs.y +
        texture(source, snapUv + vec2( one.x, 0.0)) * coeffs.z +
        texture(source, snapUv + vec2(2.0*one.x, 0.0)) * coeffs.w,
        vec4(0.0), vec4(1.0));

    vec4 col2 = clamp(
        texture(source, snapUv + vec2(-one.x, one.y)) * coeffs.x +
        texture(source, snapUv + vec2(0.0, one.y))    * coeffs.y +
        texture(source, snapUv + one)                  * coeffs.z +
        texture(source, snapUv + vec2(2.0*one.x, one.y)) * coeffs.w,
        vec4(0.0), vec4(1.0));

    col  = pow(col,  vec4(CRT_GAMMA));
    col2 = pow(col2, vec4(CRT_GAMMA));

    // Non-Gaussian dual-scanline beam profile (CRT-Geom authentic)
    // Beam width adapts to brightness — brighter pixels produce wider beams
    vec4 wid1 = 2.0 + 2.0 * pow(col, vec4(4.0));
    vec4 w1 = vec4(uvFrac.y / SCANLINE_W);
    vec4 weights1 = (LUM + 1.0) * exp(-pow(w1 * inversesqrt(0.5 * wid1), wid1)) / (0.6 + 0.2 * wid1);

    vec4 wid2 = 2.0 + 2.0 * pow(col2, vec4(4.0));
    vec4 w2 = vec4((1.0 - uvFrac.y) / SCANLINE_W);
    vec4 weights2 = (LUM + 1.0) * exp(-pow(w2 * inversesqrt(0.5 * wid2), wid2)) / (0.6 + 0.2 * wid2);

    vec3 scannedCol = col.rgb * weights1.rgb + col2.rgb * weights2.rgb;

    // Dot mask (3-pixel RGB triad)
    float modFactor = uvSafe.x * res.x;
    float dotMask = 1.0 - DOTMASK * float(fract(modFactor * 0.3333) < 0.3333);

    // CRT-Geom inverse gamma correction compensating for scanline+mask embedded gamma
    vec3 pwr = vec3(1.0 / ((-0.7 * (1.0 - SCANLINE_W) + 1.0) * (-0.5 * DOTMASK + 1.0)) - 1.25);
    vec3 masked = scannedCol * dotMask;
    vec3 cir = masked - 1.0;
    cir *= cir;
    vec3 result = mix(sqrt(max(masked, vec3(0.0))), sqrt(max(1.0 - cir, vec3(0.0))), pwr);

    result *= corner;
    result = pow(max(result, vec3(0.0)), vec3(1.0 / MONITOR_GAMMA));

    // Bezel for out-of-bounds
    vec3 bezel = u_bgColor.rgb * 0.04;
    result = mix(bezel, result, bounds);

    return vec4(result, 1.0);
}

// ── Preset 4: Royale-Lite ──

vec4 royaleLiteCRT(vec2 uv, vec2 res, float warpOn) {
    const float BEAM_WIDTH    = 0.62;
    const float HALATION      = 0.12;
    const float BLOOM         = 0.08;
    const float GAMMA_IN      = 2.4;
    const float GAMMA_OUT     = 2.2;
    const float MASK_STRENGTH = 0.3;

    // Optional curvature
    vec2 xy = uv;
    if (warpOn > 0.5) {
        xy = applyWarp(uv, 0.065);
    }

    float bounds = boundsCheck(xy);
    vec2 uvSafe = clamp(xy, vec2(0.0), vec2(0.999999));

    float palPixelSize = res.y / PAL_RES.y;
    float sceneW = res.x / max(palPixelSize, 0.0001);
    vec2 sceneRes = vec2(sceneW, PAL_RES.y);
    vec2 p = floor(uvSafe * sceneRes);

    // 5-tap halation approximation
    float dx = 1.0 / res.x;
    vec3 c0  = pow(texture(source, uvSafe).rgb, vec3(GAMMA_IN));
    vec3 cL1 = pow(texture(source, uvSafe + vec2(-dx, 0.0)).rgb, vec3(GAMMA_IN));
    vec3 cR1 = pow(texture(source, uvSafe + vec2( dx, 0.0)).rgb, vec3(GAMMA_IN));
    vec3 cL2 = pow(texture(source, uvSafe + vec2(-2.0*dx, 0.0)).rgb, vec3(GAMMA_IN));
    vec3 cR2 = pow(texture(source, uvSafe + vec2( 2.0*dx, 0.0)).rgb, vec3(GAMMA_IN));
    float lum = dot(c0, vec3(0.2126, 0.7152, 0.0722));
    float lumSq = lum * lum;
    vec3 halation = (cL2 * 0.1 + cL1 * 0.25 + c0 * 0.3 + cR1 * 0.25 + cR2 * 0.1) * lumSq * HALATION;
    vec3 col = c0 + halation;

    // Gaussian beam scanline
    float scanPos = fract(uvSafe.y * PAL_RES.y);
    float scanDist = scanPos - 0.5;
    float beamSigma = BEAM_WIDTH * (1.0 - 0.4 * lum);
    float scanWeight = exp(-0.5 * scanDist * scanDist / (beamSigma * beamSigma));

    // Vertical bloom: blend with adjacent scanline
    float dy = 1.0 / res.y;
    vec3 colUp   = pow(texture(source, uvSafe + vec2(0.0, -dy)).rgb, vec3(GAMMA_IN));
    vec3 colDown = pow(texture(source, uvSafe + vec2(0.0,  dy)).rgb, vec3(GAMMA_IN));
    vec3 bloom = (colUp + colDown) * 0.5 * lumSq * BLOOM;
    col = col * scanWeight + bloom;

    // Phosphor triad with per-channel variation
    float maskIdx = mod(p.x, 3.0);
    vec3 phosphor = vec3(1.0 - MASK_STRENGTH);
    phosphor.r += MASK_STRENGTH * (1.0 - step(0.5, abs(maskIdx - 0.0)));
    phosphor.g += MASK_STRENGTH * (1.0 - step(0.5, abs(maskIdx - 1.0)));
    phosphor.b += MASK_STRENGTH * (1.0 - step(0.5, abs(maskIdx - 2.0)));
    col *= phosphor;

    // Physically-modeled cos⁴ vignette
    vec2 centered = uvSafe * 2.0 - 1.0;
    float cosTheta = 1.0 / sqrt(1.0 + dot(centered, centered) * 0.25);
    float vignette = cosTheta * cosTheta * cosTheta * cosTheta;

    col *= vignette;

    // Gamma output
    col = pow(max(col, vec3(0.0)), vec3(1.0 / GAMMA_OUT));

    vec3 bezel = u_bgColor.rgb * 0.04;
    col = mix(bezel, col, bounds);

    return vec4(col, 1.0);
}

// ── Analog post-effects ──

// Pseudo-random hash for RF noise
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// ── Main ──

void main()
{
    int preset = int(floor(u_crtParams1.x + 0.5));

    // Preset 0: Off — passthrough
    if (preset <= 0) {
        vec3 passthrough = texture(source, qt_TexCoord0).rgb;
        fragColor = vec4(clamp(passthrough * u_crtParams2.w, 0.0, 1.0), 1.0) * qt_Opacity;
        return;
    }

    vec2 uv = qt_TexCoord0;
    float warpOn = step(0.5, u_crtParams1.y);
    vec2 res = max(resolution, vec2(1.0, 1.0));

    // ── Scanline jitter (pre-effect) ──
    // Per-scanline horizontal displacement simulating unstable CRT signal
    float crtJitter = u_crtParams2.y;
    if (crtJitter > 0.001) {
        float scanIdx = floor(uv.y * PAL_RES.y);
        float time = u_time;
        float jitterAmount = (hash(vec2(scanIdx, time * 7.919)) - 0.5) * 2.0;
        uv.x += jitterAmount * crtJitter * 0.0015;
    }

    // ── Chromatic aberration (pre-sampling) ──
    vec2 uvR = uv, uvG = uv, uvB = uv;
    float crtRgbShift = u_crtParams1.w;
    if (crtRgbShift > 0.001) {
        vec2 dir = uv - 0.5;
        float shift = crtRgbShift * 0.015;
        uvR = uv + dir * shift;
        uvB = uv - dir * shift;
    }

    // Apply barrel warp for ZFast and Easymode
    if (warpOn > 0.5 && preset <= 2) {
        uv  = applyWarp(uv,  0.085);
        uvR = applyWarp(uvR, 0.085);
        uvG = applyWarp(uvG, 0.085);
        uvB = applyWarp(uvB, 0.085);
    }

    float bounds = boundsCheck(uv);
    vec2 uvSafe = clamp(uv, vec2(0.0), vec2(0.999999));

    vec4 result;

    if (preset == 1) {
        result = zfastCRT(uvSafe, res);
    } else if (preset == 2) {
        result = easymodeCRT(uvSafe, res);
    } else if (preset == 3) {
        result = geomCRT(uv, res, warpOn);
    } else {
        result = royaleLiteCRT(uv, res, warpOn);
    }

    // Compute edge mask for warped presets 1 & 2
    float edgeMask = 1.0;
    if (warpOn > 0.5 && preset <= 2) {
        const float CORNERSIZE = 0.03;
        const float CORNERSMOOTH = 800.0;
        vec2 cornerCoord = min(uv, 1.0 - uv);
        vec2 cdist = vec2(CORNERSIZE);
        vec2 coff = max(cdist - cornerCoord, vec2(0.0));
        float cornerDist = length(coff);
        edgeMask = clamp((CORNERSIZE - cornerDist) * CORNERSMOOTH, 0.0, 1.0) * bounds;
    }

    // ── Chromatic aberration (channel compositing) ──
    if (crtRgbShift > 0.001 && edgeMask > 0.01) {
        vec2 uvRSafe = clamp(uvR, vec2(0.0), vec2(0.999999));
        vec2 uvBSafe = clamp(uvB, vec2(0.0), vec2(0.999999));
        float rChan = texture(source, uvRSafe).r;
        float bChan = texture(source, uvBSafe).b;
        float strength = min(crtRgbShift, 1.0);
        result.r = mix(result.r, rChan * result.r / max(texture(source, uvSafe).r, 0.001), strength * 0.6);
        result.b = mix(result.b, bChan * result.b / max(texture(source, uvSafe).b, 0.001), strength * 0.6);
    }

    // ── Bloom / Halation (supports negative = dimming) ──
    float crtBloom = u_crtParams1.z;
    if (abs(crtBloom) > 0.001 && edgeMask > 0.01) {
        vec2 px = 1.0 / res;        vec3 bloomSample = (
            texture(source, uvSafe + vec2(-px.x, 0.0)).rgb +
            texture(source, uvSafe + vec2( px.x, 0.0)).rgb +
            texture(source, uvSafe + vec2(0.0, -px.y)).rgb +
            texture(source, uvSafe + vec2(0.0,  px.y)).rgb
        ) * 0.25;
        float luma = dot(result.rgb, vec3(0.2126, 0.7152, 0.0722));
        result.rgb += bloomSample * crtBloom * 0.8 * (0.5 + luma);
    }


    // ── Phosphor Mask (post-effect) ──
    // 3-subpixel RGB slot mask
    float crtMaskStrength = u_crtParams2.z;
    if (crtMaskStrength > 0.001 && edgeMask > 0.01) {
        float slot = mod(floor(uvSafe.x * res.x), 3.0);
        vec3 mask = vec3(1.0 - crtMaskStrength * 0.7);
        if (slot < 0.5)       mask.r += crtMaskStrength * 0.7;
        else if (slot < 1.5)  mask.g += crtMaskStrength * 0.7;
        else                  mask.b += crtMaskStrength * 0.7;
        result.rgb *= mask;
    }

    // ── Animated RF noise ──
    float crtNoise = u_crtParams2.x;
    if (crtNoise > 0.001 && edgeMask > 0.01) {
        float time = u_time;
        float noise = hash(uvSafe * res + vec2(time * 43.758, time * 27.391));
        vec3 noiseColor = vec3(
            hash(uvSafe * res + vec2(time * 13.37, time * 7.13)),
            noise,
            hash(uvSafe * res + vec2(time * 31.17, time * 11.97))
        );
        result.rgb += (noiseColor - 0.5) * crtNoise;
    }

    result.rgb = clamp(result.rgb, vec3(0.0), vec3(1.0));

    // Apply global brightness boost
    result.rgb = clamp(result.rgb * u_crtParams2.w, vec3(0.0), vec3(1.0));

    // Apply bezel AFTER all post-effects
    if (warpOn > 0.5 && preset <= 2) {
        vec3 bezel = u_bgColor.rgb * 0.04;
        result.rgb = mix(bezel, result.rgb, edgeMask);
    }

    fragColor = result * qt_Opacity;
}
