extends CharacterBody3D

@onready var navi = $NavigationAgent3D

var SPEED = 30.0

func update_target_location(location):
	navi.set_target_position(location)

var inconpacitated = false #mf i dont even know if this exists
var uppy = 0
var gravity = 9.81
var was_not_on_ground = false
var player

func _ready() -> void:
	set_second_collision_mask(true)

func _physics_process(delta):
	player = get_parent().get_child(0)
	if player.is_ground_pounding and player.can_ground_pound_impact():
		set_second_collision_mask(false)
	
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
		
		uppy /= 1.05
		if uppy < 1:
			uppy = 0
		
		if is_on_floor():
			set_second_collision_mask(true)
			inconpacitated = false

func got_impacted():
	inconpacitated = true
	print("ee")
	uppy = 70

func set_second_collision_mask(enabled: bool):
	var mask = collision_mask
	var bit_position = 1	# The second bit is at position 1 (0-indexed)
	if enabled:
		collision_mask = mask | (1 << bit_position)
	else:
		collision_mask = mask & ~(1 << bit_position)
