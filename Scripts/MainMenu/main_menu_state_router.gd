extends Node

var main_menu_state
var main_menu_ui
var ui_panels_node

var game_config_instance = null
var game_config_panel = preload("res://Scenes/MainMenu/Panels/game_config_panel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(menu_state, ui):
	main_menu_state = menu_state
	main_menu_ui = ui

	main_menu_state.state_changed.connect(_on_state_changed)

func _on_state_changed(new_state):

	match new_state:
		main_menu_state.State.INTRO_SCREEN:
			destroy_game_config_panel()
		main_menu_state.State.SETTINGS:
			destroy_game_config_panel()
		main_menu_state.State.GAME_SETUP:
			create_game_config_panel(ui_panels_node)


func create_game_config_panel(ui_panels_node):
	if game_config_instance != null:
		return

	if main_menu_ui != null:
		ui_panels_node = main_menu_ui.panels

	game_config_instance = game_config_panel.instantiate()
	ui_panels_node.add_child(game_config_instance)


func destroy_game_config_panel():
	if game_config_instance == null:
		return

	game_config_instance.queue_free()
	game_config_instance = null
