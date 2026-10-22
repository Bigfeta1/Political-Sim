extends Node

signal money_changed(new_money)
signal public_image_changed(new_public_image)
signal life_expectancy_changed(new_life_expectancy)

var id
var is_player := false
var country_name
var country_initiative
var country_population

var country_money:
	set(value):
		country_money = value
		money_changed.emit(value)

var country_public_image:
	set(value):
		country_public_image = value
		public_image_changed.emit(value)

var country_life_expectancy:
	set(value):
		country_life_expectancy = value
		life_expectancy_changed.emit(value)

func get_save_data() -> Dictionary:
	return {
		"id": id,
		"is_player": is_player,
		"money": country_money,
		"public_image": country_public_image,
		"life_expectancy": country_life_expectancy,
	}

func load_save_data(data: Dictionary) -> void:
	country_money = data["money"]
	country_public_image = data["public_image"]
	country_life_expectancy = data["life_expectancy"]
