extends Node

@onready var event_coordinators = $EventCoordinators

func initialize(country_manager, state_mngr, playing_round_ui):
	event_coordinators.initialize(country_manager, state_mngr, playing_round_ui)
	
