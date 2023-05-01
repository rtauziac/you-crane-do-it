extends Node3D

@export var turn_speed = 0.4
@export var move_speed = 0.8
@export var min_move_pos = 1
@export var max_move_pos = 6


func _physics_process(delta):
	var turn_rate = Input.get_axis("left", "right")
	$crane.rotate_y(-turn_rate * turn_speed * delta)
	var back_forth_rate = Input.get_axis("backward", "forward")
#	$crane/HookScript.translate_object_local(Vector3.FORWARD * back_forth_rate * move_speed * delta)
	$crane/HookScript.position.z = clamp($crane/HookScript.position.z - back_forth_rate * move_speed * delta, -max_move_pos, -min_move_pos)


func _on_change_camera_target(node):
	$crane/Arm/CameraAnchor/CabinCamera.set_target(node)


func _on_mission_ended():
	$crane/HookScript._release_object()
