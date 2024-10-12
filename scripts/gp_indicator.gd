extends Sprite2D
#
#var GP
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#GP = get_parent().get_parent().get_parent().can_ground_pound_impact()
	#
	#if GP:
		#frame = 0
	#else:
		#frame = 1
