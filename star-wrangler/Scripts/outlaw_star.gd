extends Area3D
class_name OutlawStar

var current_constellation : Constellation

#region Activity
var active : bool = false
func _set_active(b : bool) -> void:
	print("Outlaw Active: ",b)
	active = b
#endregion

#region Movement
@export var speed : float = 5.0
@export var target_change_frequency : float = 5.0
var current_target_position : Vector3
var position_change_cooldown : float = 0.0
#endregion

#region Capture Settings
@export var capture_hover_time : float = 2.0 # time needed to hover over to capture it
@export var capture_decay_rate : float = 0.1
var capturing : bool = false
var capture_time : float = 0.0
#endregion


func _process(delta: float) -> void:
	if not active: return
	
	# position change cooldown
	position_change_cooldown += delta
	if position_change_cooldown >= target_change_frequency:
		position_change_cooldown = 0.0
		current_target_position = _get_new_target_pos()
	
	# move towards new target pos
	global_position.move_toward(current_target_position, speed)
	global_position = global_position.lerp(current_target_position, speed * delta)
	
	# capture logic
	capture_time += delta if capturing else -capture_decay_rate * delta
	
	if capture_time >= capture_hover_time:
		capture_time = 0.0
		capturing = false
		_set_active(false)
		current_constellation.focused_changed.disconnect(_set_active)
		current_constellation.complete_constellation()

func _get_new_target_pos() -> Vector3:
	# from origin of current_constellation
	var half_width = (current_constellation.texture.get_width() * current_constellation.pixel_size * current_constellation.scale.x) / 2.0
	var half_height = (current_constellation.texture.get_height() * current_constellation.pixel_size * current_constellation.scale.y) / 2.0

	var random_local_x = randf_range(-half_width, half_width)
	var random_local_y = randf_range(-half_height, half_height)
	var local_offset = Vector3(random_local_x, random_local_y, 0.0)
	print("New Target Pos: ",current_constellation.to_global(local_offset))
	return current_constellation.to_global(local_offset)

func enter_constellation(new_constellation : Constellation) -> void:
	current_constellation = new_constellation
	
	current_target_position = _get_new_target_pos() # first get a new target position
	
	reparent(current_constellation)
	current_constellation.focused_changed.connect(_set_active) # connect signal
	global_rotation = current_constellation.global_rotation # set global rot and pos
	global_position = current_constellation.global_position

func _on_mouse_entered() -> void:
	capturing = true


func _on_mouse_exited() -> void:
	capturing = false
