@tool
extends Node2D

@export_enum("swing", "pull", "loop") var type = "swing" :
	set(new_type) :
		type = new_type
		$AnimatedSprite2D.animation = type
@export var id : int

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		print(String(self.name)[-1])
		if String(self.name)[-1].is_valid_int() :
			self.id = int(String(self.name)[-1])
