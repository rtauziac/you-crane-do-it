extends Node

var game_ended = false


func _ready():
	$PauseMenu.visible = false


func _input(event):
	if event.is_action_pressed("pause"):
		_toggle_pause_menu()


func _toggle_pause_menu():
	get_tree().paused = not get_tree().paused
	$PauseMenu.visible = get_tree().paused
	$Town.set_mission_ui_visibility(not get_tree().paused)
	pass


func _restart_game():
	get_tree().reload_current_scene()
	get_tree().paused = false


func _quit():
	get_tree().quit()


func _on_game_ended():
	game_ended = true
	if not get_tree().paused:
		_toggle_pause_menu()
	$PauseMenu/EndGameTitleLayout.visible = true
	$PauseMenu/CenterContainer/MarginContainer2/MarginContainer/VBoxContainer/ResumeButton.text = "Resume and mess around"
