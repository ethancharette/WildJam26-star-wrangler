extends Camera3D

## the camera sensitivity as a percentage, x and y indicate horizontal and vertical axes respectively
@export var camera_sensitivity : Vector2 = Vector2(0.005, 0.005)

## the degrees from the horizon the player can look up
@export var max_look_above_degrees : float = 90
## the degrees from the horizon the player can look down
@export var max_look_below_degrees : float = 0 

## how many degrees to zoom in/out per mouse wheel increment
@export var zoom_increment : float = 5 

## how far out can you zoom in degrees
@export var max_zoom : float = 90 
## how far in can you zoom in degrees
@export var min_zoom : float = 5 
## How fast the camera will zoom to it's target fov
@export var zoom_speed : float = 5

var target_fov : float = fov

var camera_rotation : Vector2 = Vector2() # radians

var right_click_held : bool = false;

func _ready() -> void:
	# set initial look rotation upwards (copied what u did for input)
	camera_rotation.y = max_look_above_degrees
	camera_rotation.y = clamp(camera_rotation.y, deg_to_rad(-max_look_below_degrees), deg_to_rad(max_look_above_degrees)) # prevent looking up or down more than possible
	rotate_object_local(Vector3(1,0,0), camera_rotation.y)

func _process(delta: float) -> void:
	if (fov > 1. || fov < 179.):
		fov = lerp(fov, target_fov, zoom_speed * delta); # smooth out change in fov using lerp

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if right_click_held:
			var mm_event : InputEventMouseMotion = event as InputEventMouseMotion
			camera_rotation.x -= event.screen_relative.x * camera_sensitivity.x # idk why inverting it is the proper one it's weird
			camera_rotation.y -= event.screen_relative.y * camera_sensitivity.y
			
			camera_rotation.x = fposmod(camera_rotation.x, PI * 2) # clean up horizontal rotation, roating 360 degrees puts you back at 0
			camera_rotation.y = clamp(camera_rotation.y, deg_to_rad(-max_look_below_degrees), deg_to_rad(max_look_above_degrees)) # prevent looking up or down more than possible
			
			transform.basis = Basis() # reset rotation
			
			rotate_object_local(Vector3(0, 1, 0), camera_rotation.x) # first rotate horizontally
			rotate_object_local(Vector3(1, 0, 0), camera_rotation.y) # then rotate vertically
	
	elif event is InputEventMouseButton:
		var mb_event : InputEventMouseButton = event as InputEventMouseButton
		match mb_event.button_index:
			MOUSE_BUTTON_RIGHT:
				right_click_held = mb_event.pressed
			MOUSE_BUTTON_WHEEL_UP: # zoom in
				target_fov = max(fov - zoom_increment, min_zoom) 
			MOUSE_BUTTON_WHEEL_DOWN: # zoom out
				target_fov = min(fov + zoom_increment, max_zoom)
			_:
				pass
