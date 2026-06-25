@tool
extends Node2D

@export_enum("swing", "pull", "loop") var type = "swing" :
	set(new_type) :
		type = new_type
		$AnimatedSprite2D.animation = type
@export var id : int

var current_offset = Vector2(0.0, 0.0)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var name_id = String(self.name).replace("HookPoint","")
		if name_id.is_valid_int() :
			self.id = name_id
	else:
		# Code for hookpoints to randomly float around
		current_offset.x += randf_range(-0.1,0.1)
		current_offset.y += randf_range(-0.1,0.1)
		if current_offset.x > 2:
			current_offset.x = 2
		if current_offset.x < -2:
			current_offset.x = -2
		if current_offset.y > 2:
			current_offset.x = 2
		if current_offset.y < -2:
			current_offset.x = -2
		$AnimatedSprite2D.offset = Vector2(int(current_offset.x), int(current_offset.y))
