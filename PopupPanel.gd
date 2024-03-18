extends ColorRect

func _on_Start_pressed():
	if !Data.get_tutorial_shown():
		Data.set_tutorial_shown()
		get_parent().level_parent.visible = true
	visible = false


func _input(event):
	if visible:
		if event is InputEventMouseButton && event.pressed:
			_on_Start_pressed()
		elif event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_cancel"):
			_on_Start_pressed()
		get_tree().set_input_as_handled()
