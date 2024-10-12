extends MeshInstance3D

var toggle = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug-third-person"):
		toggle = not toggle
	
	if toggle:
		show()
		get_parent().get_child(2).get_child(0).position = Vector3(0,3.44,4.462)
	else:
		hide()
		get_parent().get_child(2).get_child(0).position = Vector3(0,1.17,0.055)
