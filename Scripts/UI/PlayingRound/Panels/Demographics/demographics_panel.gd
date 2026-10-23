extends Node

@onready var summary = $Panel/CountryScroll/CountryList/Summary
@onready var population_table = $Panel/CountryScroll/CountryList/PopulationTable
@onready var life_table = $Panel/CountryScroll/CountryList/LifeTable

func initialize(player_country):
	summary.initialize(player_country)
	population_table.initialize(player_country)
	life_table.initialize(player_country)
