extends GridContainer

const TableCell = preload("res://Scripts/UI/PlayingRound/Panels/Demographics/table_cell.gd")

const BAR_WIDTH = 300

var age_bands
var count

func initialize(player_country):
	age_bands = player_country.population.age_bands
	count = player_country.population.count
	count.population_count_changed.connect(draw_table.unbind(1))
	draw_table()

func draw_table():
	for child in get_children():
		remove_child(child)
		child.queue_free()

	add_child(TableCell.header("Age", HORIZONTAL_ALIGNMENT_LEFT))
	add_child(TableCell.header("Population"))
	add_child(TableCell.header("Share"))
	add_child(TableCell.header(""))

	var largest_share := 0.0
	for band in age_bands.get_children():
		largest_share = max(largest_share, band.population / count.population_count)

	for band in age_bands.get_children():
		var share = band.population / count.population_count
		add_child(TableCell.value(band.key, HORIZONTAL_ALIGNMENT_LEFT))
		add_child(TableCell.value("%.1fM" % (band.population / 1000000.0)))
		add_child(TableCell.value("%.1f%%" % (share * 100)))
		add_bar(share, largest_share)

func add_bar(share, largest_share):
	var bar = ProgressBar.new()
	bar.show_percentage = false
	bar.step = 0.0
	bar.max_value = largest_share
	bar.value = share
	bar.custom_minimum_size = Vector2(BAR_WIDTH, 16)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(bar)
