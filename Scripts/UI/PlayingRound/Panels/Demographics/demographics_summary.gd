extends Label

var country_data

func initialize(player_country):
	country_data = player_country.data
	player_country.population.life_expectancy.life_expectancy_changed.connect(draw_text.unbind(1))
	player_country.population.count.population_count_changed.connect(draw_text.unbind(1))
	draw_text()

func draw_text():
	text = "%s\nLife expectancy %.1f years   ·   WHO target %.1f   ·   Population %.1fM" % [
		country_data.country_name,
		country_data.country_life_expectancy,
		country_data.country_target_life_expectancy,
		country_data.country_population_count / 1000000.0,
	]
