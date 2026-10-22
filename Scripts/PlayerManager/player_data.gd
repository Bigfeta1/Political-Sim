extends Node

var id
var is_player := false
var country_name
var country_initiative

var population_node

# Population and life expectancy live on Parameters/Population; these read and write through to it.
var country_population:
	get:
		return population_node.population
	set(value):
		population_node.population = value

var country_life_expectancy:
	get:
		return population_node.life_expectancy
	set(value):
		population_node.life_expectancy = value

var economy_node

# Money lives on Parameters/Economy; this reads and writes through to it.
var country_money:
	get:
		return economy_node.money
	set(value):
		economy_node.money = value

var public_image_node

# Public image lives on Parameters/PublicImage; this reads and writes through to it.
var country_public_image:
	get:
		return public_image_node.public_image
	set(value):
		public_image_node.public_image = value


func initialize(parameters):
	population_node = parameters.get_node("Population")
	economy_node = parameters.get_node("Economy")
	public_image_node = parameters.get_node("PublicImage")
