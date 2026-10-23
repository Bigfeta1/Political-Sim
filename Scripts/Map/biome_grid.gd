extends RefCounted

static func build(biome_map: Dictionary, width: int, height: int) -> Array:
	var grid := []
	for y in height:
		var row := []
		row.resize(width)
		row.fill("")
		grid.append(row)

	for region in biome_map.get("regions", []):
		for points in region["polygons"]:
			mark_polygon(grid, to_polygon(points), region["biome"], width, height)

	return grid

static func to_polygon(points: Array) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for point in points:
		polygon.append(Vector2(point[0], point[1]))
	return polygon

static func mark_polygon(grid: Array, polygon: PackedVector2Array, biome: String, width: int, height: int) -> void:
	var minimum = Vector2.INF
	var maximum = -Vector2.INF
	for point in polygon:
		minimum = minimum.min(point)
		maximum = maximum.max(point)

	var left = clampi(floori((minimum.x + 180.0) / 360.0 * width), 0, width - 1)
	var right = clampi(floori((maximum.x + 180.0) / 360.0 * width), 0, width - 1)
	var top = clampi(floori((90.0 - maximum.y) / 180.0 * height), 0, height - 1)
	var bottom = clampi(floori((90.0 - minimum.y) / 180.0 * height), 0, height - 1)

	for y in range(top, bottom + 1):
		for x in range(left, right + 1):
			if Geometry2D.is_point_in_polygon(square_centre(x, y, width, height), polygon):
				grid[y][x] = biome

static func square_centre(x: int, y: int, width: int, height: int) -> Vector2:
	return Vector2(-180.0 + (x + 0.5) * 360.0 / width, 90.0 - (y + 0.5) * 180.0 / height)
