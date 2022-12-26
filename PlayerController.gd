extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const MAX_SPEED = 75
const MAX_AIR_SPEED = 25
const MAX_ACCEL = 10 * MAX_SPEED

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# var last_floor = true
# var wishdir = Vector3()
# var prev_wishdir = Vector3()
# var direction = Vector3()


#! DEBUG
@onready var wishdir_line = $Head/WishdirContainer/Center/Wishdir
@onready var wishdir_ray = $WishdirRaycast
@onready var velocity_ray = $VelocityRaycast
@onready var vel_line = $Head/WishdirContainer/Center/Velocity
@onready var vel_text = $Head/Label
#! DEBUG


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * 0.05)
		$Head.rotate_x(deg_to_rad(-event.relative.y) * 0.05)
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if Input.is_action_just_pressed("escape"):
		get_tree().quit()


func _process(delta):
	# # Add the gravity.
	# if not is_on_floor():
	# 	velocity.y -= gravity * delta

	# # Handle Jump.
	# if Input.is_action_pressed("jump") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY
	# 	prev_wishdir = wishdir

	# # Get the input direction and handle the movement/deceleration.
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var wishdir = Vector3(input.x, 0, input.y)
	
	# print(wishdir)

	# direction = lerp(direction, (transform.basis * wishdir).normalized(), 0.1)

	# if direction:
	# 	# velocity.x = direction.x * SPEED
	# 	velocity.x = lerp(velocity.x, direction.x * SPEED, 0.1)
	# 	# velocity.z = direction.z * SPEED
	# 	velocity.z = lerp(velocity.z, direction.z * SPEED, 0.1)
	# else:
	# 	if is_on_floor() and last_floor:
	# 		velocity.x = move_toward(velocity.x, 0, SPEED)
	# 		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# last_floor = is_on_floor()

	if is_on_floor():
		velocity = update_vel_ground(wishdir, velocity, delta).rotated(Vector3.UP, rotation.y)

		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	else:
		velocity = update_vel_air(wishdir, velocity, delta).rotated(Vector3.UP, rotation.y)
		velocity.y -= gravity * delta


	move_and_slide()

	debug_info(wishdir)


func update_vel_ground(wishdir: Vector3, vel: Vector3, frame_time: float) -> Vector3:
	vel = friction(vel, frame_time)

	var current_speed = vel.dot(wishdir)
	
	var add_speed = clamp(MAX_SPEED - current_speed, 0, MAX_ACCEL * frame_time)

	return vel + (add_speed * wishdir)


func update_vel_air(wishdir: Vector3, vel: Vector3, frame_time: float) -> Vector3:
	var current_speed = vel.dot(wishdir)
	var add_speed = clamp(MAX_AIR_SPEED - current_speed, 0, MAX_ACCEL * frame_time)

	return vel + (add_speed * wishdir)


func friction(vel: Vector3, frame_time: float) -> Vector3:
	return vel * 4 * frame_time


func debug_info(wishdir: Vector3):
	vel_text.text = "velocity: %.3f\nfps: %s" % [Vector2(velocity.x, velocity.z).length(), Engine.get_frames_per_second()]
	wishdir_ray.target_position = wishdir * 5
	velocity_ray.target_position = velocity * transform.basis
	# wishdir_line.set_point_position(1, Vector2(wishdir.x, wishdir.z) * 90)
	# vel_line.set_point_position(1, Vector2(velocity.x, velocity.z).rotated(rotation.y) * 30)