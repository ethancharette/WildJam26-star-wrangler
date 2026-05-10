extends Sprite3D

@export var shaded_texture : Texture;
var base_texture : Texture;

@export var look_threshold_degrees : float = 10.0; # padding to avoid needing to be spot on

@onready var player_camera : Camera3D = get_viewport().get_camera_3d();

var is_looked_at : bool = false
var discovered : bool = false

func _ready() -> void:
	base_texture = texture; # cache base texture
	look_at(player_camera.global_position, Vector3.UP) # billboard to camera at ready since cam doesn't move

func _process(delta: float) -> void:
	if discovered: return;
	var looked_at = _is_camera_looking_at_me()
	
	if looked_at != is_looked_at:
		is_looked_at = looked_at
		texture = shaded_texture if is_looked_at else base_texture

func _unhandled_input(event: InputEvent) -> void:
	if not is_looked_at or discovered: return # guard if already discovered or not looking at
	
	if event is InputEventMouseButton:
		var mb_event : InputEventMouseButton = event as InputEventMouseButton
		match mb_event.button_index:
			MOUSE_BUTTON_LEFT:
				if not mb_event.pressed: # left mouse button pressed while looking at undiscovered constellation
					discovered = true
					texture = shaded_texture # just to ensure the right tex is showing
			_:
				pass

func _is_camera_looking_at_me() -> bool:
	var to_constellation = (global_position - player_camera.global_position).normalized() # dir to constellation
	var camera_forward = -player_camera.global_transform.basis.z # camera forward angle (yeah why is forward negative)
	var dot = camera_forward.dot(to_constellation)
	var threshold = cos(deg_to_rad(look_threshold_degrees)) # convert threshold deg to dot value
	return dot >= threshold
