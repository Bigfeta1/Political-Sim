extends Node

signal band_populations_changed(new_band_populations)

var band_populations: Dictionary

func set_band_populations(value):
	band_populations = value
	band_populations_changed.emit(value)

func get_save_data() -> Dictionary:
	return {
		"population": band_populations,
	}

func load_save_data(data: Dictionary) -> void:
	set_band_populations(data["population"])
