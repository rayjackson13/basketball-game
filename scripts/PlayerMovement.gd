extends Node

@export var player: RigidBody3D
@export var mouse_sensitivity := 0.002

var head: Node
var camera: Node

var mouse_x = 0
var mouse_y = 0

func handle_player_movement(delta: float) -> void:
	var input = Vector3.ZERO
	input.z = Input.get_axis('move_right', 'move_left')
	input.x = Input.get_axis('move_forward', 'move_back')
	
	player.apply_central_force(head.basis * input * 2000.0 * delta)
	
func handle_camera_movement() -> void:
	head.rotate_y(mouse_y)
	camera.rotate_x(mouse_x)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75));
	mouse_x = 0
	mouse_y = 0

# Runs once when the project is started.
func _ready():
	head = player.find_child('Head', true)
	camera = player.find_child('Camera', true)

# Runs every frame.
func _physics_process(delta: float) -> void:
	handle_player_movement(delta)
	handle_camera_movement()

# Handles mouse movement.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_y = -event.relative.x * mouse_sensitivity
			mouse_x = -event.relative.y * mouse_sensitivity
