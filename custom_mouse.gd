extends Button

func _ready():
	ControllerIcons.connect("input_type_changed", self, "_on_input_type_changed")

func _on_input_type_changed(input_type):
	if input_type == ControllerIcons.InputType.KEYBOARD_MOUSE:
		show()
	else:
		hide()
