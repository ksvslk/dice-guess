extends Node

signal switch_level
onready var dice_current_position = Vector2(0,0)
onready var tile_map = $ViewportContainer/Viewport/Level
onready var move_dice_random = $MoveDiceRandom
onready var restart = $Restart
onready var correct = $Correct
onready var wrong = $Wrong
onready var next_level = $NextLevel
var move_pause = 0.05
const last_move_pause = 0.5
onready var level_nr = $Menu/HBoxContainer/VBoxContainer/LevelNr
onready var tutorial = $Tutorial

var game_over = false
var animating = false
var win = false
var current_level_nr = 1
var score_nr = current_level_nr * 100

onready var score_label = $Menu/HBoxContainer/VBoxContainer/Score

enum {LEFT, RIGHT, UP, DOWN}
var generated_levels = [[]]

func _ready():
	score_label.text = "Score: " + str(score_nr)
	level_nr.text = "Level: " + str(current_level_nr)
	level_scroller.update_current_level_color()


func load_latest_level():
	Data.load_current_level()

func switch_level(index):
	level_scroller.visible = false
	load_next_level(index)
	_reset_partially()

func load_next_level(lv:int = -1):
	current_level_nr = current_level_nr + 1
	if lv != -1:
		current_level_nr = lv
	var new_node_resource = load("res://levels/Level"+str(current_level_nr)+".tscn")
	var new_node = new_node_resource.instance()
	var current_node = tile_map
	var parent_node = $ViewportContainer/Viewport
	parent_node.add_child(new_node)
	current_node.queue_free()
	tile_map = new_node
	level_nr.text = "Level: " + str(current_level_nr)
	score_nr = current_level_nr * 100
	_update_score_label()
	tile_map.set_random_dice_side_up()
	level_scroller.update_current_level_color()
	

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


func _animate_to_end(guess:int, button:TextureButton):
	dice_current_position = tile_map.unique_path[0]
	animating = true
	button.modulate = Color.aqua
	var path = tile_map.unique_path
	_set_move_pause(path.size())
	var first = true
	var last_three = path.size() - 2
	for cell_index in path.size():
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
		double_blink_label_green()
		tile_map.last.modulate = Color.transparent
		tile_map.dice.modulate = Color.greenyellow
		button.modulate = Color.greenyellow
		correct.play()
		win = true
	else:
		double_blink_label_red()
		tile_map.last.modulate = Color.transparent
		tile_map.dice.modulate = Color.red
		button.modulate = Color.red
		_decrease_score_and_update_label()
		wrong.play()
	animating = false
	game_over = true


func _decrease_score_and_update_label():
	var decrease_amount = (current_level_nr * 100) / 10
	score_nr = max(score_nr - decrease_amount, 0)
	_update_score_label()


func _update_score_label() -> void:
	score_label.text = "Score: " + str(score_nr)


func _reset_level():
	restart.play()
	if win:
		next_level.play()
		load_next_level()
	else:
		tile_map.reset_level()
	_reset_partially()


func _reset_partially():
	for c in $Menu/HBoxContainer/GridContainer.get_children():
		c.modulate = Color.white
	tile_map.dice.modulate = Color.white
	tile_map.last.modulate = Color.white
	score_label.modulate = Color.white
	game_over = false
	win = false


func _set_dice_position(next_position:Vector2):
	var local_position = tile_map.map_to_world(next_position)
	tile_map.dice.position = local_position
	dice_current_position = next_position
	

func _on_1_pressed():
	if not animating && not game_over:
		_animate_to_end(1, $Menu/HBoxContainer/GridContainer/"1")


func _on_2_pressed():
	if not animating && not game_over:
		_animate_to_end(2, $Menu/HBoxContainer/GridContainer/"2")


func _on_3_pressed():
	if not animating && not game_over:
		_animate_to_end(3, $Menu/HBoxContainer/GridContainer/"3")


func _on_4_pressed():
	if not animating && not game_over:
		_animate_to_end(4, $Menu/HBoxContainer/GridContainer/"4")


func _on_5_pressed():
	if not animating && not game_over:
		_animate_to_end(5, $Menu/HBoxContainer/GridContainer/"5")


func _on_6_pressed():
	if not animating && not game_over:
		_animate_to_end(6, $Menu/HBoxContainer/GridContainer/"6")

onready var level_scroller = $LevelScroller


func _on_ViewportContainer_gui_input(event):
	if event is InputEventMouseButton && not animating:
		if game_over:
			_reset_level()


func _on_Help_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			tutorial.visible = true

func _on_LevelNr_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			level_scroller.visible = true
