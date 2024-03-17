extends ColorRect


func _on_Quit_pressed():
	get_tree().quit()


func _input(event):
	if visible:
		if event.is_action_pressed("ui_cancel"):
			visible = false


func _on_BackButton_pressed():
	if visible:
		visible = false

