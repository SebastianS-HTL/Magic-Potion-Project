extends Sprite2D

var toggle

func _process(delta: float) -> void:
	toggle = get_parent().get_parent().get_parent().get_parent().get_child(2).get_child(2).get_child(9).button_pressed
