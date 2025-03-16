extends Node2D

@onready var heart_rate_label = get_parent().get_node_or_null("TopBar/HeartRateLabel")
@onready var heart_image = get_parent().get_node_or_null("TopBar/HeartImage")

var heart_rate_values = []
var current_index = 0
var heart_rate_threshold = 70
var move_speed = 5.0
var required_count = 2
var low_heart_rate_counter = 0
var previous_hr = -1
var current_hr = -1  # Set by timer only.

func _ready():
	randomize()
	position_far_from_target()
	load_heart_rate_data()
	setup_timer()

	# ✅ Force first heartbeat update
	if heart_rate_values.size() > 0:
		current_hr = heart_rate_values[0]
		get_parent().get_node("TopBar").update_bpm(current_hr)
		animate_heart()

func position_far_from_target():
	var viewport_size = get_viewport_rect().size
	var target = get_parent().get_node("TargetObject")
	var min_distance = 250
	var margin = 100
	
	while true:
		global_position = Vector2(
			randf_range(margin, viewport_size.x - margin),
			randf_range(margin, viewport_size.y - margin)
		)
		if global_position.distance_to(target.global_position) >= min_distance:
			break

func load_heart_rate_data():
	var file = FileAccess.open("res://heart_rate.txt", FileAccess.READ)
	if not file:
		print("Failed to open heart_rate.txt")
		get_tree().quit()
		return
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.is_valid_int():
			heart_rate_values.append(int(line))
	file.close()
	
	if heart_rate_values.size() == 0:
		print("No valid heart rate data found.")
		get_tree().quit()

func setup_timer():
	var timer = Timer.new()
	timer.wait_time =10  # ⏳ Reduced from 15 to 3 seconds
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)

func _on_timer_timeout():
	if heart_rate_values.size() == 0:
		return

	current_hr = heart_rate_values[current_index]

	# ✅ Update TopBar
	get_parent().get_node("TopBar").update_bpm(current_hr)

	# ✅ Ensure heart beats immediately
	animate_heart()

	# ✅ Track heart rate count for movement logic
	if current_hr <= heart_rate_threshold:
		if previous_hr <= heart_rate_threshold and previous_hr != -1:
			low_heart_rate_counter += 1  # ✅ Count consecutive low HR values
		else:
			low_heart_rate_counter = 1
	else:
		low_heart_rate_counter = 0  # ✅ Reset if HR goes high

	print("💓 HR:", current_hr, "Low HR Counter:", low_heart_rate_counter)

	previous_hr = current_hr
	current_index = (current_index + 1) % heart_rate_values.size()


func animate_heart():
	if not heart_image:
		print("❌ Error: HeartImage not found!")
		return

	print("💓 Animating Heart! HR:", current_hr)  # Debugging print

	var tween = create_tween()
	heart_image.scale = Vector2.ONE  # Reset scale
	tween.tween_property(heart_image, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(heart_image, "scale", Vector2(1, 1), 0.2).set_delay(0.2)

func _process(delta):
	if current_hr == -1:
		return  # Skip until timer initializes first HR value

	var target = get_parent().get_node("TargetObject")
	var distance = global_position.distance_to(target.global_position)
	
	if distance < 10:
		print("🎉 Target reached!")
		get_tree().quit()
		return
	
	if current_hr >= 90:
		move_away_from_target(target, delta)
	elif low_heart_rate_counter >= required_count:
		move_toward_target(target, delta)

func move_toward_target(target, delta):
	var direction = (target.global_position - global_position).normalized()
	
	# ✅ Scale movement to be smooth
	var step_size = move_speed * delta * 0.5  # Reduce movement step
	
	if global_position.distance_to(target.global_position) > step_size:
		global_position += direction * step_size
		print("🚀 Moving toward target! HR:", current_hr, "Position:", global_position)
	else:
		print("✅ Close enough to target, stopping movement.")

func move_away_from_target(target, delta):
	var direction = (global_position - target.global_position).normalized()
	
	# ✅ Scale movement to be smooth
	var step_size = move_speed * delta * 0.5  # Reduce movement step
	
	if global_position.distance_to(target.global_position) < 500:  # Prevent infinite movement
		global_position += direction * step_size
		print("🚨 Moving away! HR:", current_hr, "Position:", global_position)
	else:
		print("🛑 Too far from target, stopping movement.")


func _draw():
	draw_circle(Vector2.ZERO, 50, Color(0, 0, 1))  # Blue circle
