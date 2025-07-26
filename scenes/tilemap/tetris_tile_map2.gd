extends TileMapLayer

@export var width: int
@export var height: int
@export var spawn_position: Vector2i

var matrix: Array
var rotations: Array

var pivot_postion: Vector2i
var rotataion_index: int

func _ready() -> void:
	matrix = get_matrix_from_tilemap(self, width, height)
	rotations = [
		[
			[2, 1, -1],
			[-1, 2, 2],
			[-1, -1, -1],
		],
		[
			[-1, -1, 1],
			[-1, 1, 2],
			[-1, 2, -1],
		],
	]
	spawn_piece()
	redraw_tilemap()

func spawn_piece():
	rotataion_index = 0
	pivot_postion = spawn_position
	redraw_piece()

func get_min_distance():
	var current_rotation: Array = rotations[rotataion_index]
	var x: int = pivot_postion.x
	var y: int = pivot_postion.y
	
	var min_dist: int = 100
	
	for y_index in [-1, 0, 1]:
		for x_index in [-1, 0, 1]:
			if current_rotation[y_index + 1][x_index + 1] == 2:
				var start_x: int = x + x_index
				var start_y: int = y + y_index
				for yi in range(start_y, height):
					if matrix[yi + 1][start_x] > 10:
						min_dist = min(min_dist, yi - start_y)
						break
	return min_dist

func redraw_piece(add_ten: bool = false):
	var current_rotation: Array = rotations[rotataion_index]
	var x: int = pivot_postion.x
	var y: int = pivot_postion.y
	
	for y_index in [-1, 0, 1]:
		for x_index in [-1, 0, 1]:
			if current_rotation[y_index + 1][x_index + 1] > -1:
				matrix[y + y_index][x + x_index] = 2
				if add_ten:
					matrix[y + y_index][x + x_index] += 10

func undraw_piece():
	var x: int = pivot_postion.x
	var y: int = pivot_postion.y
	
	for y_index in [-1, 0, 1]:
		for x_index in [-1, 0, 1]:
			if matrix[y + y_index][x + x_index] < 10:
				matrix[y + y_index][x + x_index] = -1

func get_matrix_from_tilemap(tile_map_layer: TileMapLayer, width: int, height: int) -> Array:
	var matrix: Array = []
	for y_index in height:
		var row: Array[int] = []
		for x_index in width:
			var alt_id = tile_map_layer.get_cell_alternative_tile(Vector2i(x_index, y_index))
			row.append(alt_id)
		matrix.append(row)
	return matrix
	
func redraw_tilemap() -> void:
	height = matrix.size()
	width = matrix[0].size()
	
	for y_index in height:
		for x_index in width:
			var coords: Vector2i = Vector2i(x_index, y_index)
			var alt_id: int = matrix[y_index][x_index]
			if alt_id > 0:
				set_cell(coords, 1, Vector2i(0, 0), alt_id)
			else:
				erase_cell(coords)

func display_matrix():
	for y_index in height:
		print(matrix[y_index])

func check_collision(dir_x: int, dir_y: int) -> bool:
	var new_pivot = pivot_postion + Vector2i(dir_x, dir_y)
	var current_rotation: Array = rotations[rotataion_index]
	var x: int = new_pivot.x
	var y: int = new_pivot.y
	
	for y_index in [-1, 0, 1]:
		for x_index in [-1, 0, 1]:
			var is_part_of_piece: bool = current_rotation[y_index + 1][x_index + 1] > -1
			var is_solid_in_matrix = matrix[y_index + y][x_index + x] > 10
			if is_part_of_piece and is_solid_in_matrix:
				return true
	return false

func check_collision_on_rotation() -> bool:
	var new_rotation_index: int = (rotataion_index + 1) % rotations.size()
	var current_rotation: Array = rotations[new_rotation_index]
	var x: int = pivot_postion.x
	var y: int = pivot_postion.y
	
	for y_index in [-1, 0, 1]:
		for x_index in [-1, 0, 1]:
			var is_part_of_piece: bool = current_rotation[y_index + 1][x_index + 1] > -1
			var is_solid_in_matrix = matrix[y_index + y][x_index + x] > 10
			if is_part_of_piece and is_solid_in_matrix:
				return true
	return false

func check_game_over() -> bool:
	var current_rotation: Array = rotations[rotataion_index]
	var x: int = pivot_postion.x
	var y: int = pivot_postion.y
	
	for y_index in [-1, 0, 1]:
		for x_index in [-1, 0, 1]:
			var is_part_of_piece: bool = current_rotation[y_index + 1][x_index + 1] > -1
			var is_overflow = y_index + y < 2
			if is_part_of_piece and is_overflow:
				return true
	return false

func _on_timer_timeout() -> void:
	if check_collision(0, 1):
		if check_game_over():
			get_tree().reload_current_scene()
		
		redraw_piece(true)
		spawn_piece()
		redraw_tilemap()
	else:
		undraw_piece()
		pivot_postion += Vector2i(0, 1)
		redraw_piece()
		redraw_tilemap()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		if not check_collision(-1, 0):
			undraw_piece()
			pivot_postion += Vector2i(-1, 0)
			redraw_piece()
			redraw_tilemap()
	elif event.is_action_pressed("ui_right"):
		if not check_collision(1, 0):
			undraw_piece()
			pivot_postion += Vector2i(1, 0)
			redraw_piece()
			redraw_tilemap()
	elif event.is_action_pressed("ui_up"):
		if not check_collision_on_rotation():
			undraw_piece()
			rotataion_index = (rotataion_index + 1) % rotations.size()
			redraw_piece()
			redraw_tilemap()
	elif event.is_action_pressed("ui_down"):
		pass
