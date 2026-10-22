extends Control

@onready var end_turn_button = $Buttons/EndTurnButton
@onready var turn_label = $TurnLabel
@onready var phase_label = $PhaseLabel

func initialize(state_manager, phase_manager, turn_manager):
	end_turn_button.initialize(state_manager)
	phase_label.initialize(phase_manager)
	turn_label.initialize(turn_manager)
