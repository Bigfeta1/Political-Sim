extends Node

const MainMenuState = preload("res://Scripts/Logic/MainMenu/main_menu_state.gd")

var logic
var main_menu_logic_instance: Node = null
var main_menu_logic = preload("res://Scenes/MainMenu/Core/main_menu_logic.tscn")

var ui
var main_menu_ui_instance: Node = null
var main_menu_ui = preload("res://Scenes/MainMenu/Core/main_menu_ui.tscn")

var round_config_panel_instance = null
var round_config_panel = preload("res://Scenes/MainMenu/Panels/round_config_panel.tscn")

var round_config_node_instance = null
var round_config_node = preload("res://Scenes/round_config.tscn")

#PlayingRound
var playing_round_logic_instance = null
var playing_round_logic = preload("res://Scenes/PlayingRound/playing_round_logic.tscn")

var playing_round_ui_instance = null
var playing_round_ui = preload("res://Scenes/PlayingRound/playing_round_ui.tscn")

var state_manager
var turn_manager
var phase_manager

#region INITIALZE

func _ready() -> void:
	GameState.state_changed.connect(_on_state_changed)

func initialize(logic_reference, ui_reference):
	logic = logic_reference
	ui = ui_reference

	_on_state_changed(GameState.current_state)

#endregion

func _on_state_changed(new_state):
	match new_state:
		GameState.State.MAIN_MENU:
			create_main_menu()
			destroy_playing_round()

		GameState.State.CONFIGURE_ROUND:
			destroy_main_menu()

		GameState.State.PLAYING_ROUND:
			create_playing_round()

#region MAIN MENU
func create_main_menu():
	if main_menu_ui_instance or main_menu_logic_instance != null:
		return

	main_menu_logic_instance = main_menu_logic.instantiate()
	logic.add_child(main_menu_logic_instance)

	main_menu_ui_instance = main_menu_ui.instantiate()
	ui.add_child(main_menu_ui_instance)

	main_menu_ui_instance.initialize(main_menu_logic_instance)
	main_menu_logic_instance.menu_state.state_changed.connect(_on_menu_state_changed)

func destroy_main_menu():
	if main_menu_ui_instance == null and main_menu_logic_instance == null:
		return

	main_menu_ui_instance.queue_free()
	main_menu_ui_instance = null

	main_menu_logic_instance.queue_free()
	main_menu_logic_instance = null

	round_config_panel_instance = null

func _on_menu_state_changed(new_state):
	match new_state:
		MainMenuState.State.INTRO_SCREEN:
			destroy_round_config_panel()
		MainMenuState.State.SETTINGS:
			destroy_round_config_panel()
		MainMenuState.State.GAME_SETUP:
			create_round_config_node()
			create_round_config_panel()

func create_round_config_panel():
	if round_config_panel_instance != null:
		return

	round_config_panel_instance = round_config_panel.instantiate()
	main_menu_ui_instance.panels.add_child(round_config_panel_instance)
	round_config_panel_instance.initialize(round_config_node_instance)

func create_round_config_node():
	if round_config_node_instance != null:
		return

	round_config_node_instance = round_config_node.instantiate()
	logic.add_child(round_config_node_instance)

func destroy_round_config_panel():
	if round_config_panel_instance == null:
		return

	round_config_panel_instance.queue_free()
	round_config_panel_instance = null

#endregion

#region PLAYING ROUND

func create_playing_round():
	if playing_round_logic_instance or playing_round_ui_instance != null:
		return

	playing_round_logic_instance = playing_round_logic.instantiate()
	logic.add_child(playing_round_logic_instance)
	playing_round_logic_instance.initialize()

	state_manager = playing_round_logic_instance.state_manager
	turn_manager = state_manager.turn_manager
	phase_manager = state_manager.phase_manager

	playing_round_ui_instance = playing_round_ui.instantiate()
	ui.add_child(playing_round_ui_instance)

	playing_round_ui_instance.initialize(state_manager, phase_manager, turn_manager)


func destroy_playing_round():
	if playing_round_ui_instance == null and playing_round_logic_instance == null:
		return

	playing_round_ui_instance.queue_free()
	playing_round_ui_instance = null

	playing_round_logic_instance.queue_free()
	playing_round_logic_instance = null

	state_manager = null
	turn_manager = null
	phase_manager = null
#endregion
