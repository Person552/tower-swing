extends Camera2D

@onready var player = $"..".find_child("Player")
@onready var simulation_clown = $"..".find_child("SimulationClown")

const X_OFFSET = 0
const SMOOTHING_SPEED = 12
const JUMP_DISTANCE = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player :
		var player_position
		if player.find_parent("CopycatClown") :
			player_position = player.find_parent("CopycatClown").position
		else :
			player_position = player.position
		#self.position.x = 0
		var target_x_position = player_position.x + X_OFFSET
		self.position.y = player_position.y
		#var target_x_position = 0
		if abs(self.position.x-target_x_position) < JUMP_DISTANCE :
			self.position.x = target_x_position
		if self.position.x != target_x_position :
			self.position.x += (target_x_position-self.position.x)*SMOOTHING_SPEED*delta
		#self.position.x = target_x_position
	elif simulation_clown :
		self.position = simulation_clown.position
