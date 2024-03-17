extends HSlider

export var audio_bus_name := "Master"
onready var volume_down = $"../VolumeDown"
onready var volume_up = $"../VolumeUp"
onready var select = $"../../../../Select"

onready var _bus := AudioServer.get_bus_index(audio_bus_name)

func _ready() -> void:
	value = db2linear(AudioServer.get_bus_volume_db(_bus))
	if value == 0:
		volume_down.texture = load("res://icons/sound_off.png")
	else:
		volume_down.texture = load("res://icons/volume_down.png")
		

func _on_HSlider_value_changed(value: float):
	if value == 0:
		volume_down.texture = load("res://icons/sound_off.png")
	else:
		volume_down.texture = load("res://icons/volume_down.png")
	AudioServer.set_bus_volume_db(_bus, linear2db(value))
	select.play()

func _on_VolumeDown_pressed():
	value = max(0, value - step)

func _on_VolumeUp_pressed():
	value = min(1, value + step)


func _on_HSlider_mouse_exited():
	release_focus()
