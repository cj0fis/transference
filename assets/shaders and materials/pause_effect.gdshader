shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_nearest_mipmap;
uniform float amount: hint_range(0.0,5.0);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb = textureLod(screen_texture, SCREEN_UV, amount).rgb; //blur effect
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
