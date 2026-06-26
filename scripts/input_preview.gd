extends Node2D

const INNER_SIZE = 0.02
const OUTER_SIZE = 0.06
var shrink_time = 1.0

@onready var current_shrink_time = shrink_time

const END_SIZE = 0.03
const END_TIME = 0.1

var shrinking = true
var ending = false

signal finished_shrinking(this)

func stop_shrinking() :
	shrinking = false
	ending = true
	$OuterCircle.queue_free()
	finished_shrinking.emit(self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$OuterCircle.scale.x = OUTER_SIZE
	$OuterCircle.scale.y = OUTER_SIZE
	
	$InnerCircle.scale.x = INNER_SIZE
	$InnerCircle.scale.y = INNER_SIZE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if shrinking :
		if shrink_time <= 0 :
			stop_shrinking()
		shrink_time -= delta
		$OuterCircle.scale.x = (shrink_time/current_shrink_time * (OUTER_SIZE-INNER_SIZE))+INNER_SIZE
		$OuterCircle.scale.y = (shrink_time/current_shrink_time * (OUTER_SIZE-INNER_SIZE))+INNER_SIZE
		$OuterCircle.modulate = Color($OuterCircle.modulate, min(inverse_lerp(OUTER_SIZE, (OUTER_SIZE+INNER_SIZE)/2, $OuterCircle.scale.x),1))
	elif ending :
		if $InnerCircle.scale.x >= END_SIZE :
			self.queue_free()
		var grow_amount = (END_SIZE-INNER_SIZE)/END_TIME
		$InnerCircle.scale.x += grow_amount * delta
		$InnerCircle.scale.y += grow_amount * delta
		$InnerCircle.modulate = Color($InnerCircle.modulate, max(inverse_lerp(END_SIZE, (END_SIZE+INNER_SIZE)/2, $InnerCircle.scale.x),0)*0.3)
		
