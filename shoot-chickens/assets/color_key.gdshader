shader_type canvas_item;

uniform vec4 key_color : source_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform float threshold : hint_range(0.0, 1.0) = 0.01;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float dist = distance(tex_color.rgb, key_color.rgb);
	if (dist < threshold) {
		discard;
	}
	COLOR = tex_color;
}
