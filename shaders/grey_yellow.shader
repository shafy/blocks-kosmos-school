shader_type spatial;

render_mode unshaded, cull_disabled;

void vertex() {
// Output:0

}

void fragment() {
// Color:2
	vec3 n_out2p0;
	float n_out2p1;
	n_out2p0 = vec3(0.87,0.87,0.7);
	n_out2p1 = 1.000000; 

// Output:0
	ALBEDO = n_out2p0;

}

void light() {
// Output:0

}
