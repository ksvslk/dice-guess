extends VBoxContainer

var level_button = load("res://LevelSelectButton.tscn")
onready var main = $"../.."

func _ready():
	var levels = Data.get_levels()
	for index in range(0, levels.size()):
		var button = level_button.instance()
		var level_completed_once = levels.values()[index][0] as bool
		var level_purchased = levels.values()[index][1] as bool
		button.done_visible = level_completed_once
		button.level_is_unlocked = level_purchased
		button.button_text = str(index + 1)
		button.disabled = !level_purchased
		add_child(button)
		button.connect("pressed", main, "switch_level", [index + 1])
	margin_top += C.get_top_safe_margin()
	margin_bottom -= C.get_bottom_safe_margin()


func update_current_level_color():
	var added_buttons = get_children()
	for index in range(0, added_buttons.size()):
		var level_button_l = get_child(index)
		if int(Data.current_level) == index + 1:
			level_button_l.modulate = Color.green
		else:
			level_button_l.modulate = Color.white
			
			
func _set_level_buttons_state():
	var levels = Data.get_levels()
	var added_buttons = get_children()
	for index in range(0, added_buttons.size()):
		var level_button_l = get_child(index)
		var level_completed_once = levels.values()[index][0] as bool
		var level_purchased = levels.values()[index][1] as bool
		level_button_l.set_done_visible(level_completed_once)
		level_button_l.level_is_unlocked = level_purchased
		level_button_l.disabled = !level_purchased


func _set(property, value):
	if property == "visible":
		if value == true:
			_set_level_buttons_state()
			visible = true
		elif value == false:
			visible = false
