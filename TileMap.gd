extends TileMap

onready var last = $Last
onready var dice = $Dice

var start_pos = Vector2(2,0)
export(Array) var unique_path = []
var length = 2


func _ready():
	#for j in range(1,101):
	#	var scene_path = "res://levels/Level" + str(j) +".tscn"
	#	var game = load(scene_path).instance()
	#	get_parent().get_parent().get_parent().generated_levels.push_back(game.unique_path)
	return
	var path_length = 2
	for i in range(0, 10):
		var level_nr = i + 1
		var walls_count = int(max(1, level_nr/1.5))
		path_length = get_level_path_length(level_nr)
		generate_new_level(level_nr, walls_count, path_length)
		create_new_scene(level_nr)
		scale.x = 1
		scale.y = 1
		
		
func _center_the_tilemap() -> void:
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	# Step 1: Determine the bounds
	for c in unique_path:
		var world_pos = to_global(map_to_world(c))
		min_x = min(min_x, world_pos.x)
		max_x = max(max_x, world_pos.x)
		min_y = min(min_y, world_pos.y)
		max_y = max(max_y, world_pos.y)

	# Step 2: Construct the Rect2
	var rect_position = Vector2(min_x, min_y)
	var rect_size = Vector2(max_x - min_x, max_y - min_y)
	var bounding_rect = Rect2(rect_position, rect_size)

	# Step 3: Find the center of the Rect2
	var center_of_rect = bounding_rect.position + bounding_rect.size * 0.5

	var center_cell = world_to_map(to_local(center_of_rect))
	# Step 4: Calculate the offset to move center_cell to (0,0)
	var offset = Vector2(0, 0) - center_cell

#	 Step 5: Shift all tiles by the offset
	var new_tiles = []
	for c in unique_path:
		# Calculate the new position for each cell by applying the offset
		var new_pos = c + offset
		# Store the cell's data (tile ID, etc.) to move it to the new position
		var tile_id = get_cellv(c)
		new_tiles.append({"pos": new_pos, "id": tile_id})

	# Clear the TileMap before moving tiles to avoid overlap issues
	clear()
	
	unique_path.clear()
	
	# Now, place tiles at their new positions
	for tile in new_tiles:
		unique_path.append(tile["pos"])
		set_cellv(tile["pos"], tile["id"])


func get_level_path_length(level:int) -> int:
	if range(1, 5).has(level):
		return 3
	elif range(5, 10).has(level):
		return 4
	elif range(10, 20).has(level):
		return 5
	else:
		return 6 + (level / 10)


func create_new_scene(scene_nr:int):
	resize_scene()
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


func set_random_dice_side_up():
	var rand_frame:int = randi() % dice.frames.get_frame_count("default")
	dice.frame = rand_frame


func generate_new_level(level:int, walls_count:int, path_length:int):
	var parent = get_parent().get_parent()
	while parent.generated_levels.find(unique_path) != -1:
		unique_path.clear()
		clear()
		start_pos = Vector2(0, 0)
		var selection_of_paths_with_distance = []
		var came_from_and_distances = []
		while selection_of_paths_with_distance.empty():
			var wall_positions = generate_unique_random_cell_coordinates(walls_count, C.allowed_cells.duplicate())
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
		_center_the_tilemap()
		reset_level()
	parent.generated_levels.push_back(unique_path.duplicate())


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
	print("SIZE: ", came_from_and_distance.size())
	return came_from_and_distance


func get_path_back_to(start:Vector2, goal:Vector2, came_from_and_distance:Dictionary) -> Array:
	var current = goal
	var path = []
	while current != start:
		path.append(current)
		current = came_from_and_distance[current][0]
	path.append(start)
	return path


#func get_cell_neighbors(cell:Vector2, walls:Array) -> Array:
#	var neighbors = []
#	if is_inside_walls(cell + Vector2.UP) && walls.find(cell + Vector2.UP) == -1:
#		neighbors.push_back(cell + Vector2.UP)
#	if  is_inside_walls(cell + Vector2.RIGHT) && walls.find(cell + Vector2.RIGHT) == -1:
#		neighbors.push_back(cell + Vector2.RIGHT)
#	if is_inside_walls(cell + Vector2.DOWN) && walls.find(cell + Vector2.DOWN) == -1:
#		neighbors.push_back(cell + Vector2.DOWN)
#	if is_inside_walls(cell + Vector2.LEFT) && walls.find(cell + Vector2.LEFT) == -1:
#		neighbors.push_back(cell + Vector2.LEFT)
#	return neighbors


func resize_scene():
	var exists_out_of_screen_cell = true
	var cells = get_used_cells()
	var count_of_oos_cells = 0
	while exists_out_of_screen_cell:
		exists_out_of_screen_cell = false
		for cell in cells:
			if !is_inside_walls(cell):
				count_of_oos_cells += 1
		if count_of_oos_cells == 0:
			exists_out_of_screen_cell = false
		else:
			count_of_oos_cells = 0
			scale.x -= 0.01
			scale.y -= 0.01
			exists_out_of_screen_cell = true
			


func is_inside_walls(map_pos:Vector2) -> bool:
	# 341/2=170.5 or last.get_rect().size.y/2 is the dice height that must also fit to screen (on the platform extra height)
	var local_pos = map_to_world(map_pos)
	var pos = to_global(local_pos)
	pos.x += 960
	pos.y += 450
	var left_limit = cell_size.x * scale.x
	var right_limit = 1920 - cell_size.x * scale.x
	var top_limit = cell_size.y / 2 * scale.y
	var bottom_limit = 900 - (3 * cell_size.y * scale.y)
	return pos.x > left_limit && pos.x < right_limit && pos.y > top_limit && pos.y < bottom_limit
