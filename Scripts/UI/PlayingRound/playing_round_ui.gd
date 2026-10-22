extends Control

@onready var end_turn_button = $Buttons/EndTurnButton
@onready var turn_label = $TurnLabel
@onready var phase_label = $PhaseLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(state_manager, phase_manager, turn_manager):
	end_turn_button.initialize(state_manager)
	phase_label.initialize(phase_manager)
	turn_label.initialize(turn_manager)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
