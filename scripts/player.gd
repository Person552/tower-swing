extends CharacterBody2D

const WALKSPEED = 60

const PULL_START_SPEED = 60
const PULL_ACCELERATION = 6
const PULL_MAX_SPEED = 500

const JUMP_VELOCITY = -40.0

var music_manager
var hooked = false
var target_hookpoint = 0
var swing_speed = 0
var swing_distance = 0.0

func get_hookpoint_from_id(id: int) :
	for hookpoint in $"../HookPoints".get_children() :
		if hookpoint.id == id :
			return hookpoint

func _ready() -> void:
	music_manager = $"../MusicManager"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not hooked:
		velocity += get_gravity() * delta
	
	# Autowalk on ground 
	if is_on_floor() and not hooked :
		velocity.x = WALKSPEED

	if Input.is_action_just_pressed("hook") :
		print(music_manager.current_lateness)
		swing_speed = 0.0
		hooked = true
	
	if Input.is_action_just_released("hook") :
		print(music_manager.current_lateness)
		target_hookpoint = (target_hookpoint+1)%2
		hooked = false
		swing_distance = 0.0

	move_and_slide()
	
	if hooked :
		var hookpoint_ref = get_hookpoint_from_id(target_hookpoint)
		var hookpoint_type = hookpoint_ref.type
		$Hook.visible = true
		$Hook.target_pos = hookpoint_ref.position - self.position
		if swing_distance == 0.0 :
			swing_distance = self.position.distance_to(get_hookpoint_from_id(target_hookpoint).position)
		
		if hookpoint_type in ["swing", "loop"] :
			var direction = self.position.direction_to(hookpoint_ref.position)
			direction = direction.rotated(deg_to_rad(90))
			if swing_speed == 0.0 :
				swing_speed = velocity.length()
				if velocity.dot(direction) < 0 :
					swing_speed *= -1
			if hookpoint_type == "swing" :
				swing_speed += (self.position.x - hookpoint_ref.position.x) * -0.1
			elif hookpoint_type == "loop" :
				swing_speed += 3
			#swing_speed *= 0.99
			velocity = direction * swing_speed
			
			if get_slide_collision_count() == 0 :
				var offset_distance = self.position.distance_to(hookpoint_ref.position)-swing_distance
				var offset_direction = self.position.direction_to(hookpoint_ref.position)
				self.position += offset_distance * offset_direction
			
		elif hookpoint_type == "pull" :
			if swing_speed == 0.0 :
				swing_speed = PULL_START_SPEED
			swing_speed += PULL_ACCELERATION
			swing_speed = min(swing_speed, PULL_MAX_SPEED)
			if self.position.distance_to(hookpoint_ref.position) > 10 :
				velocity = self.position.direction_to(hookpoint_ref.position) * swing_speed

	else :
		$Hook.visible = false
