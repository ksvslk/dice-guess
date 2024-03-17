extends Node

signal switch_level
onready var dice_current_position = Vector2(0,0)
onready var move_dice_random = $MoveDiceRandom
onready var restart = $Restart
onready var correct = $Correct
onready var wrong = $Wrong
onready var next_level = $NextLevel
onready var select = $Select

var move_pause = 0.05
const last_move_pause = 0.5
onready var level_nr = $Menu/HBoxContainer/VBoxContainer/LevelNr
onready var tutorial = $Tutorial
onready var tile_map = $MarginContainer/Level
onready var state_icon = $TopBar/HBoxContainer/NextOrRestart/StateIcon
onready var next_or_restart = $TopBar/HBoxContainer/NextOrRestart

onready var level_parent = $MarginContainer

onready var level_scroll_container = $LevelScrollContainer
onready var level_scroller = $LevelScrollContainer/LevelScroller
onready var win_dialog = $WinDialog
onready var grid_container = $Menu/HBoxContainer/GridContainer
onready var player_score_update = $TopBar/HBoxContainer/PlayerScoreUpdate
onready var options = $Options

onready var one = $"Menu/HBoxContainer/GridContainer/1"
onready var two = $"Menu/HBoxContainer/GridContainer/2"
onready var three = $"Menu/HBoxContainer/GridContainer/3"
onready var four = $"Menu/HBoxContainer/GridContainer/4"
onready var five = $"Menu/HBoxContainer/GridContainer/5"
onready var six = $"Menu/HBoxContainer/GridContainer/6"
onready var focus_arrow = $Menu/HBoxContainer/FocusArrow


var game_over = false
var animating = false
var win = false

onready var score_label = $Menu/HBoxContainer/VBoxContainer/Score

enum {LEFT, RIGHT, UP, DOWN}
var generated_levels = [[]]


func _assert_levels_correctness():
	for j in range(1,445):
		var scene_path = "res://levels/Level" + str(j) +".tscn"
		var game = load(scene_path).instance() as TileMap
		assert(game.get_used_cells().size() == game.unique_path.size())
		var count_of_start_points = 0
		var count_of_end_points = 0
		var count_of_regular_points = 0
		for cell in game.unique_path:
			var cell_tile = game.get_cellv(cell)
			assert(cell_tile != -1)
			if cell_tile == 1:
				count_of_start_points +=1
			elif cell_tile == 2:
				count_of_end_points +=1
			elif cell_tile == 0:
				count_of_regular_points += 1
		assert(count_of_start_points == 1)
		assert(count_of_end_points == 1)
		assert(count_of_regular_points == (game.unique_path.size() - count_of_end_points - count_of_start_points))
		game.queue_free()
	print("Levels correct.")

var current_focus = null

func _ready():
	if Data.get_tutorial_shown() == 0:
		tutorial.visible = true
	get_viewport().connect("gui_focus_changed", self, "_on_focus_changed")
	#_assert_levels_correctness()
	
	Data.load_latest_level()
	_switch_level_scene()
	focus_arrow.call_deferred("grab_focus")


func _on_focus_changed(new_focus):
	current_focus = new_focus


func switch_level(index):
	if not animating:
		level_scroll_container.visible = false
		level_scroller.visible = false
		next_or_restart.visible = false
		load_next_level(index)
		_reset_partially()


func load_next_level(lv:int = -1):
	if lv != -1:
		Data.load_next_level(lv)
	else:
		var result = Data.load_next_level()
		if result == 1:
			tile_map.reset_level()
			_update_score_label()
			return
		elif result == 2: # game over
			tile_map.reset_level()
			_update_score_label()
			return
	_switch_level_scene()


func _switch_level_scene():
	var new_node_resource = load("res://levels/Level"+str(Data.current_level)+".tscn")
	var new_node = new_node_resource.instance()
	var current_node = tile_map
	var parent_node = level_parent
	parent_node.add_child(new_node)
	current_node.queue_free()
	tile_map = new_node
	level_nr.text = tr("level") + " " + str(Data.current_level)
	# DATA BASE
	_update_score_label()
	tile_map.set_random_dice_side_up()
	level_scroller.update_current_level_color()
	_show_controller_tutorial()
	

func double_blink_label_red():
	var original_color = score_label.modulate
	var tween = get_tree().create_tween()
	tween.tween_property(score_label, "modulate", Color.red, 0.15).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(score_label, "modulate", original_color, 0.15).set_delay(0).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(score_label, "modulate", Color.red, 0.15).set_delay(0).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(score_label, "modulate", original_color, 0.15).set_delay(0).set_trans(Tween.TRANS_BOUNCE)


func double_blink_label_green():
	var original_color = score_label.modulate
	var tween = get_tree().create_tween()
	tween.tween_property(score_label, "modulate", Color.greenyellow, 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(score_label, "modulate", original_color, 0.5).set_delay(0).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(score_label, "modulate", Color.greenyellow, 0.25).set_delay(0).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(score_label, "modulate", original_color, 0.5).set_delay(0).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(score_label, "modulate", Color.greenyellow, 0.25).set_delay(0).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(score_label, "modulate", original_color, 0.5).set_delay(0).set_trans(Tween.TRANS_ELASTIC)


func _set_move_pause(length:int) -> void:
	move_pause = sqrt(length) / length * 0.75


func _hide_tutorial():
	if Data.current_level == "1" || Data.current_level == "2" || Data.current_level == "3":
		tile_map.get_node("Blinker").visible = false


func _show_tutorial():
	if Data.current_level == "1" || Data.current_level == "2" || Data.current_level == "3":
		tile_map.get_node("Blinker").visible = true


func _show_controller_tutorial():
	if Data.current_level == "1":
		$ControllerTutorial.visible = true


func _hide_controller_tutorial():
	if Data.current_level == "1":
		$ControllerTutorial.visible = false


func _animate_to_end(guess:int, button:TextureButton):
	_hide_controller_tutorial()
	_disable_focus_for_dices()
	GPack.perform_haptic_feedback(C.tap_vibration)
	_hide_tutorial()
	dice_current_position = tile_map.unique_path[0]
	animating = true
	button.modulate = Color.gold
	var path = tile_map.unique_path
	_set_move_pause(path.size())
	var first = true
	var last_three = path.size() - 2
	var path_size = path.size()
	for cell_index in path_size:
		var cell = path[cell_index]
		if cell_index >= last_three:
			move_pause = last_move_pause
		if not first:
			yield(get_tree().create_timer(move_pause), "timeout")
		first = false
		var direction_result = cell - dice_current_position
		match direction_result:
			Vector2(0,1): # RIGHT
				tile_map.dice.move_right()
				move_dice_random.play()
			Vector2(0,-1): # LEFT
				tile_map.dice.move_left()
				move_dice_random.play()
			Vector2(1,0): # UP
				tile_map.dice.move_forward()
				move_dice_random.play()
			Vector2(-1,0): # DOWN
				tile_map.dice.move_back()
				move_dice_random.play()
		_set_dice_position(cell)
	if tile_map.dice.get_top_number() == guess:
		GPack.perform_haptic_feedback(C.success_vibration)
		double_blink_label_green()
		tile_map.last.modulate = Color.transparent
		tile_map.dice.modulate = Color.greenyellow
		button.modulate = Color.greenyellow
		correct.play()
		win = true
		Data.set_best_score()
		Data.unlock_next_level()
		GSteam.submit_score()
		var current_level = int(Data.current_level)
		GSteam.set_achievement(current_level)
		next_or_restart.visible = true
		state_icon.texture = load("res://icons/forward.png")
		if current_level == 444:
			win_dialog.visible = true
	else:
		GPack.perform_haptic_feedback(C.fail_vibration)
		double_blink_label_red()
		tile_map.last.modulate = Color.transparent
		tile_map.dice.modulate = Color.red
		button.modulate = Color.red
		_decrease_score_and_update_label()
		wrong.play()
		next_or_restart.visible = true
		state_icon.texture = load("res://icons/restart.png")
	animating = false
	game_over = true


func _decrease_score_and_update_label():
	var decrease_amount = (int(Data.current_level) * 100) / 10
	var new_score = max(Data.get_current_score() - decrease_amount, 0)
	Data.set_current_score(new_score)
	_update_score_label()


func _update_score_label() -> void:
	score_label.text = str(Data.get_current_score())


func _input(event):
	if event is InputEvent && not animating:
		if event.is_action_pressed("ui_cancel"):
			_exit_menu()
		elif event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_cancel") || (event is InputEventScreenTouch && event.is_pressed()):
			if game_over:
				_reset_level()
		elif event.is_action_pressed("ui_focus_next") || event.is_action_pressed("ui_focus_prev"):
			select.play()
		elif event is InputEventJoypadButton:
			if _is_x_pressed(event):
				if game_over:
					_reset_level()
		elif event.is_action_pressed("ui_left") || event.is_action_pressed("ui_right") || event.is_action_pressed("ui_down") || event.is_action_pressed("ui_up"):
			select.play()
		elif event.is_action_pressed("nr_1"):
			_on_1_pressed()
		elif event.is_action_pressed("nr_2"):
			_on_2_pressed()
		elif event.is_action_pressed("nr_3"):
			_on_3_pressed()
		elif event.is_action_pressed("nr_4"):
			_on_4_pressed()
		elif event.is_action_pressed("nr_5"):
			_on_5_pressed()
		elif event.is_action_pressed("nr_6"):
			_on_6_pressed()


func _is_x_pressed(event:InputEventJoypadButton):
	return event.button_index == JOY_XBOX_X || event.button_index == JOY_SONY_X 


func _is_b_pressed(event:InputEventJoypadButton):
	return event.button_index == JOY_XBOX_B || event.button_index == JOY_SONY_CIRCLE 


func _reset_level():
	next_or_restart.visible = false
	restart.play()
	if win:
		next_level.play()
		load_next_level()
	else:
		tile_map.reset_level()
		_show_tutorial()
	_reset_partially()


func _disable_focus_for_dices():
	for c in grid_container.get_children():
		c.enabled_focus_mode = Control.FOCUS_NONE
		c.disabled = true
	current_focus.release_focus()


func _enable_focus_for_dices():
	current_focus.release_focus()
	if not game_over:
		for c in grid_container.get_children():
			c.modulate = Color.white
			c.enabled_focus_mode = Control.FOCUS_ALL
			c.disabled = false
	focus_arrow.call_deferred("grab_focus")
		

func _reset_partially():
	tile_map.dice.modulate = Color.white
	tile_map.last.modulate = Color.white
	score_label.modulate = Color.white
	game_over = false
	win = false
	_show_controller_tutorial()
	_enable_focus_for_dices()


func _set_dice_position(next_position:Vector2):
	var local_position = tile_map.map_to_world(next_position)
	tile_map.dice.position = local_position
	dice_current_position = next_position
	

func _on_1_pressed():
	if not animating && not game_over && level_parent.visible:
		_animate_to_end(1, one)


func _on_2_pressed():
	if not animating && not game_over && level_parent.visible:
		_animate_to_end(2, two)


func _on_3_pressed():
	if not animating && not game_over && level_parent.visible:
		_animate_to_end(3, three)


func _on_4_pressed():
	if not animating && not game_over && level_parent.visible:
		_animate_to_end(4, four)


func _on_5_pressed():
	if not animating && not game_over && level_parent.visible:
		_animate_to_end(5, five)


func _on_6_pressed():
	if not animating && not game_over && level_parent.visible:
		_animate_to_end(6, six)


func _on_LevelNr_pressed():
	level_scroll_container.visible = !level_scroll_container.visible
	level_scroller.visible = !level_scroller.visible


func _on_Help_pressed():
	_exit_menu()
	options.visible = true


func _on_LevelScrollContainer_visibility_changed():
	if level_scroll_container.visible:
		_disable_focus_for_dices()
		level_parent.visible = false
		grid_container.modulate.a = 0.5
	else:
		_enable_focus_for_dices()
		level_parent.visible = true
		grid_container.modulate.a = 1


func _on_Tutorial_visibility_changed():
	if tutorial.visible:
		$Tutorial/MarginContainer/VBoxContainer/HBoxContainer/ContinueButton.call_deferred("grab_focus")
	else:
		$Options/OptionsVBox/BackButton.call_deferred("grab_focus")


func _on_WinDialog_visibility_changed():
	if win_dialog.visible:
		_disable_focus_for_dices()
		#level_parent.visible = false
		grid_container.modulate.a = 0.5
		$WinDialog/VBoxContainer/TextureButton.call_deferred("grab_focus")
	else:
		_exit_menu()


func _exit_menu():
	level_parent.visible = true
	grid_container.modulate.a = 1
	level_scroll_container.visible = false
	level_scroller.visible = false
	win_dialog.visible = false
	tutorial.visible = false
	options.visible = false
	_enable_focus_for_dices()
	


func _on_Options_visibility_changed():
	if options.visible:
		_disable_focus_for_dices()
		level_parent.visible = false
		grid_container.modulate.a = 0.5
		$Options/OptionsVBox/BackButton.call_deferred("grab_focus")
	else:
		_exit_menu()


func _on_Tutorial_pressed():
	tutorial.visible = true
