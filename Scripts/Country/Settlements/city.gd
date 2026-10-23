extends Node

@onready var population = $Population

func get_save_data() -> Dictionary:
	return population.get_save_data()

func load_save_data(data: Dictionary) -> void:
	population.load_save_data(data)
