extends ColorRect
onready var start = $Start

func _ready():
	margin_bottom -= C.get_bottom_safe_margin()
	margin_top += C.get_top_safe_margin()
	if Data.get_tutorial_shown() == 0:
		visible = true
	else:
		start.text = "CONTINUE"

	
func _on_Start_pressed():
	Data.set_tutorial_shown()
	visible = false
