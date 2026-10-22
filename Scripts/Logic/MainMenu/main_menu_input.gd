extends Node

@onready var menu_state = $"../MainMenuState"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		menu_state.go_back()
		get_viewport().set_input_as_handled()
