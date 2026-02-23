/**
 * bg.frag
 * -------
 * Renders the static background elements:
 * - Solid color background
 * - Infinite perspective floor
 * - Vertical wall grid
 *
 * Optimized for O(1) mathematical rendering without anti-aliasing.
 */
#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 resolution;
    vec4 u_bgParams; // rgb = bgColor, a = showGrid
    vec4 u_gridColor; // rgb = gridColor
    vec4 u_stageBounds;
    vec4 u_sceneData1; // x=sceneW, y=sceneResY, z=centerX, w=stageW
    vec4 u_sceneData2; // x=wallCols, y=wallRows, z=pad, w=pad
};

const vec2 PAL_RES = vec2(320.0, 256.0);

float modPos(float x, float y)
{
    return mod(x, y);
}

float gridLine(float coord, float spacing, float width)
{
    return 1.0 - step(width, modPos(coord, spacing));
}

float horizontalLineMask(vec2 p, float y, float x0, float x1, float width)
{
    return (1.0 - step(width, abs(p.y - y))) * step(x0, p.x) * step(p.x, x1);
}

float segmentMask(vec2 p, vec2 a, vec2 b, float width)
{
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / max(dot(ba, ba), 0.0001), 0.0, 1.0);
    vec2 d = pa - ba * h;
    return 1.0 - smoothstep(0.0, 0.01, length(d) - 0.51);
}



void main()
{
    float sceneW = u_sceneData1.x;
    vec2 sceneRes = vec2(sceneW, u_sceneData1.y);

    vec2 uvSafe = clamp(qt_TexCoord0, vec2(0.0), vec2(0.999999));
    vec2 p = floor(uvSafe * sceneRes);

    vec3 color = u_bgParams.xyz;

    float gridOn = step(0.5, u_bgParams.w);
    const float cell = 20.0;
    float lineW = 0.75;
    float floorLineW = 0.95;

    float stageLeft = u_stageBounds.x;
    float stageRight = u_stageBounds.y;
    float seamY = u_stageBounds.z;
    float floorBottomY = u_stageBounds.w;
    float stageW = u_sceneData1.w;
    float centerX = u_sceneData1.z;
    float wallTop = 0.0;
    float wallCols = u_sceneData2.x;
    float wallRows = u_sceneData2.y;

    float inWallX = step(stageLeft, p.x) * step(p.x, stageRight);
    float inWallY = step(wallTop, p.y) * step(p.y, seamY);
    float inWall = inWallX * inWallY;

    float wallLineX = gridLine(p.x - stageLeft, cell, lineW);
    float wallLineY = gridLine(p.y - wallTop, cell, lineW);
    float wallGrid = inWall * max(wallLineX, wallLineY);

    float floorExpand = 299.0 / 240.0;
    float bottomHalfWRaw = min(stageW * 0.5 * floorExpand, sceneW * 0.5 - 1.0);
    float bottomHalfW = max(stageW * 0.5, floor(bottomHalfWRaw / cell) * cell);
    float floorLeftBottom = floor(centerX - bottomHalfW);
    float floorRightBottom = floorLeftBottom + 2.0 * bottomHalfW;

    // --- Smooth Vector Lines for Perspective Floor ---
    // cp anchors to exactly the same coordinate grid spacing as `p`
    vec2 cp = uvSafe * sceneRes;
    cp.x -= 0.5; // Correct the +0.5 fragment boundary subpixel phase shift
    
    // Use continuous depth for mathematically perfect lines
    float cFloorDepth = clamp((cp.y - seamY) / max(floorBottomY - seamY, 1.0), 0.0, 1.0);
    // Important: Anchor to exactly same boundaries the wall uses (stageLeft, etc)
    float cFloorLeft = mix(stageLeft, floorLeftBottom, cFloorDepth);
    float cFloorRight = mix(stageRight, floorRightBottom, cFloorDepth);
    float cFloorWidth = max(cFloorRight - cFloorLeft, 1.0);
    
    // Smooth floor domain mask
    float inFloorC = step(seamY, cp.y) * step(cp.y, floorBottomY) * step(cFloorLeft, cp.x) * step(cp.x, cFloorRight);

    // 1) Perspective Rays
    // We must project the exact continuous pixel coordinate (cp) upwards to where it intersects the seamY line.
    // The total horizontal expansion at this depth is cFloorWidth at the bottom vs stageW at the seam.
    float cFloorU = (cp.x - cFloorLeft) / cFloorWidth; 
    float cSeamX = stageLeft + cFloorU * stageW;
    
    // Compute distance from projected seam X to the nearest vertical wall line (stageLeft + i*cell)
    float rayDistSeam = modPos(cSeamX - stageLeft, cell);
    rayDistSeam = min(rayDistSeam, cell - rayDistSeam);
    // Scale distance back from seam-space to screen-space 
    float rayDistScreen = rayDistSeam * (cFloorWidth / stageW);
    
    // Draw hard vector ray (exactly 1px thick to match wall lines)
    float rayMask = 1.0 - smoothstep(0.0, 0.01, rayDistScreen - 0.51);
    float floorRays = rayMask * inFloorC;

    // 2) Horizontal Bands exactly at theoretical perspective depths 
    float cy1 = mix(seamY, floorBottomY, 2.0 / 23.0);
    float cy2 = mix(seamY, floorBottomY, 5.0 / 23.0);
    float cy3 = mix(seamY, floorBottomY, 9.0 / 23.0);
    float cy4 = mix(seamY, floorBottomY, 15.0 / 23.0);
    vec4 cyVec = vec4(cy1, cy2, cy3, cy4);
    vec4 dyVec = abs(vec4(cp.y) - cyVec);
    // Exactly 1px thick horizontal bands
    vec4 bandMasks = 1.0 - smoothstep(0.0, 0.01, dyVec - 0.51);
    float floorBands = max(max(bandMasks.x, bandMasks.y), max(bandMasks.z, bandMasks.w));
    
    floorBands *= inFloorC;

    float floorGrid = max(floorRays, floorBands) * mix(1.0, 0.78, cFloorDepth);

    float edgeL = inWallY * (1.0 - step(1.0, abs(p.x - stageLeft)));
    float edgeR = inWallY * (1.0 - step(1.0, abs(p.x - stageRight)));
    float edgeT = inWallX * (1.0 - step(1.0, abs(p.y - wallTop)));
    float edgeSeam = inWallX * (1.0 - step(1.0, abs(p.y - seamY)));
    float floorEdgeL = segmentMask(cp, vec2(stageLeft, seamY), vec2(floorLeftBottom, floorBottomY), floorLineW);
    float floorEdgeR = segmentMask(cp, vec2(stageRight, seamY), vec2(floorRightBottom, floorBottomY), floorLineW);
    float floorEdgeB = (1.0 - smoothstep(0.0, 0.01, abs(cp.y - floorBottomY) - 0.51)) * step(floorLeftBottom, cp.x) * step(cp.x, floorRightBottom);
    float frameMask = max(max(edgeL, edgeR), max(max(edgeT, edgeSeam), max(floorEdgeL, max(floorEdgeR, floorEdgeB))));

    float gridMask = max(max(wallGrid, floorGrid), frameMask) * gridOn;
    color = mix(color, u_gridColor.xyz, gridMask);


    fragColor = vec4(color, 1.0) * qt_Opacity;
}
