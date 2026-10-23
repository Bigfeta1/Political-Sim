extends Node

func settle(mortality: Dictionary) -> void:
	var band_populations := {}
	for key in mortality["bands"]:
		band_populations[key] = mortality["bands"][key]["population"]
	get_child(0).population.set_band_populations(band_populations)

func band_population(key: String) -> float:
	var total := 0.0
	for city in get_children():
		total += city.population.band_populations[key]
	return total

func get_save_data() -> Dictionary:
	var cities := []
	for city in get_children():
		cities.append(city.get_save_data())
	return {
		"settlements": cities,
	}

func load_save_data(data: Dictionary) -> void:
	if not data.has("settlements"):
		get_child(0).load_save_data(data)
		return

	var cities = data["settlements"]
	for index in cities.size():
		get_child(index).load_save_data(cities[index])
