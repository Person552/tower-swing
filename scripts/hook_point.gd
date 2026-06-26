@tool
extends Node2D

const max_drift = 2
const light_scale = 1
const TYPE_COLORS = {
	"swing":Color("6dffff"),
	"pull":Color("ef5f4a"),
	"loop": Color("fee114")
}

@export_enum("swing", "pull", "loop") var type = "swing" :
	set(new_type) :
		type = new_type
		$AnimatedSprite2D.animation = type
		$PointLight2D.color = TYPE_COLORS[type]
@export var id : int

@export var set_release_angle = false
@export_range(0, 360, 0.1, "degrees") var release_angle

var current_offset = Vector2(0.0, 0.0)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var name_id = String(self.name).replace("HookPoint","")
		if name_id.is_valid_int() :
			self.id = name_id
	else:
		# Code for hookpoints to set light size
		$PointLight2D.scale = Vector2(light_scale, light_scale)
