shader_type canvas_item;
uniform vec4 hair_color : source_color = vec4(0.56,0.4,0.29,1.0);
uniform bool world_antialiasing = false;
uniform vec4 texture_region = vec4(0.0,0.0,1.0,1.0);
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec4 source = texture(TEXTURE,UV);
	float value = dot(source.rgb,vec3(0.299,0.587,0.114));
	float shade = floor(clamp(value/0.65,0.0,1.0)*4.0+0.5)/4.0;
	vec3 outline = mix(vec3(0.12,0.10,0.085),hair_color.rgb*0.30,0.35);
	vec3 ink = mix(outline,min(hair_color.rgb*1.22,vec3(1.0)),shade);
	float alpha = source.a;
	if (world_antialiasing) {
		vec2 dx = dFdx(UV);
		vec2 dy = dFdy(UV);
		vec2 lo = texture_region.xy+TEXTURE_PIXEL_SIZE*.5;
		vec2 hi = texture_region.xy+texture_region.zw-TEXTURE_PIXEL_SIZE*.5;
		vec3 total_ink = vec3(0.0);
		float coverage = 0.0;
		for (int y=0; y<4; y++) {
			for (int x=0; x<4; x++) {
				vec2 offset = (vec2(float(x),float(y))+vec2(.5))/4.0-vec2(.5);
				vec4 sample_color = texture(TEXTURE,clamp(UV+dx*offset.x+dy*offset.y,lo,hi));
				float sample_value = dot(sample_color.rgb,vec3(.299,.587,.114));
				float sample_shade = floor(clamp(sample_value/.65,0.0,1.0)*4.0+.5)/4.0;
				total_ink += mix(outline,min(hair_color.rgb*1.22,vec3(1.0)),sample_shade)*sample_color.a;
				coverage += sample_color.a;
			}
		}
		ink = mix(total_ink/max(coverage,.00001),ink,.20*source.a);
		alpha = coverage/16.0;
	}
	COLOR = vec4(ink,alpha)*tint;
}
