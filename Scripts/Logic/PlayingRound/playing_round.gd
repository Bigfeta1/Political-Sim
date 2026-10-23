extends Node

@onready var event_coordinators = $EventCoordinators
@onready var input_handler = $Logic/InputHandler

func initialize(country_manager, state_mngr, playing_round_ui, three_d):
	event_coordinators.initialize(country_manager, state_mngr, playing_round_ui)
	three_d.camera.initialize(three_d.get_tile_bounds())
	input_handler.initialize(three_d.camera)
	
