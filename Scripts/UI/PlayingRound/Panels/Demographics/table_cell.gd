extends RefCounted

const HEADER_COLOR = Color(0.6, 0.6, 0.6)
const NOTE_COLOR = Color(0.55, 0.55, 0.55)
const COLUMN_WIDTH = 90
const NOTE_WIDTH = 380

static func header(cell_text, align := HORIZONTAL_ALIGNMENT_RIGHT) -> Label:
	var label = value(cell_text, align)
	label.modulate = HEADER_COLOR
	return label

static func value(cell_text, align := HORIZONTAL_ALIGNMENT_RIGHT) -> Label:
	var label = Label.new()
	label.text = cell_text
	label.horizontal_alignment = align
	label.custom_minimum_size.x = COLUMN_WIDTH
	return label

static func note(cell_text) -> Label:
	var label = Label.new()
	label.text = cell_text
	label.modulate = NOTE_COLOR
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = NOTE_WIDTH
	return label
