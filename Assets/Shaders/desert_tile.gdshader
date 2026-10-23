shader_type spatial;

#include "res://Assets/Shaders/coast.gdshaderinc"

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

uniform float beach_width = 0.6;

uniform sampler2D desert_data : filter_nearest, repeat_disable;
uniform float wind_variation = 1.0;
uniform float frequency_min = 0.75;
uniform float frequency_max = 1.35;
uniform vec3 red_tint = vec3(1.06, 0.90, 0.80);
uniform vec3 pale_tint = vec3(1.03, 1.01, 0.97);
uniform float cluster_offset_range = 200.0;
uniform float region_wave = 0.3;
uniform float region_wave_scale = 2.5;

uniform sampler2D desert_ergs : filter_nearest, repeat_disable;
uniform float erg_height = 0.35;
uniform float erg_floor_tone = 0.35;
uniform float draa_frequency = 0.3;
uniform float draa_width = 0.65;
uniform float draa_meander = 1.2;
uniform float draa_segment_scale = 0.15;
uniform float draa_wander = 0.35;
uniform float draa_wander_scale = 0.1;
uniform float superposed_share = 0.25;
uniform float superposed_turn = 0.35;
uniform float superposed_meander = 0.25;

varying vec3 world_position;

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

vec4 desert_style(vec2 axial) {
	ivec2 pixel = ivec2(round(axial - map_origin));
	ivec2 size = textureSize(desert_data, 0);

	if (any(lessThan(pixel, ivec2(0))) || any(greaterThanEqual(pixel, size))) {
		return vec4(0.5, 0.5, 0.5, 0.0);
	}
	return texelFetch(desert_data, pixel, 0);
}

float desert_ergs_at(vec2 axial) {
	ivec2 pixel = ivec2(round(axial - map_origin));
	ivec2 size = textureSize(desert_ergs, 0);

	if (any(lessThan(pixel, ivec2(0))) || any(greaterThanEqual(pixel, size))) {
		return 0.0;
	}
	return texelFetch(desert_ergs, pixel, 0).r;
}

vec2 cluster_wind(float turn) {
	vec2 base = normalize(wind_direction);
	float angle = (turn - 0.5) * TAU * wind_variation;
	return vec2(base.x * cos(angle) - base.y * sin(angle), base.x * sin(angle) + base.y * cos(angle));
}

vec2 rotate(vec2 vector, float angle) {
	return vec2(vector.x * cos(angle) - vector.y * sin(angle), vector.x * sin(angle) + vector.y * cos(angle));
}

vec2 to_wind_space(vec2 point, vec2 wind) {
	return vec2(dot(point, wind), dot(point, vec2(-wind.y, wind.x)));
}

float dune_profile(float phase) {
	float ramp = phase < windward_share ? phase / windward_share : (1.0 - phase) / (1.0 - windward_share);
	return mix(ramp * (2.0 - ramp), ramp * ramp, crest_sharpness);
}

float field_shape(vec2 point, vec2 wind, float frequency, float coverage, float meander_strength) {
	vec2 wind_space = to_wind_space(point, wind);
	float meander = (fbm(vec2(wind_space.y * 0.35, wind_space.x * 0.12)) - 0.5) * 2.0 * meander_strength;
	float phase = fract((wind_space.x + meander) * frequency);
	float amplitude = mix(coverage, 1.0, smoothstep(0.2, 0.5, fbm(point * 0.25 + vec2(7.1, 2.9))));
	return dune_profile(phase) * amplitude;
}

float draa_profile(float ridge) {
	float ramp = ridge < windward_share ? ridge / windward_share : (1.0 - ridge) / (1.0 - windward_share);
	return smoothstep(0.0, 1.0, ramp);
}

float draa_shape(vec2 point, vec2 wind, out float flank) {
	vec2 wind_space = to_wind_space(point, wind);
	float bend = (fbm(vec2(wind_space.y * 0.12, wind_space.x * 0.05)) - 0.5) * 2.0 * draa_meander;
	float along = (wind_space.x + bend) * draa_frequency;
	float base_index = floor(along);
	float best = 0.0;
	flank = 0.0;

	for (int offset = -1; offset <= 1; offset++) {
		float ridge_index = base_index + float(offset);
		float wander = (value_noise(vec2(wind_space.y * draa_wander_scale, ridge_index * 7.3 + 100.0)) - 0.5) * 2.0 * draa_wander;
		float local = along - ridge_index - wander;
		if (local < 0.0 || local > draa_width) {
			continue;
		}
		float ridge = local / draa_width;

		float segment = smoothstep(0.35, 0.6, value_noise(vec2(wind_space.y * draa_segment_scale, ridge_index * 7.3)));
		float height = mix(0.6, 1.0, value_noise(vec2(wind_space.y * draa_segment_scale * 0.5, ridge_index * 7.3 + 50.0)));
		float shape = draa_profile(ridge) * segment * height;

		if (shape > best) {
			best = shape;
			flank = smoothstep(0.05, 0.2, ridge) * (1.0 - smoothstep(windward_share - 0.2, windward_share - 0.05, ridge)) * segment;
		}
	}
	return best;
}

float erg_shape(vec2 point, vec2 wind, float frequency) {
	float flank;
	float draa = draa_shape(point, wind, flank);
	float superposed = field_shape(point, rotate(wind, superposed_turn), frequency, 1.0, superposed_meander);
	return draa * (1.0 - superposed_share) + superposed * flank * superposed_share;
}

float dune_shape(vec2 point, vec2 wind, float frequency, float ergs) {
	if (ergs > 0.5) {
		return erg_shape(point, wind, frequency);
	}
	return field_shape(point, wind, frequency, 0.0, dune_meander);
}

float ripple_shape(vec2 point, vec2 wind) {
	float wobble = value_noise(point * 2.5) * 6.0;
	return sin(to_wind_space(point, wind).x * ripple_frequency + wobble) * 0.5 + 0.5;
}

float surface_height(vec2 point, vec2 wind, float frequency, float ergs, float sand, float ripple_fade) {
	float dunes = dune_shape(point, wind, frequency, ergs) * (ergs > 0.5 ? erg_height : dune_height);
	float ripples = ripple_shape(point, wind) * ripple_height * ripple_fade;
	return (dunes + ripples) * sand;
}

float hex_inside(vec2 local) {
	vec2 offset = abs(local);
	return SQRT_3 * 0.5 - max(offset.x, offset.x * 0.5 + offset.y * SQRT_3 * 0.5);
}

float region_score(float inside, vec2 axial, vec2 map_position) {
	return inside + (coast_noise(map_position * region_wave_scale + hash2(axial) * 97.0) - 0.5) * region_wave;
}

vec2 style_point(vec2 world_xz, vec4 style) {
	return world_xz + vec2(style.a, fract(style.a * 7.31)) * cluster_offset_range;
}

float style_rock(vec2 point) {
	return smoothstep(rock_threshold - 0.04, rock_threshold + 0.04, fbm(point * rock_scale + vec2(31.7, 12.3)));
}

vec3 style_heights(vec2 point, vec2 wind, float frequency, float ergs, float sand, float ripple_fade, float step_size) {
	return vec3(
		surface_height(point, wind, frequency, ergs, sand, ripple_fade),
		surface_height(point + vec2(step_size, 0.0), wind, frequency, ergs, sand, ripple_fade),
		surface_height(point + vec2(0.0, step_size), wind, frequency, ergs, sand, ripple_fade)
	);
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

vec3 style_albedo(vec2 point, float dune, float rock, vec3 tint, float crack_line) {
	vec3 sand_albedo = mix(trough_colour, sand_colour, smoothstep(0.0, 0.6, dune));
	sand_albedo = mix(sand_albedo, crest_colour, smoothstep(0.75, 1.0, dune));
	sand_albedo = mix(sand_albedo, pale_colour, smoothstep(0.45, 0.7, fbm(point * patch_scale + vec2(3.3, 9.1))) * patch_strength);

	vec3 rock_albedo = rock_colour * mix(0.85, 1.1, value_noise(point * 4.0));
	rock_albedo = mix(rock_albedo, crack_colour, crack_line);

	return mix(sand_albedo, rock_albedo, rock) * tint;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 map_position = world_position.xz + map_centre;
	float step_size = 0.01;
	vec2 pixel_size = fwidth(world_position.xz);

	float inland = desert_inland(map_position);
	float desert_share = smoothstep(beach_reach, beach_width, inland);

	vec2 cell = round_axial(to_axial(map_position));
	vec2 local = map_position - to_map_position(cell);
	vec4 style = desert_style(cell);
	float ergs = desert_ergs_at(cell);

	float best = region_score(hex_inside(local), cell, map_position);
	vec4 chosen_style = style;
	float chosen_ergs = ergs;

	for (int index = 0; index < 6; index++) {
		vec2 neighbour = cell + HEX_DIRECTIONS[index];
		float inside = hex_inside(local - to_map_position(HEX_DIRECTIONS[index]));
		if (inside < -region_wave || terrain_at(neighbour) != TERRAIN_DESERT) {
			continue;
		}

		float score = region_score(inside, neighbour, map_position);
		if (score > best) {
			best = score;
			chosen_style = desert_style(neighbour);
			chosen_ergs = desert_ergs_at(neighbour);
		}
	}

	vec2 wind = cluster_wind(chosen_style.r);
	float frequency = dune_frequency * mix(frequency_min, frequency_max, chosen_style.g);
	vec3 tint = mix(red_tint, pale_tint, style.b);
	vec2 point = style_point(world_position.xz, style);

	float rock = style_rock(point);
	float sand = (1.0 - rock) * desert_share;
	float ripple_fade = 1.0 - smoothstep(0.15, 0.4, length(pixel_size) * ripple_frequency);

	vec3 heights = style_heights(point, wind, frequency, chosen_ergs, sand, ripple_fade, step_size);

	float crack = crack_distance(point * crack_scale);
	float crack_blur = fwidth(crack);
	float crack_line = 1.0 - smoothstep(crack_width - crack_blur, crack_width + crack_blur, crack);
	float dune = dune_shape(point, wind, frequency, chosen_ergs);
	float dune_tone = chosen_ergs > 0.5 ? mix(erg_floor_tone, 1.0, dune) : dune;
	vec3 desert_albedo = style_albedo(point, dune_tone, rock, tint, crack_line);

	vec2 grain = point * sparkle_scale;
	vec2 grain_cell = floor(grain);
	float sparkle_fade = 1.0 - smoothstep(0.4, 0.9, length(pixel_size * sparkle_scale));
	float sparkle = step(1.0 - sparkle_density, hash(grain_cell)) * sparkle_fade * sand;

	vec3 mesh_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	mesh_normal = normalize(mix(vec3(0.0, 1.0, 0.0), mesh_normal, desert_share));
	vec3 slope = vec3((heights.x - heights.y) / step_size, 0.0, (heights.x - heights.z) / step_size);
	vec2 grain_tilt = (hash2(grain_cell) - 0.5) * sparkle_tilt * sparkle;
	vec3 world_normal = normalize(mesh_normal + slope + vec3(grain_tilt.x, 0.0, grain_tilt.y));
	NORMAL = normalize((VIEW_MATRIX * vec4(world_normal, 0.0)).xyz);

	ALBEDO = mix(beach_albedo(inland), desert_albedo, desert_share);
	ROUGHNESS = mix(mix(beach_roughness, roughness, desert_share), 0.15, sparkle);
	SPECULAR = mix(0.3, 1.0, sparkle);
}
