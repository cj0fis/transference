shader_type spatial;
uniform vec4 hit_color: source_color;
uniform bool show_hit_color;

uniform vec4 light_color: source_color;
uniform float amount: hint_range(0.001,1.0);
uniform sampler2D albedo: filter_nearest, source_color;
uniform sampler2D noise;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec4 col = texture(albedo,UV);
	float n = texture(noise,UV).r;
	if(show_hit_color){
		EMISSION = hit_color.rgb;
		ALBEDO = vec3(0.0);
	}else{
		ALBEDO = col.rgb;
		EMISSION = step(n, mix(vec3(0.0),light_color.rgb,amount+0.1)) * mix(0.0, 2.0, amount);
	}
	ALPHA = col.a * n;
	ALPHA_SCISSOR_THRESHOLD = amount;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
