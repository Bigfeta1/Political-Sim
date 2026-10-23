shader_type spatial;

uniform vec3 deep_colour : source_color = vec3(0.04, 0.18, 0.42);
uniform vec3 shallow_colour : source_color = vec3(0.10, 0.42, 0.68);
uniform float wave_scale = 0.8;
uniform float wave_speed = 0.6;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float wave = sin(world_position.x * wave_scale + TIME * wave_speed)
		* sin(world_position.z * wave_scale * 1.3 - TIME * wave_speed * 0.8);
	ALBEDO = mix(deep_colour, shallow_colour, wave * 0.5 + 0.5);
	ROUGHNESS = 0.15;
	SPECULAR = 0.6;
}
