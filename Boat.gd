extends KinematicBody2D

#signal barrel_hit
#signal wave_hit
signal jumped

var ExplosionAudio = load("res://assets/Explosion.wav")
var JumpAudio = load("res://assets/Jump.wav")
var WaveAudio = load("res://assets/Wave.wav")

var init_position : Vector2

var accepting_jumps : bool = false
var center : Vector2 = Vector2(0, 0)
var sensitivity : Vector2 = Vector2(10, 10)
var invert_x : bool = false
var invert_y : bool = false
var score : int = 0

var wii_balance_board

var _past_com : Vector2 = Vector2(0, 0)
var _velocity : Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	init_position = position

func _physics_process(delta):
	if wii_balance_board != null and wii_balance_board.on_board():
		var new_com = wii_balance_board.get_com() - center
		
		if invert_x:
			new_com.x = -new_com.x
		if invert_y:
			new_com.y = -new_com.y
		
		_velocity.x += sensitivity.x * (new_com.x - _past_com.x)
		_velocity.y += sensitivity.y * (new_com.y - _past_com.y)
		
		_past_com = new_com
		
		#$LeftParticles2D.speed_scale = 2 * max(0, (_velocity.y + _velocity.x))
		#$RightParticles2D.speed_scale = 2 * max(0, (_velocity.y - _velocity.x))
	elif wii_balance_board != null and !wii_balance_board.on_board():
		_velocity = Vector2(0, 0)
		
		#$LeftParticles2D.speed_scale = 2
		#$RightParticles2D.speed_scale = 2
	else:
		pass
		#$LeftParticles2D.speed_scale = 2
		#$RightParticles2D.speed_scale = 2
	
	#$LeftParticles2D.amount = 25 * $LeftParticles2D.speed_scale
	#$RightParticles2D.amount = 25 * $LeftParticles2D.speed_scale
	
	if wii_balance_board != null:
		if wii_balance_board.jumped() and accepting_jumps:
			print("JUMPED")
			score += 5
			
			accepting_jumps = false
			
			emit_signal("jumped")
	
	_velocity = move_and_slide(_velocity)

func zero():
	_velocity = Vector2(0, 0)
	position = init_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body):
	#print("body entered")
	
	if body == null:
		return
	elif body is RigidBody2D:
		var type : String = body.type()
		
		if type == "wave":
			#print("wave")
			
			if $EffectPlayer.playing:
				$EffectPlayer.stop()
			
			$EffectPlayer.stream = WaveAudio
			
			$EffectPlayer.play()
			score += 10
			
			body.destroy()
		elif type == "barrel":
			#print("barrel")
			
			if $EffectPlayer.playing:
				$EffectPlayer.stop()
			
			$EffectPlayer.stream = ExplosionAudio
			
			$EffectPlayer.play()
			
			score -= 10
			
			body.destroy()
	
	#for x in range(2):#range(0, $CollisionShape2D.shape.extents.x * 2 * scale.x, 64):
	#	for y in range(2):#range(0, $CollisionShape2D.shape.extents.y * 2 * scale.y, 64):
	#		var tile_pos : Vector2 = body.world_to_map(global_position)
	#		
	#		tile_pos += Vector2(x, y) / Vector2(64, 64)
	#		tile_pos -= Vector2(4, 0)
	#		
	#		if x == 0 and y == 0:
	#			$CollisionAid.global_position = body.map_to_world(tile_pos)
	#		
	#		print(str(tile_pos))
	#		
	#		var current_tile : int = body.get_cellv(tile_pos)
	#		
	#		if current_tile == GameScene.BARREL_TILE_ID:
	#			print("barrel tile")
	#			#emit_signal("barrel_hit")
	#		elif current_tile == GameScene.WAVE_TILE_ID:
	#			print("wave tile")
	#			#emit_signal("wave_hit")
	#		else:
	#			continue
	#		
	#		body.set_cellv(tile_pos, GameScene.BLANK_TILE_ID)

func _on_Area2D_body_exited(body):
	pass # Replace with function body.
