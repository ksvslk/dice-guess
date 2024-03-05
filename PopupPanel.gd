extends ColorRect
onready var start = $Start


func _on_Start_pressed():
	Data.set_tutorial_shown()
	visible = false
