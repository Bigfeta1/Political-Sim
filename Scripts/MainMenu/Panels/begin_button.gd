extends Button

signal begin_pressed

var country_selector

func initialize(selector):
	country_selector = selector

# Called when the node enters the scene tree for the first time.
func _pressed() -> void:
	if not country_selector.has_selection:
		return

	GameState.state_change_requested.emit(GameState.State.CONFIGURE_ROUND)
