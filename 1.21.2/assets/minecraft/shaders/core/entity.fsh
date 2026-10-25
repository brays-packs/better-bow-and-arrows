#version 150

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;
uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    
    // 1. Detect Alpha ID (Exactly like your 1.21.11 version)
    int alphaID = int(round(color.a * 255.0));

    // Vanilla Alpha Cutout
    if (color.a < 0.1) discard;

    // 2. Apply Tints and Global Modulator
    color *= vertexColor * ColorModulator;

    // 3. Apply Damage Overlay (Flash)
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);

    // 4. Your Custom Emissive Logic
    switch (alphaID) {
        case 149:
        case 150:
            // DIM EMISSIVE: 35% Full Brightness
            color.rgb *= mix(lightMapColor.rgb, vec3(1.0), 0.35);
            break;
            
        case 199:
        case 200:
            // TRANSLUCENT EMISSIVE: 75% Brightness
            color.rgb *= mix(lightMapColor.rgb, vec3(1.0), 0.75);
            color.a *= 0.75;
            break;
            
        case 252:
        case 253:
            // FULL EMISSIVE: Do not apply world shadows (skip lightMapColor)
            break;
            
        default:
            // NORMAL PIXELS: Apply full world lighting
            color *= lightMapColor;
            break;
    }

    // 5. 1.21.5 Compatible Fog
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}