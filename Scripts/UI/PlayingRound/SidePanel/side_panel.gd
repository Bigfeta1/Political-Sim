extends Control

@onready var button_container = $VBoxContainer

func initialize(state_manager):
	for button in button_container.get_children():
		button.initialize(state_manager)
