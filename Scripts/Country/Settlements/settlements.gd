extends Node

func settle(mortality: Dictionary) -> void:
	var band_populations := {}
	for key in mortality["bands"]:
		band_populations[key] = mortality["bands"][key]["population"]
	get_child(0).data.city_band_populations = band_populations

func settle_workers(workers: Dictionary) -> void:
	get_child(0).data.city_workers = workers

func band_population(key: String) -> float:
	var total := 0.0
	for city in get_children():
		total += city.data.city_band_populations[key]
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
	if data.has("workers"):
		cities[0].merge({"workers": data["workers"]})
	for index in cities.size():
		get_child(index).load_save_data(cities[index])
