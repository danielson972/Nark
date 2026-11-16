shader_type canvas_item;
render_mode blend_add, unshaded;

uniform float orbit_phase = 0.0;
uniform bool back_layer = false;
varying vec4 effect_tint;

void vertex() {
	effect_tint = COLOR;
}

void fragment() {
	// Coordenadas locais do quadro atual, sem misturar os vizinhos do spritesheet.
	vec2 uv = fract(UV * vec2(6.0, 2.0));
	vec2 p = (uv - vec2(0.5)) * 2.0;
	// Pequenas variações periódicas mantêm o loop, com uma órbita menos mecânica.
	float tilt = -0.55 + 0.055 * sin(orbit_phase);
	vec2 q = mat2(vec2(cos(tilt), -sin(tilt)), vec2(sin(tilt), cos(tilt))) * p;
	vec2 ellipse = q / vec2(0.79 + 0.025 * sin(orbit_phase * 2.0), 0.41 + 0.02 * cos(orbit_phase));
	float angle = atan(ellipse.y, ellipse.x);
	float radius = length(ellipse) + 0.035 * sin(angle * 3.0 + orbit_phase);
	float head_a = orbit_phase + 0.16 * sin(orbit_phase * 2.0);
	float head_b = orbit_phase + 3.14159265 + 0.23 * sin(orbit_phase + 0.6);
	float trail_a = mod(head_a - angle + 12.5663706, 6.2831853);
	float trail_b = mod(head_b - angle + 12.5663706, 6.2831853);
	float trail = max(1.0 - smoothstep(0.0, 1.8, trail_a), 0.9 * (1.0 - smoothstep(0.0, 2.1, trail_b)));
	float line = exp(-pow((radius - 1.0) / 0.025, 2.0));
	float halo = exp(-pow((radius - 1.0) / 0.085, 2.0));
	// A metade superior da órbita é desenhada atrás do corpo, a inferior na frente.
	float front = step(0.0, sin(angle));
	float layer_mask = front;
	if (back_layer) { layer_mask = 1.0 - front; }
	vec3 light = (vec3(1.0, 0.87, 0.53) * line + vec3(1.0, 0.46, 0.07) * halo * 0.35) * trail * layer_mask;
	// Mantém o brilho central do spritesheet, fixo no torso e com pulsação suave.
	if (!back_layer) {
		vec4 source = texture(TEXTURE, UV);
		float gold = smoothstep(0.02, 0.15, source.r - source.b);
		float core = 1.0 - smoothstep(0.12, 0.40, length(p));
		light += source.rgb * source.a * gold * core * (0.8 + 0.1 * sin(orbit_phase));
	}
	COLOR = vec4(light, 1.0) * effect_tint;
}
