extends Node

@onready var data = $Data
@onready var population = $Parameters/Population
@onready var economy = $Parameters/Economy
@onready var public_image = $Parameters/PublicImage

func _ready() -> void:
	data.initialize(population, economy, public_image)

func get_save_data() -> Dictionary:
	var save_data := {
		"id": data.id,
		"is_player": data.is_player,
	}
	save_data.merge(population.get_save_data())
	save_data.merge(economy.get_save_data())
	save_data.merge(public_image.get_save_data())
	return save_data

func load_save_data(save_data: Dictionary) -> void:
	population.load_save_data(save_data)
	economy.load_save_data(save_data)
	public_image.load_save_data(save_data)
