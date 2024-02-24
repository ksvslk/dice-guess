extends Node

onready var _config := ConfigFile.new()

const _path: String = "user://data.cfg"
const _total_levels_plus_one := 201 # each level has its own section: "1", "2" etc.
var current_level := "-1"

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

signal level_loaded(level, score)
signal all_in_pack
signal level_unlocked(index)

func increase_taps():
	emit_signal("tap")

func load_current_level():
	current_level = String(_config.get_value(C.various_section, C.current_level_key))
	var current_score = _config.get_value(current_level, C.current_score_key)
	emit_signal("level_loaded", int(current_level), current_score)
	
	
func restart_level():
	var current_score = _config.get_value(current_level, C.current_score_key)
	emit_signal("level_loaded", int(current_level), current_score)


func load_next_level(nr: int = -1, from_level_select: bool = false):
	if nr == -1:
		current_level = str(int(current_level) + 1)
	else:
		current_level = str(nr)
	_config.set_value(C.various_section, C.current_level_key, current_level)
	_config.save(_path)
	var current_score = _config.get_value(current_level, C.current_score_key)
	emit_signal("level_loaded", int(current_level), current_score)
	if from_level_select:
		save_game(int(current_level))


func get_level_complete_info() -> Dictionary:
	return {
		"current_score":_config.get_value(current_level, C.current_score_key),
	}


func unlock_next_level():
	var current = int(current_level)
	if current != 200:
		var level_to_be_unlocked = current + 1
		_config.set_value(str(level_to_be_unlocked), C.unlocked, 1)
		_config.save(_path)
		emit_signal("level_unlocked", level_to_be_unlocked - 1)
		save_game(level_to_be_unlocked)


func _get_total_score() -> int:
	var total = 0
	for i in range(1, _total_levels_plus_one):
		total += _config.get_value(String(i), C.best_score_key)
	return total
	

func _save_current_level_new_score(new_score: int) -> void:
	var best_score = _config.get_value(current_level, C.best_score_key)
	if new_score > best_score:
		_config.set_value(current_level, C.best_score_key, new_score)
	_config.save(_path)


func get_levels() -> Dictionary:
	var info = Dictionary()
	for i in range(1, _total_levels_plus_one):
		info[str(i)] = [
			_config.get_value(str(i), C.unlocked)
		]
	return info


func _set_initial_launch_settings():
	_config.set_value(C.various_section, C.current_level_key, "1")
	
	for i in range(1, _total_levels_plus_one):
		_config.set_value(String(i), C.best_score_key, 0)
		_config.set_value(String(i), C.current_score_key, -1)
		if i < 201: #TODO: CHANGE BACK
			_config.set_value(String(i), C.unlocked, 1)
		else:
			_config.set_value(String(i), C.unlocked, 0)
	_config.save(_path)


func save_game(next_level:int) -> void:
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
		Gpack.save_game(game_data, next_level)
		
		
func load_game(game_data: Dictionary) -> void:
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
