extends CharacterBody2D


const WALKSPEED = 30
const JUMP_VELOCITY = -40.0
var music_manager
var hooked = false
var target_hookpoint = 0

func get_hookpoint_from_id(id: int) :
	for hookpoint in $"../HookPoints".get_children() :
		if hookpoint.id == id :
			return hookpoint

func _ready() -> void:
	music_manager = $"../MusicManager"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Autowalk on ground
	if is_on_floor() :
		velocity.x = WALKSPEED
	
	if hooked :
		var hookpoint_ref = get_hookpoint_from_id(target_hookpoint)
		var hookpoint_type = hookpoint_ref.type
		

	if Input.is_action_just_pressed("hook") :
		print(music_manager.current_lateness)
		hooked = true
	
	if Input.is_action_just_released("hook") :
		print(music_manager.current_lateness)
		hooked = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()
