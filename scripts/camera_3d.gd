extends Camera3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_fov(get_parent().get_parent().get_parent().get_child(2).get_child(2).get_child(4).get_value())
