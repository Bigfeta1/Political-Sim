extends Node

enum State {
	INTRO_SCREEN,
	SETTINGS,
	GAME_SETUP,
	LOAD_GAME
}

var current_state: State = State.INTRO_SCREEN
var previous_state = null

signal state_changed(new_state: State)

func change_state(new_state: State):
	if current_state == new_state:
		return

	previous_state = current_state
	current_state = new_state
	state_changed.emit(new_state)

func go_back():
	if previous_state == null:
		return

	current_state = previous_state
	state_changed.emit(current_state)
