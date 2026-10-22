extends Label

enum Format { PLAIN, WHOLE, BILLIONS_OF_USD, PEOPLE }

# Each label is set up in the scene. "value" is the name on the parameter node, e.g. "money":
# the label connects to "<value>_changed" on that node and draws from "country_<value>" on Data.
@export var symbol: String
@export var parameter: String
@export var value: String
@export var format: Format

var country_data

func initialize(player_country):
	country_data = player_country.data
	player_country.parameters.get_node(parameter).connect(value + "_changed", draw_text)
	draw_text(country_data.get("country_" + value))

func draw_text(new_value):
	text = symbol + " " + format_value(new_value)

func format_value(new_value) -> String:
	match format:
		Format.WHOLE:
			return str(roundi(new_value))
		Format.BILLIONS_OF_USD:
			if new_value >= 1000:
				return "%.1fT" % (new_value / 1000.0)
			return "%dB" % new_value
		Format.PEOPLE:
			if new_value >= 1000000000:
				return "%.1fB" % (new_value / 1000000000.0)
			elif new_value >= 1000000:
				return "%.1fM" % (new_value / 1000000.0)
			return "%d" % new_value
		_:
			return str(new_value)
