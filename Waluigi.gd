extends Area2D

signal full_damage

export var speed = 400 # How fast the player will move (pixels/sec).
var damage             # Amount of damage taken
var numShields
var direction = Vector2() # Last facing direction
var WhackZoneDefaultTransform

var ending_animation_playing


func whack():
	# Establish whack zone
#	var angle = acos(Vector2(1, 0).dot(direction))
#	if (direction.y < 0):
#		angle = 2 * PI - angle
	var angle
	if direction.x < 0:
		angle = PI
	else:
		angle = 0
	var Trans = WhackZoneDefaultTransform.rotated(angle)
	$WhackZone.transform = Trans
	$WhackZone.disabled = false

	# Play Audio
	$Whack.play()
	# Play animation
	$AnimatedSprite.animation = "whack"
	$AnimatedSprite.frame = 0
	if (direction.x < 0):
		$AnimatedSprite.flip_h = true
	$AnimatedSprite.play()

	# Start timer
	$WhackTimer.start()


func _ready():
	hide()
	WhackZoneDefaultTransform = $WhackZone.get_transform()


func _process(delta):
	if (!$WhackTimer.is_stopped() || get_node("../ScoreTimer").is_stopped()):
		if ending_animation_playing:
			do_ending_animation_frame(delta)
		return
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_just_pressed("whack"):
		whack()
		return

	if (velocity.length_squared() > 0):
		direction = velocity.normalized()
		velocity = direction * speed
		$AnimatedSprite.play()
		$AnimatedSprite.flip_h = false
	elif ($WhackTimer.is_stopped()):
		$AnimatedSprite.stop()

	position += velocity * delta
	position = $"../Prison".confine_vector(position)

	if velocity.x > 0:
		$AnimatedSprite.animation = "right"
	elif velocity.x < 0:
		$AnimatedSprite.animation = "left"
	elif velocity.y > 0:
		$AnimatedSprite.animation = "down"
	elif velocity.y < 0:
		$AnimatedSprite.animation = "up"


func start(pos):
	position = pos
	damage = 0
	$AnimatedSprite.material.set_shader_param("damage", damage)
	show()
	$CollisionShape2D.disabled = false


func _on_Player_body_entered(_body):
	var is_whacked = false # Determine whether the object is whacked
	if (!$WhackTimer.is_stopped()):
		#mid-whack
		if (Vector2(_body.position - position).dot(direction) > 0):
			is_whacked = true
	
	if (is_whacked):
		_body.whack(position)
	else:
		_body.queue_free()
		damage += 7
		if (damage >= 100):
			emit_signal("full_damage")
		$AnimatedSprite.material.set_shader_param("damage", clamp(damage, 0, 100))
		$GetHit.play()


func _on_WhackTimer_timeout():
	$WhackZone.disabled = true


var goal1
var goal2
var approach
var jumping
var up_force

func setup_ending_animation():
	# Waluigi has taken 100% damage and is now going to escape the prison
	if position.x < 300:
		goal2 = Vector2(-100, position.y)
	else:
		goal2 = Vector2(700, position.y)
	goal1 = $"../Prison".confine_vector(goal2)
	ending_animation_playing = true
	up_force = 0
	jumping = false
	approach = "goal1"
	if (goal2.x < 0):
		$AnimatedSprite.animation = "left"
	else:
		$AnimatedSprite.animation = "right"
	$AnimatedSprite.flip_h = false
	$AnimatedSprite.play()


func do_ending_animation_frame(delta):
	var goal
	if approach == "goal1":
		goal = goal1
	elif approach == "goal2":
		goal = goal2
	
	var velocity = goal - position
	velocity.y = 0
	velocity = velocity.normalized() * delta * speed / 5
	var pos = position + velocity

	if approach == "goal1":
		position = $"../Prison".confine_vector(pos)
		if (pos != position || velocity.x == 0):
			# next to prison wall
			jumping = true
			approach = "goal2"
			up_force = 200
			$AnimatedSprite.animation = "jumping"
			if goal2.x < 0:
				$AnimatedSprite.flip_h = true
			$Jump.play()
	else:
		position = pos
	
	if jumping:
		velocity.x = 0
		velocity.y -= up_force * delta
		up_force -= 300 * delta
		pos = position + velocity
		if pos.y > goal2.y:
			pos.y = goal2.y
			jumping = false
			if goal.x < 0:
				$AnimatedSprite.animation = "left"
			else:
				$AnimatedSprite.animation = "right"
			$AnimatedSprite.flip_h = false
			$Jump.play()
		position = pos

	if ((goal.x < 0 && position.x < goal.x) || (goal.x > 600 && position.x > goal.x)):
		ending_animation_playing = false
		$AnimatedSprite.stop()
		$"../Screens/HUD".show_game_over()


func _on_EndTimer_timeout():
	setup_ending_animation()
