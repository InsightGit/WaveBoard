extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal boat_zero_requested

var center : Vector2 = Vector2(0, 0)
var sensitivity : Vector2
var wii_balance_board

var _aid : Vector2

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
	
	_aid.x = value / 2
	
	$VisualAid.axis = _aid

func _on_AidYSlider_value_changed(value):
	$AidYSlider/Label.text = "Aid Y-length: " + str(value)
	
	_aid.y = value / 2
	
	$VisualAid.axis = _aid

func _oncenterButton_pressed():
	center = wii_balance_board.get_com()
	
	$VisualAid.center = center
	
	$CenterButton.text = "Center:" + str(center)

func _on_ResetCenterButton_pressed():
	center = Vector2(0, 0)
	$CenterButton.text = "Center"

func _on_BoatZeroButton_pressed():
	emit_signal("boat_zero_requested")
