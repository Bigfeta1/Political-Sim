extends Node

signal population_changed(new_population)

var population:
	set(value):
		population = value
		population_changed.emit(value)

func get_save_data() -> Dictionary:
	return {
		"population": population,
	}

func load_save_data(data: Dictionary) -> void:
	population = data["population"]
