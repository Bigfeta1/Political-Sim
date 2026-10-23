uniform sampler2D terrain_map : filter_nearest, repeat_disable;
uniform vec2 map_origin;
uniform vec2 map_centre;

uniform vec3 wet_sand_colour : source_color = vec3(0.64, 0.46, 0.30);
uniform vec3 beach_colour : source_color = vec3(0.93, 0.79, 0.56);
uniform float wet_sand_width = 0.12;
uniform float beach_reach = 0.3;
uniform float beach_reach_min = 0.06;
uniform float coast_wave_scale = 2.2;
uniform float beach_roughness = 0.85;

const float SQRT_3 = 1.7320508;
const int TERRAIN_WATER = 1;
const int TERRAIN_DESERT = 2;
const vec2 HEX_DIRECTIONS[6] = vec2[](
	vec2(1.0, 0.0),
	vec2(1.0, -1.0),
	vec2(0.0, -1.0),
	vec2(-1.0, 0.0),
	vec2(-1.0, 1.0),
	vec2(0.0, 1.0)
);

vec2 to_axial(vec2 map_position) {
	float r = map_position.y / 1.5;
	float q = map_position.x / SQRT_3 - r * 0.5;
	return vec2(q, r);
}

vec2 round_axial(vec2 axial) {
	vec3 cube = vec3(axial.x, axial.y, -axial.x - axial.y);
	vec3 rounded = round(cube);
	vec3 difference = abs(rounded - cube);

	if (difference.x > difference.y && difference.x > difference.z) {
		rounded.x = -rounded.y - rounded.z;
	} else if (difference.y > difference.z) {
		rounded.y = -rounded.x - rounded.z;
	}
	return rounded.xy;
}

vec2 to_map_position(vec2 axial) {
	return vec2(SQRT_3 * (axial.x + axial.y * 0.5), 1.5 * axial.y);
}

int terrain_at(vec2 axial) {
	ivec2 pixel = ivec2(round(axial - map_origin));
	ivec2 size = textureSize(terrain_map, 0);

	if (any(lessThan(pixel, ivec2(0))) || any(greaterThanEqual(pixel, size))) {
		return -1;
	}
	return int(round(texelFetch(terrain_map, pixel, 0).r * 255.0));
}

float edge_distance(vec2 local, int index) {
	return SQRT_3 * 0.5 - dot(local, normalize(to_map_position(HEX_DIRECTIONS[index])));
}

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

float coast_hash(vec2 point) {
	return float(pcg2d(point).x) / 4294967295.0;
}

float coast_noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 local = fract(point);
	vec2 blend = local * local * (3.0 - 2.0 * local);

	float bottom = mix(coast_hash(cell), coast_hash(cell + vec2(1.0, 0.0)), blend.x);
	float top = mix(coast_hash(cell + vec2(0.0, 1.0)), coast_hash(cell + vec2(1.0, 1.0)), blend.x);
	return mix(bottom, top, blend.y);
}

float coast_push(vec2 map_position) {
	vec2 point = map_position * coast_wave_scale;
	float wave = coast_noise(point) * 0.65 + coast_noise(point * 2.3 + vec2(5.1, 1.7)) * 0.35;
	return mix(beach_reach_min, beach_reach, wave);
}

float desert_inland(vec2 map_position) {
	vec2 cell = round_axial(to_axial(map_position));
	vec2 local = map_position - to_map_position(cell);
	float push = coast_push(map_position);
	float nearest = 1000.0;

	for (int index = 0; index < 6; index++) {
		if (terrain_at(cell + HEX_DIRECTIONS[index]) == TERRAIN_WATER) {
			nearest = min(nearest, edge_distance(local, index) + push);
		}
	}
	return nearest;
}

float beach_shore(vec2 map_position) {
	vec2 cell = round_axial(to_axial(map_position));
	vec2 local = map_position - to_map_position(cell);
	float push = coast_push(map_position);
	float nearest = 1000.0;

	for (int index = 0; index < 6; index++) {
		if (terrain_at(cell + HEX_DIRECTIONS[index]) == TERRAIN_DESERT) {
			nearest = min(nearest, edge_distance(local, index) - push);
		}
	}
	return nearest;
}

vec3 beach_albedo(float inland) {
	return mix(wet_sand_colour, beach_colour, smoothstep(0.0, wet_sand_width, inland));
}
