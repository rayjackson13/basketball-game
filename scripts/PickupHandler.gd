extends Node

const PICKUP_SPEED := .5
const THROW_SPEED := 8
const SHADER_OUTLINE_KEY = 'shader_parameter/outline_enabled'

@export var player: RigidBody3D

var raycast: Node3D
var hand: Node3D

var mouse_sensitivity := 0.002
var object_in_hand: RigidBody3D
var object_focused: RigidBody3D
var is_hold_pressed := false

func get_interactable_object() -> RigidBody3D:
	if !raycast.is_colliding():
		return null

	var collider = raycast.get_collider()
	if collider.has_meta('interactable') && collider.get_meta('interactable') == true:
		return collider

	return null;

func check_selectable(collider: Object) -> bool:
	return collider.has_meta('interactable') && collider.get_meta('interactable') || false

func toggle_object_collisions(object: RigidBody3D, enabled: bool) -> void:
	object.freeze = !enabled
	var collision_shape: CollisionShape3D = object.find_child('CollisionShape3D')
	if !collision_shape:
		return
	
	collision_shape.disabled = !enabled;

func move_object_to_position(object: Node3D, position: Vector3) -> void:
	object.global_position = lerp(object.global_position, position, PICKUP_SPEED)
	object.global_basis = hand.global_basis

func pickup_object() -> void:
	var object = get_interactable_object()
	if !object:
		return

	toggle_object_collisions(object, false)
	object_in_hand = object
	
func hold_object() -> void:
	move_object_to_position(object_in_hand, hand.global_position)

func drop_object() -> void:
	if !object_in_hand:
		return
	
	toggle_object_collisions(object_in_hand, true)
	object_in_hand = null
	
func throw_object() -> void:
	if !object_in_hand:
		return
	
	toggle_object_collisions(object_in_hand, true)
	object_in_hand.apply_central_impulse(hand.global_basis * hand.position * THROW_SPEED)
	object_in_hand = null

func get_mesh(object: RigidBody3D) -> MeshInstance3D:
	var mesh: MeshInstance3D
	for child in object.get_children():
		if child is MeshInstance3D:
			mesh = child
	
	return mesh

func set_object_outline(object: RigidBody3D, enabled: bool) -> void:
	var mesh = get_mesh(object)
	
	if !mesh || !mesh.get_surface_override_material_count():
		return
	
	var material = mesh.get_active_material(0)
	if !material || !material.next_pass:
		return
	
	if (enabled):
		mesh.material_override = material.duplicate(true)
		mesh.material_override.next_pass.set(SHADER_OUTLINE_KEY, enabled)
	else:
		mesh.material_override = null
	
func reset_focused_object() -> void:
	if !object_focused:
		return
		
	set_object_outline(object_focused, false)
	object_focused = null

func handle_outline() -> void:
	if object_in_hand:
		reset_focused_object()
		return

	var object = get_interactable_object()
	if !object:
		reset_focused_object()
		return
		
	if object_focused:
		if object != object_focused:
			reset_focused_object()
			return
		else:
			return
	
	set_object_outline(object, true)
	object_focused = object

# Runs once when the project is started.
func _ready():
	raycast = player.find_child('RayCast', true)
	hand = player.find_child('Hand', true)

# Runs every frame.
func _physics_process(_delta: float) -> void:
	handle_outline()

	if is_hold_pressed && object_in_hand:
		hold_object()

# Handles overall input for registered actions in Input Map.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('interact'):
		is_hold_pressed = true
		pickup_object()

	if event.is_action_released('interact'):
		is_hold_pressed = false
		drop_object()

	if event.is_action_pressed('throw'):
		throw_object()
