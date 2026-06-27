extends Node

@export_file("*.json") var beatmap_path = "res://beatmaps/fools_masquerade.json"

var time_begin
var time_delay
var bpm
var current_beat
var current_lateness
var current_beat_list
var current_time
var music_start_time = 0.000

signal beat(beat_num)

func load_beatmap(beatmap_path : String) :
	var beat_list = []
	var file = FileAccess.open(beatmap_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			for item in data_received :
				for i in range(item["start"]-1):
					beat_list.append("")
				beat_list.append("h")
				for i in range(item["release"]-1):
					beat_list.append("")
				beat_list.append("r")
			return beat_list
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

func _ready():
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	bpm = $MusicPlayer.stream.bpm
	if beatmap_path :
		current_beat_list = load_beatmap(beatmap_path)
	$MusicPlayer.play(music_start_time)

func _process(_delta):
	# Obtain from ticks.
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	# Compensate for latency.
	time -= time_delay
	# May be below 0 (did not begin yet).
	time = max(0, time)
	
	current_time = time
	
	var prev_frame_beat = current_beat
	current_beat = floor((time/60)*bpm)
	
	current_lateness = floor((time - ((current_beat/bpm)*60))*1000)
	#print(current_lateness)
	
	if current_beat != prev_frame_beat :
		beat.emit(current_beat)
