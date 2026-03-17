shader_type canvas_item;

uniform float opaque_ratio : hint_range(0.0, 1.0);

void fragment() {
    float pos = 1.0 - UV.x;  // invert the direction
    float local_alpha = pos <= opaque_ratio ? 1.0 : 0.5;
    COLOR.a *= local_alpha;
}