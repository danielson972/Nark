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
uniform vec2 attachment_size = vec2(0.0);
uniform bool world_antialiasing = false;

// Optional masks used by native armor-layer scenes. Defaults preserve all existing art.
uniform int armor_layer = -1;
uniform vec4 armor_glove_a = vec4(0.0);
uniform vec4 armor_glove_b = vec4(0.0);
uniform vec4 armor_skin_head = vec4(0.0);
uniform float armor_waist_y = 0.60;
uniform float armor_boots_y = 0.82;
uniform bool helmet_hollow = false;

bool armor_inside(vec2 p, vec4 rect) {
	return rect.z > 0.0 && p.x >= rect.x && p.y >= rect.y && p.x < rect.x + rect.z && p.y < rect.y + rect.w;
}

int armor_part_at(vec2 p) {
	if (armor_inside(p, armor_skin_head)) return -2;
	if (armor_inside(p, armor_glove_a) || armor_inside(p, armor_glove_b)) return 1;
	if (p.y >= armor_boots_y) return 3;
	if (p.y >= armor_waist_y) return 2;
	return 0;
}

void vertex() {
	equipment_tint = COLOR;
}

void fragment() {
	vec2 pixel_dx = dFdx(UV);
	vec2 pixel_dy = dFdy(UV);
	vec2 snapped_uv = UV;
	vec2 local_uv = (snapped_uv - texture_region.xy) / texture_region.zw;
	if (attachment_size.x > 0.0 && !world_antialiasing) {
		local_uv = (floor(local_uv * attachment_size) + vec2(0.5)) / attachment_size;
		snapped_uv = texture_region.xy + local_uv * texture_region.zw;
	}
	// Partition at the pixel center. Each piece samples the original full source
	// for AA, preventing doubled alpha or visible seams at internal boundaries.
	if (armor_layer >= 0 && armor_part_at(local_uv) != armor_layer) { discard; }
	if (local_uv.y < head_cutoff && local_uv.x > 0.26 && local_uv.x < 0.74) { discard; }
	// The far end of a sword grip goes behind the closed fist, not through it.
	if (trim_grip && dot(local_uv - grip_position, normalize(vec2(1.0, -1.0))) > 0.0) {
		discard;
	}
	vec4 source = texture(TEXTURE, snapped_uv);
	float alpha = smoothstep(0.75, 0.95, source.a);
	if (helmet_hollow && max(source.r, max(source.g, source.b)) < 0.12) { alpha = 0.0; }
	vec3 ink = source.rgb;
	if (world_antialiasing) {
		// Integrate the visible source area of a screen pixel before shrinking.
		// Clean transparent matte per sample, so it cannot contaminate the edge.
		vec2 lo = texture_region.xy + TEXTURE_PIXEL_SIZE * 0.5;
		vec2 hi = texture_region.xy + texture_region.zw - TEXTURE_PIXEL_SIZE * 0.5;
		vec3 total_ink = vec3(0.0);
		float coverage = 0.0;
		for (int y = 0; y < 4; y++) {
			for (int x = 0; x < 4; x++) {
				vec2 offset = (vec2(float(x),float(y)) + vec2(0.5)) / 4.0 - vec2(0.5);
				vec4 sample_color = texture(TEXTURE,clamp(UV+pixel_dx*offset.x+pixel_dy*offset.y,lo,hi));
				float sample_alpha = smoothstep(0.75,0.95,sample_color.a);
				if (helmet_hollow && max(sample_color.r, max(sample_color.g, sample_color.b)) < 0.12) { sample_alpha = 0.0; }
				total_ink += sample_color.rgb * sample_alpha;
				coverage += sample_alpha;
			}
		}
		// Retain a little native detail without bringing back hard edge aliasing.
		ink = mix(total_ink / max(coverage,0.00001),source.rgb,0.20*alpha);
		alpha = coverage / 16.0;
		source.rgb = ink;
	}
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
