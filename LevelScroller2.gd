extends VBoxContainer

var level_button = load("res://LevelSelectButton.tscn")
onready var main = $"../.."
onready var level_scroll_container = $".." as ScrollContainer

func _ready():
	print("ready")
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
	update_current_level_color()
	

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
		if int(Data.current_level) == index + 1:
			level_button_l.call_deferred("grab_focus")
			print("grab focus for: ", level_button_l.name)
			print("grab focus for: ", index + 1)


func _set(property, value):
	if property == "visible":
		if value == true:
			visible = true
			_set_level_buttons_state()
		elif value == false:
			visible = false
