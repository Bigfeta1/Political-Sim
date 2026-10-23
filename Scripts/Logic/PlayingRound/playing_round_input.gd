extends Node

const CAMERA_SPEED = 10.0

var camera
var bounds: Rect2
var focus_offset: Vector3

func initialize(camera_reference, bounds_reference: Rect2):
	camera = camera_reference
	bounds = bounds_reference
	focus_offset = camera.global_position - find_focus()

func _process(delta: float) -> void:
	move_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if event.keycode == KEY_F5:
		SaveWriter.save()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ALT:
		# Handled first: the state change frees this node, so the viewport is gone afterwards.
		get_viewport().set_input_as_handled()
		GameState.state_change_requested.emit(GameState.State.MAIN_MENU)

#region Camera
func move_camera(delta: float) -> void:
	var direction = read_direction()
	if direction == Vector3.ZERO:
		return

	var focus = camera.global_position - focus_offset + direction * CAMERA_SPEED * delta
	focus.x = clampf(focus.x, bounds.position.x, bounds.end.x)
	focus.z = clampf(focus.z, bounds.position.y, bounds.end.y)

	camera.global_position = focus + focus_offset

func read_direction() -> Vector3:
	var forward = flatten(-camera.global_basis.z)
	var right = flatten(camera.global_basis.x)
	var direction = Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		direction += forward
	if Input.is_key_pressed(KEY_S):
		direction -= forward
	if Input.is_key_pressed(KEY_D):
		direction += right
	if Input.is_key_pressed(KEY_A):
		direction -= right

	return direction.normalized()

func flatten(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0.0, vector.z).normalized()

func find_focus() -> Vector3:
	return Plane(Vector3.UP, 0.0).intersects_ray(camera.global_position, -camera.global_basis.z)
#endregion
