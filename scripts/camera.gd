extends Camera2D

@onready var player = get_node("../Player")
const X_OFFSET = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.x = player.position.x + 60
