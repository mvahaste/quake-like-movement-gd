extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var last_floor = true
var wishdir = Vector3()
var prev_wishdir = Vector3()
var direction = Vector3()


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
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		prev_wishdir = wishdir

	# Get the input direction and handle the movement/deceleration.
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	wishdir = Vector3(input.x, 0, input.y)
	
	print(wishdir)

	direction = lerp(direction, (transform.basis * wishdir).normalized(), 0.1)

	if direction:
		# velocity.x = direction.x * SPEED
		velocity.x = lerp(velocity.x, direction.x * SPEED, 0.1)
		# velocity.z = direction.z * SPEED
		velocity.z = lerp(velocity.z, direction.z * SPEED, 0.1)
	else:
		if is_on_floor() and last_floor:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	
	last_floor = is_on_floor()
	
	$Head/Label.text = "vel: %.3f" % Vector2(velocity.x, velocity.z).length()
	$WishdirRaycast.target_position = wishdir * 10

	move_and_slide()
