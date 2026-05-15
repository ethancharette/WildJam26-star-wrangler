extends Area3D
class_name Constellation

@export var look_threshold_degrees : float = 25.0

@export_group("Sprites")
@export var star_sprite : Sprite3D
@export var line_sprite : Sprite3D
@export var shaded_sprite : Sprite3D

@export_group("Star Graph")
@export var star_positions : Array[Node3D]
@export var constellation_graph : Graph

@export_group("Debug Drawing")
@export var debug_draw_enabled : bool
@export var debug_draw_material : Material
@export var debug_draw_color : Color

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
	if (debug_draw_enabled):
		_debug_draw_lines()

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

func _debug_draw_lines() -> void:
	for node in constellation_graph.edge_lookup:
		for target in constellation_graph.edge_lookup[node]:
			var line : Line3D = Line3D.new()
			line.points = [star_positions[node].position, star_positions[target].position]
			line.color = debug_draw_color
			line.material = debug_draw_material
			add_child(line)
			line.position = Vector3.ZERO
