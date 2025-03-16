extends Control

@onready var heart_image = $HeartImage  # Heart image (scales up/down)
@onready var heart_rate_label = $HeartRateLabel  # Heart rate display

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
	if new_bpm == bpm:
		return  # Avoid unnecessary updates

	bpm = new_bpm

	if heart_rate_label:
		heart_rate_label.text = "HR: %d" % bpm
	else:
		print("❌ Error: HeartRateLabel not found!")

	print("💓 Updating BPM:", bpm)  # Debugging

	beat_animation()  # ✅ Make sure this is called!


	beat_animation()  # Make heart beat
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
