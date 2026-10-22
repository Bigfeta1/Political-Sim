extends Label

var country_data

func initialize(player_country):
	country_data = player_country.data
	player_country.public_image.public_image_changed.connect(draw_text)
	draw_text(country_data.country_public_image)

func draw_text(new_public_image):
	text = "★ " + str(new_public_image)
