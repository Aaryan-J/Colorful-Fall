extends Control

# references
@onready var typingWindow: Control = $"../TypingWindow"

@onready var forestButton: TextureButton = $Forest
@onready var pondButton: TextureButton = $Pond
@onready var pumpkinButton: TextureButton = $PumpkinPatch

@onready var forestProgress: ProgressBar = $Forest/ProgressBar
@onready var pondProgress: ProgressBar = $Pond/ProgressBar
@onready var pumpkinProgress: ProgressBar = $PumpkinPatch/ProgressBar

# tracking states
var regionCompletion = {
	"forest": {"current": 0, "max": 40, "completed": false, "button": null, "progress": null},
	"pond": {"current": 0, "max": 60, "completed": false, "button": null, "progress": null},
	"pumpkin": {"current": 0, "max": 100, "completed": false, "button": null, "progress": null}
}

func _ready() -> void:
	# link code directory to nodes
	regionCompletion["forest"]["button"] = forestButton
	regionCompletion["forest"]["progress"] = forestProgress

	regionCompletion["pond"]["button"] = pondButton
	regionCompletion["pond"]["progress"] = pondProgress

	regionCompletion["pumpkin"]["button"] = pumpkinButton
	regionCompletion["pumpkin"]["progress"] = pumpkinProgress

	# set max requirements on progress bars
	for regionName in regionCompletion:
		var region = regionCompletion[regionName]
		region["progress"].max_value = region["max"]
		region["progress"].value = 0

# add progression points
func advanceRegionProgress(regionName: String, amount: int) -> void:
	if not regionCompletion.has(regionName) or regionCompletion[regionName]["completed"]:
		return

	var region = regionCompletion[regionName]
	region["current"] = clampi(region["current"] + amount, 0, region["max"])
	region["progress"].value = region["current"]

	# check if region has reached 100% color restoration
	if region["current"] >= region["max"]:
		restoreRegionColor(regionName)

# restore region color
func restoreRegionColor(regionName: String) -> void:
	var region = regionCompletion[regionName]
	region["completed"] = true
	region["button"].disabled = true # lock the button so they can't click it again

	# smoothly fade self modulate from grey back to white over 1.5 seconds
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(region["button"], "self_modulate", Color(1, 1, 1, 1), 1.5)

	print(regionName, " is fully restored to autumn colors!")


func _on_forest_pressed() -> void:
	var data = regionCompletion["forest"]
	if not data["completed"]:
		typingWindow.visible = true # Temporary toggle until we add sliding
		typingWindow.openTypingSession("forest", data["current"], data["max"])

func _on_shop_pressed() -> void:
	var shopWindow = get_node_or_null("../ShopWindow")
	if shopWindow:
		shopWindow.visible = true
		if shopWindow.has_method("updateAllShopUI"):
			shopWindow.updateAllShopUI()

func _on_pumpkin_patch_pressed() -> void:
	var data = regionCompletion["pumpkin"]
	if not data["completed"]:
		typingWindow.visible = true
		typingWindow.openTypingSession("pumpkin", data["current"], data["max"])

func _on_pond_pressed() -> void:
	var data = regionCompletion["pond"]
	if not data["completed"]:
		typingWindow.visible = true
		typingWindow.openTypingSession("pond", data["current"], data["max"])
