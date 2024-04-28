extends Area3D

@export var ball: RigidBody3D
@export var label: Label3D

var score := 0
var enter_height: int

func _on_body_entered(body):
	if body != ball:
		return
	
	enter_height = body.global_position.y

func _on_body_exited(body):
	if body != ball:
		return

	if body.global_position.y >= enter_height:
		return

	score += 3
	label.text = str(score)
