extends Node

# The band's key in the mortality file, e.g. "30-49" or "70+". Start age and width are read from it.
@export var key: String

var start_age: int
# Years the band covers; 0 for the open-ended last band.
var width: int

var population

# Deaths in this band per WHO cause name, at game start.
var deaths: Dictionary

func _ready() -> void:
	if key.ends_with("+"):
		start_age = key.trim_suffix("+").to_int()
		width = 0
	else:
		var ages = key.split("-")
		start_age = ages[0].to_int()
		width = ages[1].to_int() - start_age + 1
