extends PopupDialog


func _on_WinDialog_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			hide()
	elif event.is_action_pressed("ui_accept"):
		hide()
