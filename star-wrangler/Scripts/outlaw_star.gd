extends Area3D
class_name OutlawStar

var current_constellation : Constellation
var current_constellation_node : int

@export var sprite : Sprite3D
#region Activity
var active : bool = false
func _set_active(b : bool) -> void:
	active = b
	sprite.visible = active
#endregion

#region Movement
@export var speed : float = 5.0
@export var target_change_frequency : float = 5.0
var current_target_position : Vector3
var position_change_cooldown : float = 0.0
#endregion

#region Tag Stuff
@export var star_click_distance : float = 10.0

#region Capture Settings
@export var capture_hover_time : float = 2.0 # time needed to hover over to capture it
@export var capture_decay_rate : float = 0.1
var capturing : bool = false
var capture_time : float = 0.0
#endregion

enum OutlawStates {
	SETUP,
	PLAYER_TURN,
	OUTLAW_TURN,
}
var cur_state : OutlawStates = OutlawStates.SETUP

func _unhandled_input(event: InputEvent) -> void:
	if not active: return
	if not cur_state == OutlawStates.PLAYER_TURN : return
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var camera : Camera3D = current_constellation.player_camera
				var mouse_position = get_viewport().get_mouse_position()
				var ray_start = camera.project_ray_origin(mouse_position)
				var ray_end = ray_start + camera.project_ray_normal(mouse_position)
				
				var closest_star : int = -1
				var closest_star_dist_sqr : float = INF
				
				for i in range(0, len(current_constellation.star_positions) - 1):
					var star = current_constellation.star_positions[i]
					
					var dist_sqr : float = point_on_line(ray_start, ray_end, star.global_position).distance_squared_to(star.global_position)
					if (dist_sqr <= closest_star_dist_sqr):
						closest_star_dist_sqr = dist_sqr
						closest_star = i
					
				if closest_star != -1 and closest_star_dist_sqr < star_click_distance * star_click_distance:
					_try_player_move(closest_star)
					return

func _try_player_move(star : int) -> void:
	if not current_constellation.constellation_graph.is_possible_move(current_constellation.player_icon_position, star):
		return
	
	current_constellation._set_player_icon_position(star)
	_victory_check()
	cur_state = OutlawStates.OUTLAW_TURN

func point_on_line(line_start : Vector3, line_end : Vector3, point_position : Vector3) -> Vector3:
	var line_direction := (line_start - line_end).normalized()
	var vector_to_object := point_position - line_start
	var distance := line_direction.dot(vector_to_object)
	var closest_position := line_start + distance * line_direction
	return closest_position

func _ready() -> void:
	_set_active(false)

func _process(delta: float) -> void:
	# move towards new target pos
	global_position.move_toward(current_target_position, speed)
	global_position = global_position.lerp(current_target_position, speed * delta)
	
	if not active: return
	
	match cur_state:
		OutlawStates.SETUP:
			current_target_position = _get_new_target_pos()
			global_position = current_target_position
			cur_state = OutlawStates.PLAYER_TURN
		OutlawStates.PLAYER_TURN:
			pass
		OutlawStates.OUTLAW_TURN:
			position_change_cooldown += delta
			if position_change_cooldown >= target_change_frequency:
				position_change_cooldown = 0.0
				current_target_position = _get_new_target_pos()
				print("outlaw")
				_victory_check()
				cur_state = OutlawStates.PLAYER_TURN
	
	# position change cooldown
	
	
	# capture logic
	#capture_time += delta if capturing else -capture_decay_rate * delta

func _victory_check() -> void:
	if current_constellation.player_icon_position == current_constellation_node:
		await get_tree().create_timer(1.0).timeout
		_set_active(false)
		current_constellation.focused_changed.disconnect(_set_active)
		current_constellation.complete_constellation()

func _get_new_target_pos() -> Vector3:
	# from origin of current_constellation
	#var sprite = current_constellation.star_sprite
	#var texture = sprite.texture
	#var half_width = (texture.get_width() * sprite.pixel_size * current_constellation.scale.x) / 2.0
	#var half_height = (texture.get_height() * sprite.pixel_size * current_constellation.scale.y) / 2.0

	#var random_local_x = randf_range(-half_width, half_width)
	#var random_local_y = randf_range(-half_height, half_height)
	#var local_offset = Vector3(random_local_x, random_local_y, 0.0)
	#print("New Target Pos: ",current_constellation.to_global(local_offset))
	#return current_constellation.to_global(local_offset)
	var new_target_node : int = 0
	if (current_constellation_node == -1):
		new_target_node = current_constellation.outlaw_starting_position
	else:
		new_target_node = current_constellation.constellation_graph.get_random_neighbor(current_constellation_node)
	current_constellation_node = new_target_node
	return current_constellation.to_global(current_constellation.star_positions[new_target_node].position)

func enter_constellation(new_constellation : Constellation) -> void:
	current_constellation = new_constellation
	
	current_constellation_node = -1
	current_target_position = _get_new_target_pos() # first get a new target position
	
	reparent(current_constellation)
	current_constellation.focused_changed.connect(_set_active) # connect signal
	global_rotation = current_constellation.global_rotation # set global rot and pos
	global_position = current_constellation.global_position

func _on_mouse_entered() -> void:
	capturing = true


func _on_mouse_exited() -> void:
	capturing = false
