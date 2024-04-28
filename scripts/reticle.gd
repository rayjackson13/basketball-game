extends CenterContainer

@export var DOT_RADIUS: float = 5.0
@export var DOT_COLOR := Color.WHITE
@export var OUTLINE_COLOR := Color.DIM_GRAY


# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, DOT_RADIUS, OUTLINE_COLOR)
	draw_circle(Vector2.ZERO, DOT_RADIUS - 2, DOT_COLOR)
