extends Control

var screen = "none"
var mario
var credits_loaded = false
var difficulty_changed = false


func get_screen():
	return screen


func load_credits():
	if (credits_loaded):
		return
	var file = File.new()
	file.open("res://LICENSE", File.READ)
	$Credits/RichTextLabel.text = file.get_as_text()
	file.close()
	credits_loaded = true


func save_settings(var difficulty):
	var file = File.new()
	file.open("user://config", File.WRITE)
	file.store_string("difficulty: " + str(difficulty))
	file.close()
	

func load_settings():
	var file = File.new()
	if (file.file_exists("user://config")):
		file.open("user://config", File.READ)
		while !file.eof_reached():
			var line = file.get_line()
			var words = line.split(" ")
			if words.size() > 0 && words[0] == "difficulty:":
				var difficulty = words[words.size() - 1].to_int()
				$Options/Difficulty/Slider.set_value(difficulty)
		file.close()


# Called when the node enters the scene tree for the first time.
func _ready():
	mario = $"../Mario"
	load_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !$"../ScoreTimer".is_stopped():
		return
	if Input.is_action_just_pressed("help"):
		$Help.show()
		$Options.hide()
		$Credits.hide()
		screen = "help"
	elif Input.is_action_just_pressed("options"):
		$Options.show()
		$Help.hide()
		$Credits.hide()
		screen = "options"
	elif Input.is_action_just_pressed("credits"):
		$Credits.show()
		$Help.hide()
		$Options.hide()
		screen = "credits"
		load_credits()
	elif Input.is_action_just_pressed("ui_cancel"):
		$Help.hide()
		$Options.hide()
		$Credits.hide()
		screen = "none"
		if (difficulty_changed):
			save_settings($Options/Difficulty/Slider.get_value())
			difficulty_changed = false


func _on_Slider_value_changed(value):
	var difficulty = value
	var collShape = $"../Waluigi/WhackZone"
	var shape = collShape.get_shape()
	var marioTimer = $"../Mario/Timer"
	var difficultyLabel = $HUD/DifficultyLabel
	var trans = $"../Waluigi".WhackZoneDefaultTransform
	difficulty_changed = true

	if difficulty == 0:
		shape.radius = 33
		shape.height = 83
		trans.origin = Vector2(50, 0)
		marioTimer.set_wait_time(1)
		mario.extra_projectiles = 0
		difficultyLabel.text = "Easy"
	elif difficulty == 1:
		shape.radius = 33
		shape.height = 83
		trans.origin = Vector2(50, 0)
		marioTimer.set_wait_time(0.5)
		mario.extra_projectiles = 0
		difficultyLabel.text = "Normal"
	elif difficulty == 2:
		shape.radius = 20
		shape.height = 83
		trans.origin = Vector2(37, 0)
		marioTimer.set_wait_time(0.4)
		mario.extra_projectiles = 0
		difficultyLabel.text = "Hard"
	elif difficulty == 3:
		shape.radius = 10
		shape.height = 100
		trans.origin = Vector2(27, 0)
		marioTimer.set_wait_time(0.3)
		mario.extra_projectiles = 1
		difficultyLabel.text = "Insane!!"
	$"../Waluigi".WhackZoneDefaultTransform = trans
