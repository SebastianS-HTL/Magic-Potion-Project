extends Camera3D

var shaking = false
var timer = 0 
var intens = 0

func _process(delta: float) -> void:
	set_fov(get_parent().get_parent().get_parent().get_child(2).get_child(2).get_child(4).get_value())
	
	if shaking:
		if timer > 0:
			print(timer)
			timer -= delta
			
			var rng = RandomNumberGenerator.new()
			var my_random_number1 = rng.randf_range(-intens, intens)
			var my_random_number2 = rng.randf_range(-intens, intens)
			
			set_h_offset(my_random_number1)
			set_v_offset(my_random_number2)
	else:
		shaking = false
		set_h_offset(0)
		set_v_offset(0)

func do_screen_shake(time,intensitivity):
	print("eeeeee-received")
	shaking = true
	timer = time
	intens = intensitivity
