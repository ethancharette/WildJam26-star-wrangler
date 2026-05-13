extends Area3D
class_name Constellation

@export var star_sprite : Sprite3D
@export var line_sprite : Sprite3D
@export var shaded_sprite : Sprite3D
@export var look_threshold_degrees : float = 25.0

enum SpriteType {STARS, LINES, SHADED}

@onready var player_camera : Camera3D = get_viewport().get_camera_3d()

var is_focused : bool = false
func _set_focused(b : bool):
	is_focused = b
	focused_changed.emit(is_focused)
	_set_sprite(SpriteType.STARS) if not is_focused else _set_sprite(SpriteType.LINES)
var has_outlaw_star : bool = false
var is_completed : bool = false

# signals
signal constellation_completed
signal focused_changed(focused : bool)

func _ready() -> void:
	_set_sprite(SpriteType.STARS) # cache base texture
	look_at(player_camera.global_position, Vector3.UP) # billboard to camera at ready since cam doesn't move

func _process(delta: float) -> void:
	if is_completed or not has_outlaw_star: return;


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if is_completed: return # guard if doesn't have the outlaw star or is already fixed
	
	if event is InputEventMouseButton:
		var mb_event : InputEventMouseButton = event as InputEventMouseButton
		match mb_event.button_index:
			MOUSE_BUTTON_LEFT:
				if not mb_event.pressed and not is_focused:
					_set_focused(true)
					player_camera.focus_on_position(self)
			MOUSE_BUTTON_RIGHT:
				if not mb_event.pressed and is_focused:
					_set_focused(false)
					player_camera.remove_focus()
			_:
				pass

func _is_camera_looking_at_me() -> bool:
	var to_constellation = (global_position - player_camera.global_position).normalized() # dir to constellation
	var camera_forward = -player_camera.global_transform.basis.z # camera forward angle (yeah why is forward negative)
	var dot = camera_forward.dot(to_constellation)
	var threshold = cos(deg_to_rad(look_threshold_degrees)) # convert threshold deg to dot value
	return dot >= threshold

func complete_constellation() -> void:
	is_focused = false
	is_completed = true
	constellation_completed.emit()
	has_outlaw_star = false
	_set_sprite(SpriteType.SHADED)
	
	player_camera.remove_focus()

func _set_sprite(type : SpriteType) -> void:
	match type:
		SpriteType.STARS:
			star_sprite.visible = true
			line_sprite.visible = false
			shaded_sprite.visible = false
		SpriteType.LINES:
			star_sprite.visible = true
			line_sprite.visible = true
			shaded_sprite.visible = false
		SpriteType.SHADED:
			star_sprite.visible = true
			line_sprite.visible = true
			shaded_sprite.visible = true
		_:
			print("Unable to set sprite of ",name)
