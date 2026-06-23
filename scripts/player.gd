extends CharacterBody2D

const WALKSPEED = 60
const PULL_SPEED = 200
const LOOP_SPEED = 240
const JUMP_VELOCITY = -40.0
var music_manager
var hooked = false
var target_hookpoint = 0
var swing_speed = 0

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
		$Hook.visible = true
		$Hook.target_pos = hookpoint_ref.position - self.position
		
		if hookpoint_type == "swing" :
			var direction = self.position.direction_to(hookpoint_ref.position)
			direction = direction.rotated(deg_to_rad(90))
			swing_speed += (self.position.x - hookpoint_ref.position.x) * -0.1
			#swing_speed *= 0.99
			velocity = direction * swing_speed
		elif hookpoint_type == "pull" :
			if self.position.distance_to(hookpoint_ref.position) > 10 :
				velocity = self.position.direction_to(hookpoint_ref.position) * PULL_SPEED
		elif hookpoint_type == "loop" :
			var direction = self.position.direction_to(hookpoint_ref.position)
			direction = direction.rotated(deg_to_rad(90))
			swing_speed += 2
			velocity = direction * swing_speed
	else :
		$Hook.visible = false

	if Input.is_action_just_pressed("hook") :
		print(music_manager.current_lateness)
		swing_speed = velocity.x/2
		hooked = true
	
	if Input.is_action_just_released("hook") :
		print(music_manager.current_lateness)
		target_hookpoint = (target_hookpoint+1)%3
		hooked = false

	move_and_slide()
