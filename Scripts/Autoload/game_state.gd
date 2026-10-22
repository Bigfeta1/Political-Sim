extends Node

enum State {
	MAIN_MENU,
	CONFIGURE_ROUND,
	PLAYING_ROUND
}

var current_state: State = State.MAIN_MENU

signal state_change_requested(new_state: State)
signal state_changed(new_state: State)

func _ready():
	state_change_requested.connect(change_state)

func change_state(new_state: State):
	if current_state == new_state:
		return
	
	current_state = new_state
	state_changed.emit(new_state)
