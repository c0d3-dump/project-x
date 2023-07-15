extends CharacterBody3D

@onready var cam: Camera3D = $Camera3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

const SPEED: float = 3.0
const ACCEL: float = 10.0
const gravity: float = 9.8
const ray_length: int = 1000
const camera_move: float = 12
const camera_weight: float = 0.9

var target_player_pos: Vector2

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var intersection = raycast_from_mouse(event.position)
		if intersection.has("position"):
			var t_pos: Vector3 = intersection.position
			move_player(Vector2(t_pos.x, t_pos.z))

func _process(delta: float):
	var m_pos = get_viewport().get_mouse_position()
	move_camera(m_pos, delta)
	
	if Input.is_action_pressed("canter-camera"):
		var tween = get_tree().create_tween()
		tween.tween_property(cam, "position", Vector3(position.x, 30, position.z), 0.3).set_trans(Tween.TRANS_EXPO)

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
	nav_agent.target_position = Vector3(t_pos.x, global_position.y, t_pos.y)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var direction: Vector3 = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * SPEED, ACCEL * delta)
	
	move_and_slide()
