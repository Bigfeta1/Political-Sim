extends Node

var id
var is_player := false
var country_name
var country_initiative
var country_population
var country_money
var country_public_image


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_save_data() -> Dictionary:
	return {
		"id": id,
		"is_player": is_player,
	}
