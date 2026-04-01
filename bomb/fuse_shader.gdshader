shader_type canvas_item;

uniform float burn_progress : hint_range(0.2, 1.0);
uniform float keep_start = 0.0;
uniform float keep_end = 0.5;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    bool protected_area = UV.x >= keep_start && UV.x <= keep_end;

    if (UV.x > burn_progress && !protected_area) {
        discard;
    }

    COLOR = color;
}