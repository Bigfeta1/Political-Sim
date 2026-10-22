extends Node

@onready var country_factory = $CountryFactory

func initialize(country_list):
	country_factory.initialize(country_list)
