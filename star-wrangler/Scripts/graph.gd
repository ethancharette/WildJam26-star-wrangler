extends Resource
class_name Graph

@export var edge_lookup : Dictionary[int, Array] # Dictionary[int, Array[int]]

func _init(p_edge_lookup : Dictionary[int, Array] = {}):
	edge_lookup = p_edge_lookup

func is_possible_move(from : int, to : int) -> bool:
	return edge_lookup.has(from) and edge_lookup[from].has(to)

func graph_contains(node : int) -> bool:
	return edge_lookup.has(node) or edge_lookup.values().any(func(array : Array[int]) -> bool: return array.has(node))

func get_paths_from(node : int) -> Array[int]:
	if not graph_contains(node):
		return []
	var output : Array[int] = []
	output.assign(edge_lookup[node]) # stupid nested generics not casting
	return output

func get_paths_to(node : int) -> Array[int]:
	if not graph_contains(node):
		return []
	var output : Array[int] = []
	for lookup in edge_lookup:
		if edge_lookup[lookup].has(node):
			output.append(lookup)
	return output

func get_neighbor_count(node: int) -> int:
	return len(get_paths_from(node))

func get_neighbor_by_index(node : int, index : int) -> int:
	return get_paths_from(node)[index]

func get_random_neighbor(node : int) -> int:
	return get_neighbor_by_index(node, randi_range(0, get_neighbor_count(node) - 1))
