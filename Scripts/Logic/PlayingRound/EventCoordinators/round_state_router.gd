extends Node

var state_manager
var menu_state_manager
var ui
var country_manager
var tile_selection

var demographics_panel_instance = null
const DEMOGRAPHICS_PANEL = "res://Scenes/PlayingRound/Panels/demographics_panel.tscn"

var tile_tooltip_instance = null
const TILE_TOOLTIP = "res://Scenes/MainMenu/Panels/tooltips/tile_tooltip.tscn"
const TILE_TOOLTIP_OFFSET = Vector2(16, 16)

func initialize(state_mngr, playing_round_ui, country_mngr, tile_selection_reference):
	state_manager = state_mngr
	menu_state_manager = state_manager.menu_state_manager
	ui = playing_round_ui
	country_manager = country_mngr
	tile_selection = tile_selection_reference

	menu_state_manager.menu_state_changed.connect(_on_menu_state_changed)
	tile_selection.long_hovered_changed.connect(_on_long_hovered_changed)

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
	demographics_panel_instance.initialize(country_manager.get_player_country(), menu_state_manager)

func destroy_demographics_panel():
	if demographics_panel_instance == null:
		return

	demographics_panel_instance.queue_free()
	demographics_panel_instance = null
#endregion

#region TILE TOOLTIP
func _on_long_hovered_changed(long_hovered):
	if long_hovered:
		create_tile_tooltip()
	else:
		destroy_tile_tooltip()

func create_tile_tooltip():
	if tile_tooltip_instance != null:
		return

	tile_tooltip_instance = SceneLoader.instantiate(TILE_TOOLTIP)
	ui.panels.add_child(tile_tooltip_instance)
	place_tile_tooltip()

func place_tile_tooltip():
	var viewport_size = get_viewport().get_visible_rect().size
	var tooltip_position = get_viewport().get_mouse_position() + TILE_TOOLTIP_OFFSET
	tile_tooltip_instance.global_position = tooltip_position.clamp(Vector2.ZERO, viewport_size - tile_tooltip_instance.size)

func destroy_tile_tooltip():
	if tile_tooltip_instance == null:
		return

	tile_tooltip_instance.queue_free()
	tile_tooltip_instance = null
#endregion
