extends Control

# references
@onready var forestButton: TextureButton = $Forest
@onready var pondButton: TextureButton = $Pond
@onready var pumpkinButton: TextureButton = $PumpkinPatch

@onready var forestProgress: ProgressBar = $Forest/ProgressBar
@onready var pondProgress: ProgressBar = $Pond/ProgressBar
@onready var pumpkinProgress: ProgressBar = $PumpkinPatch/ProgressBar

# tracking states
var regionCompletion = {
	"canopy": {"current": 0, "max": 40, "completed": false, "button": null, "progress": null},
	"lake": {"current": 0, "max": 60, "completed": false, "button": null, "progress": null},
	"pumpkin": {"current": 0, "max": 100, "completed": false, "button": null, "progress": null}
}

func _ready() -> void:
	# link code directory to nodes
	regionCompletion["canopy"]["button"] = forestButton
	regionCompletion["canopy"]["progress"] = forestProgress

	regionCompletion["lake"]["button"] = pondButton
	regionCompletion["lake"]["progress"] = pondProgress

	regionCompletion["pumpkin"]["button"] = pumpkinButton
	regionCompletion["pumpkin"]["progress"] = pumpkinProgress

	# set max requirements on progress bars
	for regionName in regionCompletion:
		var region = regionCompletion[regionName]
		region["progress"].max_value = region["max"]
		region["progress"].value = 0

# add progression points
func advance_region_progress(regionName: String, amount: int) -> void:
	if not regionCompletion.has(regionName) or regionCompletion[regionName]["completed"]:
		return

	var region = regionCompletion[regionName]
	region["current"] = clampi(region["current"] + amount, 0, region["max"])
	region["progress"].value = region["current"]

	# check if region has reached 100% color restoration
	if region["current"] >= region["max"]:
		restore_region_color(regionName)

# restore region color
func restore_region_color(regionName: String) -> void:
	var region = regionCompletion[regionName]
	region["completed"] = true
	region["button"].disabled = true # lock the button so they can't click it again

	# smoothly fade self modulate from grey back to white over 1.5 seconds
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(region["button"], "self_modulate", Color(1, 1, 1, 1), 1.5)

	print(regionName, " is fully restored to autumn colors!")


func _on_forest_pressed() -> void:
	print_debug("Pressed Forest button")

func _on_shop_pressed() -> void:
	print_debug("Pressed Shop button")

func _on_pumpkin_patch_pressed() -> void:
	print_debug("Pressed Pumpkin Patch button")

func _on_pond_pressed() -> void:
	print_debug("Pressed Pond button")
