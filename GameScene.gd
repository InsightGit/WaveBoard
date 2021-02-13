extends Node2D

class_name GameScene

const BARREL_TILE_ID : int = 0
const BLANK_TILE_ID : int = 1
const WAVE_TILE_ID : int = 2
const TILEMAP_LENGTH : Vector2 = Vector2(9, 12)
const TILEMAP_START : Vector2 = Vector2(-7, -4)

# gameplay constants
const BARREL_PROBABLITY : float = 0.05
const WAVE_PROBABLITY : float = 0.05
const PROGRESS_SPEED : float = 0.5


var _delta_time : float
var _game_started : bool = false

func start_game(sensitivity : Vector2, center : Vector2, axis : Vector2):
	$ControlArea/Boat.wii_balance_board = WiiBalanceBoard
	$ControlArea/Boat.sensitivity = sensitivity
	$ControlArea/Boat.center = center
	$VisualAid.axis = axis
	
	_game_started = true

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		WiiBalanceBoard.shutdown()
		get_tree().quit() # default behavior

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _game_started:
		_delta_time += delta
		
		if _delta_time >= PROGRESS_SPEED:
			_shift_rows()
			_generate_top_row()
			
			_delta_time = 0
		
		$VisualAid.update_aid(WiiBalanceBoard.get_com())
