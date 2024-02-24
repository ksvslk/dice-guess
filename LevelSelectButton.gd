extends Button

var button_text = ""
var level_is_unlocked = false

func _ready():
	text = button_text
	disabled = !level_is_unlocked
