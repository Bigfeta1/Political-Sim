extends Node


@onready var country_logic = $Logic
@onready var country_list = $CountryList


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize():
	country_logic.initialize(country_list)
