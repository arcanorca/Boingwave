/**
 * ball.frag
 * ---------
 * Renders the dynamic Boing Ball.
 * Maps a pre-rendered 2D index texture (.pgm) to user-defined theme colors.
 * Calculates dynamic dropshadow and specular highlights based on movement direction.
 */
#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 ballColorPrimary;
    vec4 ballColorSecondary;
    vec4 ballHighlightColor;
    vec4 shadowColor;
    float shadowOpacity;
    
    vec2 resolution;
    float u_palPixelSize;
    float u_time;
    float u_rotationSpeed;
    float u_targetFrameRate;
    
    float u_ballPosX;
    float u_ballPosY;
    float u_ballDirX;
};

layout(binding = 1) uniform sampler2D ballIndexTex;

vec3 boingPalette(float idx, float colorCycle, float xDir)
{
    float shadowMask = step(0.5, idx) * (1.0 - step(1.5, idx));
    float ballMask = step(1.5, idx);

    float rel = mod((idx - 2.0) - colorCycle + 14.0 * 8.0, 14.0);
    vec3 checker = mix(ballColorPrimary.rgb, ballColorSecondary.rgb, 1.0 - step(7.0, rel));
    float hiRel = mix(6.0, 0.0, step(0.0, xDir));
    float hi = 1.0 - step(0.5, abs(rel - hiRel));
    vec3 ballCol = mix(checker, ballHighlightColor.rgb, hi);

    return shadowColor.rgb * shadowMask + ballCol * ballMask;
}

void main()
{
    // Mechanical spatial rotation ported from the 1984 original mechanics.
    // X natively tracks both velocity and boundaries, guaranteeing true rolling.
    float xDir = u_ballDirX;
    
    // ~2.33 pixels per frame maps natively to 0.42857 multiplier.
    // u_rotationSpeed allows the user to break physical correctness for artistic effect.
    float frameMultiplier = 0.42857 * clamp(u_rotationSpeed, 0.1, 3.0);
    float frame = floor(u_ballPosX * frameMultiplier);
    
    // Because 'frame' is statically locked to X, when X decreases (moving left),
    // 'frame' natively decreases. Subtracting 'frame' ensures it spins clockwise 
    // going right, and counter-clockwise going left.
    float cycle = mod(2.0 - frame, 14.0);
    if (cycle < 0.0) cycle += 14.0;
    
    vec2 fragCoord = qt_TexCoord0 * resolution;
    // Center coordinate projection mapped directly to integer grid scale.
    // The C++ GPU drivers bind float directly, so we reconstruct vec2 manually to maintain O(1) packing.
    vec2 ballPosVector = vec2(u_ballPosX, u_ballPosY);
    vec2 pos = ballPosVector * u_palPixelSize;
    vec2 size = vec2(144.0, 100.0) * u_palPixelSize;

    if (fragCoord.x < pos.x || fragCoord.y < pos.y || fragCoord.x >= pos.x + size.x || fragCoord.y >= pos.y + size.y) {
        fragColor = vec4(0.0);
        return;
    }

    vec2 ballUV = (fragCoord - pos) / size;
    vec2 texSize = vec2(144.0, 100.0);
    vec2 texUv = (floor(ballUV * texSize) + vec2(0.5, 0.5)) / texSize;
    vec2 safeUv = clamp(texUv, vec2(0.0), vec2(0.9999));
    float idx = floor(texture(ballIndexTex, safeUv).r * 15.0 + 0.5);

    float shadowMask = step(0.5, idx) * (1.0 - step(1.5, idx));
    float ballMask = step(1.5, idx);
    float drawAlpha = ballMask + shadowMask * clamp(shadowOpacity, 0.0, 1.0);

    if (drawAlpha <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    vec3 color = boingPalette(idx, cycle, xDir);
    fragColor = vec4(color * drawAlpha, drawAlpha) * qt_Opacity;
}
