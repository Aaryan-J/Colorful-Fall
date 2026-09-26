extends Node

var catnipBalance: int = 0

# upgrade Levels (0 = Base level)
var productivityLevel: int = 0
var stubbornKittyLevel: int = 0
var fourLeavedCloverLevel: int = 0

signal catnipChanged(new_amount: int)

func addCatnip(amount: int) -> void:
	catnipBalance += amount
	catnipChanged.emit(catnipBalance)
	print("Catnip balance updated: ", catnipBalance)

# passive clover income handler
func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_onCloverTick)
	add_child(timer)

func _onCloverTick() -> void:
	if fourLeavedCloverLevel == 1:
		addCatnip(2)
	elif fourLeavedCloverLevel == 2:
		addCatnip(5)
