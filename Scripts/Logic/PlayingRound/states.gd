extends Node

@onready var turn_manager = $TurnManager
@onready var phase_manager = $PhaseManager

signal round_changed(new_round: int)

var current_round: int = 0

func set_round(new_round: int) -> void:
	current_round = new_round
	round_changed.emit(current_round)

func _on_phase_manager_cycle_completed() -> void:
	set_round(current_round + 1)

func get_save_data() -> Dictionary:
	return {"current_round": current_round}

func load_save_data(data: Dictionary) -> void:
	current_round = int(data["current_round"])
