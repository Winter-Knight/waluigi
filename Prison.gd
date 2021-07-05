extends Sprite

export var pos = Vector2(100,100)
export var dimensions = Vector2(400,400)
export var buffer = Vector2(25,50)


func confine_vector(vec):
	# It appears that clamp does not work with Vectors at this time :(
	var x = clamp(vec.x, pos.x + buffer.x, pos.x + dimensions.x - buffer.x)
	var y = clamp(vec.y, pos.y + buffer.y, pos.y + dimensions.y - buffer.y)
	return Vector2(x, y)
