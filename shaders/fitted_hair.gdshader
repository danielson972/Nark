shader_type canvas_item;
uniform vec4 hair_color : source_color = vec4(0.56,0.4,0.29,1.0);
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec4 source = texture(TEXTURE,UV);
	float value = dot(source.rgb,vec3(0.299,0.587,0.114));
	float shade = floor(clamp(value/0.65,0.0,1.0)*4.0+0.5)/4.0;
	vec3 outline = mix(vec3(0.12,0.10,0.085),hair_color.rgb*0.30,0.35);
	vec3 ink = mix(outline,min(hair_color.rgb*1.22,vec3(1.0)),shade);
	COLOR = vec4(ink,source.a)*tint;
}
