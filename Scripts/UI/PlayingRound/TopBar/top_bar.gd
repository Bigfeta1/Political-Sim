extends Control

@onready var money_label = $HBoxContainer/MoneyLabel
@onready var public_image_label = $HBoxContainer/PublicImageLabel
@onready var life_expectancy_label = $HBoxContainer/LifeExpectancyLabel
@onready var population_label = $HBoxContainer/PopulationLabel

func initialize(player_country):
	money_label.initialize(player_country)
	public_image_label.initialize(player_country)
	life_expectancy_label.initialize(player_country)
	population_label.initialize(player_country)
