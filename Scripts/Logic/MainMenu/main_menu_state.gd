extends Node

enum State {
	INTRO_SCREEN,
	SETTINGS,
	GAME_SETUP
}

var current_state: State = State.INTRO_SCREEN
var previous_state = null

signal state_change_requested(new_state: State)
signal state_changed(new_state: State)

func _ready():
	state_change_requested.connect(change_state)

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
