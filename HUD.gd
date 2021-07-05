extends Control

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()


func show_game_over():
	show_message("Game Over")
	yield($MessageTimer, "timeout")
	yield(get_tree().create_timer(1), "timeout")
	$StartButton.show()
	$MessageLabel.text = "Press F1 for Instructions"
	$MessageLabel.show()


func update_score(score, damage, _numShields):
	$ScoreLabel.text = str("Points: " + str(score) + "\nDamage: " + str(damage) + "%")


func _on_StartButton_pressed():
	if $"../".get_screen() == "none":
		$StartButton.hide()
		$"../../".new_game()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()
