extends Node

const MapCell = preload("res://Scripts/Map/map_cell.gd")

const LAND_SHARE = 0.29

const CONTINENT_COUNT = 6
const CONTINENT_RADIUS_MIN = 5.0
const CONTINENT_RADIUS_MAX = 9.0
const CONTINENT_STRETCH_MAX = 2.2
const CONTINENT_SPACING = 1.0 / 4.2
const CONTINENT_MARGIN = Vector2(0.12, 0.15)
const PLACEMENT_ATTEMPTS = 5000

const WARP_STRENGTH = 3.0
const WARP_FREQUENCY = 0.03
const WARP_OCTAVES = 3

const DETAIL_STRENGTH = 0.2
const DETAIL_FREQUENCY = 0.12
const DETAIL_OCTAVES = 4

const EDGE_FADE = 4.0

func generate(dimensions: Vector2i) -> Dictionary:
	var positions = find_positions(dimensions)
	var map_size = Vector2(dimensions.x + 0.5, (dimensions.y - 1) * sqrt(3.0) / 2.0)
	var continents = place_continents(map_size)

	var warp_x = normalise(sample(positions, create_noise(WARP_FREQUENCY, WARP_OCTAVES)))
	var warp_y = normalise(sample(positions, create_noise(WARP_FREQUENCY, WARP_OCTAVES)))
	var detail = normalise(sample(positions, create_noise(DETAIL_FREQUENCY, DETAIL_OCTAVES)))

	var heights := {}
	for offset in positions:
		var position = positions[offset]
		var warped = position + WARP_STRENGTH * Vector2(warp_x[offset], warp_y[offset])
		heights[offset] = continent_height(warped, continents) + DETAIL_STRENGTH * detail[offset] - edge_fade(position, map_size)

	var sea_level = find_sea_level(heights.values())
	var terrain := {}
	for offset in heights:
		terrain[offset] = MapCell.Terrain.LAND if heights[offset] > sea_level else MapCell.Terrain.WATER

	return terrain

#region Positions
func find_positions(dimensions: Vector2i) -> Dictionary:
	var positions := {}

	for row in dimensions.y:
		for column in dimensions.x:
			positions[Vector2i(column, row)] = Vector2(column + 0.5 * (row % 2), row * sqrt(3.0) / 2.0)

	return positions
#endregion

#region Continents
func place_continents(map_size: Vector2) -> Array:
	var continents := []
	var minimum = map_size * CONTINENT_MARGIN
	var maximum = map_size * (Vector2.ONE - CONTINENT_MARGIN)

	for _attempt in PLACEMENT_ATTEMPTS:
		if continents.size() == CONTINENT_COUNT:
			break

		var centre = Vector2(randf_range(minimum.x, maximum.x), randf_range(minimum.y, maximum.y))
		if is_spaced(centre, continents, map_size.x * CONTINENT_SPACING):
			continents.append({
				"centre": centre,
				"angle": randf_range(0.0, PI),
				"stretch": randf_range(1.0, CONTINENT_STRETCH_MAX),
				"radius": randf_range(CONTINENT_RADIUS_MIN, CONTINENT_RADIUS_MAX),
			})

	return continents

func is_spaced(centre: Vector2, continents: Array, spacing: float) -> bool:
	for continent in continents:
		if centre.distance_to(continent["centre"]) <= spacing:
			return false

	return true

func continent_height(position: Vector2, continents: Array) -> float:
	var height = -INF

	for continent in continents:
		var local = (position - continent["centre"]).rotated(-continent["angle"])
		var distance = Vector2(local.x / continent["stretch"], local.y).length()
		height = max(height, 1.0 - distance / continent["radius"])

	return height

func edge_fade(position: Vector2, map_size: Vector2) -> float:
	var edge = min(position.x, map_size.x - position.x, position.y, map_size.y - position.y)
	return max(0.0, (EDGE_FADE - edge) / EDGE_FADE)
#endregion

#region Noise
func create_noise(frequency: float, octaves: int) -> FastNoiseLite:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = frequency
	noise.fractal_octaves = octaves
	return noise

func sample(positions: Dictionary, noise: FastNoiseLite) -> Dictionary:
	var values := {}

	for offset in positions:
		values[offset] = noise.get_noise_2d(positions[offset].x, positions[offset].y)

	return values

func normalise(values: Dictionary) -> Dictionary:
	var mean = 0.0
	for value in values.values():
		mean += value
	mean /= values.size()

	var variance = 0.0
	for value in values.values():
		variance += (value - mean) * (value - mean)
	var deviation = sqrt(variance / values.size())

	var normalised := {}
	for key in values:
		normalised[key] = (values[key] - mean) / deviation

	return normalised
#endregion

func find_sea_level(heights: Array) -> float:
	heights.sort()
	return heights[int(heights.size() * (1.0 - LAND_SHARE))]
