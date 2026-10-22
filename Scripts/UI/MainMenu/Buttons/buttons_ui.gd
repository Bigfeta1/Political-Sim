extends Control

@onready var new_game_button = $NewGameButton
@onready var load_game_button = $LoadGameButton

func initialize(main_menu_logic):
	new_game_button.initialize(main_menu_logic)
	load_game_button.initialize(main_menu_logic)
