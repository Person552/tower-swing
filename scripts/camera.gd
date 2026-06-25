extends Camera2D

@onready var player = get_node("../Player")
const X_OFFSET = 60
const SMOOTHING_SPEED = 0.2
const JUMP_DISTANCE = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#self.position.x = 0
	var target_x_position = player.position.x + X_OFFSET
	#var target_x_position = 0
	if abs(self.position.x-target_x_position) < JUMP_DISTANCE :
		self.position.x = target_x_position
	if self.position.x != target_x_position :
		self.position.x += (target_x_position-self.position.x)*SMOOTHING_SPEED
	#self.position.x = target_x_position
