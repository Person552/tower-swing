extends Control

# -----   important vars   -----

## If there is already a map with this name, it will be loaded. Otherwise, it will be created.
@export var target_filename = "new_map.json"
## If set to true will attempt to load the image at image_filename instead of loading a file.
@export var load_image = false
## Name to save images as when exporting/importing images, will overwrite existing images with the same name.
@export var image_filename = "new_image.png"
## The song to play in the editor, for now this must be manually matched if loading a map.
@export var song : AudioStream
## Whether or not to play a metronome sound every beat.
@export var metronome_sound = false

# ----- end important vars -----

const BEATMAP_PATH = "res://beatmaps/"

@onready var target_path = BEATMAP_PATH+target_filename
@onready var image_path = BEATMAP_PATH+image_filename

var current_beat_list

var time_begin
var time_delay
var bpm
var current_beat = 0
var started = false
var prev_edited_beat = -1
var buffered_input = ""

var metronome_state = false
const METRONOME_COLOR_1 = Color(255,0,0)
const METRONOME_COLOR_0 = Color(0,0,0)

var player_holding = false
const INPUT_COLOR_DOWN = Color(0.0, 1.0, 0.0, 1.0)
const INPUT_COLOR_UP = Color(0.0, 0.0, 0.0, 1.0)

const BEAT_OVERVIEW_BASE = Color(1.0, 1.0, 1.0, 1.0)
const BEAT_OVERVIEW_SWING = Color("6dffff")
const BEAT_OVERVIEW_PULL = Color("ef5f4a")
const BEAT_OVERVIEW_LOOP = Color("fee114")
const BEAT_OVERVIEW_GENERIC = Color(0.0, 1.0, 0.0, 1.0)

const BEAT_OVERVIEW_COLOR_DICT = {"s":BEAT_OVERVIEW_SWING,"p":BEAT_OVERVIEW_PULL,"l":BEAT_OVERVIEW_LOOP,"h":BEAT_OVERVIEW_GENERIC}

@onready var beat_text = $CenterContainer/VBoxContainer/HBoxContainer/PanelContainer3/VBoxContainer/Beat
@onready var time_text = $CenterContainer/VBoxContainer/HBoxContainer/PanelContainer3/VBoxContainer/Time
@onready var metronome_rect = $CenterContainer/VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/MetronomeRect
@onready var input_rect = $CenterContainer/VBoxContainer/HBoxContainer/PanelContainer2/VBoxContainer/InputRect
@onready var seek_slider = $CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer2/SeekSlider
@onready var seek_box = $CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/HBoxContainer2/SeekBox
@onready var progress_bar = $CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/ProgressBar
@onready var beat_overview = $CenterContainer/VBoxContainer/PanelContainer2/VBoxContainer/BeatOverview

func save_file() :
	var delay = 0
	var beat_map_array = []
	var current_hookpoint_id = -1
	var index = 0
	for input in current_beat_list :
		delay += 1
		if input in ["s","p","l","h"] :
			var time_pressed = index*(60.0/bpm)
			var note_name = {"s":"Swing","p":"Pull","l":"Loop","h":"Unknown (likely an old beatmap)"}[input]
			beat_map_array.append({"start":delay,"release":0,"notes":"Time: %ss"%[time_pressed],"hookpoint type":note_name})
			current_hookpoint_id += 1
			delay = 0
		elif input == "r" :
			beat_map_array[current_hookpoint_id]["release"] = delay
			delay = 0
		index += 1
	
	var content = JSON.stringify(beat_map_array, "\t")
	
	var file = FileAccess.open(target_path, FileAccess.WRITE)
	file.store_string(content)


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


func load_beatmap_image(beatmap_path : String) :
	var beat_list = []
	var image = Image.load_from_file(beatmap_path)
	for i in range(image.get_width()) :
		beat_list.append(" ")
	var prev_pixel = BEAT_OVERVIEW_BASE
	for pixel_x in range(image.get_width()) :
		var pixel = image.get_pixel(pixel_x,0)
		if pixel != prev_pixel :
			if pixel == BEAT_OVERVIEW_BASE :
				beat_list[pixel_x] = "r"
			elif pixel == BEAT_OVERVIEW_SWING :
				beat_list[pixel_x] = "s"
			elif pixel == BEAT_OVERVIEW_PULL :
				beat_list[pixel_x] = "p"
			elif pixel == BEAT_OVERVIEW_LOOP :
				beat_list[pixel_x] = "l"
			elif pixel == BEAT_OVERVIEW_GENERIC :
				beat_list[pixel_x] = "h"
		prev_pixel = pixel
	print(beat_list)
	return beat_list


func find_closest_beat(current_time) :
	return round((current_time/60)*bpm)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.stream = song
	if load_image and FileAccess.file_exists(image_path) :
		current_beat_list = load_beatmap_image(image_path)
	elif FileAccess.file_exists(target_path) :
		current_beat_list = load_beatmap(target_path)
	else :
		current_beat_list = []
	if len(current_beat_list) < $Player.stream.beat_count :
		for i in range($Player.stream.beat_count-len(current_beat_list)) :
			current_beat_list.append(" ")
	#print(current_beat_list)
	seek_box.max_value = $Player.stream.get_length()-0.1
	seek_slider.max_value = $Player.stream.get_length()-0.1
	progress_bar.max_value = $Player.stream.get_length()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if started :
		# Obtain from ticks.
		#var time = ($Player.get_playback_position() - time_begin)
		var time = $Player.get_playback_position()
		#print(time)
		# Compensate for latency.
		time -= time_delay
		# May be below 0 (did not begin yet).
		time = max(0, time)
		
		var prev_frame_beat = current_beat
		current_beat = floor((time/60)*bpm)
		
		if current_beat != prev_frame_beat :
			if metronome_sound :
				$"Metronome Player".play()
			metronome_state = not metronome_state
			if metronome_state :
				metronome_rect.color = METRONOME_COLOR_1
			else :
				metronome_rect.color = METRONOME_COLOR_0
		
		progress_bar.value = time
		
		if current_beat_list and current_beat < len(current_beat_list) :
			if current_beat_list[current_beat] in ["s","p","l","h"] :
				player_holding = true
			elif current_beat_list[current_beat] == "r" :
				player_holding = false
		
		var target_beat = find_closest_beat(time)
		if buffered_input != "" :
			if target_beat != prev_edited_beat :
				current_beat_list[target_beat] = buffered_input
				prev_edited_beat = current_beat
				buffered_input = ""
		
		elif Input.is_action_just_pressed("editor_swing") :
			if target_beat == prev_edited_beat :
				buffered_input = "s"
			else :
				current_beat_list[target_beat] = "s"
				prev_edited_beat = current_beat
		elif Input.is_action_just_pressed("editor_pull") :
			if target_beat == prev_edited_beat :
				buffered_input = "p"
			else :
				current_beat_list[target_beat] = "p"
				prev_edited_beat = current_beat
		elif Input.is_action_just_pressed("editor_loop") :
			if target_beat == prev_edited_beat :
				buffered_input = "l"
			else :
				current_beat_list[target_beat] = "l"
				prev_edited_beat = current_beat
		
		elif Input.is_action_just_released("editor_swing") or Input.is_action_just_released("editor_pull") or Input.is_action_just_released("editor_loop") :
			if target_beat == prev_edited_beat :
				buffered_input = "r"
			else :
				current_beat_list[target_beat] = "r"
				prev_edited_beat = current_beat
			
		var beat_overview_image = Image.create($Player.stream.beat_count,1,false,Image.FORMAT_RGB8)
		beat_overview_image.fill(BEAT_OVERVIEW_BASE)
		
		var drawing = false
		var index = 0
		var beat_overview_color = BEAT_OVERVIEW_GENERIC
		for input in current_beat_list :
			if input in ["s","p","l","h"] :
				beat_overview_color = BEAT_OVERVIEW_COLOR_DICT[input]
				drawing = true
			elif input == "r" :
				drawing = false
			if drawing :
				beat_overview_image.set_pixel(index,0,beat_overview_color)
			index += 1
		if Input.is_action_just_pressed("editor_save_image") :
			beat_overview_image.save_png(image_path)
		beat_overview.texture = ImageTexture.create_from_image(beat_overview_image)
			
	
	if player_holding :
		input_rect.color = INPUT_COLOR_DOWN
	else :
		input_rect.color = INPUT_COLOR_UP
	
	var max_beats = "?"
	if $Player.stream.beat_count > 0 :
		max_beats = $Player.stream.beat_count
	beat_text.text = "(%s / %s)"%[int(current_beat), max_beats]
	time_text.text = "(%s / %s)"%[round($Player.get_playback_position()*10)/10.0, round($Player.stream.get_length()*10)/10.0]


func _on_start_button_pressed() -> void:
	started = true
	#time_begin = Time.get_ticks_usec() / 1000000.0
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	bpm = $Player.stream.bpm
	$Player.play()


func _on_seek_box_value_changed(value: float) -> void:
	seek_slider.value = value


func _on_seek_slider_value_changed(value: float) -> void:
	seek_box.value = value


func _on_seek_button_pressed() -> void:
	$Player.seek(seek_slider.value)
	var time = $Player.get_playback_position()
	# Compensate for latency.
	time -= time_delay
	# May be below 0 (did not begin yet).
	time = max(0, time)
	current_beat = floor((time/60)*bpm)
	
	var prev_character = ""
	var index = 0
	while prev_character == "" :
		if current_beat-index < 0 or current_beat-index >= len(current_beat_list) :
			prev_character = "r"
		else :
			prev_character = current_beat_list[current_beat-index]
		index += 1
	if prev_character in ["s","p","l","h"] :
		player_holding = true
	else :
		player_holding = false



func _on_player_finished() -> void:
	save_file()
