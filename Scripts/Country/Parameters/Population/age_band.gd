extends Node

@export var key: String

var start_age: int
var width: int

var population

var death_rates: Dictionary

func _ready() -> void:
	if key.ends_with("+"):
		start_age = key.trim_suffix("+").to_int()
		width = 0
	else:
		var ages = key.split("-")
		start_age = ages[0].to_int()
		width = ages[1].to_int() - start_age + 1
