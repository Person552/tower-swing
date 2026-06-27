extends Node2D

var target_pos : Vector2
var player_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	player_pos = $"..".global_position
	self.global_position = target_pos
	$StickyHandRing.position.x = self.global_position.distance_to($"..".find_child("Sticky Hand Hardpoint").global_position)
	$Chain.region_rect.size.x = self.position.length() - 20 # $StickyHandRing.texture.get_width()
	# Changed above and altered textures and offset prevent a visual glitch where the arm and ring would disconnect
	self.look_at($"../AnimatedSprite2D/Sticky Hand Hardpoint".global_position)
