extends Node

var city_name

var population_node
var workers_node

var city_band_populations:
	get:
		return population_node.band_populations
	set(value):
		population_node.set_band_populations(value)

var city_workers:
	get:
		return workers_node.workers
	set(value):
		workers_node.set_workers(value)

func initialize(population, workers):
	population_node = population
	workers_node = workers
