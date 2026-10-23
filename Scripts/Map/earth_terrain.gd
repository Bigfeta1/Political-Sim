extends Node

const MapCell = preload("res://Scripts/Map/map_cell.gd")
const MapFiles = preload("res://Scripts/Data/map_files.gd")
const BiomeGrid = preload("res://Scripts/Map/biome_grid.gd")

const MAP_ID = "earth"
const LAND_THRESHOLD = 0.5
const ISLAND_THRESHOLD = 0.25
const ISLAND_MAX_SQUARES = 200
const MIN_RESCUE_SQUARES = 3
const BIOME_THRESHOLD = 0.5

const BIOME_TERRAINS = {
	"desert": MapCell.Terrain.DESERT,
}

const EVEN_ROW_NEIGHBOURS = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(-1, -1),
	Vector2i(-1, 1),
]

const ODD_ROW_NEIGHBOURS = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(1, -1),
	Vector2i(1, 1),
]

var desert_regions := {}
var city_cells := {}

func generate(dimensions: Vector2i) -> Dictionary:
	desert_regions.clear()
	city_cells.clear()
	var land_map = MapFiles.find_by_id(MAP_ID)
	var sizes = measure_landmasses(land_map["rows"])
	var counts := {}
	var terrain := {}

	for row in dimensions.y:
		for column in dimensions.x:
			var offset = Vector2i(column, row)
			var squares = find_squares(land_map, dimensions, column, row)
			counts[offset] = count_landmasses(land_map["rows"], squares)
			terrain[offset] = MapCell.Terrain.LAND if is_land(counts[offset], squares.size(), sizes) else MapCell.Terrain.WATER

	var cells_of = index_landmasses(counts)
	rescue_islands(terrain, counts, cells_of, sizes)
	bridge_landmasses(terrain, counts, cells_of, dimensions)
	place_biomes(terrain, land_map, dimensions)
	place_cities(terrain, land_map, dimensions)

	return terrain

#region Squares
func find_squares(land_map: Dictionary, dimensions: Vector2i, column: int, row: int) -> Array[Vector2i]:
	var map_width = int(land_map["width"])
	var map_height = int(land_map["height"])
	var shift = 0.5 * (row % 2)

	var left = int((column + shift) / (dimensions.x + 0.5) * map_width)
	var right = max(left + 1, int((column + 1 + shift) / (dimensions.x + 0.5) * map_width))
	var top = int(float(row) / dimensions.y * map_height)
	var bottom = max(top + 1, int(float(row + 1) / dimensions.y * map_height))

	var squares: Array[Vector2i] = []
	for y in range(top, min(bottom, map_height)):
		for x in range(left, min(right, map_width)):
			squares.append(Vector2i(x, y))

	return squares
#endregion

#region Landmasses
func measure_landmasses(rows: Array) -> Dictionary:
	var sizes := {}

	for row in rows:
		for value in row:
			var landmass = int(value)
			if landmass != 0:
				sizes[landmass] = sizes.get(landmass, 0) + 1

	return sizes

func is_land(landmasses: Dictionary, square_count: int, sizes: Dictionary) -> bool:
	if land_total(landmasses) >= LAND_THRESHOLD * square_count:
		return true

	for landmass in landmasses:
		if sizes[landmass] < ISLAND_MAX_SQUARES and landmasses[landmass] >= ISLAND_THRESHOLD * square_count:
			return true

	return false

func count_landmasses(rows: Array, squares: Array[Vector2i]) -> Dictionary:
	var landmasses := {}

	for square in squares:
		var landmass = int(rows[square.y][square.x])
		if landmass != 0:
			landmasses[landmass] = landmasses.get(landmass, 0) + 1

	return landmasses

func land_total(landmasses: Dictionary) -> int:
	var total = 0
	for squares in landmasses.values():
		total += squares
	return total

func dominant(landmasses: Dictionary):
	var best = null
	for landmass in landmasses:
		if best == null or landmasses[landmass] > landmasses[best]:
			best = landmass
	return best

func index_landmasses(counts: Dictionary) -> Dictionary:
	var cells_of := {}

	for offset in counts:
		for landmass in counts[offset]:
			if not cells_of.has(landmass):
				cells_of[landmass] = {}
			cells_of[landmass][offset] = counts[offset][landmass]

	return cells_of
#endregion

#region Islands
func rescue_islands(terrain: Dictionary, counts: Dictionary, cells_of: Dictionary, sizes: Dictionary) -> void:
	var shown := {}
	for offset in terrain:
		if terrain[offset] == MapCell.Terrain.LAND:
			shown[dominant(counts[offset])] = true

	for landmass in cells_of:
		if not shown.has(landmass) and sizes[landmass] >= MIN_RESCUE_SQUARES:
			var cell = best_water_cell(cells_of[landmass], terrain)
			if cell != null:
				terrain[cell] = MapCell.Terrain.LAND

func best_water_cell(cells: Dictionary, terrain: Dictionary):
	var best = null
	for offset in cells:
		if terrain[offset] == MapCell.Terrain.WATER and (best == null or cells[offset] > cells[best]):
			best = offset
	return best
#endregion

#region Bridges
func bridge_landmasses(terrain: Dictionary, counts: Dictionary, cells_of: Dictionary, dimensions: Vector2i) -> void:
	for landmass in cells_of:
		var cells = cells_of[landmass]
		var pieces = find_pieces(landmass, cells, terrain, counts, dimensions)
		if pieces.size() < 2:
			continue

		pieces.sort_custom(func(a, b): return a.size() > b.size())
		var joined = pieces[0].duplicate()

		for i in range(1, pieces.size()):
			var path = cheapest_path(pieces[i], joined, cells, terrain, dimensions)
			if path.is_empty():
				continue

			for offset in path:
				terrain[offset] = MapCell.Terrain.LAND
			joined.merge(pieces[i])

func find_pieces(landmass, cells: Dictionary, terrain: Dictionary, counts: Dictionary, dimensions: Vector2i) -> Array:
	var pieces := []
	var seen := {}

	for start in cells:
		if seen.has(start) or not belongs_to(start, landmass, terrain, counts):
			continue

		var piece := {start: true}
		var stack := [start]
		seen[start] = true

		while not stack.is_empty():
			var current = stack.pop_back()
			for neighbour in neighbours(current, dimensions):
				if cells.has(neighbour) and not seen.has(neighbour) and belongs_to(neighbour, landmass, terrain, counts):
					seen[neighbour] = true
					piece[neighbour] = true
					stack.append(neighbour)

		pieces.append(piece)

	return pieces

func belongs_to(offset: Vector2i, landmass, terrain: Dictionary, counts: Dictionary) -> bool:
	return terrain[offset] == MapCell.Terrain.LAND and dominant(counts[offset]) == landmass

func cheapest_path(start: Dictionary, goal: Dictionary, cells: Dictionary, terrain: Dictionary, dimensions: Vector2i) -> Array:
	var cost := {}
	var previous := {}
	var queue := []

	for offset in start:
		cost[offset] = 0
		queue.append(offset)

	while not queue.is_empty():
		var current = queue.pop_front()
		if goal.has(current):
			return trace_water(current, previous, terrain)

		for neighbour in neighbours(current, dimensions):
			if not cells.has(neighbour):
				continue

			var step = 0 if terrain[neighbour] == MapCell.Terrain.LAND else 1
			var new_cost = cost[current] + step
			if new_cost < cost.get(neighbour, INF):
				cost[neighbour] = new_cost
				previous[neighbour] = current
				if step == 0:
					queue.push_front(neighbour)
				else:
					queue.push_back(neighbour)

	return []

func trace_water(end: Vector2i, previous: Dictionary, terrain: Dictionary) -> Array:
	var water := []
	var current = end

	while previous.has(current):
		if terrain[current] == MapCell.Terrain.WATER:
			water.append(current)
		current = previous[current]

	return water

func neighbours(offset: Vector2i, dimensions: Vector2i) -> Array:
	var result := []
	var directions = ODD_ROW_NEIGHBOURS if offset.y % 2 == 1 else EVEN_ROW_NEIGHBOURS

	for direction in directions:
		var neighbour = offset + direction
		if neighbour.x >= 0 and neighbour.x < dimensions.x and neighbour.y >= 0 and neighbour.y < dimensions.y:
			result.append(neighbour)

	return result
#endregion

#region Biomes
func place_biomes(terrain: Dictionary, land_map: Dictionary, dimensions: Vector2i) -> void:
	var biome_map = MapFiles.find_biomes_by_id(MAP_ID)
	var grid = BiomeGrid.build(biome_map, int(land_map["width"]), int(land_map["height"]))
	var desert_rows = biome_map.get("desert_rows", [])

	for offset in terrain:
		if terrain[offset] != MapCell.Terrain.LAND:
			continue

		var squares = find_squares(land_map, dimensions, offset.x, offset.y)
		var biomes = count_biomes(grid, squares)
		var biome = dominant(biomes)
		if biome != null and biomes[biome] >= BIOME_THRESHOLD * squares.size():
			terrain[offset] = BIOME_TERRAINS[biome]

		if terrain[offset] == MapCell.Terrain.DESERT:
			var region = dominant(count_desert_regions(desert_rows, squares))
			if region != null:
				desert_regions[offset] = region

func count_biomes(grid: Array, squares: Array[Vector2i]) -> Dictionary:
	var biomes := {}

	for square in squares:
		var biome = grid[square.y][square.x]
		if biome != "" and BIOME_TERRAINS.has(biome):
			biomes[biome] = biomes.get(biome, 0) + 1

	return biomes

func count_desert_regions(desert_rows: Array, squares: Array[Vector2i]) -> Dictionary:
	var regions := {}

	for square in squares:
		if square.y >= desert_rows.size():
			continue

		var region = int(desert_rows[square.y][square.x])
		if region != 0:
			regions[region] = regions.get(region, 0) + 1

	return regions
#endregion

#region Cities
func place_cities(terrain: Dictionary, land_map: Dictionary, dimensions: Vector2i) -> void:
	var city_squares := {}
	for city in MapFiles.find_cities_by_id(MAP_ID).get("cities", []):
		city_squares[to_square(city, land_map)] = true

	for offset in terrain:
		for square in find_squares(land_map, dimensions, offset.x, offset.y):
			if city_squares.has(square):
				city_cells[offset] = true

func to_square(city: Dictionary, land_map: Dictionary) -> Vector2i:
	var map_width = int(land_map["width"])
	var map_height = int(land_map["height"])
	var x = clampi(floori((city["longitude"] + 180.0) / 360.0 * map_width), 0, map_width - 1)
	var y = clampi(floori((90.0 - city["latitude"]) / 180.0 * map_height), 0, map_height - 1)
	return Vector2i(x, y)
#endregion
