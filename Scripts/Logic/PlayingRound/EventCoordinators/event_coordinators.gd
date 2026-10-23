extends Node

@onready var game_initializer = $GameInitializer
@onready var state_router = $StateRouter

func initialize(country_manager, state_mngr, playing_round_ui):
	game_initializer.initialize(country_manager)
	state_router.initialize(state_mngr, playing_round_ui, country_manager)
