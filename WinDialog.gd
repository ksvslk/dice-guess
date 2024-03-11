extends PopupDialog


func _input(event):
	if visible:
		if event is InputEventMouseButton && event.pressed:
			hide()
		elif event.is_action_pressed("ui_accept"):
			hide()
