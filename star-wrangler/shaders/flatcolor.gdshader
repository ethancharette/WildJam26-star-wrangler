shader_type spatial;
render_mode unshaded;

void fragment() {
	ALBEDO = COLOR.rgb;
	EMISSION = COLOR.rgb;
}
