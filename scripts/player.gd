extends CharacterBody2D

const BEAT_PREVIEW_DURATION = 4

@onready var copycat_clown = $".."
@onready var music_manager = $"../../MusicManager"
@onready var input_previews_holder = $"../../InputPreviews"

@onready var beat_list = music_manager.current_beat_list
@onready var bpm = music_manager.bpm

@onready var input_preview_scene = preload("res://scenes/input_preview.tscn")

var quality_thresholds = {
	"okay":300,
	"good":200,
	"great":100,
	"perfect":50
}

var input_preview_created = false
var current_beat = 0

func fail() :
	self.reparent(get_tree().root.get_child(0))


func create_input_preview(duration_beats) :
	var new_scene = input_preview_scene.instantiate()
	var shrink_time = (60/bpm)*(duration_beats-1)
	var end_time = ((60/bpm)*current_beat) + ((60/bpm)*(duration_beats-1))
	new_scene.position = copycat_clown.get_position_at_time(end_time)
	#print(copycat_clown.position.distance_to(copycat_clown.get_position_at_time((60/bpm)*current_beat)))
	new_scene.shrink_time = shrink_time
	input_previews_holder.add_child(new_scene)
	new_scene.finished_shrinking.connect(_debug_preview_pop)
	new_scene.shrinking = true


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
	$"../../../../GameplayGUI".display_timing(quality, offset_ms)


func try_hook() :
	var offset = get_input_offset("h")
	display_timing(offset)


func try_release() :
	var offset = get_input_offset("r")
	display_timing(offset)


func _process(_delta: float) -> void:
	Input.set_use_accumulated_input(false)
	if Input.is_action_just_pressed("hook") :
		try_hook()
	elif Input.is_action_just_released("hook") :
		try_release()

func _debug_preview_pop(_this) :
	pass
	#print(this.position.distance_to(copycat_clown.position))


func _on_music_manager_beat(beat_num: Variant) -> void:
	current_beat = beat_num
	#var result = get_next_input_beat(current_beat)
	#next_beat_time = result[0]
	#next_beat = result[1]
	if beat_list[beat_num+BEAT_PREVIEW_DURATION] != "" :
		create_input_preview(BEAT_PREVIEW_DURATION)
	
	#try_hook()
	#if beat_list[beat_num] == "h" :
		#try_hook()
	#elif beat_list[beat_num] == "r" :
		#try_release()
