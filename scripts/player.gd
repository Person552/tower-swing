extends CharacterBody2D


const SPEED = 30
const JUMP_VELOCITY = -40.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor() :
		velocity.x = SPEED

	# Handle jump.
	if Input.is_action_just_pressed("hook") :
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()
