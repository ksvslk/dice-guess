extends Button

func _ready():
	_set_text_and_icons()
	

func _on_FullScreen_toggled(button_pressed):
	OS.set_window_fullscreen(!OS.window_fullscreen)
	_set_text_and_icons()


func _set_text_and_icons():
	if OS.window_fullscreen:
		icon = load("res://icons/window.png")
		text = "Windowed mode"
		print("Is fullscreen mode")
	else:
		icon = load("res://icons/fullscreen.png")
		text = "Fullscreen mode"
		print("Is windowed mode")
