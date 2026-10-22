extends Control

@onready var buttons = $Buttons
@onready var panels = $Panels

func initialize(main_menu_logic):
	buttons.initialize(main_menu_logic)
