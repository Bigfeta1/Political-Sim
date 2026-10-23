shader_type spatial;

uniform vec3 deep_colour : source_color = vec3(0.02, 0.12, 0.32);
uniform vec3 shallow_colour : source_color = vec3(0.06, 0.36, 0.58);
uniform vec3 rim_colour : source_color = vec3(0.55, 0.78, 0.92);
uniform float wave_scale = 1.6;
uniform float wave_speed = 0.25;
uniform float wave_strength = 0.35;
uniform float warp_strength = 0.6;
uniform float fresnel_power = 4.0;
uniform float fresnel_strength = 0.6;
uniform float roughness = 0.08;

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

float fbm(vec2 point) {
	float total = 0.0;
	float amplitude = 0.5;
	mat2 rotation = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));

	for (int octave = 0; octave < 4; octave++) {
		total += value_noise(point) * amplitude;
		point = rotation * point * 2.03;
		amplitude *= 0.5;
	}
	return total;
}

float wave_height(vec2 point, float time) {
	vec2 warp = vec2(
		fbm(point * 0.35 + vec2(time * 0.10, 0.0)),
		fbm(point * 0.35 + vec2(5.2, time * 0.08))
	);
	vec2 warped = point + (warp - 0.5) * warp_strength * 4.0;

	float first = fbm(warped + vec2(time, time * 0.6));
	float second = fbm(warped * 1.7 + vec2(-time * 0.8, time * 1.1) + vec2(13.7, 4.1));
	return first * 0.6 + second * 0.4;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 point = world_position.xz * wave_scale;
	float time = TIME * wave_speed;
	float step_size = 0.05;

	float height = wave_height(point, time);
	float height_x = wave_height(point + vec2(step_size, 0.0), time);
	float height_z = wave_height(point + vec2(0.0, step_size), time);

	vec3 world_normal = normalize(vec3(
		(height - height_x) / step_size * wave_strength,
		1.0,
		(height - height_z) / step_size * wave_strength
	));
	NORMAL = normalize((VIEW_MATRIX * vec4(world_normal, 0.0)).xyz);

	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	vec3 water = mix(deep_colour, shallow_colour, smoothstep(0.3, 0.75, height));

	ALBEDO = mix(water, rim_colour, fresnel * fresnel_strength);
	ROUGHNESS = roughness;
	SPECULAR = 0.7;
}
