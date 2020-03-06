shader_type spatial;

render_mode unshaded, cull_disabled;

uniform vec3 color;


void fragment() {
	ALBEDO = color;
}

