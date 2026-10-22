extends Node

var main_menu_state
var main_menu_ui
var ui_panels_node

var main_scene_logic

var round_config_panel_instance = null
var round_config_panel = preload("res://Scenes/MainMenu/Panels/round_config_panel.tscn")

var round_config_node_instance = null
var round_config_node = preload("res://Scenes/round_config.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(menu_state, ui, logic):
	main_menu_state = menu_state
	main_menu_ui = ui
	main_scene_logic = logic

	main_menu_state.state_changed.connect(_on_state_changed)

func _on_state_changed(new_state):

	match new_state:
		main_menu_state.State.INTRO_SCREEN:
			destroy_round_config_panel()
		main_menu_state.State.SETTINGS:
			destroy_round_config_panel()
		main_menu_state.State.GAME_SETUP:
			create_round_config_node()
			create_round_config_panel(ui_panels_node)


func create_round_config_panel(ui_panels_node):
	if round_config_panel_instance != null:
		return

	if main_menu_ui != null:
		ui_panels_node = main_menu_ui.panels

	round_config_panel_instance = round_config_panel.instantiate()
	ui_panels_node.add_child(round_config_panel_instance)
	round_config_panel_instance.initialize(round_config_node_instance)

func create_round_config_node():
	if round_config_node_instance != null:
		return
	
	round_config_node_instance = round_config_node.instantiate()
	main_scene_logic.add_child(round_config_node_instance)


func destroy_round_config_panel():
	if round_config_panel_instance == null:
		return

	round_config_panel_instance.queue_free()
	round_config_panel_instance = null
