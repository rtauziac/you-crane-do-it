extends Node3D

signal change_camera_target_to_node3D(node: Node3D)
signal mission_ended
signal game_ended


@export var mission_list: Array[Mission]
@export var current_mission_index = -1
var _current_mission_start_dialog_index = 0
var _current_mission_end_dialog_index = 0
var _mission_done = false

var start_mission_timer = Timer.new()


func _ready():
	add_child(start_mission_timer)
	start_mission_timer.one_shot = true
	start_mission_timer.connect("timeout", func(): 
		self.start_next_mission()
	)
	delay_then_start_mission(2.0)


func start_next_mission():
	current_mission_index += 1
	if current_mission_index < 0 or current_mission_index > mission_list.size() - 1:
		push_warning("no mission corresponding to index %d" % current_mission_index)
		if current_mission_index == mission_list.size():
			emit_signal("game_ended")
		return
	# display mission text
	_current_mission_start_dialog_index = 0
	_current_mission_end_dialog_index = 0
	_mission_done = false
	var dialog_line = mission_list[current_mission_index].mission_text[_current_mission_start_dialog_index]
	$MissionOverlay.display_mission_text(dialog_line)
	var target = null if dialog_line.camera_target == null else $City.find_child(dialog_line.camera_target)
	emit_signal("change_camera_target_to_node3D", target)


func delay_then_start_mission(delay: float):
	start_mission_timer.start(delay)


func show_end_mission():
	_mission_done = true
	$MissionOverlay.hide_mission_task()
	var dialog_line = mission_list[current_mission_index].end_text[_current_mission_end_dialog_index]
	$MissionOverlay.display_mission_text(dialog_line)
	var target = null if dialog_line.camera_target == null else $City.find_child(dialog_line.camera_target)
	emit_signal("change_camera_target_to_node3D", target)


func set_mission_ui_visibility(visible: bool):
	$MissionOverlay.visible = visible


func _input(event):
	if event.is_action_pressed("grab"):
		if current_mission_index > mission_list.size() - 1 or current_mission_index < 0:
			return
		var mission = mission_list[current_mission_index]
		if not _mission_done:
			if _current_mission_start_dialog_index < mission.mission_text.size() - 1:
				_current_mission_start_dialog_index += 1
				var dialog_line: MissionDialog = mission.mission_text[_current_mission_start_dialog_index]
				$MissionOverlay.display_mission_text(dialog_line)
				var target = null if dialog_line.camera_target == null else $City.find_child(dialog_line.camera_target)
				emit_signal("change_camera_target_to_node3D", target)
				get_tree().root.get_viewport().set_input_as_handled()
			elif $MissionOverlay.is_dialog_visible():
				# hide dialog
				$MissionOverlay.hide_dialog()
				$MissionOverlay.set_mission_task(mission.mission_task)
				emit_signal("change_camera_target_to_node3D", null)
				activate_objects_for_mission(mission)
				get_tree().root.get_viewport().set_input_as_handled()
		else:
			if _current_mission_end_dialog_index < mission.end_text.size() - 1:
				_current_mission_end_dialog_index += 1
				var dialog_line = mission.end_text[_current_mission_end_dialog_index]
				$MissionOverlay.display_mission_text(dialog_line)
				if dialog_line.camera_target != null:
					var target = $City.find_child(dialog_line.camera_target)
					if target != null:
						emit_signal("change_camera_target_to_node3D", target)
				get_tree().root.get_viewport().set_input_as_handled()
			elif $MissionOverlay.is_dialog_visible():
				$MissionOverlay.hide_dialog()
				emit_signal("change_camera_target_to_node3D", null)
				emit_signal("mission_ended")
				delay_then_start_mission(2.0)
				get_tree().root.get_viewport().set_input_as_handled()


func activate_objects_for_mission(mission: Mission):
	# activate mission objects when text is done displayed
	# - enable grabbable
	var grabbable = find_child(mission.object_name, true, true) as RigidBody3D
	grabbable.add_to_group("grab")
	grabbable.physics_material_override = preload("res://city/object_phys_material.tres")
	grabbable.linear_damp = 1
	grabbable.angular_damp = 1
	grabbable.freeze = false
	(grabbable.get_child(0) as MeshInstance3D).set_surface_override_material(0, preload("res://palette_material.tres").duplicate(true))
	# - enable target
	var target = find_child(mission.destination_name, true, true) as Area3D
	target.monitoring = true
	target.connect("body_entered", func body_entered_callable(body):
		if body == grabbable:
			_mission_done = true
			target.monitoring = false
			self.show_end_mission()
			target.disconnect("body_entered", target.get_signal_connection_list("body_entered")[0].get("callable"))
	)
	get_tree().root.get_viewport().set_input_as_handled()

