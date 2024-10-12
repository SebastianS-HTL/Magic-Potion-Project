extends CharacterBody3D

@onready var navi = $NavigationAgent3D

var SPEED = 30.0

func update_target_location(location):
	navi.set_target_position(location)

var inconpacitated = false #mf i dont even know if this exists
var uppy = 0
var gravity = 9.81

func _physics_process(delta):
	if not inconpacitated:
		update_target_location(get_parent().get_child(0).position)
		
		var current_location = global_transform.origin
		var next_location = navi.get_next_path_position()
		var new_vel = (next_location - current_location).normalized() * SPEED
		
		velocity = new_vel
		
		#velocity.x = 0
		#velocity.z = 0
		
		move_and_slide()
		look_at(get_parent().get_child(0).position)
		rotation.x = 0
		rotation.z = 0
	else:
		velocity = Vector3(0,uppy - gravity,0)
		
		move_and_slide()
		
		uppy /= 1.1
		if uppy < 1:
			uppy = 0
		
		if is_on_floor():
			inconpacitated = false

func got_impacted():
	inconpacitated = true
	uppy = 100
