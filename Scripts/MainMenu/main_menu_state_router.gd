extends Node

var main_menu_state
var main_menu_ui
var main_scene_logic

var round_config_panel_instance = null
var round_config_panel = preload("res://Scenes/MainMenu/Panels/RoundConfig/round_config_panel.tscn")

var round_config_node = preload("res://Scenes/ConfigureRound/round_config.tscn")

var load_panel_instance = null
var load_panel = preload("res://Scenes/MainMenu/Panels/LoadPanel/load_game_panel.tscn")

func initialize(menu_state, ui, logic):
	main_menu_state = menu_state
	main_menu_ui = ui
	main_scene_logic = logic

	main_menu_state.state_changed.connect(_on_state_changed)

func _on_state_changed(new_state):
	match new_state:
		main_menu_state.State.INTRO_SCREEN:
			destroy_round_config_panel()
			destroy_load_panel()
		main_menu_state.State.SETTINGS:
			destroy_round_config_panel()
			destroy_load_panel()
		main_menu_state.State.GAME_SETUP:
			destroy_load_panel()
			create_round_config_node()
			create_round_config_panel()
		main_menu_state.State.LOAD_GAME:
			destroy_round_config_panel()
			create_load_panel()

#region ROUND CONFIG
func create_round_config_panel():
	if round_config_panel_instance != null:
		return

	round_config_panel_instance = round_config_panel.instantiate()
	main_menu_ui.panels.add_child(round_config_panel_instance)
	round_config_panel_instance.initialize(main_scene_logic.get_system("round_config"))

func create_round_config_node():
	if main_scene_logic.get_system("round_config") != null:
		return

	var config = round_config_node.instantiate()
	main_scene_logic.add_child(config)
	main_scene_logic.register("round_config", config)

func destroy_round_config_panel():
	if round_config_panel_instance == null:
		return

	round_config_panel_instance.queue_free()
	round_config_panel_instance = null
#endregion

#region LOAD
func create_load_panel():
	if load_panel_instance != null:
		return

	load_panel_instance = load_panel.instantiate()
	main_menu_ui.panels.add_child(load_panel_instance)

func destroy_load_panel():
	if load_panel_instance == null:
		return

	load_panel_instance.queue_free()
	load_panel_instance = null
#endregion
