extends Node

@onready var event_coordinators = $EventCoordinators
@onready var input_handler = $Logic/InputHandler
@onready var tile_selection = $Logic/TileSelection

func initialize(country_manager, state_mngr, playing_round_ui, three_d, tile_directory):
	event_coordinators.initialize(country_manager, state_mngr, playing_round_ui, tile_selection)
	three_d.camera.initialize(three_d.get_tile_bounds())
	tile_selection.initialize(tile_directory)
	input_handler.initialize(three_d.camera, three_d.hex_tile_grid, tile_directory, tile_selection)
	
