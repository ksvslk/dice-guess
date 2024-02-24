extends TileMap

onready var last = $Last
onready var dice = $Dice

var start_pos = Vector2(-13,-13)
export(Array, int) var unique_path = []
var length = 2

var time_start = 0
var time_now = 0

func _ready():
	return
	var path_length = 2
	for i in range(100):
		var level_nr = i + 1
		var walls_count = max(1, level_nr/2)
		path_length = get_level_path_length(level_nr, path_length)
		generate_new_level(walls_count, path_length)
		create_new_scene(level_nr)


func get_level_path_length(level:int, last_path_length:int) -> int:
	if range(1, 5).has(level):
		return 2
	elif range(5, 10).has(level):
		return 3
	elif range(10, 20).has(level):
		return 4
	else:
		return 4 + (level / 10)


func create_new_scene(scene_nr:int):
	var scene_name = "Level"+str(scene_nr)
	var new_scene = PackedScene.new()
	var root_node = duplicate()
	root_node.name = scene_name
	new_scene.pack(root_node)
	var scene_path = "res://levels/"+scene_name+".tscn"
	var error = ResourceSaver.save(scene_path, new_scene)
	if error == OK:
		print("Scene saved successfully at: ", scene_path)
	else:
		print("Failed to save scene")
	root_node.queue_free()

	
func fit_level_to_screen():
	scale.x = 1
	scale.y = 1
	var used = get_used_cells()
	var parent_rect = get_parent().get_visible_rect()
	var fit = false
	while not fit:
		used = get_used_cells()
		var count = 0
		for u in used:
			var local_position = map_to_world(u)
			var global_pos = to_global(local_position)
			if !parent_rect.has_point(global_pos):
				scale.x -= 0.1
				scale.y -= 0.1
				count += 1
		if count == 0:
			fit = true


func _set_random_dice_side_up():
	var rand_frame:int = randi() % dice.frames.get_frame_count("default")
	dice.frame = rand_frame


func generate_new_level(walls_count:int, path_length:int):
	clear()
	start_pos = Vector2(0,0)
	var selection_of_paths_with_distance = []
	var came_from_and_distances = []
	while selection_of_paths_with_distance.empty():
		var wall_positions = generate_unique_random_cell_coordinates(200, C.allowed_cells.duplicate())
		came_from_and_distances = get_paths(wall_positions)
		for came_from_and_distance in came_from_and_distances.values():
			if came_from_and_distance[1] == path_length:
				selection_of_paths_with_distance.push_back(came_from_and_distance[0])
	var index = randi() % selection_of_paths_with_distance.size() - 1
	var goal = selection_of_paths_with_distance[index]
	while selection_of_paths_with_distance.find(goal) == -1:
		index = randi() % came_from_and_distances.keys().size() - 1
		goal = came_from_and_distances.keys()[index]
	unique_path = get_path_back_to(start_pos, goal, came_from_and_distances)
	for v in unique_path:
		set_cellv(v, 0)
	set_cellv(unique_path[0], 1)
	set_cellv(unique_path[unique_path.size() - 1], 2)
	reset_level()
	_set_random_dice_side_up()


func generate_unique_random_cell_coordinates(amount: int, available_coords: Array) -> Array:
	randomize()
	var random_cells = []
	var indices_picked = {} # Use a dictionary to track picked indices to ensure uniqueness

	while random_cells.size() < amount and available_coords.size() > 0:
		var index = randi() % available_coords.size() # Pick a random index from available coordinates
		if not indices_picked.has(index): # Check if the index has already been picked
			indices_picked[index] = true
			random_cells.append(available_coords[index])
			available_coords.remove(index) # Remove the picked coordinate to prevent picking it again

		# Optional: Break the loop if it seems we cannot find new unique positions after many attempts
		# This prevents an infinite loop in cases where the amount requested is too high for the given array size
		if random_cells.size() == available_coords.size() or indices_picked.size() >= amount:
			break

	if random_cells.size() < amount:
		print("Requested amount exceeds the number of unique positions available in the provided array.")

	return random_cells
	

func reset_level():
	dice.position = map_to_world(unique_path[0])
	last.position = map_to_world(unique_path[unique_path.size() - 1])


func get_cell_neighbors(cell:Vector2, walls:Array) -> Array:
	var neighbors = []
	if C.allowed_cells.find(cell + Vector2.UP) != -1 && walls.find(cell + Vector2.UP) == -1:
		neighbors.push_back(cell + Vector2.UP)
	if C.allowed_cells.find(cell + Vector2.RIGHT) != -1 && walls.find(cell + Vector2.RIGHT) == -1:
		neighbors.push_back(cell + Vector2.RIGHT)
	if C.allowed_cells.find(cell + Vector2.DOWN) != -1 && walls.find(cell + Vector2.DOWN) == -1:
		neighbors.push_back(cell + Vector2.DOWN)
	if C.allowed_cells.find(cell + Vector2.LEFT) != -1 && walls.find(cell + Vector2.LEFT) == -1:
		neighbors.push_back(cell + Vector2.LEFT)
	return neighbors


func get_paths(wall_positions:Array) -> Dictionary:
	var frontier = [start_pos]
	var came_from_and_distance:Dictionary = { start_pos:[null, 0] } # path A->B is stored as came_from[B] == A
	var current = null
	#set_cellv(start_pos, 0)
	while not frontier.empty():
		current = frontier.pop_front()
		for next in get_cell_neighbors(current, wall_positions):
			if !came_from_and_distance.has(next):
				frontier.push_back(next)
				came_from_and_distance[next] = [current, 1 + came_from_and_distance[current][1]]
				#set_cellv(next, 1)
				#yield(get_tree().create_timer(0.01), "timeout")
	return came_from_and_distance


func get_path_back_to(start:Vector2, goal:Vector2, came_from_and_distance:Dictionary) -> Array:
	var current = goal
	var path = []
	while current != start:
		path.append(current)
		current = came_from_and_distance[current][0]
	path.append(start)
	return path
