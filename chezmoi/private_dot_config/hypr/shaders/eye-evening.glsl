#version 300 es

precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float BRIGHTNESS = 0.80;
const float SATURATION = 0.72;
const vec3 WHITEPOINT = vec3(1.00, 0.90, 0.68);

void main() {
    vec4 px = texture(tex, v_texcoord);

    const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);
    float y = dot(px.rgb, LUMA);

    // Lower chroma without destroying syntax/diagnostic colors.
    vec3 rgb = mix(vec3(y), px.rgb, SATURATION);

    // Lower emitted intensity and progressively suppress shorter wavelengths.
    rgb *= WHITEPOINT * BRIGHTNESS;

    fragColor = vec4(clamp(rgb, 0.0, 1.0), px.a);
}
