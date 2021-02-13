extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_auto_accept_quit(false)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		$WiiBalanceBoard.shutdown()
		get_tree().quit() # default behavior

func _exit_tree():
	$WiiBalanceBoard.shutdown()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $WiiBalanceBoard.connected and $CalibrationPanel.wii_balance_board == null:
		$CalibrationPanel.wii_balance_board = $WiiBalanceBoard
