extends Node3D


func set_override_material_to_grab():
	var grabbable = get_tree().get_nodes_in_group("grab")
	for grab in grabbable:
		var grab_mesh = grab.get_child(0) as MeshInstance3D
		grab_mesh.set_surface_override_material(0, preload("res://palette_material.tres").duplicate(true))
