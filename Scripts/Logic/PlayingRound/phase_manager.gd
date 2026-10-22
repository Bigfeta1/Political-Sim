extends Node

enum RoundPhase {
	ECONOMIC_PHASE,
	PROXY_WAR_PHASE,
	UPKEEP_PHASE,
	STANDBY
}

var current_phase: RoundPhase = RoundPhase.STANDBY

signal phase_changed(new_phase: RoundPhase)
signal cycle_completed

func next_phase():
	var cycle = RoundPhase.values().filter(func(phase): return phase != RoundPhase.STANDBY)
	var next_index = cycle.find(current_phase) + 1

	if next_index >= cycle.size():
		next_index = 0
		if current_phase != RoundPhase.STANDBY:
			cycle_completed.emit()

	advance_phase(cycle[next_index])

func advance_phase(new_phase: RoundPhase):
	if current_phase == new_phase:
		return
	
	current_phase = new_phase
	phase_changed.emit(current_phase)

func get_save_data() -> Dictionary:
	return {"current_phase": current_phase}

# Set directly: phase_changed would call start_turns and reset the turn index.
func load_save_data(data: Dictionary) -> void:
	current_phase = int(data["current_phase"])
