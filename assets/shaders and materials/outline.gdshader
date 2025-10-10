shader_type spatial;
render_mode unshaded, cull_back;
varying vec3 v;
varying vec3 n;
void vertex() {
	v = VERTEX;
	n = NORMAL;
    //VERTEX += NORMAL * 0.05;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(v.y,0,0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
