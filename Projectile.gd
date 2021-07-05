extends RigidBody2D


var is_whacked = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.playing = true
	var projectileTypes = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = projectileTypes[randi() % projectileTypes.size()]


func whack(fromPosition):
	is_whacked = true
	var direction = position - fromPosition
	linear_velocity = direction.normalized() * 500
	collision_layer = 1 # Remove from second layer
	collision_mask = 1  # Remove from second mask
	$Whacked.play()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_WallTimer_timeout():
	if (!is_whacked):
		collision_layer = 3 # Bounce off of prison walls
		collision_mask = 3  # Bounce off of prison walls
