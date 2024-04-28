shader_type spatial;

render_mode unshaded, cull_front;

uniform bool outline_enabled = false;
uniform float border_width : hint_range(0,1,0.001);
uniform vec4 color : source_color = vec4(1.0);

void vertex() {
	if (outline_enabled) {
		VERTEX += VERTEX * border_width;
	}
}

void fragment() {
	if (outline_enabled) {
		ALBEDO = color.xyz;
	}
}