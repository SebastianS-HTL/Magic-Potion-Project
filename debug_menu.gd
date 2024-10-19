extends Control

@onready var Speed = $Speed
@onready var SpeedMultiplier = $SpeedMultiplier
@onready var ExtraJumpHeight = $ExtraJumpHeight
@onready var NonJumpTimer = $NonJumpTimer
@onready var player = get_parent()

func _process(delta: float) -> void:
	Speed.text = "speed: " + str(player.speed * player.speedMultiplier)
	SpeedMultiplier.text = "speed_multiplier: " + str(player.speedMultiplier)
	ExtraJumpHeight.text = "extra_jump_height: " + str(player.extra_jump_height)
	NonJumpTimer.text = "non_jump_time: " + str(player.non_jump_time_counter)
