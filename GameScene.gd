extends Node2D

class_name GameScene

signal results_restart_game

const BARREL_TILE_ID : int = 0
const BLANK_TILE_ID : int = 1
const WAVE_TILE_ID : int = 2
const TILEMAP_LENGTH : Vector2 = Vector2(9, 12)
const TILEMAP_START : Vector2 = Vector2(-7, -4)

# gameplay constants
const BARREL_PROBABLITY : float = 0.05
const WAVE_PROBABLITY : float = 0.10
const PROGRESS_SPEED : float = 0.5
const GAME_LENGTH : int = 180 # seconds

var Barrel = load("res://Barrel.tscn")
var Wave = load("res://Wave.tscn")

var _delta_time : float
var _game_started : bool = false
var _obstacles : Array = []

func start_game(sensitivity : Vector2, center : Vector2, axis : Vector2, 
				invert_x : bool, invert_y : bool):
	$ControlArea/Boat.wii_balance_board = WiiBalanceBoard
	$ControlArea/Boat.sensitivity = sensitivity
	$ControlArea/Boat.center = center
	$ControlArea/Boat.invert_x = invert_x
	$ControlArea/Boat.invert_y = invert_y
	$VisualAid.axis = axis
	
	$ScoreBoard.start_game_timer(GAME_LENGTH)
	$AnimationPlayer.play("jump_countdown")
	
	_game_started = true

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		WiiBalanceBoard.shutdown()
		get_tree().quit() # default behavior

func _ready():
	#$ControlArea/Boat.tile_map = $TileMap
	pass

func _generate_top_row():
	for i in range(TILEMAP_LENGTH.x):
		randomize()
		
		var tile_id : int = BLANK_TILE_ID
		var rand_barrel : int = randi() % (int(1 / BARREL_PROBABLITY))
		var rand_wave : int = randi() % (int(1 / WAVE_PROBABLITY))
		
		if rand_barrel == 0:
			tile_id = BARREL_TILE_ID
		elif rand_wave == 0:
			tile_id = WAVE_TILE_ID
		
		$TileMap.set_cell(TILEMAP_START.x + i, TILEMAP_START.y, tile_id)

func _shift_rows():
	for x in range(TILEMAP_LENGTH.x, 0, -1):
		for y in range(TILEMAP_LENGTH.y - 1, 0, -1):
			$TileMap.set_cell(TILEMAP_START.x + (x - 1), 
							  TILEMAP_START.y + y + 1, 
							  $TileMap.get_cell(TILEMAP_START.x + x - 1, 
												TILEMAP_START.y + y - 1))

func _spawn_new_obstacles():
	for i in range(TILEMAP_LENGTH.x):
		var tile_id : int = BLANK_TILE_ID
		randomize()
		var rand_barrel : int = randi() % (int(1 / BARREL_PROBABLITY))
		
		randomize()
		var rand_wave : int = randi() % (int(1 / WAVE_PROBABLITY))
		var obstacle : RigidBody2D
		
		if rand_barrel == 0:
			obstacle = Barrel.instance()
		elif rand_wave == 0:
			obstacle = Wave.instance()
		else:
			continue
		
		obstacle.position = Vector2(64 * i, -276)
		obstacle.collision_mask = 0
		
		$ControlArea.add_child(obstacle)
		
		randomize()
		obstacle.add_force(Vector2(0, 0), Vector2(randf(), randf()))
		
		_obstacles.append(obstacle)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _game_started:
		_delta_time += delta
		
		$ScoreBoard.score = $ControlArea/Boat.score
		
		if _delta_time >= PROGRESS_SPEED:
			#_shift_rows()
			#_generate_top_row()
			_spawn_new_obstacles()
			
			_delta_time = 0
		
		$VisualAid.update_aid(WiiBalanceBoard.get_com())
		
		for obstacle in _obstacles:
			
			if obstacle != null:
				if obstacle.global_position.x > 1024 || \
				   obstacle.global_position.y > 600:
					obstacle.destroy() 
					_obstacles.erase(obstacle)

#func _on_Boat_barrel_hit():
#	$ScoreBoard.score -= 10

#func _on_Boat_wave_hit():
#	$ScoreBoard.score += 10

func _on_ScoreBoard_on_game_over():
	$Results.on_game_over($ScoreBoard.score)
	
	_game_started = false

func _on_Results_restart_game():
	$ControlArea/Boat.score = 0
	$ScoreBoard.score = 0
	
	emit_signal("results_restart_game")

func _on_AnimationPlayer_animation_finished(anim_name : String):
	if anim_name == "jump_countdown":
		$ControlArea/Boat.accepting_jumps = true
		
		$AnimationPlayer.play("jump_period")
	elif anim_name == "jump_period":
		$ControlArea/Boat.accepting_jumps = false
		
		$AnimationPlayer.play("jump_countdown")

func _on_Boat_jumped():
	$JumpAid/Label.text = "Great Jump!"
