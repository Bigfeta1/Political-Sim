extends Node

signal country_created(new_country: Node)

var country_list

const CountryFiles = preload("res://Scripts/Data/country_files.gd")
const MortalityFiles = preload("res://Scripts/Data/mortality_files.gd")

const COUNTRY_NODE = "res://Scenes/country.tscn"

func initialize(emp_list):
	country_list = emp_list

func create_country(country_name):
	var new_country = SceneLoader.instantiate(COUNTRY_NODE)
	country_list.add_child(new_country)
	configure_country(new_country, country_name)
	country_created.emit(new_country)
	return new_country

#region Country Configuration
func configure_country(country, country_name):
	var country_data = CountryFiles.find_by_id(country_name)
	var country_node_data = country.data

	country_node_data.id = country_data["id"]
	country_node_data.country_name = country_data["country_name"]
	country_node_data.country_initiative = country_data["initiative"]
	country_node_data.country_money = country_data["money"]
	country_node_data.country_public_image = country_data["public_image"]
	# The target must be set before the mortality data, which calibrates against it.
	country_node_data.country_target_life_expectancy = country_data["life_expectancy"]
	country_node_data.country_mortality = MortalityFiles.find_by_id(country_data["id"])
	country_node_data.country_risk_prevalence = country_data["risk_prevalence"]
	country_node_data.country_population = country_data["population"]
	country_node_data.country_workers = country_data["workers"]
#endregion
