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
uniform float flow_speed = 0.12;
uniform float flow_cycle = 4.0;

uniform sampler2D map_data : filter_linear, repeat_disable;
uniform vec2 map_origin;
uniform vec2 map_centre;
uniform float max_coast_distance = 8.0;

uniform vec3 coast_colour : source_color = vec3(0.12, 0.62, 0.66);
uniform float shallow_hexes = 3.0;

uniform vec3 foam_colour : source_color = vec3(0.92, 0.97, 1.0);
uniform float foam_width = 0.22;
uniform float foam_line_width = 0.05;
uniform float foam_stripe_frequency = 35.0;
uniform float foam_stripe_speed = 1.5;
uniform float foam_breakup = 0.6;

uniform bool show_hex_outline = true;
uniform vec3 outline_colour : source_color = vec3(0.02, 0.08, 0.18);
uniform float outline_width = 0.03;
uniform float outline_opacity = 0.5;

const float SQRT_3 = 1.7320508;
const vec2 HEX_DIRECTIONS[6] = vec2[](
	vec2(1.0, 0.0),
	vec2(1.0, -1.0),
	vec2(0.0, -1.0),
	vec2(-1.0, 0.0),
	vec2(-1.0, 1.0),
	vec2(0.0, 1.0)
);

varying vec3 world_position;

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

vec4 sample_map_data(vec2 axial) {
	vec2 uv = (axial - map_origin + 0.5) / vec2(textureSize(map_data, 0));
	return texture(map_data, uv);
}

float land_flag(vec2 axial) {
	ivec2 pixel = ivec2(round(axial - map_origin));
	ivec2 size = textureSize(map_data, 0);

	if (any(lessThan(pixel, ivec2(0))) || any(greaterThanEqual(pixel, size))) {
		return 0.0;
	}
	return texelFetch(map_data, pixel, 0).g;
}

float shore_distance(vec2 map_position) {
	vec2 cell = round_axial(to_axial(map_position));
	vec2 local = map_position - to_map_position(cell);
	float nearest = 1000.0;

	for (int index = 0; index < 6; index++) {
		if (land_flag(cell + HEX_DIRECTIONS[index]) > 0.5) {
			vec2 direction = normalize(to_map_position(HEX_DIRECTIONS[index]));
			nearest = min(nearest, SQRT_3 * 0.5 - dot(local, direction));
		}
	}
	return nearest;
}

float hex_edge_distance(vec2 map_position) {
	vec2 local = abs(map_position - to_map_position(round_axial(to_axial(map_position))));
	return SQRT_3 * 0.5 - max(local.x, local.x * 0.5 + local.y * SQRT_3 * 0.5);
}

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

float flowed_height(vec2 point, float time, vec2 flow) {
	float cycle = TIME / flow_cycle;
	float first_phase = fract(cycle);
	float second_phase = fract(cycle + 0.5);
	float blend = abs(first_phase - 0.5) * 2.0;
	vec2 travel = flow * flow_speed * flow_cycle * wave_scale;

	float first = wave_height(point - travel * first_phase, time);
	float second = wave_height(point - travel * second_phase + vec2(7.3, 3.9), time);
	return mix(first, second, blend);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 point = world_position.xz * wave_scale;
	float time = TIME * wave_speed;
	float step_size = 0.05;

	vec2 map_position = world_position.xz + map_centre;
	vec4 map_sample = sample_map_data(to_axial(map_position));
	vec2 flow = map_sample.ba * 2.0 - 1.0;

	float height = flowed_height(point, time, flow);
	float height_x = flowed_height(point + vec2(step_size, 0.0), time, flow);
	float height_z = flowed_height(point + vec2(0.0, step_size), time, flow);

	vec3 world_normal = normalize(vec3(
		(height - height_x) / step_size * wave_strength,
		1.0,
		(height - height_z) / step_size * wave_strength
	));
	NORMAL = normalize((VIEW_MATRIX * vec4(world_normal, 0.0)).xyz);

	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	float coast_distance = map_sample.r * max_coast_distance;
	float openness = smoothstep(0.0, shallow_hexes, coast_distance);

	vec3 open_water = mix(deep_colour, shallow_colour, smoothstep(0.3, 0.75, height));
	vec3 water = mix(coast_colour, open_water, openness);

	ALBEDO = mix(water, rim_colour, fresnel * fresnel_strength);

	float shore = shore_distance(map_position) + (height - 0.5) * foam_breakup * foam_width;
	float foam_line = 1.0 - smoothstep(0.0, foam_line_width, shore);
	float stripe = smoothstep(0.6, 0.9, sin(shore * foam_stripe_frequency + TIME * foam_stripe_speed) * 0.5 + 0.5);
	float stripe_fade = 1.0 - smoothstep(0.0, foam_width, shore);
	float foam = max(foam_line, stripe * stripe_fade);
	ALBEDO = mix(ALBEDO, foam_colour, foam);

	if (show_hex_outline) {
		float edge = hex_edge_distance(map_position);
		float blur = fwidth(edge);
		float line = 1.0 - smoothstep(outline_width - blur, outline_width + blur, edge);
		ALBEDO = mix(ALBEDO, outline_colour, line * outline_opacity);
	}

	ROUGHNESS = mix(roughness, 0.8, foam);
	SPECULAR = 0.7;
}
