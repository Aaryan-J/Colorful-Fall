extends Control

@onready var catnipLabel: Label = $ShopCard/Catnip/CatnipLabel

# references
@onready var productivityButton: Button = $ShopCard/ProductivityButton
@onready var stubbornButton: Button = $ShopCard/StubbornButton
@onready var cloverButton: Button = $ShopCard/CloverButton

@onready var blur: Panel = $"../MapWindow/Blur"

# price structures
var productivityPrices = [50, 200, 500]
var stubbornPrices = [200, 500]
var cloverPrices = [250, 500]

func _ready() -> void:
	# connect to gamemanager
	if GameManager.has_signal("catnipChanged"):
		GameManager.catnipChanged.connect(onCatnipUpdated)

	updateAllShopUI()

func openShopSession() -> void:
	updateAllShopUI()

	blur.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 0.0, 0.4)

# updates all shop UI elements to reflect the current state
func updateAllShopUI() -> void:
	catnipLabel.text = str(GameManager.catnipBalance)
	updateProdButton()
	updateKittyButton()
	updateCloverButton()

func onCatnipUpdated(newAmount: int) -> void:
	catnipLabel.text = str(newAmount)

# --- productivity button ---
func updateProdButton() -> void:
	var lvl = GameManager.productivityLevel
	if lvl >= 3:
		productivityButton.text = "MAX LEVEL\n(3/3)"
		productivityButton.disabled = true
	else:
		productivityButton.text = str(productivityPrices[lvl]) + " Catnip\n(" + str(lvl) + "/3)"

func _on_productivity_button_pressed() -> void:
	var lvl = GameManager.productivityLevel
	if lvl < 3 and GameManager.catnipBalance >= productivityPrices[lvl]:
		GameManager.catnipBalance -= productivityPrices[lvl]
		GameManager.productivityLevel += 1
		GameManager.catnipChanged.emit(GameManager.catnipBalance)
		updateProdButton()

# --- stubborn kitty button ---
func updateKittyButton() -> void:
	var lvl = GameManager.stubbornKittyLevel
	if lvl >= 2:
		stubbornButton.text = "MAX LEVEL\n(2/2)"
		stubbornButton.disabled = true
	else:
		stubbornButton.text = str(stubbornPrices[lvl]) + " Catnip\n(" + str(lvl) + "/2)"

func _on_stubborn_button_pressed() -> void:
	var lvl = GameManager.stubbornKittyLevel
	if lvl < 2 and GameManager.catnipBalance >= stubbornPrices[lvl]:
		GameManager.catnipBalance -= stubbornPrices[lvl]
		GameManager.stubbornKittyLevel += 1
		GameManager.catnipChanged.emit(GameManager.catnipBalance)
		updateKittyButton()

# --- four leaved clover button ---
func updateCloverButton() -> void:
	var lvl = GameManager.fourLeavedCloverLevel
	if lvl >= 2:
		cloverButton.text = "MAX LEVEL\n(2/2)"
		cloverButton.disabled = true
	else:
		cloverButton.text = str(cloverPrices[lvl]) + " Catnip\n(" + str(lvl) + "/2)"

func _on_clover_button_pressed() -> void:
	var lvl = GameManager.fourLeavedCloverLevel
	if lvl < 2 and GameManager.catnipBalance >= cloverPrices[lvl]:
		GameManager.catnipBalance -= cloverPrices[lvl]
		GameManager.fourLeavedCloverLevel += 1
		GameManager.catnipChanged.emit(GameManager.catnipBalance)
		updateCloverButton()

# close button
func _on_close_button_pressed() -> void:
	blur.visible = false
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", -200.0, 0.4)
