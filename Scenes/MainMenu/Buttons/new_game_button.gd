extends Button

var main_menu_state_manager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(main_menu_logic):
	main_menu_state_manager = main_menu_logic.menu_state

func _pressed() -> void:
	main_menu_state_manager.change_state(main_menu_state_manager.State.GAME_SETUP)
