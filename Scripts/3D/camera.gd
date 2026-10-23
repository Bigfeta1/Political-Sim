extends Camera3D

const TileFactory = preload("res://Scripts/Map/tile_factory.gd")

const ZOOM_STEP = 0.1
const TOP_DOWN_PITCH = -PI / 2.0

var bounds: Rect2
var focus: Vector3
var zoom := 0.0
var close_pitch: float
var close_distance: float

func _ready() -> void:
	close_pitch = rotation.x
	focus = Plane(Vector3.UP, 0.0).intersects_ray(global_position, -global_basis.z)
	close_distance = global_position.distance_to(focus)

func initialize(bounds_reference: Rect2) -> void:
	bounds = bounds_reference
	place()

#region Zoom
func zoom_in() -> void:
	set_zoom(zoom - ZOOM_STEP)

func zoom_out() -> void:
	set_zoom(zoom + ZOOM_STEP)

func set_zoom(value: float) -> void:
	zoom = clampf(value, 0.0, 1.0)
	place()

func far_distance() -> float:
	var area = bounds.grow(TileFactory.TILE_SIZE)
	var half_height = tan(deg_to_rad(fov) / 2.0)
	var aspect = get_viewport().get_visible_rect().size.aspect()
	return maxf(area.size.y / 2.0 / half_height, area.size.x / 2.0 / (half_height * aspect))

func zoom_distance() -> float:
	return close_distance * pow(far_distance() / close_distance, zoom)
#endregion

#region Movement
func pan(offset: Vector3) -> void:
	if zoom >= 1.0:
		return

	focus += offset * zoom_distance() / close_distance / (1.0 - zoom)
	place()

func place() -> void:
	var centre = bounds.get_center()
	if zoom < 1.0:
		var reach = bounds.size / 2.0 / (1.0 - zoom)
		focus.x = clampf(focus.x, centre.x - reach.x, centre.x + reach.x)
		focus.z = clampf(focus.z, centre.y - reach.y, centre.y + reach.y)

	var target = focus.lerp(Vector3(centre.x, 0.0, centre.y), zoom)

	rotation.x = lerpf(close_pitch, TOP_DOWN_PITCH, zoom)
	global_position = target + global_basis.z * zoom_distance()
#endregion
