extends Camera3D

var shaking = false
var timer = 0 
var intens = 0
var extrafov = 0

func _process(delta: float) -> void:
	set_fov(get_parent().get_parent().get_parent().get_child(2).get_child(2).get_child(4).get_value()+extrafov)
	
	#dash
	if get_parent().get_parent().is_dashing:
		if extrafov <= 5:
			extrafov += 0.5
		else:
			extrafov = 5
	else:
		if extrafov >= 5:
			extrafov -= 0.5
		else:
			extrafov = 0
	
	#screenshake
	if shaking:
		if timer > 0:
			timer -= delta
			
			var rng = RandomNumberGenerator.new()
			var my_random_number1 = rng.randf_range(-intens, intens)
			var my_random_number2 = rng.randf_range(-intens, intens)
			
			set_h_offset(my_random_number1)
			set_v_offset(my_random_number2)
		else:
			set_h_offset(0)
			set_v_offset(0)
	else:
		shaking = false
	
	#sliding
	if get_parent().get_parent().is_sliding:
		set_v_offset(-1.5)
	else:
		if not shaking:
			set_v_offset(0)

func do_screen_shake(time,intensitivity):
	shaking = true
	timer = time
	intens = intensitivity
