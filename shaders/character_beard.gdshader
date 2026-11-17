shader_type canvas_item;
uniform bool original_color = true;
uniform bool world_antialiasing = false;
uniform vec4 beard_color : source_color = vec4(0.56,0.4,0.29,1.0);
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec4 source = texture(TEXTURE,UV);
	float alpha = smoothstep(.75,.95,source.a);
	if (world_antialiasing) {
		vec2 dx = dFdx(UV);
		vec2 dy = dFdy(UV);
		vec3 total_ink = vec3(0.0);
		float coverage = 0.0;
		for (int y=0; y<4; y++) {
			for (int x=0; x<4; x++) {
				vec2 offset = (vec2(float(x),float(y))+vec2(.5))/4.0-vec2(.5);
				vec4 sample_color = texture(TEXTURE,clamp(UV+dx*offset.x+dy*offset.y,TEXTURE_PIXEL_SIZE*.5,vec2(1.0)-TEXTURE_PIXEL_SIZE*.5));
				float sample_alpha = smoothstep(.75,.95,sample_color.a);
				total_ink += sample_color.rgb*sample_alpha;
				coverage += sample_alpha;
			}
		}
		source.rgb = mix(total_ink/max(coverage,.00001),source.rgb,.20*alpha);
		alpha = coverage/16.0;
	}
	vec3 ink = source.rgb;
	if (!original_color) {
		float value = dot(source.rgb,vec3(0.299,0.587,0.114));
		ink = beard_color.rgb*(0.30+value*1.8);
	}
	COLOR = vec4(ink,alpha)*tint;
}
