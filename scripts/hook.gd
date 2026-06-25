extends Node2D

var target_pos : Vector2
var player_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	player_pos = $"..".position + $"../Sticky Hand Hardpoint".position
	self.position = target_pos
	$StickyHandRing.position.x = self.position.distance_to($"../Sticky Hand Hardpoint".position)
	$Chain.region_rect.size.x = self.position.length() - 20 # $StickyHandRing.texture.get_width()
	# Changed above and altered textures and offset prevent a visual glitch where the arm and ring would disconnect
	self.look_at(player_pos)
