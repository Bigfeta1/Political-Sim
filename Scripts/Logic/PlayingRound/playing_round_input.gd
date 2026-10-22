extends Node

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if event.keycode == KEY_F5:
		SaveWriter.save()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ALT:
		# Handled first: the state change frees this node, so the viewport is gone afterwards.
		get_viewport().set_input_as_handled()
		GameState.state_change_requested.emit(GameState.State.MAIN_MENU)
