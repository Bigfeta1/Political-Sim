extends Node

@onready var data = $Data
@onready var population = $Parameters/Population
@onready var economy = $Parameters/Economy
@onready var public_image = $Parameters/PublicImage
@onready var parameters = $Parameters
@onready var settlements = $Settlements

func _ready() -> void:
	population.initialize(settlements)
	data.initialize(population, economy, public_image)

# Every parameter node with save functions is included; nodes without a script are skipped.
func get_save_data() -> Dictionary:
	var save_data := {
		"id": data.id,
		"is_player": data.is_player,
	}
	for parameter in parameters.get_children():
		if parameter.has_method("get_save_data"):
			save_data.merge(parameter.get_save_data())
	save_data.merge(settlements.get_save_data())
	return save_data

func load_save_data(save_data: Dictionary) -> void:
	for parameter in parameters.get_children():
		if parameter.has_method("load_save_data"):
			parameter.load_save_data(save_data)
	settlements.load_save_data(save_data)
