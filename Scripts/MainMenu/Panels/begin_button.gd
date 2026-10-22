extends Button

signal begin_pressed

# Called when the node enters the scene tree for the first time.
func _pressed() -> void:
	GameState.state_change_requested.emit(GameState.State.CONFIGURE_ROUND)
