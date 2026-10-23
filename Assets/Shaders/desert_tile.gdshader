shader_type spatial;

uniform vec3 crest_colour : source_color = vec3(0.97, 0.82, 0.55);
uniform vec3 sand_colour : source_color = vec3(0.90, 0.66, 0.38);
uniform vec3 trough_colour : source_color = vec3(0.76, 0.49, 0.27);
uniform vec3 pale_colour : source_color = vec3(0.94, 0.83, 0.64);
uniform vec3 rock_colour : source_color = vec3(0.68, 0.47, 0.31);
uniform vec3 crack_colour : source_color = vec3(0.45, 0.29, 0.19);

uniform vec2 wind_direction = vec2(0.8, 0.6);
uniform float dune_frequency = 1.4;
uniform float dune_height = 0.09;
uniform float dune_meander = 0.9;
uniform float windward_share = 0.72;
uniform float crest_sharpness = 0.85;

uniform float ripple_frequency = 28.0;
uniform float ripple_height = 0.01;

uniform float patch_scale = 0.18;
uniform float patch_strength = 0.6;

uniform float rock_scale = 0.3;
uniform float rock_threshold = 0.67;
uniform float crack_scale = 6.0;
uniform float crack_width = 0.035;

uniform float sparkle_scale = 90.0;
uniform float sparkle_density = 0.04;
uniform float sparkle_tilt = 0.6;

uniform float roughness = 0.85;

varying vec3 world_position;

uvec2 pcg2d(vec2 point) {
	uvec2 value = uvec2(ivec2(floor(point))) * 1664525u + 1013904223u;
	value.x += value.y * 1664525u;
	value.y += value.x * 1664525u;
	value = value ^ (value >> 16u);
	value.x += value.y * 1664525u;
	value.y += value.x * 1664525u;
	value = value ^ (value >> 16u);
	return value;
}

float hash(vec2 point) {
	return float(pcg2d(point).x) / 4294967295.0;
}

vec2 hash2(vec2 point) {
	return vec2(pcg2d(point)) / 4294967295.0;
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

	for (int octave = 0; octave < 3; octave++) {
		total += value_noise(point) * amplitude;
		point = rotation * point * 2.03;
		amplitude *= 0.5;
	}
	return total / 0.875;
}

vec2 to_wind_space(vec2 point) {
	vec2 wind = normalize(wind_direction);
	return vec2(dot(point, wind), dot(point, vec2(-wind.y, wind.x)));
}

float dune_profile(float phase) {
	float ramp = phase < windward_share ? phase / windward_share : (1.0 - phase) / (1.0 - windward_share);
	return mix(ramp * (2.0 - ramp), ramp * ramp, crest_sharpness);
}

float dune_shape(vec2 point) {
	vec2 wind_space = to_wind_space(point);
	float meander = (fbm(vec2(wind_space.y * 0.35, wind_space.x * 0.12)) - 0.5) * 2.0 * dune_meander;
	float phase = fract((wind_space.x + meander) * dune_frequency);
	float amplitude = smoothstep(0.2, 0.5, fbm(point * 0.25 + vec2(7.1, 2.9)));
	return dune_profile(phase) * amplitude;
}

float ripple_shape(vec2 point) {
	float wobble = value_noise(point * 2.5) * 6.0;
	return sin(to_wind_space(point).x * ripple_frequency + wobble) * 0.5 + 0.5;
}

float surface_height(vec2 point, float sand, float ripple_fade) {
	float dunes = dune_shape(point) * dune_height;
	float ripples = ripple_shape(point) * ripple_height * ripple_fade;
	return (dunes + ripples) * sand;
}

float crack_distance(vec2 point) {
	vec2 cell = floor(point);
	vec2 local = fract(point);
	float nearest = 8.0;
	float second = 8.0;

	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 offset = vec2(float(x), float(y));
			float distance_to_seed = length(offset + hash2(cell + offset) - local);
			if (distance_to_seed < nearest) {
				second = nearest;
				nearest = distance_to_seed;
			} else if (distance_to_seed < second) {
				second = distance_to_seed;
			}
		}
	}
	return second - nearest;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 point = world_position.xz;
	float step_size = 0.01;

	float rock = smoothstep(rock_threshold - 0.04, rock_threshold + 0.04, fbm(point * rock_scale + vec2(31.7, 12.3)));
	float sand = 1.0 - rock;
	float ripple_fade = 1.0 - smoothstep(0.15, 0.4, length(fwidth(point)) * ripple_frequency);

	float height = surface_height(point, sand, ripple_fade);
	float height_x = surface_height(point + vec2(step_size, 0.0), sand, ripple_fade);
	float height_z = surface_height(point + vec2(0.0, step_size), sand, ripple_fade);

	vec2 grain = point * sparkle_scale;
	vec2 grain_cell = floor(grain);
	float sparkle_fade = 1.0 - smoothstep(0.4, 0.9, length(fwidth(grain)));
	float sparkle = step(1.0 - sparkle_density, hash(grain_cell)) * sparkle_fade * sand;

	vec3 mesh_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vec3 slope = vec3((height - height_x) / step_size, 0.0, (height - height_z) / step_size);
	vec2 grain_tilt = (hash2(grain_cell) - 0.5) * sparkle_tilt * sparkle;
	vec3 world_normal = normalize(mesh_normal + slope + vec3(grain_tilt.x, 0.0, grain_tilt.y));
	NORMAL = normalize((VIEW_MATRIX * vec4(world_normal, 0.0)).xyz);

	float dune = dune_shape(point);
	vec3 sand_albedo = mix(trough_colour, sand_colour, smoothstep(0.0, 0.6, dune));
	sand_albedo = mix(sand_albedo, crest_colour, smoothstep(0.75, 1.0, dune));
	sand_albedo = mix(sand_albedo, pale_colour, smoothstep(0.45, 0.7, fbm(point * patch_scale + vec2(3.3, 9.1))) * patch_strength);

	float crack = crack_distance(point * crack_scale);
	float crack_blur = fwidth(crack);
	float crack_line = 1.0 - smoothstep(crack_width - crack_blur, crack_width + crack_blur, crack);
	vec3 rock_albedo = rock_colour * mix(0.85, 1.1, value_noise(point * 4.0));
	rock_albedo = mix(rock_albedo, crack_colour, crack_line);

	ALBEDO = mix(sand_albedo, rock_albedo, rock);
	ROUGHNESS = mix(roughness, 0.15, sparkle);
	SPECULAR = mix(0.3, 1.0, sparkle);
}
