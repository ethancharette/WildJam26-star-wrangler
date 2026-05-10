extends Node3D

@export var speed : Vector3 = Vector3(0,0,0);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_x(speed.x * delta);
	rotate_y(speed.y * delta);
	rotate_z(speed.z * delta);
