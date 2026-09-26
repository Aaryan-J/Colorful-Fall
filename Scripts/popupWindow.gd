extends Control

@onready var celebrationLabel: Label = $CelebrationLabel

func showCelebration(regionName: String):
	var cleanName = regionName.capitalize()
	celebrationLabel.text = "The " + cleanName + " has regained its color!"
	visible = true

	# tween to fade the text in
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(celebrationLabel, "modulate:a", 1.0, 1.0)
	tween.tween_interval(2.0)
	tween.tween_property(celebrationLabel, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): visible = false)
