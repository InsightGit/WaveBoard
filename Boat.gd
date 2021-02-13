extends KinematicBody2D

var init_position : Vector2

var center : Vector2 = Vector2(0, 0)
var sensitivity : Vector2 = Vector2(10, 10)

var wii_balance_board

var _collided_tiles : Array = []
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

func _on_Area2D_body_entered(body : TileMap):
	print("body entered")
	
	if body == null:
		return
	
	print("REEEEEEEEEEEEEEEEEE:" + str($CollisionShape2D.shape.extents * 2 * scale))
	
	for x in range(0, $CollisionShape2D.shape.extents.x * 2 * scale.x, 64):
		for y in range(0, $CollisionShape2D.shape.extents.y * 2 * scale.y, 64):
			var tile_pos : Vector2 = body.world_to_map(global_position)
			
			tile_pos += Vector2(x, y) / Vector2(64, 64)
			tile_pos -= Vector2(3, 0)
			
			print(str(tile_pos))
			
			var current_tile : int = body.get_cellv(tile_pos)
			
			if current_tile == GameScene.BARREL_TILE_ID:
				print("barrel tile")
			elif current_tile == GameScene.WAVE_TILE_ID:
				print("wave tile")
			else:
				continue
			
			body.set_cellv(tile_pos, GameScene.BLANK_TILE_ID)

func _on_Area2D_body_exited(body):
	pass # Replace with function body.
