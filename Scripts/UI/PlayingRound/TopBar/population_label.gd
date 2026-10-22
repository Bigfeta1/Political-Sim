extends Label

var country_data

func initialize(player_country):
	country_data = player_country.data
	player_country.population.population_changed.connect(draw_text)
	draw_text(country_data.country_population)

func draw_text(new_population):
	if new_population >= 1000000000:
		text = "☻ %.1fB" % (new_population / 1000000000.0)
	elif new_population >= 1000000:
		text = "☻ %.1fM" % (new_population / 1000000.0)
	else:
		text = "☻ %d" % new_population
