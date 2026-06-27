extends Control

@onready var margin_container: MarginContainer = $MarginContainer/PanelContainer/MarginContainer

var dialogue_step = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("hook") :
		dialogue_step += 1
		for node in margin_container.find_children("*") :
			if str(node.name)[-1] == str(dialogue_step) :
				node.visible = true
			else :
				node.visible = false
		if dialogue_step == 7 :
			$Love.visible = true
		elif dialogue_step == 8 :
			$ColorRect.visible = true
			$ImportantMessage.visible = true
		elif dialogue_step == 9 :
			get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
