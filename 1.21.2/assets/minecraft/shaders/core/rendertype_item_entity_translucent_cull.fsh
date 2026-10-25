#version 150

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightColor;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * ColorModulator;

    // Emissive logic
    ivec4 ich = ivec4(floor(texelFetch(Sampler0, ivec2(texCoord0 * textureSize(Sampler0, 0)), 0) * 255) + .001);

    switch (ich.a) {
        case 149:
        case 150:
            color.rgb *= 0.35;
            color.a = 1.0;
            break;
        case 199:
        case 200:
            color.rgb *= 1.0;
            color.a = 0.75;
            break;
        case 252:
        case 253:
            color.rgb *= 1.0;
            color.a = 1.0;
            break;
        default:
            color *= vertexColor * lightColor;
            break;
    }

    if (color.a < 0.1) discard;

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}