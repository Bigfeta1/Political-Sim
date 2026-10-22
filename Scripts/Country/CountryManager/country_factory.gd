extends Node

signal country_created(new_country: Node)

var country_list

const GameConfig = preload("res://Scripts/Logic/game_config.gd")

var countries: Dictionary = {}

var country_node: PackedScene = preload("res://Scenes/country.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countries = GameConfig.find_country_files()

func initialize(emp_list):
	country_list = emp_list

func create_country(country_name):
	var new_country = country_node.instantiate()
	country_list.add_child(new_country)
	configure_country(new_country, country_name)
	country_created.emit(new_country)

#region Country Configuration
func configure_country(country, country_name):
	var country_data = access_country_data(country_name)
	var country_node_data = country.data

	country_node_data.country_name = country_data["country_name"]

func access_country_data(country_name):
	var file_path = countries[country_name]
	var file = FileAccess.open(file_path, FileAccess.READ)
	var country_data = JSON.parse_string(file.get_as_text())
	file.close()

	return country_data

#endregion
