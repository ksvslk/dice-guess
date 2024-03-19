extends HSlider

onready var speed_down = $"../SpeedDown"
onready var speed_up = $"../SpeedUp"
onready var select = $"../../../../Select"


func _ready() -> void:
	value = Data.get_move_pause_factor()


func _on_HSliderSpeed_value_changed(value:float):
	Data.set_move_pause_factor(value)
	select.play()


func _on_HSliderSpeed_mouse_exited():
	release_focus()

