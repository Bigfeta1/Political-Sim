extends RefCounted

static func build(biome_map: Dictionary, width: int, height: int) -> Array:
	var grid := []
	for y in height:
		var row := []
		row.resize(width)
		row.fill("")
		grid.append(row)

	var class_biomes = find_class_biomes(biome_map)
	var rows = biome_map.get("rows", [])

	for y in min(rows.size(), height):
		for x in min(rows[y].size(), width):
			grid[y][x] = class_biomes.get(int(rows[y][x]), "")

	return grid

static func find_class_biomes(biome_map: Dictionary) -> Dictionary:
	var class_biomes := {}
	var biomes = biome_map.get("biomes", {})

	for biome in biomes:
		for climate_class in biomes[biome]:
			class_biomes[int(climate_class)] = biome

	return class_biomes
