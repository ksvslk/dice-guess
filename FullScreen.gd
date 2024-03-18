extends Button

func _ready():
	_set_text_and_icons()
	OS.set_window_fullscreen(Data.get_fullscreen() == 1)

func _on_FullScreen_toggled(button_pressed):
	OS.set_window_fullscreen(!OS.window_fullscreen)
	if OS.window_fullscreen:
		Data.set_fullscreen(1)
	else:
		Data.set_fullscreen(0)
	_set_text_and_icons()


func _set_text_and_icons():
	if Data.get_fullscreen() == 1:
		icon = load("res://icons/window.png")
		text = tr("windowed")
		print("Is fullscreen mode")
	else:
		icon = load("res://icons/fullscreen.png")
		text = tr("fullscreen")
		print("Is windowed mode")
