extends RefCounted

const MapCell = preload("res://Scripts/Map/map_cell.gd")

const MAX_COAST_DISTANCE = 8
const COASTAL_CURRENT_DISTANCE = 3.0
const PREVAILING_CURRENT = Vector2(0.96, 0.28)

static func build(cells: Dictionary) -> ImageTexture:
	var origin = find_origin(cells)
	var size = find_size(cells, origin)
	var distances = find_coast_distances(cells)
	var open_current = encode_current(PREVAILING_CURRENT)

	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 0.0, open_current.x, open_current.y))

	for coordinate in cells:
		var pixel = coordinate - origin
		var distance = coast_distance(distances, coordinate)
		var land = 1.0 if cells[coordinate].terrain == MapCell.Terrain.LAND else 0.0
		var current = encode_current(find_current(cells, distances, coordinate))
		image.set_pixel(pixel.x, pixel.y, Color(distance / float(MAX_COAST_DISTANCE), land, current.x, current.y))

	return ImageTexture.create_from_image(image)

static func coast_distance(distances: Dictionary, coordinate: Vector2i) -> int:
	return min(distances.get(coordinate, MAX_COAST_DISTANCE), MAX_COAST_DISTANCE)

static func find_current(cells: Dictionary, distances: Dictionary, coordinate: Vector2i) -> Vector2:
	var distance = coast_distance(distances, coordinate)
	var slope = Vector2.ZERO

	for neighbour in cells[coordinate].neighbours:
		var offset = neighbour - coordinate
		var direction = Vector2(sqrt(3.0) * (offset.x + offset.y / 2.0), 1.5 * offset.y).normalized()
		slope += direction * (coast_distance(distances, neighbour) - distance)

	if slope.is_zero_approx():
		return PREVAILING_CURRENT.normalized()

	var along_coast = Vector2(-slope.y, slope.x).normalized()
	var coastal_weight = 1.0 - clamp((distance - 1) / COASTAL_CURRENT_DISTANCE, 0.0, 1.0)
	return PREVAILING_CURRENT.normalized().lerp(along_coast, coastal_weight).normalized()

static func encode_current(current: Vector2) -> Vector2:
	return current * 0.5 + Vector2(0.5, 0.5)

static func find_origin(cells: Dictionary) -> Vector2i:
	var origin = Vector2i(2147483647, 2147483647)

	for coordinate in cells:
		origin = origin.min(coordinate)

	return origin

static func find_size(cells: Dictionary, origin: Vector2i) -> Vector2i:
	var maximum = origin

	for coordinate in cells:
		maximum = maximum.max(coordinate)

	return maximum - origin + Vector2i.ONE

static func find_coast_distances(cells: Dictionary) -> Dictionary:
	var distances := {}
	var frontier := []

	for coordinate in cells:
		if cells[coordinate].terrain == MapCell.Terrain.LAND:
			distances[coordinate] = 0
			frontier.append(coordinate)

	var index = 0
	while index < frontier.size():
		var coordinate = frontier[index]
		index += 1

		for neighbour in cells[coordinate].neighbours:
			if not distances.has(neighbour):
				distances[neighbour] = distances[coordinate] + 1
				frontier.append(neighbour)

	return distances
