extends Node

var time_begin
var time_delay
var bpm
var current_beat
var current_lateness

signal beat(beat_num)

func _ready():
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	bpm = $Player.stream.bpm
	$Player.play()

func _process(delta):
	# Obtain from ticks.
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	# Compensate for latency.
	time -= time_delay
	# May be below 0 (did not begin yet).
	time = max(0, time)
	
	var prev_frame_beat = current_beat
	current_beat = floor((time/60)*bpm)
	
	if current_beat != prev_frame_beat :
		beat.emit(current_beat)
	
	current_lateness = time/60*bpm - current_beat
	

func _on_beat(beat_num: Variant) -> void:
	print(current_beat, " | ", current_lateness)
