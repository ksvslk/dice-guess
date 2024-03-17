extends ColorRect

func _input(event):
	if visible:
		if event is InputEventMouseButton && event.pressed:
			visible = false
		elif event.is_action_pressed("ui_accept"):
			visible = false
