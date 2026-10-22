extends Node

var id
var is_player := false
var country_name
var country_initiative
var country_population
var country_money
var country_public_image

func get_save_data() -> Dictionary:
	return {
		"id": id,
		"is_player": is_player,
	}
