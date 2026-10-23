extends Node

@onready var data = $Data
@onready var population = $Population
@onready var workers = $Workers

func _ready() -> void:
	data.initialize(population, workers)

func get_save_data() -> Dictionary:
	var save_data: Dictionary = population.get_save_data()
	save_data.merge(workers.get_save_data())
	return save_data

func load_save_data(save_data: Dictionary) -> void:
	population.load_save_data(save_data)
	workers.load_save_data(save_data)
