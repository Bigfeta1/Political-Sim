extends Node

const CountryFiles = preload("res://Scripts/Data/country_files.gd")

var country_files := []
var player_country_id := ""
var player_count := 3
var save_data := {}

func _ready() -> void:
	country_files = CountryFiles.find_paths()
	country_files.sort()

func select_country(country_id: String) -> void:
	player_country_id = country_id
