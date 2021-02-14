extends ColorRect

signal on_game_over

var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _display_time():
	var total_time_sec : int = $Timer.time_left
	var time_min : int = int($Timer.time_left) / 60
	var time_sec : int = int($Timer.time_left) % 60
	
	if time_sec < 10:
		return str(time_min) + ":0" + str(time_sec)
	else:
		return str(time_min) + ":" + str(time_sec)

func _process(delta):
	$ScoreLabel.text = "Score: " + str(score)
	$TimeLabel.text = "Time Left: " + _display_time()

func start_game_timer(time : int):
	$Timer.start(time)

func _on_Timer_timeout():
	emit_signal("on_game_over")
