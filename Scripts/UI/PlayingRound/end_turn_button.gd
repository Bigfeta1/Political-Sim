extends Button

var state_manager

func initialize(state_mngr):
	state_manager = state_mngr

func _pressed() -> void:
	state_manager.turn_manager.next_turn()
