extends Control


@onready var player: CharacterBody3D = $"../../../../../Player"

@onready var velocity_label: Label = $Velocity
@onready var velocity_bar: ProgressBar = $Velocity/Bar
@onready var jump_distance: Label = $JumpDistance
@onready var mouse: Control = $Mouse
@onready var mouse_cursor: ColorRect = $Mouse/Center/MouseCursor
@onready var mouse_line: Line2D = $Mouse/Center/Line2D
@onready var keyboard: Control = $Keyboard

var lerp_return: float = 0.25


func _ready() -> void:
	player.connect("player_landed", update_jump_distance)


func _physics_process(_delta) -> void:
	velocity_label.text = "Velocity: %s m/s" % (round(Vector3(player.velocity.x, 0, player.velocity.z).length() * 100) / 100)
	velocity_bar.value = round(Vector3(player.velocity.x, 0, player.velocity.z).length() * 100) / 100

	mouse_line.set_point_position(1, lerp(mouse_line.points[1], Vector2.ZERO, lerp_return))
	mouse_cursor.position = lerp(mouse_cursor.position, Vector2(-7.5, -7.5), lerp_return)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_forward"):
		press_key("W")
	elif Input.is_action_just_released("move_forward"):
		release_key("W")
	
	if Input.is_action_just_pressed("move_backward"):
		press_key("S")
	elif Input.is_action_just_released("move_backward"):
		release_key("S")
	
	if Input.is_action_just_pressed("move_left"):
		press_key("A")
	elif Input.is_action_just_released("move_left"):
		release_key("A")
	
	if Input.is_action_just_pressed("move_right"):
		press_key("D")
	elif Input.is_action_just_released("move_right"):
		release_key("D")
	
	if Input.is_action_just_pressed("jump"):
		press_key("Space")
	elif Input.is_action_just_released("jump"):
		release_key("Space")
	
	if Input.is_action_just_released("scroll_down"):
		scroll("Down")

	if Input.is_action_just_released("scroll_up"):
		scroll("Up")

	if event is InputEventMouseMotion:
		# print("Mouse Pos: %s" % event.relative)
		mouse_line.set_point_position(1, mouse_line.points[1] + event.relative * 0.1)
		mouse_cursor.position = mouse_cursor.position + event.relative * 0.1


func press_key(key: String) -> void:
	keyboard.get_node(key).get_node("ColorRect").color = Color(0, 0, 0, 0.5)


func release_key(key: String) -> void:
	keyboard.get_node(key).get_node("ColorRect").color = Color(0, 0, 0, 0.25)


func scroll(dir: String) -> void:
	mouse.get_node(dir).get_node("ColorRect").color = Color(0, 0, 0, 0.5)
	await get_tree().create_timer(0.075).timeout
	mouse.get_node(dir).get_node("ColorRect").color = Color(0, 0, 0, 0.25)


func delay(time: float) -> void:
	get_tree().create_timer(time)


func update_jump_distance(jump_point: Vector3) -> void:
	jump_distance.text = "Last jump distance: %s m" % (round(player.position.distance_to(jump_point) * 100) / 100)
