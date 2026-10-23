extends Node

signal population_count_changed(new_population_count)

var population_count

func set_population_count(value):
	population_count = value
	population_count_changed.emit(value)

func get_save_data() -> Dictionary:
	return {
		"population_count": population_count,
	}

func load_save_data(data: Dictionary) -> void:
	set_population_count(data["population_count"])
