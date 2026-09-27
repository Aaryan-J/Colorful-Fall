extends Control

@onready var wordLabel: RichTextLabel = $BackgroundCard/WordLabel
@onready var miniProgress: ProgressBar = $BackgroundCard/ProgressBar

@onready var blur: Panel = $"../MapWindow/Blur"

@onready var catnipIndicator: Label = $BackgroundCard/CatnipIndicator

# states for the current typing test
var activeRegionName: String = ""
var currentWord: String = ""
var currentCharIdx: int = 0
var mistakesMade: int = 0

# word arrays for each regions
var wordPools = {
	"forest": [
		"moss", "bark", "twig", "leaf", "fern", "root", "wood", "deer", "owl", "bear",
		"acorn", "maple", "cedar", "birch", "grove", "canopy", "timber", "forage", "rustle", "canopy",
		"thicket", "bramble", "sprout", "foliage", "woodland", "sapling", "mulch", "mossy", "forest", "fungi",
		"russet", "amber", "copper", "chestnut", "hazel", "walnut", "evergreen", "spruce", "willow", "poplar",
		"undergrowth", "wilderness", "mushrooms", "woodpecker", "squirrel", "chipmunk", "hedgehog", "badger", "foxglove", "chrysalis",
		"deciduous", "overstory", "understory", "mycelium", "woodsmoke", "decomposing", "shady", "dense", "overgrown", "untamed"
	],
	"pond": [
		"mist", "fog", "rain", "dew", "pond", "lake", "pier", "dock", "fish", "frog",
		"ripple", "pebble", "breeze", "drizzle", "glassy", "murky", "chill", "still", "shore", "bank",
		"cattail", "lilypad", "lotus", "tadpole", "minnow", "dragonfly", "heron", "mallard", "beaver", "otter",
		"reflection", "shimmer", "glisten", "overcast", "cloudy", "moisture", "vapor", "splash", "current", "stream",
		"waterfront", "watershed", "trickle", "cascade", "downpour", "shallows", "submerged", "aquatic", "reedy", "marshy",
		"weathered", "dampness", "condensation", "evaporation", "rainwater", "raindrop", "puddle", "brook", "creek", "wetlands"
	],
	"pumpkin": [
		"hay", "dirt", "seed", "gourd", "vines", "crop", "farm", "plow", "corn", "crow",
		"pumpkin", "harvest", "squash", "marrow", "hayride", "scarecrow", "wheelbarrow", "tractor", "barnyard", "patch",
		"cinnamon", "nutmeg", "clove", "ginger", "allspice", "baked", "roasting", "toasted", "autumnal", "equinox",
		"sweater", "flannel", "cardigan", "blanket", "slippers", "scarf, mitten", "bonfire", "hearth", "fireplace", "cider",
		"teacup", "steaming", "simmer", "spiced", "festive", "bountiful", "abundance", "solstice", "folklore", "tradition",
		"orchard", "baskets", "crates", "bushel", "windrow", "cornucopia", "homestead", "wholesome", "crunchy", "plentiful"
	]
}


func openTypingSession(regionName: String, currentProg: int, maxProg: int):
	activeRegionName = regionName
	miniProgress.max_value = maxProg
	miniProgress.value = currentProg
	set_process_unhandled_input(true)
	startNewWord()

	blur.visible = true

	# Smoothly slide down into view from y: -200 to y: 0
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 0.0, 0.4)

func startNewWord():
	if not wordPools.has(activeRegionName):
		return

	var pool = wordPools[activeRegionName]
	currentWord = pool.pick_random()
	currentCharIdx = 0
	mistakesMade = 0
	updateWordDisplay()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if not visible or not event.pressed or currentWord == "":
		return

	if event.unicode == 0:
		return

	var typedChar = char(event.unicode).to_lower()
	var targetChar = currentWord[currentCharIdx].to_lower()

	if typedChar == targetChar:
		# --- SUCCESS ---
		currentCharIdx += 1
		updateWordDisplay()

		GameManager.playSFX(GameManager.typeSound)

		# if the whole string is fully typed then complete the word
		if currentCharIdx >= currentWord.length():
			completeWord()
	else:
		# --- TYPO HANDLING ---
		mistakesMade += 1
		GameManager.playSFX(GameManager.wrongLetterSound)

		var maxAllowedMistakes = 1 + GameManager.stubbornKittyLevel

		if mistakesMade < maxAllowedMistakes:
			# Stubborn Kitty Feature: delete last letter, step back 1 index, let them retry
			if currentCharIdx > 0:
				currentCharIdx -= 1

			updateWordDisplay()
		else:
			# Failed completely: lock input and immediately spawn a completely brand new word
			startNewWord()

func updateWordDisplay():
	# correct letter = white, uncompleted letter = gray
	var correctPart = currentWord.substr(0, currentCharIdx)
	var remainingPart = currentWord.substr(currentCharIdx, currentWord.length() - currentCharIdx)

	wordLabel.text = "[center][color=white]" + correctPart + "[/color][color=gray]" + remainingPart + "[/color][/center]"

func completeWord():
	# catnip indicator
	catnipIndicator.text = "+10"

	catnipIndicator.position.y = -20
	catnipIndicator.modulate.a = 1.0

	var indicator_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	indicator_tween.tween_property(catnipIndicator, "position:y", catnipIndicator.position.y - 15, 0.6)
	indicator_tween.tween_property(catnipIndicator, "modulate:a", 0.0, 0.6)

	GameManager.playSFX(GameManager.correctWordSound)

	# calculate productivity modifier scale: 2 -> 4 -> 8 -> 16
	var productivityLevel = 0
	if GameManager.has_meta("productivityLevel"):
		productivityLevel = GameManager.get_meta("productivityLevel")

	var progressGain = 2 * int(pow(2, productivityLevel))

	# give 10 base catnip currency points
	if GameManager.has_method("addCatnip"):
		GameManager.call("addCatnip", 10)

	# pass the progress gain back up to the main map window
	var mapWin = get_node_or_null("../MapWindow")
	if mapWin and mapWin.has_method("advanceRegionProgress"):
		mapWin.call("advanceRegionProgress", activeRegionName, progressGain)

		# sync the small progress bar layout
		miniProgress.value += progressGain

		# if the region hit 100%, close out of this window automatically
		if miniProgress.value >= miniProgress.max_value:
			closeWindow()
			return

	# move to the next string word
	startNewWord()

func closeWindow():
	currentWord = "" # clear typing focus
	set_process_unhandled_input(false)

	blur.visible = false

	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", -200.0, 0.4)


func _on_close_button_pressed() -> void:
	closeWindow()
