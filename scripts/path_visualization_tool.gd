@tool
extends Path2D

@export_file("*.json") var target_file
@export_tool_button("Load Path", "Curve2D") var load_action = load_path

var prev_loaded_file

func load_path() :
	var file = FileAccess.open(target_file, FileAccess.READ)
	var content = file.get_as_text()
	prev_loaded_file = content
	file.close()
	var json_content = JSON.parse_string(content)
	self.curve.clear_points()
	for coordinate in json_content :
		self.curve.add_point(Vector2(coordinate[0],coordinate[1]))

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if FileAccess.open(target_file, FileAccess.READ).get_as_text() != prev_loaded_file :
			load_path()
