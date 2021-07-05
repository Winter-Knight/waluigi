extends Area2D

var direction = 1
export var speed = 0.01
export(PackedScene) var projectile_scene

var mode = "run"
var extra_projectiles = 0


func _ready():
	hide()


func _process(delta):
	if ($Timer.is_stopped() || mode == "throw"):
		return
	if (randi() % 100 == 0):
		direction *= -1
	var marioLocation = $Path/Location
	marioLocation.unit_offset += speed * direction * delta
	position = marioLocation.position
	if marioLocation.unit_offset < 0.25:
		if direction > 0:
			$AnimatedSprite.animation = "right"
			$AnimatedSprite.flip_h = false
		else:
			$AnimatedSprite.animation = "right"
			$AnimatedSprite.flip_h = true
	elif marioLocation.unit_offset < 0.5:
		if direction > 0:
			$AnimatedSprite.animation = "down"
		else:
			$AnimatedSprite.animation = "up"
	elif marioLocation.unit_offset < 0.75:
		if direction > 0:
			$AnimatedSprite.animation = "right"
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.animation = "right"
			$AnimatedSprite.flip_h = false
	else:
		if direction > 0:
			$AnimatedSprite.animation = "up"
		else:
			$AnimatedSprite.animation = "down"


func throw():
	var waluigi = get_node("../Waluigi")
	var pDirection = waluigi.position - (position + $ThrowOrigin.position)
# warning-ignore:integer_division
	var numProjectiles = int(get_node("..").score) / 100 + 1 + extra_projectiles
	
	for _i in range(numProjectiles):
		var projectile = projectile_scene.instance()
		get_node("..").add_child(projectile)
		projectile.position = position + $ThrowOrigin.position
		projectile.linear_velocity = pDirection.normalized() * 200
	
	var x = randi() % 3
	if x == 0:
		$Hoo.play()
	elif x == 1:
		$HooHoo.play()
	else:
		$Waha.play()


func start_throw():
	var waluigi = get_node("../Waluigi")
	var pDirection = waluigi.position - (position + $ThrowOrigin.position)

	$AnimatedSprite.animation = "throw"
	$AnimatedSprite.flip_h = (pDirection.x < 0)
	$ThrowTimer.start()


func _on_MarioTimer_timeout():
	if mode == "run":
		start_throw()
		mode = "throw"
	elif mode == "throw":
		mode = "run"


func _on_ThrowTimer_timeout():
	throw()
