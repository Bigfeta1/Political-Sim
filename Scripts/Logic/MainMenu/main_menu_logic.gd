extends Node

@onready var menu_state = $MainMenuState
@onready var main_menu_router = $MainMenuRouter

func initialize(ui, logic):
	main_menu_router.initialize(menu_state, ui, logic)
