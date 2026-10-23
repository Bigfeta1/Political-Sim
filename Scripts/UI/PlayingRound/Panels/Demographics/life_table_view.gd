extends VBoxContainer

const TableCell = preload("res://Scripts/UI/PlayingRound/Panels/Demographics/table_cell.gd")

const HEADERS = ["n", "m(x) per 1,000", "q(x)", "l(x)", "L(x) years"]
const LEGEND = [
	"n    years the age band covers",
	"m(x)    deaths per 1,000 people in the band per year",
	"q(x)    chance that someone entering the band dies before leaving it",
	"l(x)    share of newborns still alive at the start of the band",
	"L(x)    years the average newborn lives inside the band; for %s, all years lived from %d on",
]

@onready var rows = $Rows
@onready var legend = $Legend
@onready var totals = $Totals

var life_expectancy
var mortality

func initialize(player_country):
	life_expectancy = player_country.population.life_expectancy
	mortality = player_country.population.mortality
	life_expectancy.life_expectancy_changed.connect(draw_table.unbind(1))
	draw_table()

func draw_table():
	clear(rows)
	clear(totals)

	var open_band = life_expectancy.open_band
	var table = life_expectancy.life_table()
	var open_years = life_expectancy.open_band_years()

	rows.add_child(TableCell.header("Age", HORIZONTAL_ALIGNMENT_LEFT))
	for header in HEADERS:
		rows.add_child(TableCell.header(header))

	for row in table["rows"]:
		add_row([row["band"].key, str(row["band"].width), "%.2f" % (row["rate"] * 1000), "%.4f" % row["dying"], "%.3f" % row["survivors"], "%.2f" % row["years"]])
	add_row([open_band.key, "—", "%.2f" % (mortality.death_rate(open_band) * 1000), "—", "%.3f" % table["survivors"], "%.2f" % (table["survivors"] * open_years)])

	var legend_lines = LEGEND.duplicate()
	legend_lines[-1] = legend_lines[-1] % [open_band.key, open_band.start_age]
	legend.text = "\n".join(legend_lines)

	add_total("Years lived before %d" % open_band.start_age, "%.2f" % table["years"], "sum of L(x) for the bands below %d" % open_band.start_age)
	add_total("Share reaching %d" % open_band.start_age, "%.3f" % table["survivors"], "l(x) at %d" % open_band.start_age)
	add_total("Years remaining at %d" % open_band.start_age, "%.2f" % open_years, "set so life expectancy matches the WHO target; one flat rate (1/m) would give %.2f" % life_expectancy.flat_open_band_years())
	add_total("Life expectancy at birth", "%.2f" % life_expectancy.life_expectancy, "%.2f + %.3f × %.2f" % [table["years"], table["survivors"], open_years])

func add_row(cells):
	rows.add_child(TableCell.value(cells[0], HORIZONTAL_ALIGNMENT_LEFT))
	for i in range(1, cells.size()):
		rows.add_child(TableCell.value(cells[i]))

func add_total(total_name, total_value, total_note):
	totals.add_child(TableCell.value(total_name, HORIZONTAL_ALIGNMENT_LEFT))
	totals.add_child(TableCell.value(total_value))
	totals.add_child(TableCell.note(total_note))

func clear(container):
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
