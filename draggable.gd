extends Node2D

var dragging = false
var heart_rate_values = []  # List to store heart rate data
var current_index = 0  # Track which heart rate value we're using
var heart_rate_threshold = 70  # Threshold for relaxation
var move_speed = 25.0  # Movement speed toward target
var last_delta = 0.9  # Default small delta value
var previous_heart_rate = -1  # ✅ Store last heart rate value
var low_heart_rate_counter = 0  # ✅ Counter to track consecutive low heart rate readings
var required_count = 2  # ✅ Number of times HR must stay low before moving

func _ready():
	randomize()
	var viewport_size = get_viewport_rect().size
	var margin = 100
	var target = get_parent().get_node("TargetObject")  # ✅ Get target position
	var min_distance = 250  # ✅ Increased minimum distance

	# ✅ Ensure the object is far enough from the target
	var new_position = global_position
	if target:
		while true:
			new_position = Vector2(
				randf_range(margin, viewport_size.x - margin),
				randf_range(margin, viewport_size.y - margin)
			)
			var distance = new_position.distance_to(target.global_position)
			if distance > min_distance:
				break  # ✅ Stop when a valid position is found

	global_position = new_position  # ✅ Set position only after finding a valid one

	print("✅ Starting Position:", global_position, "Target Position:", target.global_position, "Distance:", global_position.distance_to(target.global_position))

	load_heart_rate_data()
	start_heart_rate_timer()


func load_heart_rate_data():
	var file = FileAccess.open("res://heart_rate.txt", FileAccess.READ)
	
	if not file:
		print("Failed to load heart rate data! Stopping script...")
		set_process(false)
		set_physics_process(false)
		get_tree().quit()
		return

	file.seek(0)  # ✅ Ensure we start from the beginning
	print("DEBUG: File position before reading:", file.get_position(), "/", file.get_length())

	while file.get_position() < file.get_length():  
		var line = file.get_line().strip_edges()  # ✅ Read a line first

		# ✅ Only check EOF AFTER calling `get_line()`
		if file.get_position() >= file.get_length():
			print("EOF reached - Exiting game.")
			break  # ✅ Exit the loop properly

		if line.is_empty():  # ✅ Ignore blank lines
			continue

		if line.is_valid_float():
			heart_rate_values.append(int(line))

	file.close()

	if heart_rate_values.is_empty():
		print("No valid heart rate values found! Stopping script...")
		set_process(false)
		set_physics_process(false)
		get_tree().quit()

func start_heart_rate_timer():
	var timer = Timer.new()
	timer.wait_time = 3.0  # Update heart rate every 5 seconds
	timer.autostart = true
	timer.timeout.connect(_on_heart_rate_timer)
	add_child(timer)

func _on_heart_rate_timer():
	update_heart_rate(last_delta)  # Pass delta stored from _process()


func update_heart_rate(delta):
	if heart_rate_values.size() == 0:
		print("No heart rate data found!")
		return

	var simulated_heart_rate = heart_rate_values[current_index]
	print("Current HR:", simulated_heart_rate, "Previous HR:", previous_heart_rate, "Counter:", low_heart_rate_counter)

	if simulated_heart_rate <= heart_rate_threshold:
		if simulated_heart_rate == previous_heart_rate:
			low_heart_rate_counter += 1  
		else:
			low_heart_rate_counter = 1  

		print("✅ HR Counter:", low_heart_rate_counter, "/", required_count)



	# ✅ Update previous heart rate
	previous_heart_rate = simulated_heart_rate

	# ✅ Move to next heart rate value (loop if needed)
	current_index = (current_index + 1) % heart_rate_values.size()
func move_toward_target(delta):
	var target = get_parent().get_node("TargetObject")
	
	if target:
		var direction = (target.global_position - global_position).normalized()  # ✅ Move toward target
		global_position += direction * (move_speed + 10) * delta  # ✅ Move same speed as moving away

		print("➡ Moving TOWARD from:", global_position, "Target at:", target.global_position)
 

func move_away_from_target(delta):
	var target = get_parent().get_node("TargetObject")
	
	if target:
		var direction = (global_position - target.global_position).normalized()  # Opposite direction
		global_position += direction * (move_speed + 10) * delta  # Move away faster

		print("Moving AWAY from:", global_position, "Target at:", target.global_position)

func _process(delta):
	last_delta = delta  # Store delta for timer function

	var target = get_parent().get_node("TargetObject")
	if target and global_position.distance_to(target.global_position) < 5:  # ✅ Only stop if very close
		print("🎉 You reached the target!")
		set_process(false)
		set_physics_process(false)
		get_tree().quit()
		return

	print("delta is:", last_delta)

	if target and heart_rate_values.size() > 0:
		var simulated_heart_rate = heart_rate_values[current_index]

		print("Checking movement conditions - HR:", simulated_heart_rate, "Counter:", low_heart_rate_counter, "/", required_count)

		if simulated_heart_rate < heart_rate_threshold:
			low_heart_rate_counter += 1  
			if low_heart_rate_counter >= required_count:
				print("🚀 Moving toward target!")
				move_toward_target(delta)
				low_heart_rate_counter = 0  

		elif simulated_heart_rate >= 90:
			print("🚨 Heart rate too high! Moving away...")
			move_away_from_target(delta)  

func _draw():
	draw_circle(Vector2.ZERO, 50, Color(0, 0, 1))  # Blue circle
