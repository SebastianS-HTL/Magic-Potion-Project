extends WorldEnvironment

var slider

func _process(delta):
	slider = get_parent().get_child(2).get_child(2).get_child(7)
	
	get_environment().ambient_light_energy = slider.value
