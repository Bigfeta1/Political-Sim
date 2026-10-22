extends Button

var country_selector

func initialize(selector):
	country_selector = selector

func _pressed() -> void:
	if not country_selector.has_selection:
		return

	GameState.state_change_requested.emit(GameState.State.CONFIGURE_ROUND)
