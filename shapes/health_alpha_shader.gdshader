shader_type canvas_item;

uniform float opaque_ratio: hint_range(0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Choose left or right half
    float local_alpha = UV.x < opaque_ratio ? 1.0 : 0.5;

    // Multiply texture alpha by local_alpha and parent modulate
    COLOR.rgb = tex_color.rgb * COLOR.rgb;           // tint with parent modulate
    COLOR.a = tex_color.a * local_alpha * COLOR.a;  // combine shader and parent alpha
}