@tool
extends Node2D

@export_enum("swing", "pull", "loop") var type = "swing" :
	set(new_type) :
		type = new_type
		$AnimatedSprite2D.animation = type
@export var id : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
