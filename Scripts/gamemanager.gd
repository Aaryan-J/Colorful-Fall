extends Node

var currentStoryState: int = 0 # 0 = sleeping, 1 = awake, 2 = ending

var catnipBalance: int = 0

# audio
@export var bgMusic: AudioStream
@export var typeSound: AudioStream
@export var wrongLetterSound: AudioStream
@export var correctWordSound: AudioStream

var bgMusicPlayer: AudioStreamPlayer
var sfxPlayer: AudioStreamPlayer

# upgrade Levels (0 = Base level)
var productivityLevel: int = 0
var stubbornKittyLevel: int = 0
var fourLeavedCloverLevel: int = 0

signal catnipChanged(new_amount: int)


# passive clover income handler
func _ready() -> void:
	bgMusicPlayer = AudioStreamPlayer.new()
	add_child(bgMusicPlayer)
	if bgMusic:
		bgMusicPlayer.stream = bgMusic
		bgMusicPlayer.autoplay = false
		bgMusicPlayer.process_mode = ProcessMode.PROCESS_MODE_ALWAYS
		bgMusicPlayer.volume_db = -15.0
		bgMusicPlayer.play()

	sfxPlayer = AudioStreamPlayer.new()
	add_child(sfxPlayer)

	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_onCloverTick)
	add_child(timer)

func playSFX(sound: AudioStream) -> void:
	if sound and sfxPlayer:
		sfxPlayer.stream = sound
		sfxPlayer.play()

func addCatnip(amount: int) -> void:
	catnipBalance += amount
	catnipChanged.emit(catnipBalance)
	print("Catnip balance updated: ", catnipBalance)

func _onCloverTick() -> void:
	if fourLeavedCloverLevel == 1:
		addCatnip(1)
	elif fourLeavedCloverLevel == 2:
		addCatnip(3)
