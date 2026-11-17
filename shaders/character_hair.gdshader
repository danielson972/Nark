shader_type canvas_item;
uniform vec4 hair_color : source_color = vec4(0.56, 0.4, 0.29, 1.0);
uniform bool face_mask_enabled = false;
uniform bool bake_source = false;
uniform sampler2D bald_base : source_color, filter_nearest, repeat_disable;
uniform vec4 bald_region;
uniform vec4 hair_region = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec4 hair_destination = vec4(0.0, 0.0, 256.0, 256.0);
uniform vec4 head_source;
uniform vec4 head_destination;
uniform vec4 ear_mask;
uniform vec4 scalp;
uniform bool pointed_ears = false;
uniform vec4 face_features;
uniform bool front_braid = false;
uniform float strand_extension = 0.0;
varying vec4 tint;
void vertex() { tint = COLOR; }
float side(vec2 a, vec2 b, vec2 p) {
	return (b.x-a.x)*(p.y-a.y)-(b.y-a.y)*(p.x-a.x);
}
void fragment() {
	// Sample on the body's 256x512 canvas, not the much finer hair atlas.
	vec2 hair_uv = (UV - hair_region.xy) / hair_region.zw;
	vec2 point = hair_destination.xy + hair_uv * hair_destination.zw;
	vec2 sample_point = floor(point) + vec2(0.5);
	vec2 sample_uv = (sample_point - hair_destination.xy) / hair_destination.zw;
	if (strand_extension > 0.0) {
		float original_height = hair_destination.w - strand_extension;
		float pivot = clamp(head_destination.y + 32.0 * head_destination.z / head_source.z - hair_destination.y, 1.0, original_height - 1.0);
		float y = sample_point.y - hair_destination.y;
		if (y > pivot) { y = pivot + (y - pivot) * (original_height - pivot) / (hair_destination.w - pivot); }
		sample_uv.y = y / original_height;
	}
	vec4 source = texture(TEXTURE, hair_region.xy + clamp(sample_uv, vec2(0.0), vec2(1.0)) * hair_region.zw);
	float value = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	// A fixed ink outline and a small ramp match the body and beard palette.
	float shade = floor(clamp(value / 0.65, 0.0, 1.0) * 4.0 + 0.5) / 4.0;
	vec3 outline = mix(vec3(0.12, 0.10, 0.085), hair_color.rgb * 0.30, 0.35);
	vec3 ink = mix(outline, min(hair_color.rgb * 1.22, vec3(1.0)), shade);
	float alpha = smoothstep(0.75, 0.95, source.a);
	if (face_mask_enabled) {
		vec2 head_uv = (sample_point - head_destination.xy) / head_destination.zw;
		vec2 base_point = head_source.xy + head_uv * head_source.zw;
		// The supplied hair already has a transparent face opening. Never erase
		// the forehead with a horizontal cutoff: that also amputates the fringe.
		vec2 ear_point = (base_point - ear_mask.xy) / max(ear_mask.zw, vec2(1.0));
		float ear = 1.0 - smoothstep(0.85, 1.0, dot(ear_point, ear_point));
		if (pointed_ears) {
			vec2 a = vec2(scalp.x + scalp.z - 20.0, scalp.y + 48.0);
			vec2 b = vec2(scalp.x + scalp.z + 23.0, scalp.y + 31.0);
			vec2 c = vec2(scalp.x + scalp.z - 6.0, scalp.y + 70.0);
			ear = (side(a,b,base_point) >= 0.0 && side(b,c,base_point) >= 0.0 && side(c,a,base_point) >= 0.0) ? 1.0 : 0.0;
		}
		vec2 face_point = (base_point - face_features.xy) / max(face_features.zw, vec2(1.0));
		float features = 1.0 - smoothstep(0.85, 1.0, dot(face_point, face_point));
		bool behind_body = !front_braid && base_point.y >= head_source.y + head_source.w;
		if (base_point.x >= 0.0 && base_point.x <= 256.0 && base_point.y >= 0.0 && base_point.y <= 512.0) {
			vec2 base_uv = bald_region.xy + base_point / vec2(256.0, 512.0) * bald_region.zw;
			float face_alpha = smoothstep(0.75, 0.95, texture(bald_base, base_uv).a);
			alpha *= 1.0 - face_alpha * (behind_body ? 1.0 : max(ear, features));
		}
	}
	COLOR = vec4(bake_source ? source.rgb : ink, alpha) * tint;
}
