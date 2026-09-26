extends Control

@onready var wordLabel: RichTextLabel = $BackgroundCard/WordLabel
@onready var miniProgress: ProgressBar = $BackgroundCard/ProgressBar

# states for the current typing test
var activeRegionName: String = ""
var currentWord: String = ""
var currentCharIdx: int = 0
var mistakesMade: int = 0

# word arrays for each regions
var wordPools = {
	"forest": ["maple", "acorn", "leaves", "branches", "russet", "mulch", "mossy", "forest"],
	"pond": ["ripple", "pebble", "reflection", "breeze", "mist", "drizzle", "pond", "glassy"],
	"pumpkin": ["pumpkin", "harvest", "gourd", "squash", "scarecrow", "hayride", "marrow"]
}

func openTypingSession(regionName: String, currentProg: int, maxProg: int):
	activeRegionName = regionName

	# update progress bar to match the region's current health
	miniProgress.max_value = maxProg
	miniProgress.value = currentProg

	startNewWord()

func startNewWord():
	if not wordPools.has(activeRegionName):
		return

	var pool = wordPools[activeRegionName]
	currentWord = pool.pick_random()
	currentCharIdx = 0
	mistakesMade = 0
	updateWordDisplay()

func _unhandled_input(event: InputEvent) -> void:
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

		# if the whole string is fully typed then complete the word
		if currentCharIdx >= currentWord.length():
			completeWord()
	else:
		# --- TYPO HANDLING ---
		mistakesMade += 1

		# pull current upgrade values from the central game controller
		var stubbornKittyLevel = 0
		if GameManager.has_meta("stubbornKittyLevel"):
			stubbornKittyLevel = GameManager.get_meta("stubbornKittyLevel")

		var maxAllowedMistakes = 1 + stubbornKittyLevel

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
	visible = false


func _on_close_button_pressed() -> void:
	closeWindow()
