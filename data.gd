extends Node

onready var _config := ConfigFile.new()

const _path: String = "user://data.cfg"
const _total_levels_plus_one := 445 # each level has its own section: "1", "2" etc.
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


func load_latest_level():
	current_level = String(_config.get_value(C.various_section, C.current_level_key))
	var current_score = _config.get_value(current_level, C.current_score_key)


func restart_level():
	var current_score = _config.get_value(current_level, C.current_score_key)


# success code - 0
# next level not purchased - 1
# game complete, no more levels - 2

func load_next_level(nr: int = -1, from_level_select: bool = false) -> int:
	var next_level_nr = 0
	if nr == -1:
		next_level_nr = int(current_level) + 1
	else:
		next_level_nr = nr
	
	if next_level_nr == _total_levels_plus_one:
		return 2
		
	current_level = str(next_level_nr)
	_config.set_value(C.various_section, C.current_level_key, current_level)
	_config.save(_path)
	var current_score = _config.get_value(current_level, C.current_score_key)
	if current_score == -1:
		var default_score = nr * 100
		set_current_score(default_score)
	return 0
	
	
func get_level_complete_info() -> Dictionary:
	return {
		"current_score":_config.get_value(current_level, C.current_score_key),
		"best_score":_config.get_value(current_level, C.best_score_key),
	}


func unlock_next_level():
	var current = int(current_level)
	if current != _total_levels_plus_one - 1:
		var level_to_be_unlocked = current + 1
		_config.set_value(str(level_to_be_unlocked), C.unlocked, 1)
		_config.save(_path)


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
			_config.get_value(str(i), C.unlocked),
		]
	return info


func _set_initial_launch_settings():
	_config.set_value(C.various_section, C.current_level_key, "1")
	_config.set_value(C.various_section, C.tutorial_shown_key, 0)
	
	for i in range(1, _total_levels_plus_one):
		_config.set_value(String(i), C.best_score_key, 0)
		_config.set_value(String(i), C.current_score_key, i * 100)
		_config.set_value(String(i), C.level_completed_once_key, 0)
		if i == 1:
			_config.set_value(String(i), C.unlocked, 1)
		else:
			_config.set_value(String(i), C.unlocked, 0)
	_config.save(_path)
