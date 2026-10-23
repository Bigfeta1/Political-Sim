extends Node

var id
var is_player = false
var country_name
var country_initiative

var population_count_node
var mortality_node
var life_expectancy_node
var workers_node

# Population, mortality, life expectancy and workers live on the children of Parameters/Population; these read and write through to them.
var country_population_count:
	get:
		return population_count_node.population_count

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
		return mortality_node.mortality
	set(value):
		mortality_node.set_mortality(value)

var country_risk_prevalence:
	get:
		return mortality_node.risk_prevalence
	set(value):
		mortality_node.set_risk_prevalence(value)

var country_workers:
	get:
		return workers_node.workers
	set(value):
		workers_node.set_workers(value)

var economy_node

# Money lives on Parameters/Economy; this reads and writes through to it.
var country_money:
	get:
		return economy_node.money
	set(value):
		economy_node.set_money(value)

var public_image_node

# Public image lives on Parameters/PublicImage; this reads and writes through to it.
var country_public_image:
	get:
		return public_image_node.public_image
	set(value):
		public_image_node.set_public_image(value)

func initialize(population, economy, public_image):
	population_count_node = population.count
	mortality_node = population.mortality
	life_expectancy_node = population.life_expectancy
	workers_node = population.workers
	economy_node = economy
	public_image_node = public_image
