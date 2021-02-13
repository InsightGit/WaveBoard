extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var wii_balance_board

var _aid : Vector2
var _center : Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_AidXSlider_value_changed($AidXSlider.value)
	_on_AidYSlider_value_changed($AidYSlider.value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wii_balance_board != null: 
		var original_com : Vector2 = wii_balance_board.get_com()
		var new_com : Vector2 = original_com - _center
		var visual_aid_size : Vector2 = $VisualAid.rect_size * 2
		
		print("original:" + str(original_com))
		print("new:" + str(new_com))
		
		$VisualAid/COM.rect_position = Vector2(new_com.x * (visual_aid_size.x / _aid.x), 
										  new_com.y * (visual_aid_size.y / _aid.y)) + \
								  + (visual_aid_size / 2)

func _on_HorizontalSenseSlider_value_changed(value):
	$HorizontalSenseSlider/Label.text = "Horizontal Sensitivity Ratio:\n" + \
		str(value)

func _on_VerticalSenseSlider_value_changed(value):
	$VerticalSenseSlider/Label2.text = "Vertical Sensitivity Ratio:\n" + \
		str(value)

func _on_AidXSlider_value_changed(value):
	$AidXSlider/Label.text = "Aid X-length: " + str(value)
	
	_aid.x = value / 2
	
	$VisualAid/XposLabel.text = "x:" + str(_aid.x)
	$VisualAid/XnegLabel.text = "x:-" + str(_aid.x)

func _on_AidYSlider_value_changed(value):
	$AidYSlider/Label.text = "Aid Y-length: " + str(value)
	
	_aid.y = value / 2
	
	$VisualAid/YposLabel.text = "y:" + str(_aid.y)
	$VisualAid/YnegLabel.text = "y:-" + str(_aid.y)

func _on_CenterButton_pressed():
	_center = wii_balance_board.get_com()
	
	$CenterButton.text = "Center:" + str(_center)

func _on_ResetCenterButton_pressed():
	_center = Vector2(0, 0)
	$CenterButton.text = "Center"
