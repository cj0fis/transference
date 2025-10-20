shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_nearest_mipmap;

uniform sampler2D blur_mask;
uniform float amount: hint_range(0.0,5.0);
uniform float dim: hint_range(0.0, 1.0);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float mask = texture(blur_mask, UV).r;
	COLOR.rgb = mix(textureLod(screen_texture, SCREEN_UV, amount).rgb, texture(screen_texture, SCREEN_UV).rgb, mask);
	//COLOR.rgb = textureLod(screen_texture, SCREEN_UV, amount).rgb * mix(1.0, texture(dim_texture, UV).r, dim); //blur effect
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
