extends Button

@export var menu_state: MenuStateManager.MenuState

var state_manager
var menu_state_manager

func initialize(state_mngr):
	state_manager = state_mngr
	menu_state_manager = state_manager.menu_state_manager

func _pressed() -> void:
	if menu_state_manager.current_menu_state == menu_state:
		menu_state_manager.change_state(menu_state_manager.MenuState.STANDBY)
		return

	menu_state_manager.change_state(menu_state)
