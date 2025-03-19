extends Control

@onready var heart_image = $HeartImage  # Heart image (scales up/down)
@onready var heart_rate_label = $HeartRateLabel  # Heart rate display
@onready var heart_rate_label2 = $HeartRateLabel2  # Heart rate display
var bpm_values = []  # Stores all BPM values
var min_bpm = INF  
var max_bpm = -INF  
var normal_range = []  # Store user’s normal BPM range  
# Initially set to negative infinity (lowest possible value)
	


var bpm = 60  # Default BPM
var last_bpm = -1  # Track last BPM to prevent redundant updates

func _ready():

	print("✅ TopBar Ready!")  
	if not heart_rate_label:
		print("❌ Error: HeartRateLabel is NULL! Check if it exists in the scene.")
	if not heart_image:
		print("❌ Error: HeartImage is NULL! Check if it exists in the scene.")
	print("✅ TopBar Ready! Testing heartbeat...")
	beat_animation()  # ✅ Manually force first beat for testing

func update_bpm(new_bpm):
	print("💓 Updating BPM:", new_bpm)  # Debugging

	# ✅ Add new BPM to the list
	bpm_values.append(new_bpm)
	var avg_bpm = bpm_values.reduce(func(a, b): return a + b) / bpm_values.size()

	var stateofmind = "Normal"  # ✅ Default value

	if bpm_values.size() > 10:  # Only learn after 10 BPM readings
		normal_range = bpm_values.slice(-10, bpm_values.size())  # Take last 10 readings
		normal_range.sort()  # Sort to find thresholds
		var lower_bound = normal_range[1]  # 10% percentile
		var upper_bound = normal_range[-2]  # 90% percentile

		# ✅ Determine State of Mind
		if new_bpm < lower_bound:
			stateofmind = "User is VERY RELAXED 🟢"
		elif new_bpm > upper_bound:
			stateofmind = "User is STRESSED 🔴"

	# ✅ Check if this is the new smallest BPM
	if bpm_values.size() == 1 or new_bpm < min_bpm:
		min_bpm = new_bpm  

	# ✅ Check if this is the new largest BPM
	if bpm_values.size() == 1 or new_bpm > max_bpm:
		max_bpm = new_bpm  

	# ✅ Update labels
	if heart_rate_label:
		heart_rate_label.text = "HR: %d" % new_bpm  
	else:
		print("❌ Error: HeartRateLabel not found!")

	if heart_rate_label2:  
		heart_rate_label2.text = "AVG BPM: %.1f | MIN BPM: %d | MAX BPM: %d | STATEOFMIND: %s" % [avg_bpm, min_bpm, max_bpm, stateofmind]  # ✅ Use `%s` for string

		print("💓 New BPM:", new_bpm, "| 📊 AVG BPM:", avg_bpm, "| 🔽 MIN BPM:", min_bpm, "| 🔼 MAX BPM:", max_bpm, "| 🧠 StateOfMind:", stateofmind)  # ✅ Debug print  
	else:
		print("❌ Error: HeartRateLabel2 not found!")

	beat_animation()  # ✅ Ensure heartbeat animation is triggered



func beat_animation():
	if not heart_image:
		print("❌ Error: HeartImage not found!")
		return

	print("💓 Heartbeat animation triggered! BPM:", bpm)  # Debugging

	var beat_speed = 60.0 / bpm  # Faster BPM = Faster beats

	# Reset heart size before animation
	heart_image.set_scale(Vector2(1, 1))

	var tween = create_tween()
	tween.set_loops()

	tween.tween_property(heart_image, "scale", Vector2(1.2, 1.2), beat_speed * 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(heart_image, "scale", Vector2(1, 1), beat_speed * 0.2).set_delay(beat_speed * 0.2)
