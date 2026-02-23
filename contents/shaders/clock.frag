/**
 * clock.frag
 * ----------
 * Renders the digital pixel clock with optional fractional seconds bar.
 * Computes a signed distance field (SDF) of the digits for smooth
 * scaling, rounded corners, borders, and shadows.
 *
 * Uses pre-computed digit data passed from the CPU.
 */
#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 resolution;
    vec4 u_stageBounds;
    vec4 u_clockParams; // x=clockMode, y=clockSeconds, z=clockOpacity
    vec4 u_clockDigits;
    vec4 u_clockColors1; // xyz=panelColor, a=pad
    vec4 u_clockColors2; // xyz=borderColor, a=pad
    vec4 u_clockColors3; // xyz=digitColor, a=pad
    vec4 u_clockColors4; // xyz=outlineColor, a=pad
    vec4 u_clockColors5; // xyz=barColor, a=pad
    vec4 u_sceneData1; // x=sceneW, y=sceneResY, z=centerX, w=stageW
    vec4 u_sceneData2; // x=wallCols, y=wallRows, z=pad, w=pad
};

const vec2 PAL_RES = vec2(320.0, 256.0);
const int font[50] = int[](
    7, 5, 5, 5, 7,
    2, 6, 2, 2, 7,
    7, 1, 7, 4, 7,
    7, 1, 7, 1, 7,
    5, 5, 7, 1, 1,
    7, 4, 7, 1, 7,
    7, 4, 7, 5, 7,
    7, 1, 1, 1, 1,
    7, 5, 7, 5, 7,
    7, 5, 7, 1, 7
);

float digitMask(vec2 logical, int digit)
{
    int x = int(floor(logical.x));
    int y = int(floor(logical.y));
    if (x < 0 || x > 2 || y < 0 || y > 4) {
        return 0.0;
    }
    int d = clamp(digit, 0, 9);
    int bits = font[d * 5 + y];
    int bit = (bits >> (2 - x)) & 1;
    return float(bit);
}

float colonMask(vec2 logical)
{
    int x = int(floor(logical.x));
    int y = int(floor(logical.y));
    if (x != 0) {
        return 0.0;
    }
    return float((y == 1) || (y == 3));
}

float clockGlyphMask(
    vec2 logical,
    int h0,
    int h1,
    int m0,
    int m1
) {
    if (logical.y < 0.0 || logical.y >= 5.0 || logical.x < 0.0 || logical.x >= 17.0) return 0.0;
    
    if (logical.x < 3.0) return digitMask(logical, h0);
    else if (logical.x >= 4.0 && logical.x < 7.0) return digitMask(logical - vec2(4.0, 0.0), h1);
    else if (logical.x >= 8.0 && logical.x < 9.0) return colonMask(logical - vec2(8.0, 0.0));
    else if (logical.x >= 10.0 && logical.x < 13.0) return digitMask(logical - vec2(10.0, 0.0), m0);
    else if (logical.x >= 14.0 && logical.x < 17.0) return digitMask(logical - vec2(14.0, 0.0), m1);
    
    return 0.0;
}

vec4 blendClockAlpha(
    float panelMask,
    float outlineMask,
    float glyphMask,
    float barTrackMask,
    float barFillMask,
    float panelOpacity
) {
    if (panelMask <= 0.0) return vec4(0.0);
    
    vec4 c = vec4(u_clockColors1.xyz, panelOpacity);
    
    c.xyz = mix(c.xyz, u_clockColors4.xyz, outlineMask * 0.68);
    c.w = max(c.w, outlineMask * panelOpacity * 0.95);
    
    c.xyz = mix(c.xyz, mix(u_clockColors2.xyz, vec3(0.0), 0.55), barTrackMask * 0.55);
    c.w = max(c.w, barTrackMask);
    
    c.xyz = mix(c.xyz, u_clockColors5.xyz, barFillMask * 0.92);
    c.w = max(c.w, barFillMask);
    
    c.xyz = mix(c.xyz, u_clockColors3.xyz, glyphMask);
    c.w = max(c.w, glyphMask);
    
    return vec4(c.xyz * c.w, c.w);
}

void main()
{
    int clockSizeMode = int(floor(u_clockParams.x + 0.5));
    if (clockSizeMode <= 0) {
        fragColor = vec4(0.0);
        return;
    }

    float sceneW = u_sceneData1.x;
    vec2 sceneRes = vec2(sceneW, u_sceneData1.y);

    vec2 uvSafe = clamp(qt_TexCoord0, vec2(0.0), vec2(0.999999));
    vec2 p = floor(uvSafe * sceneRes);

    float stageLeft = u_stageBounds.x;
    float stageRight = u_stageBounds.y;
    float seamY = u_stageBounds.z;
    float wallTop = 0.0;
    const float cell = 20.0;

    float stageW = u_sceneData1.w;
    float wallCols = u_sceneData2.x;
    float wallRows = u_sceneData2.y;

    float clockPanelMask = 0.0;
    float clockGlyph = 0.0;
    float clockOutline = 0.0;
    float clockBarTrack = 0.0;
    float clockBarFill = 0.0;

    float secValue = clamp(u_clockParams.y, 0.0, 59.999);
    float clockCell = 3.0; // Assuming default mapping from 2 for S etc if mode is 1 base

    if (clockSizeMode == 1) clockCell = 2.0;
    else if (clockSizeMode == 2) clockCell = 4.0;
    else if (clockSizeMode == 3) clockCell = 6.0;
    else if (clockSizeMode == 4) clockCell = 8.0;

    float logicalW = 17.0;
    float logicalH = 5.0;
    float digitsW = logicalW * clockCell;
    float digitsH = logicalH * clockCell;
    float gapToBar = max(1.0, floor(clockCell));
    float barH = max(1.0, floor(clockCell * 0.75));
    if (clockSizeMode == 1) {
        gapToBar = max(gapToBar, 3.0);
        barH = max(barH, 2.0);
    }
    float barMargin = 0.0;

    float contentW = digitsW;
    float contentH = digitsH + gapToBar + barH;
    float pad = max(1.0, floor(clockCell));

    float rawPanelW = contentW + 2.0 * pad;
    float rawPanelH = contentH + 2.0 * pad;
    float panelCellsW = 2.0;
    if (clockSizeMode == 2) panelCellsW = 4.0;
    else if (clockSizeMode == 3) panelCellsW = 6.0;
    else if (clockSizeMode == 4) panelCellsW = 8.0;
    panelCellsW = max(panelCellsW, ceil(rawPanelW / cell));
    float panelCellsHMin = (clockSizeMode == 1) ? 1.0 : 2.0;
    float panelCellsH = max(panelCellsHMin, ceil(rawPanelH / cell));

    float panelSpanW = panelCellsW * cell;
    float panelSpanH = panelCellsH * cell;
    float panelW = panelSpanW + 1.0;
    float panelH = panelSpanH + 1.0;

    float cellOffsetX = floor((wallCols - panelCellsW) * 0.5 + 0.5);
    float cellOffsetY = floor((wallRows - panelCellsH) * 0.5 + 0.5);
    float snappedOriginX = stageLeft + cellOffsetX * cell;
    float snappedOriginY = wallTop + cellOffsetY * cell;
    float maxOriginX = max(stageLeft, stageRight - panelSpanW);
    float maxOriginY = max(wallTop, seamY - panelSpanH);
    vec2 origin = floor(vec2(
        clamp(snappedOriginX, stageLeft, maxOriginX),
        clamp(snappedOriginY, wallTop, maxOriginY)
    ));
    vec2 panelLocal = p - origin;

    clockPanelMask =
        step(0.0, panelLocal.x) * step(panelLocal.x, panelW - 1.0) *
        step(0.0, panelLocal.y) * step(panelLocal.y, panelH - 1.0);

    if (clockPanelMask > 0.0) {
        vec2 contentOrigin = floor(vec2(
            (panelW - contentW) * 0.5,
            (panelH - contentH) * 0.5
        ));
        vec2 contentLocal = panelLocal - contentOrigin;

        float inDigits =
            step(0.0, contentLocal.x) * step(contentLocal.x, digitsW - 1.0) *
            step(0.0, contentLocal.y) * step(contentLocal.y, digitsH - 1.0);

        vec2 digitsLocal = contentLocal;
        if (inDigits > 0.0) {
            vec2 logical = floor(digitsLocal / clockCell);
            
            // Reusable digit values to save UBO lookups per neighbor
            int d_h0 = int(u_clockDigits.x);
            int d_h1 = int(u_clockDigits.y);
            int d_m0 = int(u_clockDigits.z);
            int d_m1 = int(u_clockDigits.w);

            clockGlyph = clockGlyphMask(logical, d_h0, d_h1, d_m0, d_m1);
            
            float nearGlyph = clockGlyph;
            nearGlyph = max(nearGlyph, clockGlyphMask(logical + vec2(1.0, 0.0), d_h0, d_h1, d_m0, d_m1));
            nearGlyph = max(nearGlyph, clockGlyphMask(logical + vec2(-1.0, 0.0), d_h0, d_h1, d_m0, d_m1));
            nearGlyph = max(nearGlyph, clockGlyphMask(logical + vec2(0.0, 1.0), d_h0, d_h1, d_m0, d_m1));
            nearGlyph = max(nearGlyph, clockGlyphMask(logical + vec2(0.0, -1.0), d_h0, d_h1, d_m0, d_m1));
            
            clockOutline = clamp(nearGlyph - clockGlyph, 0.0, 1.0) * inDigits;
        }

        float symGapToBar = gapToBar;
        float barY0 = digitsH + symGapToBar;
        float barX0 = barMargin;
        float barX1 = max(barX0, digitsW - 1.0 - barMargin);
        float inBarX = step(barX0, digitsLocal.x) * step(digitsLocal.x, barX1);
        float inBarY = step(barY0, digitsLocal.y) * step(digitsLocal.y, barY0 + barH - 1.0);
        clockBarTrack = inBarX * inBarY * clockPanelMask;
        float fillX = floor(mix(barX0, barX1, secValue / 59.999));
        clockBarFill = clockBarTrack * step(digitsLocal.x, fillX);
    }

    fragColor = blendClockAlpha(
        clockPanelMask,
        clockOutline,
        clockGlyph,
        clockBarTrack,
        clockBarFill,
        u_clockParams.z
    ) * qt_Opacity;
}
