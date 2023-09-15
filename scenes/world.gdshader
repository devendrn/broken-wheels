shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 col = textureLod(screen_texture, SCREEN_UV, 0.0);
	float vignette = 2.0*length(UV-vec2(0.5));
	col.rgb *= smoothstep(3.2,0.0,vignette);
	COLOR = col;
}
