extends Node

@onready var country_logic = $Logic
@onready var country_list = $CountryList

func initialize():
	country_logic.initialize(country_list)
