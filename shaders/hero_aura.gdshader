shader_type canvas_item;
render_mode blend_add, unshaded;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	// Remove o quadriculado neutro da referência, preservando o dourado e o centro claro.
	float gold = smoothstep(0.02, 0.15, source.r - source.b);
	float core = smoothstep(0.65, 0.95, min(source.r, min(source.g, source.b)));
	COLOR = vec4(source.rgb, source.a * max(gold, core)) * COLOR;
}
