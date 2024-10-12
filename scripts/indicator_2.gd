extends Sprite2D

var dash_count

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	dash_count = get_parent().get_parent().get_parent().dash_count
	
	if dash_count > 1:
		frame = 0
	else:
		frame = 1
