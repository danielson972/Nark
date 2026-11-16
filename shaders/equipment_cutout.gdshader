shader_type canvas_item;

// Generated inventory art has a faint translucent matte outside the silhouette.
// Keep the original PNGs intact and suppress that matte when worn in the world.
varying vec4 equipment_tint;
uniform bool trim_grip = false;
uniform vec2 grip_position = vec2(0.5);
uniform vec4 texture_region = vec4(0.0, 0.0, 1.0, 1.0);
uniform bool colossal = false;

float silhouette(sampler2D image, vec2 uv, vec2 texel) {
	vec2 bounded = clamp(uv, texture_region.xy + texel, texture_region.xy + texture_region.zw - texel);
	return smoothstep(0.75, 0.95, texture(image, bounded).a);
}

void vertex() {
	equipment_tint = COLOR;
}

void fragment() {
	vec2 local_uv = (UV - texture_region.xy) / texture_region.zw;
	// The far end of a sword grip goes behind the closed fist, not through it.
	if (trim_grip && dot(local_uv - grip_position, normalize(vec2(1.0, -1.0))) > 0.0) {
		discard;
	}
	vec4 source = texture(TEXTURE, UV);
	float alpha = smoothstep(0.75, 0.95, source.a);
	vec3 ink = source.rgb;
	if (colossal) {
		float pulse = 0.5 + 0.5 * sin(TIME * 3.4);
		float shine = pow(max(0.0, sin((local_uv.x + local_uv.y) * 15.0 - TIME * 5.0)), 12.0);
		ink += vec3(0.23, 0.08, 0.34) * pulse + vec3(0.65, 0.40, 0.85) * shine;
		vec2 step_uv = texture_region.zw * 0.025;
		float around = max(max(silhouette(TEXTURE, UV + vec2(step_uv.x, 0.0), TEXTURE_PIXEL_SIZE), silhouette(TEXTURE, UV - vec2(step_uv.x, 0.0), TEXTURE_PIXEL_SIZE)),
			max(silhouette(TEXTURE, UV + vec2(0.0, step_uv.y), TEXTURE_PIXEL_SIZE), silhouette(TEXTURE, UV - vec2(0.0, step_uv.y), TEXTURE_PIXEL_SIZE)));
		float aura = max(0.0, around - alpha) * (0.25 + pulse * 0.30);
		ink = mix(vec3(0.68, 0.28, 1.0), ink, alpha);
		alpha = max(alpha, aura);
	}
	COLOR = vec4(ink, alpha) * equipment_tint;
}
