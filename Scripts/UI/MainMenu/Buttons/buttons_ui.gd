extends Control

@onready var new_game_button = $NewGameButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(main_menu_logic):
	new_game_button.initialize(main_menu_logic)
