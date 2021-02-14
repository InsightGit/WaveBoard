extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal boat_zero_requested
signal ready_to_play

var aid : Vector2
var center : Vector2 = Vector2(0, 0)
var sensitivity : Vector2
var invert_x : bool = false
var invert_y : bool = false
var wii_balance_board

var _setup_step : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	sensitivity = Vector2($HorizontalSenseSlider.value, 
						  $VerticalSenseSlider.value)
	
	_on_AidXSlider_value_changed($AidXSlider.value)
	_on_AidYSlider_value_changed($AidYSlider.value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wii_balance_board != null and wii_balance_board.on_board(): 
		$VisualAid.update_aid(wii_balance_board.get_com())
	

func _on_HorizontalSenseSlider_value_changed(value):
	$HorizontalSenseSlider/Label.text = "Horizontal Sensitivity Ratio:\n" + \
		str(value)
	
	sensitivity.x = value

func _on_VerticalSenseSlider_value_changed(value):
	$VerticalSenseSlider/Label2.text = "Vertical Sensitivity Ratio:\n" + \
		str(value)
	
	sensitivity.y = value

func _on_AidXSlider_value_changed(value):
	$AidXSlider/Label.text = "Aid X-length: " + str(value)
	
	aid.x = value / 2
	
	$VisualAid.axis = aid

func _on_AidYSlider_value_changed(value):
	$AidYSlider/Label.text = "Aid Y-length: " + str(value)
	
	aid.y = value / 2
	
	$VisualAid.axis = aid

func _on_ResetCenterButton_pressed():
	center = Vector2(0, 0)
	$CenterButton.text = "Center"
	
	$ResetCenterButton.disabled = true

func _on_BoatZeroButton_pressed():
	emit_signal("boat_zero_requested")

func _on_PlayButton_pressed():
	emit_signal("ready_to_play")

func _on_CenterButton_pressed():
	center = wii_balance_board.get_com()
	
	$VisualAid.center = center
	
	$CenterButton.text = "Center:" + str(center)
	
	$ResetCenterButton.disabled = false

func _on_InvertX_toggled(button_pressed : bool):
	invert_x = button_pressed
	
	$VisualAid.invert_x = invert_x

func _on_InvertY_toggled(button_pressed : bool):
	invert_y = button_pressed
	
	$VisualAid.invert_y = invert_y
