extends Control

@onready var end_turn_button = $Buttons/EndTurnButton
@onready var turn_label = $TurnLabel
@onready var phase_label = $PhaseLabel
@onready var top_bar = $TopBar
@onready var side_panel = $SidePanel
@onready var panels = $Panels

func initialize(state_manager, phase_manager, turn_manager, player_country):
	end_turn_button.initialize(state_manager)
	phase_label.initialize(phase_manager)
	turn_label.initialize(turn_manager)
	top_bar.initialize(player_country)
	side_panel.initialize(state_manager)
