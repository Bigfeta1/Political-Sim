extends Node

var id
var is_player := false
var country_name
var country_initiative

var population_count_node
var life_expectancy_node
var workers_node

# Population, life expectancy and workers live on the children of Parameters/Population; these read and write through to them.
var country_population:
	get:
		return population_count_node.population
	set(value):
		population_count_node.population = value

# Life expectancy is calculated from the mortality data, so it can only be read.
var country_life_expectancy:
	get:
		return life_expectancy_node.life_expectancy

var country_target_life_expectancy:
	get:
		return life_expectancy_node.target_life_expectancy
	set(value):
		life_expectancy_node.target_life_expectancy = value

var country_mortality:
	get:
		return life_expectancy_node.mortality
	set(value):
		life_expectancy_node.mortality = value

var country_risk_prevalence:
	get:
		return life_expectancy_node.risk_prevalence
	set(value):
		life_expectancy_node.risk_prevalence = value

var country_workers:
	get:
		return workers_node.workers
	set(value):
		workers_node.workers = value

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
	population_count_node = parameters.get_node("Population/Count")
	life_expectancy_node = parameters.get_node("Population/LifeExpectancy")
	workers_node = parameters.get_node("Population/Workers")
	economy_node = parameters.get_node("Economy")
	public_image_node = parameters.get_node("PublicImage")
