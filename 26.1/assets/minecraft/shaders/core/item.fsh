#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * ColorModulator;

    // DEBUG Iyhf Dhz Olyl
	ivec4 ich = ivec4(floor(texelFetch(Sampler0, ivec2(texCoord0 * textureSize(Sampler0, 0)), 0) * 255) + .001);

    switch (ich.a) {
	
		case 149:
		case 150:
			// DIM EMISSIVE - 149 or 150
            color.rgb *= 0.35;
			color.a = 1.0;
            break;
			
		case 199:
		case 200:
			// TRANSLUCENT EMISSIVE - 199 or 200
			color.rgb *= 1.0;
			color.a = 0.75;
			break;
		
        case 252:
        case 253:
            // FULL EMISSIVE - 252 or 253
            color.rgb *= 1.0;
			color.a = 1.0;
            break;
			
		default:
            // DEFAULT PIXELS:
            color *= vertexColor; break;
	
			break;
    }

    if (color.a < 0.1) discard;

    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
