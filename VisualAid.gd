extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var axis : Vector2 = Vector2(2, 2)
var center : Vector2 = Vector2(0, 0)

var invert_x : bool = false
var invert_y : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_aid(new_com : Vector2):
	var original_com : Vector2 = new_com
	var visual_aid_size : Vector2 = rect_size * 2
	
	new_com -= center
	
	if invert_x:
		original_com.x = -original_com.x
	
	if invert_y:
		original_com.y = -original_com.y
	
	#print("original:" + str(original_com))
	#print("new:" + str(new_com))

	
	$COM.rect_position = Vector2(new_com.x * (visual_aid_size.x / axis.x), 
								 new_com.y * (visual_aid_size.y / axis.y)) + \
							  + (visual_aid_size / 2)
	
	$XposLabel.text = "x:" + str(axis.x)
	$XnegLabel.text = "x:-" + str(axis.x)
	$YposLabel.text = "y:" + str(axis.y)
	$YnegLabel.text = "y:-" + str(axis.y)
