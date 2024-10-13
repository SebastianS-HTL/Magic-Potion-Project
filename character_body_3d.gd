extends CharacterBody3D

var speed = 15.0

var mouse_sensitivity

@export var gravity = 9.8
@export var jump_force = 10
@export var sensitivity_multiplier = 1.0  # Sensitivity multiplier variable

@export var max_jumps = 1  # Maximum number of jumps allowed (double jump in this case)
@export var ground_pound_force = -100.0  # Ground pound force when in the air

var camera
var head
var is_paused = false

var slide_direction: Vector3 = Vector3.ZERO
var dash_direction: Vector3 = Vector3.ZERO
var jump_count = 0  # Track the number of jumps

var is_dashing = false
var dash_duration = 0.2  # Duration of the dash in seconds
var dash_speed = 40.0
var dash_timer = 0.0
var dash_count = 2  # Number of dashes allowed
var dash_reload_time = 1  # Time to reload one dash
var dash_reload_timer = 0.0  # Timer for reloading dashes

var is_sliding = false  # Flag to check if sliding is active
var slide_disabled = false  # Flag to check if sliding is disabled after a jump
var slide_speed = 20.0  # Speed during slide

var is_ground_pounding = false  # Flag to track if ground pound is active

var original_camera_y = 0.0  # Store original camera position

#Ground Pounds
var height_before_GP = 0.0
var GP_impact_min_height = 6
var extra_jump_height = 0
var extra_jump_height_increase = 3

# Reference to the PauseMenu node
var pause_menu = null

# Multiplier for temporary speed ups
var speedMultiplier = 1

#sounds
var slide
var jump
var gp_start
var gp_impact
var dash

var jump_decrease_counter = 0
var max_non_jump_time = 1

func _ready():
	slide = $slide
	jump = $jump
	gp_start = $gp_start
	gp_impact = $gp_impact
	dash = $dash
	
	head = get_child(2)
	camera = get_child(2).get_child(0)
	
	# Store the original camera position
	original_camera_y = camera.position.y
	
	# Get reference to the PauseMenu in the same scene
	pause_menu = get_parent().get_child(2)
	
	# Hide the pause menu initially
	pause_menu.visible = false
	
	# Capture the mouse cursor initially
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  

func _input(event):
	mouse_sensitivity = get_parent().get_child(2).get_child(2).get_child(1).get_value() * 4 / 1000
	
	if event is InputEventMouseMotion and not is_paused:
		rotate_y(-event.relative.x * mouse_sensitivity * sensitivity_multiplier)
		head.rotate_x(-event.relative.y * mouse_sensitivity * sensitivity_multiplier)
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 90)

	# Toggle pause with the "pause" action (assign this action in Project Settings -> Input Map)
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func _process(delta):
	if is_on_floor():
		jump_decrease_counter += delta
	
	if jump_decrease_counter > max_non_jump_time:
		extra_jump_height = 0
	
	print(extra_jump_height)
	
	if is_paused:
		return  # Stop movement and input processing when paused
	
	var input_direction = Vector3.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	input_direction = input_direction.normalized()
	
	var direction = (global_transform.basis * input_direction).normalized()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Double jump implementation
	if Input.is_action_just_pressed("jump") and (is_on_floor() or jump_count < max_jumps):
		jump_decrease_counter = 0
		jump.play()
		velocity.y = jump_force + extra_jump_height
		jump_count += 1  # Increase the jump count whenever a jump is performed

		# Stop sliding when jumping
		if is_sliding:
			stop_slide()
			speedMultiplier += 0.4 #increment speed if slide canceling
			slide_disabled = true  # Disable sliding until Ctrl is released and pressed again

		# Stop ground pound when jumping
		if is_ground_pounding:
			stop_ground_pound()

	# Reset jump count when on the floor
	if is_on_floor():
		jump_count = 0
		if is_ground_pounding and height_before_GP - position.y > GP_impact_min_height:
			impact()
		is_ground_pounding = false  # Reset ground pound when on the floor

	# Dash mechanic with limited dashes and reloading
	if Input.is_action_just_pressed("shift") and not is_dashing and not is_sliding and dash_count > 0:
		start_dash(direction)
		dash_count -= 1  # Decrement available dashes

	# Handle dash timer and dash reload
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			stop_dash()
	if dash_count < 2:
		dash_reload_timer += delta
		if dash_reload_timer >= dash_reload_time:
			dash_reload_timer = 0
			dash_count += 1  # Increment available dashes

	# Ground pound mechanic (only when in air)
	if not is_on_floor() and Input.is_action_just_pressed("ctrl") and not is_ground_pounding:
		start_ground_pound()
	
	# Slide mechanic (only when on ground and moving)
	if is_on_floor() and Input.is_action_pressed("ctrl") and not is_sliding and not is_dashing and not slide_disabled and direction != Vector3.ZERO:
		start_slide(direction * 0.7)
	elif is_on_floor() and not Input.is_action_pressed("ctrl") and is_sliding:
		stop_slide()
	elif not Input.is_action_pressed("ctrl") and slide_disabled:
		slide_disabled = false  # Re-enable sliding when Ctrl is released

	# Apply movement speed based on state
	if is_sliding:
		velocity.x = slide_direction.x * slide_speed
		velocity.z = slide_direction.z * slide_speed
	elif is_dashing:
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
	else:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	# Apply ground pound force
	if is_ground_pounding:
		velocity.y = ground_pound_force

	# Camera sideways rotation while moving
	var sidelean = 0.06
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		if camera.rotation.z < sidelean:
			camera.rotation.z += 0.01
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		if camera.rotation.z > -1 * sidelean:
			camera.rotation.z -= 0.01
	elif not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right") and camera.rotation.z < 0.01 and camera.rotation.z > -0.01:
		camera.rotation.z = 0
	elif Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right") and camera.rotation.z < 0.01 and camera.rotation.z > -0.01:
		camera.rotation.z = 0
	elif (Input.is_action_pressed("move_right") and Input.is_action_pressed("move_left")) or (not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left") and camera.rotation.z != 0):
		if camera.rotation.z < 0:
			camera.rotation.z += 0.01
		else:
			camera.rotation.z -= 0.01
	
	velocity.x *= speedMultiplier
	velocity.z *= speedMultiplier
	move_and_slide()
	
	if is_on_floor() and speedMultiplier > 1:
		speedMultiplier -= 0.02
		
		if velocity == Vector3.ZERO:
			speedMultiplier -= 0.02
		
		if speedMultiplier < 1:
			speedMultiplier = 1

# Function to check if the distance to the ground is greater than the impact limit
func can_ground_pound_impact() -> bool:
	var ray_length = 100000

	# Create a temporary RayCast3D node
	var raycast = RayCast3D.new()
	raycast.enabled = true
	raycast.target_position = Vector3(0, -ray_length, 0)  # Set the target position downwards
	raycast.collide_with_areas = false  # Ignore areas, only collide with bodies
	raycast.collide_with_bodies = true

	# Add the raycast node to the character temporarily
	add_child(raycast)
	raycast.force_raycast_update()  # Force the raycast to update immediately

	# Calculate distance to ground and check against GP_impact_min_height
	var can_impact = false
	if raycast.is_colliding():
		var distance_to_ground = raycast.get_collision_point().distance_to(global_transform.origin)
		can_impact = distance_to_ground >= GP_impact_min_height+1.1

	# Remove the temporary raycast node
	remove_child(raycast)
	raycast.queue_free()  # Free the raycast from memory

	return can_impact


#when a gp is high anof (bro dont judge me)
func impact():
	extra_jump_height += extra_jump_height_increase
	#print("n-word goes boom")
	
	var gp_impact_area = get_child(3)  # assume the Area3D node is a child of the player
	
	for body in gp_impact_area.get_overlapping_bodies():
		if body is CharacterBody3D:
			body.got_impacted()
	
	gp_impact.play()

# Start sliding
func start_slide(direction: Vector3):
	slide.play()
	is_sliding = true
	slide_direction = direction

	# Lower the camera position
	camera.v_offset = -1

func stop_slide():
	is_sliding = false
	slide_direction = Vector3.ZERO

	# Reset camera position
	camera.v_offset = 0

# Start dashing
func start_dash(direction: Vector3):
	dash.play()
	is_dashing = true
	dash_direction = direction
	dash_timer = dash_duration

# Stop dashing
func stop_dash():
	is_dashing = false
	dash_direction = Vector3.ZERO

# Start ground pound
func start_ground_pound():
	height_before_GP = position.y
	gp_start.play()
	is_ground_pounding = true

# Stop ground pound
func stop_ground_pound():
	is_ground_pounding = false

# Function to toggle pause and resume
func toggle_pause():
	is_paused = not is_paused
	get_tree().paused = is_paused

	# Show or hide the pause menu based on the pause state
	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Show the mouse when paused
		pause_menu.visible = true  # Show the pause menu
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Capture the mouse when resuming
		pause_menu.visible = false  # Hide the pause menu

# Update sensitivity when slider value changes
func _on_sensitivity_slider_value_changed(value):
	sensitivity_multiplier = value

func _on_button_pressed():
	print("Return to menu button pressed.")

func death():
	#placeholder
	position = Vector3(0,-45.436,-101.163)

func _on_deathborders_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	death()
