extends Control

var paused = false
var pause_begin_time = 0.0

const DO_INITIAL_PAUSE = false

var inital_pause = false

signal unpaused(pause_time)


func pause() :
	get_tree().paused = true
	self.visible = true
	pause_begin_time = Time.get_ticks_usec()


func unpause() :
	$PauseMenuContainer.visible = false
	$CountdownContainer.visible = true
	$UnpauseTimer.start()
	

#func _ready() :
	#pause()
	#unpause()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void :
	if DO_INITIAL_PAUSE and not inital_pause and Time.get_ticks_usec() > 100 :
		inital_pause = true
		pause()
		unpause()
	if not $UnpauseTimer.is_stopped() :
		$CountdownContainer/PauseCountdown.text = str(int(ceil($UnpauseTimer.time_left)))
	elif Input.is_action_just_pressed("pause") :
		paused = not paused
		if paused :
			pause()
		else :
			unpause()
	elif Input.is_action_just_pressed("restart") :
		_on_restart_pressed()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _on_unpause_timer_timeout() -> void:
	get_tree().paused = false
	self.visible = false
	$PauseMenuContainer.visible = true
	$CountdownContainer.visible = false
	$CountdownContainer/PauseCountdown.text = "3"
	unpaused.emit(Time.get_ticks_usec()-pause_begin_time)
