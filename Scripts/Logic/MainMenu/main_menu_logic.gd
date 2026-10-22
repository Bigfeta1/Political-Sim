extends Node

@onready var menu_state = $MainMenuState
@onready var main_menu_state_router = $StateRouter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(ui):
	main_menu_state_router.initialize(menu_state, ui)
