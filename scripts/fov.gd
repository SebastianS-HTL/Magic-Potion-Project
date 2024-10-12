extends Label

var slider

func _ready() -> void:
	slider = get_parent().get_child(4)

func _process(delta: float) -> void:
	var texty = str(slider.get_value())
	set_text(texty)
