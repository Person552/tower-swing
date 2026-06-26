@tool
extends Path2D

@export_file("*.json") var target_file
@export_tool_button("Load Path", "Curve2D") var load_action = load_path

func load_path() :
	var file = FileAccess.open(target_file, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json_content = JSON.parse_string(content)
	self.curve.clear_points()
	for coordinate in json_content :
		print(coordinate)
		self.curve.add_point(Vector2(coordinate[0],coordinate[1]))
