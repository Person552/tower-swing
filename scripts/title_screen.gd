extends Control

@onready var main_scene = preload("res://scenes/main_testing.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CreditsContainer.set_process(false)
	$SettingsContainer.set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_credits_button_pressed() -> void:
	#focused_container = "credits"
	$CreditsContainer.visible = true


func _on_settings_button_pressed() -> void:
	#focused_container = "settings"
	$SettingsContainer.visible = true


func _on_credits_exit_button_button_down() -> void:
	#focused_container = "main"
	$CreditsContainer.visible = false


func _on_settings_exit_button_pressed() -> void:
	#focused_container = "main"
	$SettingsContainer.visible = false


func _on_delay_box_value_changed(value: float) -> void:
	$SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer3/DelaySlider.value = value


func _on_delay_slider_value_changed(value: float) -> void:
	$SettingsContainer/MarginContainer/VBoxContainer/HBoxContainer3/DelayBox.value = value


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)
