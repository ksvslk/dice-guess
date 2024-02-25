extends Button
onready var done = $Done

var button_text = ""
var level_is_unlocked = false
var done_visible = false

func _ready():
	text = button_text
	disabled = !level_is_unlocked
	done.visible = done_visible


func set_done_visible(value:bool):
	done_visible = value
	done.visible = done_visible
