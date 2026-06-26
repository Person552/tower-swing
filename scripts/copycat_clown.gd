extends Node

var position_list = []
var frame_num = 0
var time = 0.0

const FILE_FPS = 30
@export_file("*.json") var path_file = "res://clownpaths/new_path.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file = FileAccess.open(path_file, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			for item in data_received :
				position_list.append(item)
		else:
			print("Unexpected data")
	
	#print(position_list)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	var position_frame = floor(time*FILE_FPS)
	if position_frame < len(position_list) :
		var lerp_position = (time-(position_frame/FILE_FPS))*FILE_FPS
		#print(position_frame, " ", lerp_position)
		var frame_position = Vector2(0,0)
		if position_frame == len(position_list)-1 :
			frame_position = Vector2(position_list[position_frame][0], position_list[position_frame][1])
		else :
			frame_position = Vector2((position_list[position_frame][0]*abs(1-lerp_position))+(position_list[position_frame+1][0]*lerp_position),
									 (position_list[position_frame][1]*abs(1-lerp_position))+(position_list[position_frame+1][1]*lerp_position))
		self.position = frame_position
		frame_num += 1
