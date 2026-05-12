extends Node
class_name GameManager

@export var constellations_parent : Node
@export var outlaw_star : OutlawStar
@onready var constellations_arr : Array = constellations_parent.get_children().filter(func(child): return child.get_script() == preload("res://Scripts/constellation.gd"))
var available_indices : Array[int] = []


func _ready() -> void:
	for i in constellations_arr.size(): available_indices.append(i)
	_set_active_constellation(randi_range(0,constellations_arr.size()-1))

func _give_outlaw_star(constellation : Constellation) -> void:
	constellation.has_outlaw_star = true # set bool flag
	outlaw_star.enter_constellation(constellation) # call func on outlaw star so it knows where to go

func _set_active_constellation(index : int) -> void:
	# grab indexed constellation and give outlaw star
	var constellation = constellations_arr[index] as Constellation
	_give_outlaw_star(constellation)
	constellation.constellation_completed.connect(_choose_new_constellation.bind(index)) # connect signal
	print(constellation.name + " has outlaw star")

func _choose_new_constellation(previous_index : int) :
	
	# remove completed constellation from available list & disconnect signal
	available_indices.erase(previous_index)
	constellations_arr[previous_index].constellation_completed.disconnect(_choose_new_constellation.bind(previous_index))
	
	# check if all have been completed
	if (available_indices.size() == 0):
		_all_constellations_completed()
		return
	
	# grab random next index and set active
	var next_index = available_indices.pick_random()
	_set_active_constellation(next_index)

func _all_constellations_completed() -> void :
	print("All Constellations Completed")
