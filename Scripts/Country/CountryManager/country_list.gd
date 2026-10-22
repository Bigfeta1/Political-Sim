extends Node

var countries: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_countries():
	countries.clear()
	
	for country in get_children():
		#Logs entire node ion dictionary under the country name
		#Country name is found in countries data node
		#Allows entire country node to be looke dup by its name
		countries[country.data.country_name] = country
		
	return countries
