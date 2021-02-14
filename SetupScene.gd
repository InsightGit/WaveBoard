extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Calibration_ready_to_play():
	$InstructionPanel.start_game()

func _on_InstructionPanel_concealed():
	$Calibration.hide()
	$GameScene.show()

func _on_InstructionPanel_start_game():
	print("aid: " + str($Calibration/CalibrationPanel.aid))
	
	$GameScene.start_game($Calibration/CalibrationPanel.sensitivity, 
						  $Calibration/CalibrationPanel.center, 
						  $Calibration/CalibrationPanel.aid,
						  $Calibration/CalibrationPanel.invert_x,
						  $Calibration/CalibrationPanel.invert_y)
