extends Node

@onready var count = $Count
@onready var age_bands = $AgeBands
@onready var risk_factors = $RiskFactors
@onready var mortality = $Mortality
@onready var life_expectancy = $LifeExpectancy

func _ready() -> void:
	mortality.initialize(age_bands, risk_factors)
	life_expectancy.initialize(age_bands, mortality)

func initialize(settlements):
	count.initialize(age_bands, settlements)

func get_save_data() -> Dictionary:
	var save_data := {}
	for child in get_children():
		if child.has_method("get_save_data"):
			save_data.merge(child.get_save_data())
	return save_data

func load_save_data(data: Dictionary) -> void:
	for child in get_children():
		if child.has_method("load_save_data"):
			child.load_save_data(data)
