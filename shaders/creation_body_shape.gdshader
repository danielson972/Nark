shader_type canvas_item;
// Front reference has a single build. Change the torso silhouette while
// retaining the original face, height and foot position in the editor.
uniform vec4 region = vec4(0.0, 0.0, 1.0, 1.0);
uniform float center_x = 0.5;
uniform float shoulders = 0.28;
uniform float hips = 0.68;
uniform float body_width = 1.0;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec2 local = (UV - region.xy) / region.zw;
	float weight = smoothstep(shoulders - 0.045, shoulders + 0.05, local.y);
	weight *= 1.0 - smoothstep(hips, hips + 0.15, local.y);
	local.x = center_x + (local.x - center_x) / mix(1.0, body_width, weight);
	if (local.x < 0.0 || local.x > 1.0) { discard; }
	COLOR = texture(TEXTURE, region.xy + local * region.zw) * tint;
}
