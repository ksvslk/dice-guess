extends ColorRect

func _on_Start_pressed():
	Data.set_tutorial_shown()
	visible = false


func _on_ContinueButton_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			_on_Start_pressed()
	if event.is_action_pressed("ui_accept"):
		_on_Start_pressed()
