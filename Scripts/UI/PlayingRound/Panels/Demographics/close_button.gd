extends Button

var menu_state_manager

func initialize(menu_state_mngr):
	menu_state_manager = menu_state_mngr

func _pressed() -> void:
	menu_state_manager.change_state(menu_state_manager.MenuState.STANDBY)
