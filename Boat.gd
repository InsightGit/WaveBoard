extends KinematicBody2D

var init_position : Vector2

var center : Vector2 = Vector2(0, 0)
var sensitivity : Vector2 = Vector2(10, 10)

var wii_balance_board

var _past_com : Vector2 = Vector2(0, 0)
var _velocity : Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	init_position = position

func _physics_process(delta):
	if wii_balance_board != null and wii_balance_board.on_board():
		var new_com = wii_balance_board.get_com() - center
		
		_velocity.x += sensitivity.x * (new_com.x - _past_com.x)
		_velocity.y += sensitivity.y * (new_com.y - _past_com.y)
		
		_past_com = new_com
	elif wii_balance_board != null and !wii_balance_board.on_board():
		_velocity = Vector2(0, 0)
	
	_velocity = move_and_slide(_velocity)

func zero():
	_velocity = Vector2(0, 0)
	position = init_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
