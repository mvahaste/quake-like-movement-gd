extends CharacterBody3D


@export var mouse_sensitivity: float = 0.05

@onready var head: Marker3D = $Head
@onready var camera: Camera3D = $Head/Camera3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * 0.05)
		$Head.rotate_x(deg_to_rad(-event.relative.y) * 0.05)
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if Input.is_action_just_pressed("escape"):
		get_tree().quit()


func _process(_delta: float) -> void:
	$Head/Label.text = str(velocity.length())


func _physics_process(_delta: float) -> void:
	move_ground()


func accelerate() -> void:
	return


func friction() -> void:
	return


func move_ground() -> void:
	return


func move_air() -> void:
	return
