extends Node3D

signal change_camera_target_to_node3D(node: Node3D)


@export var mission_list: Array[Mission]
var _current_mission_index = -1
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
	_current_mission_index += 1
	if _current_mission_index < 0 or _current_mission_index > mission_list.size() - 1:
		push_warning("no mission corresponding to index %d" % _current_mission_index)
		return
	# display mission text
	_current_mission_start_dialog_index = 0
	_mission_done = false
	var dialog_line = mission_list[_current_mission_index].mission_text[_current_mission_start_dialog_index]
	$MissionOverlay.display_mission_text(dialog_line)
	var target = null if dialog_line.camera_target == null else $City.find_child(dialog_line.camera_target)
	emit_signal("change_camera_target_to_node3D", target)


func delay_then_start_mission(delay: float):
	start_mission_timer.start(delay)

func show_end_mission():
	_mission_done = true
	$MissionOverlay.display_mission_text(mission_list[_current_mission_index].end_text[_current_mission_end_dialog_index])
	
	
func _input(event):
	if event.is_action_pressed("grab"):
		if _current_mission_index > mission_list.size() - 1:
			return
		var mission = mission_list[_current_mission_index]
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
				emit_signal("change_camera_target_to_node3D", null)
				activate_objects_for_mission(mission)
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
				delay_then_start_mission(2.0)


func activate_objects_for_mission(mission: Mission):
	# activate mission objects when text is done displayed
	# - enable grabbable
	var grabbable = find_child(mission.object_name, true, true)
	grabbable.add_to_group("grab")
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

