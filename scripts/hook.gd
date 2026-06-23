extends Node2D

var target_pos : Vector2
var player_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_pos = $"..".position
	self.position = target_pos
	$Chain.region_rect.size.y = self.position.length()
	self.look_at(player_pos)
