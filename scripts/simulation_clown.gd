extends CharacterBody2D

const WALKSPEED = 60

const PULL_START_SPEED = 60
const PULL_ACCELERATION = 3
const PULL_MAX_SPEED = 250
const MAX_VELOCITY = 2000

const LOOP_PULL_FACTOR = 0.99
const LOOP_MIN_DISTANCE = 40

const SIMULATED_FPS = 120
const RECORDING_FPS = 30 # for best results this should be easily divisible into simulated_fps

var music_manager
var hooked = false
var target_hookpoint = 0
var swing_speed = 0
var swing_distance = 0.0

var current_beat = 0
var time = 0.0
var current_frame = 0

var recent_hookpoint_type
var recent_hookpoint_ref

var position_list = []

#const SWING_SPEED_CHANGE_BASE = 1.044
#const SWING_SPEED_CHANGE_DENOMINATOR = 4.6
const SWING_SPEED_CHANGE_MULT = -0.08
#func calculate_swing_speed_change(distance : float) :
	#var is_negative = distance < 0
	#distance = abs(distance)
	#var speed = sqrt(2*get_gravity().length()*distance)
	#if is_negative : speed *= -1
	#return speed

func get_hookpoint_from_id(id: int) :
	for hookpoint in $"../HookPoints".get_children() :
		if hookpoint.id == id :
			return hookpoint

func hook_hookpoint():
	swing_speed = 0.0
	hooked = true
	
func release_hookpoint() :
	target_hookpoint += 1
	hooked = false
	swing_distance = 0.0
	if recent_hookpoint_ref.set_release_angle :
		self.velocity = self.velocity.length() * Vector2.RIGHT.rotated(recent_hookpoint_ref.release_angle)

func take_snapshot() :
	position_list.append([position.x, position.y])

func save_file() :
	var json_string = JSON.stringify(position_list)
	var path = "res://clownpaths/fools_masquerade.json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	#print(FileAccess.get_open_error())
	file.store_string(json_string)

func _ready() -> void:
	music_manager = $"../MusicManager"

func _process(_delta: float) -> void:
	current_frame += 1
	time = current_frame*(1.0/SIMULATED_FPS)
	var prev_frame_beat = current_beat
	current_beat = floor((time/60)*music_manager.bpm)
	
	if current_frame % floor(SIMULATED_FPS/RECORDING_FPS) == 0 :
		take_snapshot()
	
	if current_beat != prev_frame_beat :
		on_simulated_beat(current_beat)
	
	# Add the gravity.
	if not hooked:
		velocity += get_gravity()*(1.0/SIMULATED_FPS)

	if velocity.length() > MAX_VELOCITY :
		velocity = velocity.normalized() * MAX_VELOCITY
	
	position += velocity*(1.0/SIMULATED_FPS)
	
	if hooked :
		var hookpoint_ref = get_hookpoint_from_id(target_hookpoint)
		var hookpoint_type = hookpoint_ref.type
		recent_hookpoint_type = hookpoint_type
		recent_hookpoint_ref = hookpoint_ref
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
				if hookpoint_type == "loop" :
					swing_speed *= 2
			if hookpoint_type == "swing" :
				#swing_speed = calculate_swing_speed_change(self.position.distance_to(hookpoint_ref.position))
				swing_speed += (self.position.x - hookpoint_ref.position.x) * SWING_SPEED_CHANGE_MULT
				#swing_speed *= 0.99
				#swing_speed = sqrt(2*get_gravity().length()*abs(self.position.y - hookpoint_ref.position.y))
			elif hookpoint_type == "loop" :
				if self.position.distance_to(hookpoint_ref.position) < LOOP_MIN_DISTANCE :
					swing_distance = LOOP_MIN_DISTANCE
				else :
					swing_distance *= LOOP_PULL_FACTOR
			#swing_speed *= 0.99
			velocity = direction * swing_speed
			
			var offset_distance = self.position.distance_to(hookpoint_ref.position)-swing_distance
			var offset_direction = self.position.direction_to(hookpoint_ref.position)
			self.position += offset_distance * offset_direction
			
		elif hookpoint_type == "pull" :
			var pull_direction = self.position.direction_to(hookpoint_ref.position)
			if swing_speed == 0.0 :
				var dot_product_temp = max(0,velocity.normalized().dot(pull_direction))
				swing_speed = max(PULL_START_SPEED, (self.velocity*dot_product_temp).length())
			swing_speed += PULL_ACCELERATION
			swing_speed = min(swing_speed, PULL_MAX_SPEED)
			velocity = pull_direction * swing_speed
			
		if hookpoint_type in ["pull"] :
			if self.position.distance_to(hookpoint_ref.position) < 10 :
				release_hookpoint()

	else :
		$Hook.visible = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_file()
		get_tree().quit() # default behavior

func on_simulated_beat(beat_num: Variant) -> void:
	if beat_num >= len(music_manager.current_beat_list) :
		save_file()
		get_tree().quit()
		#self.set_process(false)
	else :
		if music_manager.current_beat_list[beat_num] == "h" :
				hook_hookpoint()
		elif music_manager.current_beat_list[beat_num] == "r" :
			#target_hookpoint = (target_hookpoint+1)%3
			#if recent_hookpoint_type != "pull" :
			release_hookpoint()
