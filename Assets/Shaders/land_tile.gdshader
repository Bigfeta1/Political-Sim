shader_type spatial;

uniform vec3 grass_colour : source_color = vec3(0.24, 0.48, 0.18);
uniform vec3 dry_colour : source_color = vec3(0.46, 0.50, 0.24);
uniform float variation_scale = 0.35;

varying vec3 world_position;

float hash(vec2 point) {
	return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 local = fract(point);
	vec2 blend = local * local * (3.0 - 2.0 * local);

	float bottom = mix(hash(cell), hash(cell + vec2(1.0, 0.0)), blend.x);
	float top = mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0, 1.0)), blend.x);
	return mix(bottom, top, blend.y);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	ALBEDO = mix(grass_colour, dry_colour, value_noise(world_position.xz * variation_scale));
	ROUGHNESS = 0.9;
}
