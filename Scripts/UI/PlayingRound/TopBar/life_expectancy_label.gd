extends Label

var country_data

func initialize(player_country):
	country_data = player_country.data
	player_country.population.life_expectancy_changed.connect(draw_text)
	draw_text(country_data.country_life_expectancy)

func draw_text(new_life_expectancy):
	text = "♥ " + str(roundi(new_life_expectancy))
