extends CharacterBody3D

@onready var cam: Camera3D = $Camera3D

const SPEED: int = 5.0
const gravity: float = 9.8
const ray_length: int = 1000
const camera_move: float = 8
const camera_weight: float = 0.9

var target_player_pos: Vector2

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var intersection = raycast_from_mouse(event.position)
		var t_pos: Vector3 = intersection.position
		move_player(Vector2(t_pos.x, t_pos.z))

func _process(delta: float):
	var m_pos = get_viewport().get_mouse_position()
	move_camera(m_pos, delta)

func raycast_from_mouse(m_pos: Vector2):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 1)
	return space_state.intersect_ray(query)

func move_camera(m_pos: Vector2, delta: float):
	var viewport_size: Vector2 = get_viewport().size
	if m_pos.x <= 5:
		cam.position.x = lerpf(cam.position.x, cam.position.x - camera_move * delta, camera_weight)
	elif m_pos.x >= viewport_size.x - 5:
		cam.position.x = lerpf(cam.position.x, cam.position.x + camera_move * delta, camera_weight)
	if m_pos.y <= 5:
		cam.position.z = lerpf(cam.position.z, cam.position.z - camera_move * delta, camera_weight)
	elif m_pos.y >= viewport_size.y - 5:
		cam.position.z = lerpf(cam.position.z, cam.position.z + camera_move * delta, camera_weight)

func move_player(t_pos: Vector2):
	target_player_pos = t_pos

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if position.x != target_player_pos.x or position.z != target_player_pos.y:
		position.x = lerpf(position.x, target_player_pos.x, 0.3)
		position.z = lerpf(position.z, target_player_pos.y, 0.3)
		

#	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
#	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	if direction:
#		velocity.x = direction.x * SPEED
#		velocity.z = direction.z * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
