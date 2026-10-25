#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;

#ifdef PER_FACE_LIGHTING
in vec4 vertexPerFaceColorBack;
in vec4 vertexPerFaceColorFront;
#else
in vec4 vertexColor;
#endif

in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    
    // 1. CAPTURES RAW ALPHA ID
    int alphaID = int(round(color.a * 255.0));

#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif

    // 2. APPLY TINTS (Vertex Color & Global Modulator)
#ifdef PER_FACE_LIGHTING
    color *= (gl_FrontFacing ? vertexPerFaceColorFront : vertexPerFaceColorBack) * ColorModulator;
#else
    color *= vertexColor * ColorModulator;
#endif

    // 3. APPLY DAMAGE OVERLAY
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif

    // 4. CUSTOM EMISSIVE/UNLIT LOGIC
#ifndef EMISSIVE
    switch (alphaID) {
        case 149:
        case 150:
            // 35% Brightness
            color.rgb *= mix(lightMapColor.rgb, vec3(1.0), 0.35);
            break;
            
        case 199:
        case 200:
            // 75% Brightness
            color.rgb *= mix(lightMapColor.rgb, vec3(1.0), 0.75);
            break;
            
        case 252:
        case 253:
            // 100% Brightness
            break;
            
        default:
            // VANILLA BEHAVIOR: Apply full world lighting
            color *= lightMapColor;
            break;
    }
#endif

    // 5. APPLY FOG
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}