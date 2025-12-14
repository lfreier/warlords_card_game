class_name DifficultySelection
extends Control

@export var buttons: Array[Button]

func init() -> void:
	for i in range(0, buttons.size()):
		if i == 0:
			buttons[i].pressed.connect(diff1_selected)
			buttons[i].anchor_left = 0.25
			buttons[i].anchor_right = 0.25
		elif i == 1:
			buttons[i].pressed.connect(diff2_selected)
			buttons[i].anchor_left = 0.75
			buttons[i].anchor_right = 0.75
		buttons[i].size.x = 400

func diff1_selected() -> void:
	signals.set_difficulty.emit(0)
	signals.next_intro_scene.emit("diff")
	queue_free()
	
func diff2_selected() -> void:
	signals.set_difficulty.emit(1)
	signals.next_intro_scene.emit("diff")
	queue_free()
