extends Button

var main_menu_state_manager

func initialize(main_menu_logic):
	main_menu_state_manager = main_menu_logic.menu_state

func _pressed() -> void:
	main_menu_state_manager.change_state(main_menu_state_manager.State.LOAD_GAME)
