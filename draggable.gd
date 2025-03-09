extends Node2D

var dragging = false

func _ready():
	randomize()  # Ensures randomness on each run
	var viewport_size = get_viewport_rect().size

	# Define safe spawn margins to avoid edges
	var margin = 100

	# Get a random position within screen bounds
	var random_position = Vector2(
		randf_range(margin, viewport_size.x - margin),
		randf_range(margin, viewport_size.y - margin)
	)

	global_position = random_position  # Set randomized position

	# Debugging Output
	print("Draggable Object Spawned at:", global_position)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and (event.position - global_position).length() < 50:
			dragging = true
		elif !event.pressed:
			dragging = false
			check_win()

	elif event is InputEventMouseMotion and dragging:
		global_position = event.position

func check_win():
	var target = get_parent().get_node("TargetObject")
	if target:
		var distance = global_position.distance_to(target.global_position)

		if distance <= 10:  # Ensures only close alignment triggers win
			global_position = target.global_position  # Snap to target
			print("You Win!")  # Replace with actual win logic

func _draw():
	draw_circle(Vector2.ZERO, 50, Color(0, 0, 1))  # Draws a blue circle (draggable)
