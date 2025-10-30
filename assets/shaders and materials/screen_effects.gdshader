shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;
uniform float scale = 5.0;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_size = 1.0 / vec2(textureSize(SCREEN_TEXTURE,0)) * scale;
	uv = floor(SCREEN_UV / pixel_size) * pixel_size;
	vec4 col = texture(SCREEN_TEXTURE, uv);
	ALBEDO.rgb = vec3(1.0,0.0,0.0);
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
