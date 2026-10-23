extends Node

var state_manager
var menu_state_manager
var ui

var demographics_panel_instance = null
const DEMOGRAPHICS_PANEL = "res://Scenes/PlayingRound/Panels/demographics_panel.tscn"

func initialize(state_mngr, playing_round_ui):
	state_manager = state_mngr
	menu_state_manager = state_manager.menu_state_manager
	ui = playing_round_ui

	menu_state_manager.menu_state_changed.connect(_on_menu_state_changed)

func _on_menu_state_changed(new_state):
	match new_state:
		menu_state_manager.MenuState.STANDBY:
			destroy_demographics_panel()
		menu_state_manager.MenuState.DEMOGRAPHICS:
			create_demographics_panel()

#region DEMOGRAPHICS
func create_demographics_panel():
	if demographics_panel_instance != null:
		return

	demographics_panel_instance = SceneLoader.instantiate(DEMOGRAPHICS_PANEL)
	ui.panels.add_child(demographics_panel_instance)

func destroy_demographics_panel():
	if demographics_panel_instance == null:
		return

	demographics_panel_instance.queue_free()
	demographics_panel_instance = null
#endregion
