extends Control

# kitty stuff
@export var awakeKittyTexture: Texture2D
@export var sleepingKittyTexture: Texture2D

@onready var catDisplayNode: TextureRect = $SleepingCat
@onready var dialogueLabel: Label = $"../DialogueLabel"
@onready var endWindow: Control = $"../EndWindow"
@onready var fadeOverlay: ColorRect = $"../EndWindow/FadeOverlay"
@onready var endLabel: Label = $"../EndWindow/EndLabel"

var dialogueTween: Tween

# references
@onready var typingWindow: Control = $"../TypingWindow"
@onready var popupWindow: Control = $"../PopUpWindow"

@onready var forestButton: TextureButton = $Forest
@onready var pondButton: TextureButton = $Pond
@onready var pumpkinButton: TextureButton = $PumpkinPatch

@onready var forestProgress: ProgressBar = $Forest/ProgressBar
@onready var pondProgress: ProgressBar = $Pond/ProgressBar
@onready var pumpkinProgress: ProgressBar = $PumpkinPatch/ProgressBar

@onready var menuTL: TextureRect = $"../MainMenu/TopLeft"
@onready var menuTR: TextureRect = $"../MainMenu/TopRight"
@onready var menuBL: TextureRect = $"../MainMenu/BottomLeft"
@onready var menuBR: TextureRect = $"../MainMenu/BottomRight"
@onready var menu: Control = $"../MainMenu"


# tracking states
var regionCompletion = {
	"forest": {"current": 0, "max": 10, "completed": false, "button": null, "progress": null}, #120
	"pond": {"current": 0, "max": 10, "completed": false, "button": null, "progress": null}, #200
	"pumpkin": {"current": 0, "max": 10, "completed": false, "button": null, "progress": null} #400
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

	popupWindow.showCelebration(regionName)
	print(regionName, " is fully restored to autumn colors!")

	checkWinCondition()

func checkWinCondition() -> void:
	var totalCompleted = 0
	for regionName in regionCompletion:
		if regionCompletion[regionName]["completed"]:
			totalCompleted += 1
	if totalCompleted >= 3:
		GameManager.currentStoryState = 2
		showTemporaryDialogue("Mrow? The world is nice again! Time for a nap... (Click me!)", false)

func _on_cat_interaction_button_pressed() -> void:
	match GameManager.currentStoryState:
		0:
			GameManager.currentStoryState = 1
			if awakeKittyTexture:
				catDisplayNode.texture = awakeKittyTexture
			animateMenuReveal()
			showTemporaryDialogue("The color is washed out from everything... Let's fix it!", true)

		1:
			showTemporaryDialogue("Keep trying! Let's bring all the color back!", true)
		2:
			triggerFinalNapCutscene()

func showTemporaryDialogue(text: String, shouldFade: bool) -> void:
	if dialogueTween and dialogueTween.is_valid():
		dialogueTween.kill()

	dialogueLabel.text = text
	dialogueLabel.modulate.a = 1.0

	if shouldFade:
		dialogueTween = create_tween()
		dialogueTween.tween_interval(2.0)
		dialogueTween.tween_property(dialogueLabel, "modulate:a", 0.0, 1.0)
		dialogueTween.tween_callback(func(): dialogueLabel.text = "")

func triggerFinalNapCutscene() -> void:
	dialogueLabel.text = ""

	if sleepingKittyTexture:
		catDisplayNode.texture = sleepingKittyTexture

	endWindow.visible = true
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE # Freeze map clicks

	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	# Fade screen to black over 2 seconds
	tween.tween_property(fadeOverlay, "modulate:a", 1.0, 2.0)
	tween.tween_interval(1.0)

	# Fade in the cozy ending credits text over 1.5 seconds
	tween.tween_property(endLabel, "modulate:a", 1.0, 1.5)

func _on_forest_pressed() -> void:
	var data = regionCompletion["forest"]
	if not data["completed"]:
		typingWindow.visible = true # Temporary toggle until we add sliding
		typingWindow.openTypingSession("forest", data["current"], data["max"])

func _on_pond_pressed() -> void:
	var data = regionCompletion["pond"]
	if not data["completed"]:
		typingWindow.visible = true
		typingWindow.openTypingSession("pond", data["current"], data["max"])

func _on_pumpkin_patch_pressed() -> void:
	var data = regionCompletion["pumpkin"]
	if not data["completed"]:
		typingWindow.visible = true
		typingWindow.openTypingSession("pumpkin", data["current"], data["max"])

func _on_shop_pressed() -> void:
	var shopWindow = get_node_or_null("../ShopWindow")
	if shopWindow:
		shopWindow.visible = true
		if shopWindow.has_method("updateAllShopUI"):
			shopWindow.openShopSession()


func animateMenuReveal():
	var slideTime = 0.6
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(menuTL, "position", Vector2(-160, -90), slideTime)
	tween.tween_property(menuTR, "position", Vector2(320, -90), slideTime)
	tween.tween_property(menuBL, "position", Vector2(-160, 180), slideTime)
	tween.tween_property(menuBR, "position", Vector2(320, 180), slideTime)

	var master_tween = create_tween()
	master_tween.tween_interval(slideTime)
	master_tween.tween_callback(func(): menu.queue_free())
