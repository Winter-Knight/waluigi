extends Node

var score


func _ready():
	randomize()


func game_over():
	$ScoreTimer.stop()
	$Mario/Timer.stop()
	$Screens/HUD.update_score(score, $Waluigi.damage, $Waluigi.numShields)
	$Music.stop()
	get_tree().call_group("projectiles", "whack", $Waluigi.position)
	$Waluigi/AnimatedSprite.stop()
	$Mario/AnimatedSprite.stop()
	$Waluigi/EndTimer.start()

func new_game():
	get_tree().call_group("projectiles", "queue_free")
	score = 0
	$Waluigi.start($StartPosition.position)
	$StartTimer.start()
	$Screens/HUD.update_score(score, $Waluigi.damage, $Waluigi.numShields)
	$Screens/HUD.show_message("Get Ready")
	$Screens/HUD/StartButton.hide()
	$Music.play()


func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		new_game()


func _on_ScoreTimer_timeout():
	score += 1
	$Screens/HUD.update_score(score, $Waluigi.damage, $Waluigi.numShields)
	if (score % 21 == 0 && $Waluigi.damage > 0):
		$Waluigi.damage -= 1


func _on_StartTimer_timeout():
	$Mario/Timer.start()
	$Mario.show()
	$ScoreTimer.start()
	$Mario/AnimatedSprite.play()
