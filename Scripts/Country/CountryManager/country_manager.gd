extends Node

@onready var country_logic = $Logic
@onready var country_list = $CountryList

func initialize():
	country_logic.initialize(country_list)

func get_player_country():
	for country in country_list.get_children():
		if country.data.is_player:
			return country
	return null
