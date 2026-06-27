extends Control
var zoom_intensity = 2
var screenshake_intensity = 10

const SHAKE_DECAY = 5.0
const SHAKE_TIME_SPEED = 20.0
var shake_time = 0.0

var noise = FastNoiseLite.new()

var offset = Vector2.ZERO

const QUALITY_COLORS = {
"okay":   Color("#FFA500"),
"good":   Color("008000"),
"great":  Color("00FFFF"),
"perfect":Color("FF00FF")
}

const QUALITY_TEXT = {
"okay":   "[color=orange][b]OK...",
"good":   "[color=green][b]GOOD",
"great":  "[color=cyan][b]GREAT!",
"perfect":"[color=magenta][b]PERFECT!!"
}

func pulse_vignette(quality : String) :
	$Vignette.modulate = QUALITY_COLORS[quality]
	$VignetteTimer.start()

func display_timing(quality, timing : int) :
	$CenterContainer/ScoreDisplay/QualityWord.text = QUALITY_TEXT[quality]
	var timing_text = "( %sms )"%(timing)
	if timing > 0 :
		timing_text = "( +%sms )"%(timing)
	$CenterContainer/ScoreDisplay/Timing.text = timing_text
	$ScoreDisplayTimer.start()

func zoom(duration:float,intensity:float) :
	$ZoomTimer.start(duration)
	zoom_intensity = intensity

func shake_screen(duration:float,intensity:float) :
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	screenshake_intensity = intensity
	shake_time = 0.0
	$ShakeTimer.start(duration)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not $ShakeTimer.is_stopped() :
		shake_time += delta*SHAKE_TIME_SPEED
		offset = Vector2(
			noise.get_noise_2d(shake_time,0)*screenshake_intensity,
			noise.get_noise_2d(0,shake_time)*screenshake_intensity,
		)
		
		screenshake_intensity = max(screenshake_intensity-SHAKE_DECAY*delta,0)
	else :
		offset = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") :
		pass
		#pulse_vignette()
		#$PauseCountdownTimer.start()
		#display_timing("okay", 0.005)
		#zoom(0.2, 1.05)
		#shake_screen(0.4, 6)
		
	if not $VignetteTimer.is_stopped() :
		$Vignette.visible = true
		var time_percentage = $VignetteTimer.time_left/$VignetteTimer.wait_time
		var alpha = (-2*abs(time_percentage - 0.5)+1)
		$Vignette.modulate = Color($Vignette.modulate,alpha)
	else :
		$Vignette.visible = false
	
	if not $PauseCountdownTimer.is_stopped() :
		$CenterContainer2/PauseCountdown.visible = true
		$CenterContainer2/PauseCountdown.text = "[b]%s"%(int(ceil($PauseCountdownTimer.time_left)))
	else :
		$CenterContainer2/PauseCountdown.visible = false
		
	if not $ScoreDisplayTimer.is_stopped() :
		$CenterContainer/ScoreDisplay.visible = true
		var time_percentage = $ScoreDisplayTimer.time_left/$ScoreDisplayTimer.wait_time
		var alpha = min(4*time_percentage,1)
		$CenterContainer/ScoreDisplay.modulate = Color($CenterContainer/ScoreDisplay.modulate,alpha)
	else :
		$CenterContainer/ScoreDisplay.visible = false
	
	if not $ZoomTimer.is_stopped() :
		var time_percentage = $ZoomTimer.time_left/$ZoomTimer.wait_time
		var zoom_amount = ((4-(4*zoom_intensity))*((time_percentage-0.5)**2))+zoom_intensity
		$MarginContainer/MainViewport.offset_transform_scale = Vector2(zoom_amount, zoom_amount)
	else :
		$MarginContainer/MainViewport.offset_transform_scale = Vector2(1, 1)
	
	$MarginContainer/MainViewport.offset_transform_position = offset
