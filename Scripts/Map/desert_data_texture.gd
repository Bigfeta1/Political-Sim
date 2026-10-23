extends RefCounted

const MapCell = preload("res://Scripts/Map/map_cell.gd")
const WaterDataTexture = preload("res://Scripts/Map/water_data_texture.gd")

const ERG_SIZE = 25

static func build(cells: Dictionary) -> Dictionary:
	var origin = WaterDataTexture.find_origin(cells)
	var size = WaterDataTexture.find_size(cells, origin)

	var styles = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	styles.fill(Color(0.5, 0.5, 0.5, 0.0))
	var ergs = Image.create(size.x, size.y, false, Image.FORMAT_R8)
	ergs.fill(Color(0.0, 0.0, 0.0))

	for cluster in find_clusters(cells):
		var style = cluster_style(cluster)
		var erg_flag = 1.0 if cluster.size() >= ERG_SIZE else 0.0

		for coordinate in cluster:
			var pixel = coordinate - origin
			styles.set_pixel(pixel.x, pixel.y, style)
			ergs.set_pixel(pixel.x, pixel.y, Color(erg_flag, 0.0, 0.0))

	return {
		"styles": ImageTexture.create_from_image(styles),
		"ergs": ImageTexture.create_from_image(ergs),
	}

static func find_clusters(cells: Dictionary) -> Array:
	var clusters := []
	var seen := {}

	for start in cells:
		if seen.has(start) or cells[start].terrain != MapCell.Terrain.DESERT:
			continue

		var cluster := [start]
		seen[start] = true

		var index = 0
		while index < cluster.size():
			var coordinate = cluster[index]
			index += 1

			for neighbour in cells[coordinate].neighbours:
				if not seen.has(neighbour) and cells[neighbour].terrain == MapCell.Terrain.DESERT:
					seen[neighbour] = true
					cluster.append(neighbour)

		clusters.append(cluster)

	return clusters

static func lowest(cluster: Array) -> Vector2i:
	var anchor = cluster[0]
	for coordinate in cluster:
		if coordinate < anchor:
			anchor = coordinate
	return anchor

static func cluster_style(cluster: Array) -> Color:
	var anchor = lowest(cluster)

	var random = RandomNumberGenerator.new()
	random.seed = (anchor.x * 73856093) ^ (anchor.y * 19349663)
	return Color(random.randf(), random.randf(), random.randf(), random.randf())
