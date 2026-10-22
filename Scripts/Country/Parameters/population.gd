extends Node

signal population_changed(new_population)
signal life_expectancy_changed(new_life_expectancy)

var population:
	set(value):
		population = value
		population_changed.emit(value)

var life_expectancy:
	set(value):
		life_expectancy = value
		life_expectancy_changed.emit(value)

func get_save_data() -> Dictionary:
	return {
		"population": population,
		"life_expectancy": life_expectancy,
	}

func load_save_data(data: Dictionary) -> void:
	population = data["population"]
	life_expectancy = data["life_expectancy"]
