extends Node3D

@export var turn_speed = 1.0
@export var move_speed = 0.4

func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func _physics_process(delta):
	var turn_rate = Input.get_axis("left", "right")
	$crane.rotate_y(-turn_rate * turn_speed * delta)
	var back_forth_rate = Input.get_axis("backward", "forward")
	$crane/HookScript.translate_object_local(Vector3.FORWARD * back_forth_rate * move_speed * delta)
