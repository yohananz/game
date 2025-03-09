extends Node2D

func _ready():
	global_position = get_viewport_rect().size / 2  # Center the target

func _draw():
	draw_circle(Vector2.ZERO, 50, Color(1, 0, 0))  # Draws a red circle (target)
