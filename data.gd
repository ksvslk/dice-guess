extends Node

onready var _config := ConfigFile.new()

const _path: String = "user://data.cfg"
const _total_levels_plus_one := 556 # each level has its own section: "1", "2" etc.
var current_level := "-1"

const all_level_packs_id = "all_level_packs"
const level_pack_1_id = "level_pack_51_100"
const level_pack_2_id = "level_pack_101_150"
const level_pack_3_id = "level_pack_151_200"

var skus = {
	all_level_packs_id:false,
	level_pack_1_id:false,
	level_pack_2_id:false,
	level_pack_3_id:false
}

########################
#	 DATABASE PART	  #
########################	

func _ready():
	var err := _config.load(_path)
	if err == ERR_FILE_NOT_FOUND:
		 # This should be done ONLY ONCE when also cloud has no info!!!
		_set_initial_launch_settings()
	elif err != 0:
		printerr("Could not load local data. ", err)
	

######################################
#	REPOSITORY/VIEWMODEL PART	    #
######################################


func load_latest_level():
	current_level = String(_config.get_value(C.various_section, C.current_level_key))
	var current_score = _config.get_value(current_level, C.current_score_key)


func restart_level():
	var current_score = _config.get_value(current_level, C.current_score_key)


func is_next_level_purchased(lv:int) -> bool:
	var is_purchased = _config.get_value(str(lv), C.level_purchased_key)
	return is_purchased == 1
	

# success code - 0
# next level not purchased - 1
# game complete, no more levels - 2

func load_next_level(nr: int = -1, from_level_select: bool = false) -> int:
	var next_level_nr = 0
	if nr == -1:
		next_level_nr = int(current_level) + 1
	else:
		next_level_nr = nr
	var is_next_purchased = is_next_level_purchased(next_level_nr)
	
	if next_level_nr == 201:
		return 2
	if !is_next_purchased:
		return 1
		
	current_level = str(next_level_nr)
	_config.set_value(C.various_section, C.current_level_key, current_level)
	_config.save(_path)
	var current_score = _config.get_value(current_level, C.current_score_key)
	if current_score == -1:
		var default_score = nr * 100
		set_current_score(default_score)
	if from_level_select:
		save_game(int(current_level))
	return 0
	
	
func get_level_complete_info() -> Dictionary:
	return {
		"current_score":_config.get_value(current_level, C.current_score_key),
		"best_score":_config.get_value(current_level, C.best_score_key),
	}


func unlock_next_level():
	var current = int(current_level)
	if current != _total_levels_plus_one-1:
		var level_to_be_unlocked = current + 1
		_config.set_value(str(level_to_be_unlocked), C.unlocked, 1)
		_config.save(_path)
		save_game(level_to_be_unlocked)


func get_total_score() -> int:
	var total = 0
	for i in range(1, _total_levels_plus_one):
		total += _config.get_value(String(i), C.best_score_key)
	return total


func set_current_score(score:int) -> void:
	_config.set_value(current_level, C.current_score_key, score)
	_config.save(_path)
	
	
func get_current_score() -> int:
	var value = _config.get_value(current_level, C.current_score_key)
	return value
	

func set_best_score() -> void:
	var current_score = get_current_score()
	var best_score = _config.get_value(current_level, C.best_score_key)
	if current_score > best_score:
		_config.set_value(current_level, C.best_score_key, current_score)
	_config.set_value(current_level, C.current_score_key, int(current_level) * 100)
	_config.set_value(current_level, C.level_completed_once_key, 1)
	_config.save(_path)


func get_tutorial_shown() -> int:
	var value = _config.get_value(C.various_section, C.tutorial_shown_key)
	return value


func set_tutorial_shown() -> void:
	_config.set_value(C.various_section, C.tutorial_shown_key, 1)
	_config.save(_path)


func get_levels() -> Dictionary:
	var info = Dictionary()
	for i in range(1, _total_levels_plus_one):
		info[str(i)] = [
			_config.get_value(str(i), C.level_completed_once_key),
			_config.get_value(str(i), C.level_purchased_key),
		]
	return info


func set_all_level_packs_purchased():
	skus[all_level_packs_id] = true
	for i in range(1, _total_levels_plus_one):
		_config.set_value(str(i), C.level_purchased_key, 1)
	_config.save(_path)


func set_level_pack_1_purchased():
	skus[level_pack_1_id] = true
	for i in range(51, 101):
		_config.set_value(str(i), C.level_purchased_key, 1)
	_config.save(_path)


func set_level_pack_2_purchased():
	skus[level_pack_2_id] = true
	for i in range(101, 151):
		_config.set_value(str(i), C.level_purchased_key, 1)
	_config.save(_path)	


func set_level_pack_3_purchased():
	skus[level_pack_3_id] = true
	for i in range(151, _total_levels_plus_one):
		_config.set_value(str(i), C.level_purchased_key, 1)
	_config.save(_path)


func _set_initial_launch_settings():
	_config.set_value(C.various_section, C.current_level_key, "1")
	_config.set_value(C.various_section, C.tutorial_shown_key, 0)
	
	for i in range(1, _total_levels_plus_one):
		_config.set_value(String(i), C.best_score_key, 0)
		_config.set_value(String(i), C.current_score_key, i * 100)
		_config.set_value(String(i), C.level_completed_once_key, 0)
		_config.set_value(String(i), C.level_purchased_key, 1)

	_config.save(_path)


func save_game(next_level:int) -> void:
	return
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		var game_data = Dictionary()
		for key in C.various_section_dictionary_keys:
			if key == C.current_level_key:
				game_data[key] = str(next_level)
			else:
				game_data[key] = _config.get_value(C.various_section, key)
		for level_nr in range(1, _total_levels_plus_one):
			var level = str(level_nr)
			var level_info = []
			for level_info_key in _config.get_section_keys(level):
				level_info.push_back(_config.get_value(level, level_info_key))
			game_data[level] = str(level_info)
		GPack.save_game(game_data, next_level)


func load_game(game_data: Dictionary) -> void:
	return
	if not game_data.empty():
		for key in C.various_section_dictionary_keys:
			_config.set_value(C.various_section, key, game_data[key])
		for level_nr in range(1, _total_levels_plus_one):
			var level = str(level_nr)
			var level_info = JSON.parse(game_data[level])
			if typeof(level_info.result) == TYPE_ARRAY:
					for index in range(0, level_info.result.size()):
						_config.set_value(level, C.level_section_dictionary_keys[index], level_info.result[index])
			else:
				push_error("Unexpected results when loading level info data.")
		_config.save(_path)
