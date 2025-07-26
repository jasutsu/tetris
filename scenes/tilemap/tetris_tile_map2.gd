extends TileMapLayer

@export var width: int
@export var height: int
@export var playable_width: int
@export var playable_height: int
@export var spawn_position: Vector2i
@export var next_piece_pivot: Vector2i

var matrix: Array
var rotations: Array
var pivot_postion: Vector2i
var rotataion_index: int
var piece_index: int
var new_piece_index: int

var default_timer_interval: float
var score: int

var touch_start_pos: Vector2 = Vector2.ZERO
var min_swipe_distance: float = 100.0

var all_pieces: Array = [
	[# Z
		[
			[1, 1, -1],
			[-1, 1, 1],
			[-1, -1, -1],
		],
		[
			[-1, -1, 1],
			[-1, 1, 1],
			[-1, 1, -1],
		],
	],
	[# Z reverse
		[
			[-1, 1, 1],
			[1, 1, -1],
			[-1, -1, -1],
		],
		[
			[1, -1, -1],
			[1, 1, -1],
			[-1, 1, -1],
		],
	],
	[# box
		[
			[1, 1, -1],
			[1, 1, -1],
			[-1, -1, -1],
		],
	],
	[# L
		[
			[1, -1, -1],
			[1, 1, 1],
			[-1, -1, -1],
		],
		[
			[-1, 1, 1],
			[-1, 1, -1],
			[-1, 1, -1],
		],
		[
			[-1, -1, -1],
			[1, 1, 1],
			[-1, -1, 1],
		],
		[
			[-1, 1, -1],
			[-1, 1, -1],
			[1, 1, -1],
		],
	],
	[# L reverse
		[
			[-1, -1, 1],
			[1, 1, 1],
			[-1, -1, -1],
		],
		[
			[1, 1, -1],
			[-1, 1, -1],
			[-1, 1, -1],
		],
		[
			[-1, -1, -1],
			[1, 1, 1],
			[1, -1, -1],
		],
		[
			[-1, 1, -1],
			[-1, 1, -1],
			[-1, 1, 1],
		],
	],
	[# T
		[
			[-1, 1, -1],
			[1, 1, 1],
			[-1, -1, -1],
		],
		[
			[-1, 1, -1],
			[-1, 1, 1],
			[-1, 1, -1],
		],
		[
			[-1, -1, -1],
			[1, 1, 1],
			[-1, 1, -1],
		],
		[
			[-1, 1, -1],
			[1, 1, -1],
			[-1, 1, -1],
		],
	],
	[# Stick
		[
			[-1, 1, -1],
			[-1, 1, -1],
			[-1, 1, -1],
		],
		[
			[-1, -1, -1],
			[1, 1, 1],
			[-1, -1, -1],
		],
	],
]

func _ready() -> void:
	default_timer_interval = $Timer.wait_time
	score = 0
	
	matrix = get_matrix_from_tilemap(self, width, height)
	new_piece_index = randi() % all_pieces.size()
	spawn_piece()
	redraw_tilemap()

func display_next_piece():
	new_piece_index = randi() % all_pieces.size()
	var new_piece_rotations: Array = all_pieces[new_piece_index]
	var current_rotation: Array = new_piece_rotations[0]
	var x: int = next_piece_pivot.x
	var y: int = next_piece_pivot.y
	
	for y_index in [-1, 0, 1]:
		for x_index in [-1, 0, 1]:
			matrix[y + y_index][x + x_index] = -1
			if current_rotation[y_index + 1][x_index + 1] > -1:
				matrix[y + y_index][x + x_index] = new_piece_index + 2

func spawn_piece():
	score += 1
	$ScoreLabel.text = str(score)
	
	piece_index = new_piece_index
	rotations = all_pieces[piece_index]
	rotataion_index = 0
	
	pivot_postion = spawn_position
	display_next_piece()
	redraw_piece()

func redraw_piece(add_ten: bool = false):
	var current_rotation: Array = rotations[rotataion_index]
	var x: int = pivot_postion.x
	var y: int = pivot_postion.y
	
	for y_index in [-1, 0, 1]:
		for x_index in [-1, 0, 1]:
			if current_rotation[y_index + 1][x_index + 1] > -1:
				matrix[y + y_index][x + x_index] = piece_index + 2
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

func get_y_values_for_lines() -> Dictionary[int, int]:
	var current_rotation: Array = rotations[rotataion_index]
	var x: int = pivot_postion.x
	var y: int = pivot_postion.y
	
	var y_values: Dictionary[int, int] = {}
	
	for y_index in [-1, 0, 1]:
		for x_index in [-1, 0, 1]:
			var is_part_of_piece: bool = current_rotation[y_index + 1][x_index + 1] > -1
			if is_part_of_piece:
				y_values[y_index + y] = 0

	var keys = y_values.keys()
	for y_value in keys:
		for x_value in range(1, playable_width + 1):
			if matrix[y_value][x_value] < 12:
				y_values.erase(y_value)
				break
	
	return y_values

func destory_lines(y_values: Array[int]) -> void:
	for y in y_values:
		for yi in range(y, 2, -1):
			for xi in  range(1, playable_width + 1):
				matrix[yi][xi] = matrix[yi - 1][xi]

func _on_timer_timeout() -> void:
	if check_collision(0, 1):
		if check_game_over():
			get_tree().reload_current_scene()
		
		redraw_piece(true)
		
		var y_values: Dictionary[int, int] = get_y_values_for_lines()
		print(y_values.keys())
		destory_lines(y_values.keys())
		
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
		$Timer.wait_time = default_timer_interval * 0.1
	elif event.is_action_released("ui_down"):
		$Timer.wait_time = default_timer_interval
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
		else:
			var swipe_vector: Vector2 = event.position - touch_start_pos
			if swipe_vector.length() > min_swipe_distance:
				var degrees: float = rad_to_deg(swipe_vector.angle())
				if abs(degrees) < 30.0:
					if not check_collision(1, 0):
						undraw_piece()
						pivot_postion += Vector2i(1, 0)
						redraw_piece()
						redraw_tilemap()
				elif abs(degrees) > 150.0:
					if not check_collision(-1, 0):
						undraw_piece()
						pivot_postion += Vector2i(-1, 0)
						redraw_piece()
						redraw_tilemap()
				elif degrees < -60.0 and degrees > -120.0:
					if not check_collision_on_rotation():
						undraw_piece()
						rotataion_index = (rotataion_index + 1) % rotations.size()
						redraw_piece()
						redraw_tilemap()
