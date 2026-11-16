shader_type canvas_item;
uniform vec4 texture_region = vec4(0.0, 0.0, 1.0, 1.0);

// Generated inventory art has a faint translucent matte outside the silhouette.
// Keep the original PNGs intact and suppress that matte when worn in the world.
varying vec4 equipment_tint;
uniform bool trim_grip = false;
uniform vec2 grip_position = vec2(0.5);
uniform bool colossal = false;
uniform float head_cutoff = 0.0;
uniform bool orc_skin = false;

void vertex() {
	equipment_tint = COLOR;
}

void fragment() {
	vec2 snapped_uv = UV;
	vec2 local_uv = (snapped_uv - texture_region.xy) / texture_region.zw;
	if (local_uv.y < head_cutoff && local_uv.x > 0.26 && local_uv.x < 0.74) { discard; }
	// The far end of a sword grip goes behind the closed fist, not through it.
	if (trim_grip && dot(local_uv - grip_position, normalize(vec2(1.0, -1.0))) > 0.0) {
		discard;
	}
	vec4 source = texture(TEXTURE, snapped_uv);
	float alpha = smoothstep(0.75, 0.95, source.a);
	vec3 ink = source.rgb;
	bool hand_area = length((local_uv - vec2(0.23, 0.54)) / vec2(0.09, 0.08)) < 1.0 || length((local_uv - vec2(0.77, 0.55)) / vec2(0.09, 0.08)) < 1.0;
	bool neck_area = local_uv.x > 0.36 && local_uv.x < 0.67 && local_uv.y > 0.20 && local_uv.y < 0.30;
	if (orc_skin && (hand_area || neck_area) && source.r > source.g * 1.12 && source.g > source.b * 1.18 && source.r > 0.50) {
		ink = vec3(source.r * 0.65, source.g * 0.92, source.b * 0.54);
	}
	if (colossal) {
		float pulse = 0.5 + 0.5 * sin(TIME * 3.4);
		float shine = pow(max(0.0, sin((local_uv.x + local_uv.y) * 15.0 - TIME * 5.0)), 12.0);
		ink += vec3(0.23, 0.08, 0.34) * pulse + vec3(0.65, 0.40, 0.85) * shine;
		vec2 step_uv = texture_region.zw * 0.025;
		vec2 lo = texture_region.xy + TEXTURE_PIXEL_SIZE;
		vec2 hi = texture_region.xy + texture_region.zw - TEXTURE_PIXEL_SIZE;
		float around = smoothstep(0.75, 0.95, max(max(texture(TEXTURE, clamp(UV + vec2(step_uv.x, 0.0), lo, hi)).a,
			texture(TEXTURE, clamp(UV - vec2(step_uv.x, 0.0), lo, hi)).a),
			max(texture(TEXTURE, clamp(UV + vec2(0.0, step_uv.y), lo, hi)).a,
			texture(TEXTURE, clamp(UV - vec2(0.0, step_uv.y), lo, hi)).a)));
		float aura = max(0.0, around - alpha) * (0.25 + pulse * 0.30);
		ink = mix(vec3(0.68, 0.28, 1.0), ink, alpha);
		alpha = max(alpha, aura);
	}
	COLOR = vec4(ink, alpha) * equipment_tint;
}
