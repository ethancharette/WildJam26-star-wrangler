extends MeshInstance3D
class_name Line3D

@export var points : PackedVector3Array
@export var color : Color
@export var material : Material

var line_immediate_mesh : ImmediateMesh

func _ready() -> void:
	line_immediate_mesh = ImmediateMesh.new()
	mesh = line_immediate_mesh
	material_override = material


func _process(delta: float) -> void:
	line_immediate_mesh.clear_surfaces()
	
	if len(points) <= 0:
		return
	
	line_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for i in range(1, len(points)):
		line_immediate_mesh.surface_set_color(color)
		line_immediate_mesh.surface_add_vertex(points[i - 1]) # doubling is intentional
		line_immediate_mesh.surface_add_vertex(points[i])
	
	line_immediate_mesh.surface_end()
