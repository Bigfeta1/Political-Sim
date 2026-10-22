extends Node

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ALT:
		# Handled first: the state change frees this node, so the viewport is gone afterwards.
		get_viewport().set_input_as_handled()
		GameState.state_change_requested.emit(GameState.State.MAIN_MENU)
