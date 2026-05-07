shader_type canvas_item;

uniform float intensity = 0.0;

void fragment() {
	float d = distance(UV, vec2(0.5));
	COLOR = vec4(0.0, 0.5, 1.0, d * intensity); // Màu xanh dương ở rìa
}
