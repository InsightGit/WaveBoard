extends Control

signal restart_game

var all_time_max_score : int = -100000000
var session_max_score : int = -100000000


# Called when the node enters the scene tree for the first time.
func _ready():
	var save_file = File.new()
	
	if save_file.open("user://highscore.txt", File.READ) == OK:
		all_time_max_score = int(save_file.get_float())
		
		save_file.close()

func on_game_over(score: int):
	var save_file = File.new()
	
	all_time_max_score = max(all_time_max_score, score)
	session_max_score = max(session_max_score, score)
	
	if save_file.open("user://highscore.txt", File.WRITE) == OK:
		save_file.store_float(all_time_max_score)
		
		save_file.close()
	
	$CurrentScore.text = "Final Score: " + str(score)
	$HighScores.text = "Session High Score: " + str(session_max_score) + \
					   "\nAll-time High Score: " + str(all_time_max_score)
	
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_PlayAgainButton_pressed():
	hide()
	
	emit_signal("restart_game")
