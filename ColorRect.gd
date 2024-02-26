extends ColorRect

onready var tween = $Tween
const SHINE_TIME = 1


func start_loading():
	visible = true
	tween.interpolate_property(material, "shader_param/shine_progress", 0.0, 1.0, SHINE_TIME, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	tween.repeat = true
	tween.start()


func end_loading():
	visible = false
	tween.stop_all()
