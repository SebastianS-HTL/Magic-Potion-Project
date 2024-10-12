extends Control

var toggl = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and toggl:
		toggl = false
		get_parent().get_child(0).toggle_pause()
	
	if is_visible():
		toggl = true
