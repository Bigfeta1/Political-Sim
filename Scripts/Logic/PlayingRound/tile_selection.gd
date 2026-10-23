extends Node

const MapCell = preload("res://Scripts/Map/map_cell.gd")

signal hovered_coordinate_changed(new_coordinate)
signal long_hovered_changed(new_long_hovered)
signal selected_coordinate_changed(new_coordinate)

@onready var long_hover_timer = $LongHoverTimer

var tile_directory
var hovered_coordinate = null
var long_hovered := false
var selected_coordinate = null

func initialize(tile_directory_reference):
	tile_directory = tile_directory_reference

func set_hovered_coordinate(value) -> void:
	if value == hovered_coordinate:
		return

	hovered_coordinate = value
	hovered_coordinate_changed.emit(value)
	set_long_hovered(false)

	if value == null:
		long_hover_timer.stop()
	else:
		long_hover_timer.start()

func set_long_hovered(value: bool) -> void:
	if value == long_hovered:
		return

	long_hovered = value
	long_hovered_changed.emit(value)

func set_selected_coordinate(value) -> void:
	if value == selected_coordinate:
		return

	selected_coordinate = value
	selected_coordinate_changed.emit(value)

func select(coordinate) -> void:
	if coordinate == null or coordinate == selected_coordinate or tile_directory.get_cell(coordinate).terrain == MapCell.Terrain.WATER:
		set_selected_coordinate(null)
	else:
		set_selected_coordinate(coordinate)

func _on_long_hover_timer_timeout() -> void:
	set_long_hovered(true)
