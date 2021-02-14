extends Control

signal concealed
signal start_game

var stage : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("next")
	
	rect_scale = Vector2(1, 1)
	
	$TextureRect.show()

func _input(event : InputEvent):
	if event.is_action_pressed("ui_accept"):
		match stage:
			0:
				$TextLabel.text = "Looking for a Wii Balance Board...\n" + \
								  "(press the red sync button now)"
				
				$AnimationPlayer.stop(true)
				$ActionTriangle.hide()
				
				$LoadingRect.show()
				$AnimationPlayer.play("loading")
				
				stage = 1
			2:
				$AnimationPlayer.play("smallize")
				
				$ActionTriangle.hide()
				
				$TextLabel.text = \
					"Adjust the settings on the right panel to match your board.\n" + \
					"When you're ready, hit the Play button!"
				
				stage = 3

func _process(delta):
	if stage == 1:
		if WiiBalanceBoard.connected:
			stage = 2
			
			$TextLabel.text = "Done! Now let's calibrate!"
			
			$AnimationPlayer.stop(true)
			$LoadingRect.hide()
			
			$ActionTriangle.show()
			$AnimationPlayer.play("next")
		elif WiiBalanceBoard.connecting:
			$TextLabel.text = "Connecting to the Wii Balance Board..."

func start_game():
	stage = 4
	
	$TextureRect.show()
	$TextLabel.show()
	
	$GameRect1.rect_size = Vector2(0,0)
	$GameRect1.show()
	$GameRect2.rect_size = Vector2(0,0)
	$GameRect2.show()
	$GameRect3.rect_size = Vector2(0,0)
	$GameRect3.show()
	show()
	
	$TextLabel.text = "Get ready..."
	
	$AnimationPlayer.play("largeize")

func _on_AnimationPlayer_animation_finished(anim_name : String):
	if stage == 4 and anim_name == "largeize":
		emit_signal("concealed")
		stage = 5
		
		$AnimationPlayer.play("start_game")
	elif stage == 5 and anim_name == "start_game":
		emit_signal("start_game")
		$AnimationPlayer.play("post_game")
	elif stage == 5 and anim_name == "post_game":
		hide()
