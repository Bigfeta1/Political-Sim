extends Node

@onready var game_initializer = $GameInitializer

func initialize(country_manager):
	game_initializer.initialize(country_manager)
