extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal ready_to_play

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_auto_accept_quit(false)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		WiiBalanceBoard.shutdown()
		get_tree().quit() # default behavior

func _exit_tree():
	WiiBalanceBoard.shutdown()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if WiiBalanceBoard.connected and $CalibrationPanel.wii_balance_board == null:
		$CalibrationPanel.wii_balance_board = WiiBalanceBoard
		$ColorRect/Boat.wii_balance_board = WiiBalanceBoard
		
		$ColorRect/Boat.center = $CalibrationPanel.center
		$ColorRect/Boat.sensitivity = $CalibrationPanel.sensitivity
		$ColorRect/Boat.invert_x = $ColorRect/Boat.invert_x
		$ColorRect/Boat.invert_y = $ColorRect/Boat.invert_y
	elif $CalibrationPanel.wii_balance_board != null:
		$ColorRect/Boat.center = $CalibrationPanel.center
		$ColorRect/Boat.sensitivity = $CalibrationPanel.sensitivity
		$ColorRect/Boat.invert_x = $CalibrationPanel.invert_x
		$ColorRect/Boat.invert_y = $CalibrationPanel.invert_y

func _on_CalibrationPanel_boat_zero_requested():
	$ColorRect/Boat.zero()

func _on_CalibrationPanel_ready_to_play():
	emit_signal("ready_to_play")
