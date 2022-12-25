extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const MAX_SPEED = 128
const MAX_ACCEL = 10 * MAX_SPEED
const MOUSE_SENSITIVITY = 0.001

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	# Lock mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	
	# Move mouse
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		$Head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)


func _process(delta):
	# TODO: Add the gravity.
	# if not is_on_floor():
	# 	velocity.y -= gravity * delta

	# TODO: Handle Jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var wishdir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(wishdir.x, 0, wishdir.y)).normalized()

	# var current_speed = velocity * Vector3(wishdir.x, 0, wishdir.y)

	# print(Vector3(wishdir.x, 1.25, wishdir.y))

	$WishdirRaycast.target_position = lerp($WishdirRaycast.target_position, Vector3(wishdir.x, 0, wishdir.y) * 3, 0.25)
	$Head/Label.text = "vel: %.3f" % velocity.length()

	if direction:
		velocity.x = direction.x * MAX_ACCEL * delta
		velocity.z = direction.z * MAX_ACCEL * delta
	else:
		velocity.x = move_toward(velocity.x, 0, MAX_ACCEL) * delta
		velocity.z = move_toward(velocity.z, 0, MAX_ACCEL) * delta

	move_and_slide()
