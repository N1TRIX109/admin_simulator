shader_type canvas_item;

/*
	Endless Scrolling Checkerboard
	Works on ColorRect, TextureRect, Sprite2D, etc.
	Checker size and scroll speed are in pixels.
*/

uniform vec4 color_a : source_color = vec4(0.9, 0.9, 0.9, 1.0);
uniform vec4 color_b : source_color = vec4(0.2, 0.2, 0.2, 1.0);
uniform float checker_size : hint_range(1.0, 512.0, 1.0) = 64.0;
uniform vec2 scroll_speed = vec2(40.0, 40.0); // pixels per second, negative reverses
uniform float angle_degrees : hint_range(-180.0, 180.0, 0.1) = 0.0;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	float a = radians(angle_degrees);
	mat2 rot = mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)));
	vec2 p = (rot * (local_pos + scroll_speed * TIME)) / checker_size;
	float checker = mod(floor(p.x) + floor(p.y), 2.0);
	COLOR = mix(color_a, color_b, checker);
}