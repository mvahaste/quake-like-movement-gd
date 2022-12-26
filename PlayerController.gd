extends CharacterBody3D


@export var mouse_sensitivity: float = 0.05
@export var autohop: bool = false

@onready var head: Marker3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var v_friction: float = 10
var v_max_speed: float = 6
var v_max_air_speed: float = 0.1 * v_max_speed
var v_accel: float = 12 * v_max_speed
var v_gravity: float = 22
var v_jump_velocity: float = v_gravity / 2.85
var v_terminal_velocity: float = v_gravity * -3

var hop: bool
var vertical_velocity: float = 0
var landing: bool = false

var jump_point: Vector3 = Vector3(0, 1, 0)

signal player_landed


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * 0.05)
		$Head.rotate_x(deg_to_rad(-event.relative.y) * 0.05)
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if Input.is_action_just_pressed("escape"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
	var forward_input: float = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var strafe_input: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	var wishdir = Vector3(strafe_input, 0, forward_input).rotated(Vector3.UP, rotation.y).normalized()

	if self.is_on_floor():
		if landing:
			emit_signal("player_landed", jump_point)
			landing = false
		
		hop = autohop and Input.is_action_pressed("jump")
		
		if Input.is_action_just_pressed("jump") or Input.is_action_just_released("scroll_down") or hop:
			jump_point = self.position

			vertical_velocity = v_jump_velocity

			# Don't use move_air(), keep the single move_ground() frame causing the player to lose a small amount of speed on hop just like Quake
			# move_air(velocity, wishdir, delta)
		else:
			vertical_velocity = 0

		move_ground(velocity, wishdir, delta)
	else:
		if not landing:
			landing = true
		
		if vertical_velocity >= v_terminal_velocity:
			vertical_velocity -= v_gravity * delta

		move_air(velocity, wishdir, delta)
	
	move_and_slide()


# func _physics_process(delta: float) -> void:
# 	var forward_input: float = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
# 	var strafe_input: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

# 	var wishdir = Vector3(strafe_input, 0, forward_input).rotated(Vector3.UP, rotation.y).normalized()

# 	if self.is_on_floor():
# 		if Input.is_action_just_pressed("jump"):
# 			vertical_velocity = v_jump_velocity
		
# 			move_air(velocity, wishdir, delta)
# 			print("jump")
# 		else:
# 			vertical_velocity = 0

# 			move_ground(velocity, wishdir, delta)
# 			print("ground")
# 	else:
# 		if vertical_velocity >= v_terminal_velocity:
# 			vertical_velocity -= v_gravity * delta

# 		move_air(velocity, wishdir, delta)
# 		print("air")
	
# 	move_and_slide()


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
	
	if speed <= 0.25:
		return scaled_velocity * 0
	
	return scaled_velocity


func move_ground(input_velocity: Vector3, wishdir: Vector3, delta: float) -> void:
	var vel: Vector3 = Vector3.ZERO

	vel.x = input_velocity.x
	vel.z = input_velocity.z
	
	vel = friction(vel, delta)
	vel = accelerate(wishdir, vel, v_max_speed, delta)

	vel.y = vertical_velocity

	velocity = vel


func move_air(input_velocity: Vector3, wishdir: Vector3, delta: float) -> void:
	var vel: Vector3 = Vector3.ZERO

	vel.x = input_velocity.x
	vel.z = input_velocity.z

	vel = accelerate(wishdir, vel, v_max_air_speed, delta)

	vel.y = vertical_velocity

	velocity = vel
	