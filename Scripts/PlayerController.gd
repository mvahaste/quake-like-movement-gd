extends CharacterBody3D


# Export variables
@export var e_mouse_sensitivity: float = 0.05
@export var e_autohop: bool = false

# Node variables
@onready var n_head: Marker3D = $Head
@onready var n_camera: Camera3D = $Head/Camera3D

# Value variables
var v_friction: float = 8
var v_friction_min: float = 0.1
var v_max_speed: float = 6
var v_max_air_speed: float = 0.1 * v_max_speed
var v_accel: float = 12 * v_max_speed
var v_gravity: float = 22
var v_jump_velocity: float = v_gravity / 2.85
var v_jump_surface_angle_modifier: float = 0.1
var v_terminal_velocity: float = v_gravity * -3
var v_cam_accel: float = 80.0

# Data variables
var d_hop: bool
var d_vertical_velocity: float = 0
var d_landing: bool = false
var d_walking: bool = true

# Signal variables
var s_jump_point: Vector3 = Vector3(0, 1, 0)

signal player_landed


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * 0.05)
		$Head.rotate_x(deg_to_rad(-event.relative.y) * 0.05)
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _process(delta):
	if Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		# Separate camera from player and interpolate it's position to the head
		n_camera.set_as_top_level(true)
		n_camera.global_transform.origin = n_camera.global_transform.origin.lerp(n_head.global_transform.origin, v_cam_accel * delta)
		n_camera.rotation.y = rotation.y
		n_camera.rotation.x = n_head.rotation.x
	else:
		# Revert back to default
		n_camera.set_as_top_level(false)
		n_camera.global_transform = n_head.global_transform


func _physics_process(delta: float) -> void:
	# Get input
	var forward_input: float = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var strafe_input: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	var wishdir = Vector3(strafe_input, 0, forward_input).rotated(Vector3.UP, rotation.y).normalized()

	# Bump head on ceiling, don't keep jump velocity
	if is_on_ceiling():
		d_vertical_velocity = 0
	
	if self.is_on_floor():
		# Player landing, counts hops
		if d_landing:
			emit_signal("player_landed", s_jump_point)
			d_landing = false
		
		# Autohop?
		d_hop = e_autohop and Input.is_action_pressed("jump")
		
		# Check for input or autohop
		if Input.is_action_just_pressed("jump") or Input.is_action_just_released("scroll_down") or Input.is_action_just_released("scroll_up") or d_hop:
			s_jump_point = self.position

			d_vertical_velocity = v_jump_velocity

			$Sounds/Jump.play()

			if d_walking:
				d_walking = false
			
			move_air(velocity, wishdir, delta)
		else:
			d_vertical_velocity = 0

			# Player landing, doesn't count hops
			if not d_walking:
				$Sounds/Land.play()
				d_walking = true

			move_ground(velocity, wishdir, delta)
	else:
		if not d_landing:
			d_landing = true
		
		if d_vertical_velocity >= v_terminal_velocity:
			d_vertical_velocity -= v_gravity * delta

		move_air(velocity, wishdir, delta)
	
	move_and_slide()


func accelerate(wishdir: Vector3, input_velocity: Vector3, max_speed: float, delta: float) -> Vector3:
	var current_speed: float = input_velocity.dot(wishdir)

	var add_speed: float = clamp(max_speed - current_speed, 0, v_accel * delta)

	return input_velocity + wishdir * add_speed


func friction(input_velocity: Vector3, delta: float) -> Vector3:
	var speed: float = input_velocity.length()
	var scaled_velocity: Vector3

	if speed != 0:
		var drop = speed * v_friction * delta

		scaled_velocity = input_velocity * max(speed - drop, 0) / speed
	
	if speed <= v_friction_min:
		return scaled_velocity * 0
	
	return scaled_velocity


func move_ground(input_velocity: Vector3, wishdir: Vector3, delta: float) -> void:
	var vel: Vector3 = Vector3.ZERO

	vel.x = input_velocity.x
	vel.z = input_velocity.z
	
	vel = friction(vel, delta)
	vel = accelerate(wishdir, vel, v_max_speed, delta)

	vel.y = d_vertical_velocity

	velocity = vel


func move_air(input_velocity: Vector3, wishdir: Vector3, delta: float) -> void:
	var vel: Vector3 = Vector3.ZERO

	vel.x = input_velocity.x
	vel.z = input_velocity.z

	vel = accelerate(wishdir, vel, v_max_air_speed, delta)

	vel.y = d_vertical_velocity

	velocity = vel
	
