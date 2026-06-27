extends CharacterBody2D

var beat_preview_duration = 4
var timing_offset_ms = 200

@onready var copycat_clown = $".."
@onready var music_manager = $"../../MusicManager"
@onready var input_previews_holder = $"../../InputPreviews"
@onready var hookpoints_holder = $"../../HookPoints"
@onready var gui = $"../../../../GameplayGUI"

@onready var beat_list = music_manager.current_beat_list
@onready var bpm = music_manager.bpm

@onready var input_preview_scene = preload("res://scenes/input_preview.tscn")

var quality_thresholds = {
	"okay":400,
	"good":200,
	"great":100,
	"perfect":50
}
@onready var max_off_s = quality_thresholds["okay"]/1000.0

var prev_frame_angle = 0
var initial_angle = 0
var angular_momentum = 0
var angle_lerp_value = 0

var input_preview_created = false
var current_beat = 0
var current_hook_id = 0
var song_hook_id = 0
var recent_hit_hookpoint = -1

var hooked = false

var failed = false
var prev_frame_position = Vector2.ZERO
var fail_velocity = Vector2.ZERO
var fail_music_lerp_value = 0

func fail() :
	if not failed :
		failed = true
		hooked = false
		input_previews_holder.queue_free()
		fail_velocity.x *= 1.5
		music_manager.find_child("MusicPlayerFail").play(music_manager.find_child("MusicPlayer").get_playback_position())
		#music_manager.find_child("MusicPlayer").stop()
	
		self.reparent($"../..")
	

func create_input_preview(duration_beats) :
	var new_scene = input_preview_scene.instantiate()
	var shrink_time = (60/bpm)*(duration_beats-1)
	var end_time = ((60/bpm)*current_beat) + ((60/bpm)*(duration_beats-1))
	var target_position = copycat_clown.get_position_at_time(end_time)
	if target_position :
		new_scene.position = target_position
		#print(copycat_clown.position.distance_to(copycat_clown.get_position_at_time((60/bpm)*current_beat)))
		new_scene.shrink_time = shrink_time
		input_previews_holder.add_child(new_scene)
		#new_scene.finished_shrinking.connect(_debug_preview_pop)
		new_scene.shrinking = true
	else :
		print("target position out of bounds")


func get_next_input_beat(start_beat : int, filter : String) :
	var beat_check = ""
	var index = 0
	while beat_check != filter :
		if start_beat+index >= len(beat_list) :
			return "e"
		beat_check = beat_list[start_beat+index]
		index += 1
	return [start_beat+index]


func find_closest_beat(current_time, filter=null) :
	var closest_beat = round((current_time/60)*bpm)
	if filter == null :
		return closest_beat
	var index = 0
	var beat_check = ""
	var offset
	while beat_check != filter :
		offset = int(index/2.0)
		if index %2 != 0 :
			offset *= -1
		beat_check = beat_list[closest_beat+offset]
		index += 1
		#print(offset, " ", beat_check)
	#if offset < 0 :
		#print("late")
	#else :
		#print("early")
	return closest_beat+offset


func get_input_offset(input_type) :
	var current_time = music_manager.current_time
	var beat_number = find_closest_beat(current_time, input_type)
	var beat_time = (60/bpm)*beat_number
	return current_time-beat_time


func display_timing(offset) :
	var offset_ms = int(offset*1000)
	var quality = "okay"
	var best_threshold = INF
	for threshold in quality_thresholds :
		if abs(offset_ms) < quality_thresholds[threshold] and best_threshold > quality_thresholds[threshold] :
			best_threshold = quality_thresholds[threshold]
			quality = threshold
	gui.display_timing(quality, offset_ms)
	gui.pulse_vignette(quality)
	#gui.zoom(0.2, 1.05)


func try_hook() :
	var offset = get_input_offset("h")
	offset += timing_offset_ms/1000.0
	if abs(offset) > max_off_s :
		fail()
	else :
		display_timing(offset)
		hooked = true
		initial_angle = $AnimatedSprite2D.rotation
		angle_lerp_value = 0.0
		recent_hit_hookpoint = current_hook_id
		$FailureTimer.stop()


func try_release() :
	var offset = get_input_offset("r")
	offset += timing_offset_ms/1000.0
	if abs(offset) > max_off_s :
		fail()
	else :
		display_timing(offset)
		hooked = false
		current_hook_id += 1
		$FailureTimer.stop()


func get_hookpoint_from_id(id: int) :
	for hookpoint in hookpoints_holder.get_children() :
		if hookpoint.id == id :
			return hookpoint


func _physics_process(delta: float) -> void:
		if not failed :
			fail_velocity = self.global_position-prev_frame_position
			prev_frame_position = self.global_position
		else :
			self.position += fail_velocity
			self.fail_velocity += get_gravity()*delta*0.2
			
			fail_music_lerp_value = min(fail_music_lerp_value+delta*2,1)
			music_manager.find_child("MusicPlayer").volume_db = linear_to_db(abs(1-fail_music_lerp_value))
			music_manager.find_child("MusicPlayerFail").volume_db = linear_to_db(fail_music_lerp_value)
		
		var hookpoint_ref = get_hookpoint_from_id(current_hook_id)
		$Hook.target_pos = hookpoint_ref.position
		if hooked and not failed :
			angle_lerp_value = min((angle_lerp_value+delta*4.0),1.0)
			prev_frame_angle = $AnimatedSprite2D.rotation
			$AnimatedSprite2D.rotation = lerp_angle(initial_angle, $AnimatedSprite2D.global_position.angle_to_point(hookpoint_ref.position), angle_lerp_value)
			#$AnimatedSprite2D.look_at(hookpoint_ref.position)
			
			$Hook.visible = true
			angular_momentum = ($AnimatedSprite2D.rotation-prev_frame_angle)
		else :
			$AnimatedSprite2D.rotation += angular_momentum
			$Hook.visible = false


func _process(_delta: float) -> void:
	if not failed :
		Input.set_use_accumulated_input(false) 
		if Input.is_action_just_pressed("hook") :
			try_hook()
		elif Input.is_action_just_released("hook") :
			try_release()


func _on_music_manager_beat(beat_num: Variant) -> void:
	if not failed :
		current_beat = beat_num
		#var result = get_next_input_beat(current_beat)
		#next_beat_time = result[0]
		#next_beat = result[1]
		if beat_num+beat_preview_duration < len(beat_list) and beat_list[beat_num+beat_preview_duration] != "" :
			create_input_preview(beat_preview_duration)
			
		
		if beat_list[beat_num] == "h" :
			if recent_hit_hookpoint != song_hook_id  :
				$FailureTimer.start((max_off_s-(timing_offset_ms/1000.0)))
			
		elif beat_list[beat_num] == "r" :
			song_hook_id += 1
			if current_hook_id != song_hook_id :
				$FailureTimer.start((max_off_s-(timing_offset_ms/1000.0)))


func _on_failure_timer_timeout() -> void:
	fail()
