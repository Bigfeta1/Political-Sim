extends Node

var logic
var main_menu_logic = preload("res://Scenes/MainMenu/Core/main_menu_logic.tscn")

var ui
var main_menu_ui_instance: Node = null
var main_menu_ui = preload("res://Scenes/MainMenu/Core/main_menu_ui.tscn")

#RoundConfigurator
var round_configurator = preload("res://Scenes/ConfigureRound/round_configurator_logic.tscn")

var round_configurator_ui_instance = null
var round_configurator_ui = preload("res://Scenes/ConfigureRound/round_configurator_ui.tscn")

#PlayingRound
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
			logic.clear()
			create_main_menu()
			destroy_playing_round()

		GameState.State.CONFIGURE_ROUND:
			destroy_main_menu()
			create_round_configurator()

		GameState.State.PLAYING_ROUND:
			destroy_round_configurator()
			create_playing_round()

#region MAIN MENU
func create_main_menu():
	if logic.get_system("main_menu") != null:
		return

	var menu = main_menu_logic.instantiate()
	logic.add_child(menu)
	logic.register("main_menu", menu)

	main_menu_ui_instance = main_menu_ui.instantiate()
	ui.add_child(main_menu_ui_instance)

	menu.initialize(main_menu_ui_instance, logic)
	main_menu_ui_instance.initialize(menu)

func destroy_main_menu():
	if main_menu_ui_instance == null:
		return

	main_menu_ui_instance.queue_free()
	main_menu_ui_instance = null

	logic.release("main_menu")

#endregion

#region ROUND CONFIGURATOR

func create_round_configurator():
	if logic.get_system("round_configurator") != null:
		return

	var configurator = round_configurator.instantiate()
	logic.add_child(configurator)
	logic.register("round_configurator", configurator)

	round_configurator_ui_instance = round_configurator_ui.instantiate()
	ui.add_child(round_configurator_ui_instance)
	round_configurator_ui_instance.initialize(configurator)

func destroy_round_configurator():
	logic.release("round_configurator")

	if round_configurator_ui_instance == null:
		return

	round_configurator_ui_instance.queue_free()
	round_configurator_ui_instance = null

#endregion

#region PLAYING ROUND

func create_playing_round():
	if logic.get_system("playing_round") != null or playing_round_ui_instance != null:
		return

	var playing_round = playing_round_logic.instantiate()
	logic.add_child(playing_round)
	logic.register("playing_round", playing_round)
	playing_round.initialize(logic.get_system("country_manager"))

	state_manager = logic.get_system("state_manager")
	turn_manager = state_manager.turn_manager
	phase_manager = state_manager.phase_manager

	playing_round_ui_instance = playing_round_ui.instantiate()
	ui.add_child(playing_round_ui_instance)

	playing_round_ui_instance.initialize(state_manager, phase_manager, turn_manager)


func destroy_playing_round():
	if playing_round_ui_instance == null:
		return

	playing_round_ui_instance.queue_free()
	playing_round_ui_instance = null

	state_manager = null
	turn_manager = null
	phase_manager = null
#endregion
