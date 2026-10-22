extends Label

var country_data

func initialize(player_country):
	country_data = player_country.data
	country_data.money_changed.connect(draw_text)
	draw_text(country_data.country_money)

# Money is stored in billions of USD.
func draw_text(new_money):
	if new_money >= 1000:
		text = "$ %.1fT" % (new_money / 1000.0)
	else:
		text = "$ %dB" % new_money
