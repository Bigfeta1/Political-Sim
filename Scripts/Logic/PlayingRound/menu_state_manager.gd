extends Node
class_name MenuStateManager

enum MenuState {
	STANDBY,
	DEMOGRAPHICS,
	
}

var current_menu_state: MenuState = MenuState.STANDBY

signal menu_state_changed(new_state: MenuState)

func change_state(new_state: MenuState):
	if current_menu_state == new_state:
		return

	current_menu_state = new_state
	menu_state_changed.emit(new_state)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
