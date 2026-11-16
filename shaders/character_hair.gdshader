shader_type canvas_item;
uniform vec4 hair_color : source_color = vec4(0.56, 0.4, 0.29, 1.0);
uniform bool face_mask_enabled = false;
uniform sampler2D bald_base : source_color, filter_nearest, repeat_disable;
uniform vec4 bald_region;
uniform vec4 hair_region;
uniform vec4 hair_destination;
uniform vec4 head_source;
uniform vec4 head_destination;
uniform float face_top = 63.0;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float value = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	vec3 ink = hair_color.rgb * (0.35 + value * 1.8);
	float alpha = smoothstep(0.75, 0.95, source.a);
	if (face_mask_enabled) {
		vec2 hair_uv = (UV - hair_region.xy) / hair_region.zw;
		vec2 point = hair_destination.xy + hair_uv * hair_destination.zw;
		vec2 head_uv = (point - head_destination.xy) / head_destination.zw;
		vec2 base_point = head_source.xy + head_uv * head_source.zw;
		// Below the fringe, long strands fall behind the head and shoulders.
		// Follow the complete body silhouette to avoid a horizontal neck seam.
		if (base_point.x >= 0.0 && base_point.x <= 256.0 && base_point.y >= face_top && base_point.y <= 512.0) {
			vec2 base_uv = bald_region.xy + base_point / vec2(256.0, 512.0) * bald_region.zw;
			float face_alpha = smoothstep(0.75, 0.95, texture(bald_base, base_uv).a);
			alpha *= 1.0 - face_alpha;
		}
	}
	COLOR = vec4(ink, alpha) * tint;
}
