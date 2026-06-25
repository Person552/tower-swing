@tool
extends Node2D

@export_enum("swing", "pull", "loop") var type = "swing" :
	set(new_type) :
		type = new_type
		$AnimatedSprite2D.animation = type
@export var id : int

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var name_id = String(self.name).replace("HookPoint","")
		if name_id.is_valid_int() :
			self.id = name_id
