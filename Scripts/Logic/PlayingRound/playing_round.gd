extends Node

@onready var event_coordinators = $EventCoordinators

func initialize(country_manager):
	event_coordinators.initialize(country_manager)
