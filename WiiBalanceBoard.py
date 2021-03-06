from godot import exposed, export
from godot import *

#import collections
import socket
import subprocess
import threading
import time


#import wiiboard

# from https://github.com/pierriko/wiiboard
#class WiiboardCOM(wiiboard.Wiiboard):
#	com = Vector2()
#	
#	def __init__(self, address=None, nsamples=wiiboard.N_SAMPLES):
#		wiiboard.Wiiboard.__init__(self, address)
#		self.samples = collections.deque([], nsamples)
#	
#	def on_mass(self, mass):
#		comx = 1.0
#		comy = 1.0
#		try:
#			total_right  = mass['top_right']   + mass['bottom_right']
#			total_left   = mass['top_left']    + mass['bottom_left']
#			comx = total_right / total_left
#			if comx > 1:
#				comx = 1 - total_right / total_left
#			else:
#				comx -= 1
#			total_bottom = mass['bottom_left'] + mass['bottom_right']
#			total_top    = mass['top_left']    + mass['top_right']
#			comy = total_bottom / total_top
#			if comy > 1:
#				comy = 1 - total_top / total_bottom
#			else:
#				comy -= 1
#		except:
#			pass
#			
#		self.com.x = comx
#		self.com.y = comy
#		print("Center of mass: %s"%str({'x': comx, 'y': comy}))
#	def on_sample(self):
#		time.sleep(0.01)

@exposed
class WiiBalanceBoard(Control):
	# member variables here, example:
	connected = export(bool, default=False)
	connecting = export(bool, default=False)
	error = export(str, default="")
	com = Vector2()
	
	_last_off_board_time = 0
	_last_off_board_duration = 0
	
	_com_mutex = threading.Lock()
	_response_thread = None
	_wiiboard_process = None
	
	def _ready(self):
		"""
		Called every time the node is added to the scene.
		Initialization here.
		"""
		print("creating WiiBalanceBoard response thread")
		self._response_thread = threading.Thread(target=self.response)
		
		self._response_thread.start()
	
	def restart(self):
		print("recreating WiiBalanceBoard response thread")
		self._response_thread = threading.Thread(target=self.response)
		
		self._response_thread.start()
	
	def shutdown(self):
		self._wiiboard_process.kill()
	
	def _process(self, delta):
		#label = self.get_node("StatusLabel")
		
		#if self.connected:
		#	label.text = "Balance board status:\n Connected!"
		#else:
		#	label.text = "Balance board status:\n Disconnected."
		pass
	
	def response(self):
		#self._wiiboard = WiiboardCOM()
		
		#wiiboards = wiiboard.discover()
		#print("Found wiiboards: %s", str(wiiboards))
		
		#if not wiiboards:
		#	self.connected = False
		#	self.error = "Not paired!"
		
		#address = wiiboards[0]
		
		#with WiiboardCOM(address) as wiiprint:
		#	self.connected = True
		#	
		#	wiiprint.loop()
		
		self._wiiboard_process = subprocess.Popen(["/usr/bin/python", "wiiboard.py"])
		
		tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		
		time.sleep(2)
		
		tcp_socket.connect(("127.0.0.1", 7375))
		
		while True:
			tcp_socket.send(b"ping")
			
			data = tcp_socket.recv(1024).decode("ascii").split("_")
			
			if len(data) < 3:
				assert(len(data) > 1)
				
				if data[0] == "connecting":
					self.connecting = True
					print("connecting...")
				else:
					print("searching...")
				
				time.sleep(2)
				continue
			
			self.connected = True
			
			self._com_mutex.acquire()
			
			self.com.x = float(data[1])
			self.com.y = float(data[2])
			
			self._com_mutex.release()
			
			if self.on_board():
				self._last_off_board_duration = 0
			else:
				self._last_off_board_duration += time.monotonic() - \
												self._last_off_board_time
				self._last_off_board_time = time.monotonic()
		
		tcp_socket.close()
	
	@export(bool)
	def on_board(self):
		return self.com.y != -1
	
	@export(Vector2)
	def get_com(self):
		self._com_mutex.acquire()
		
		return_value = self.com
		
		self._com_mutex.release()
		
		return self.com
	
	@export(bool)
	def jumped(self):
		return_value = \
			(self.get_com().y != -1) and \
			 ((time.monotonic() - self._last_off_board_time) < 1.5) and \
			self._last_off_board_duration < 1.5
		
		#if return_value:
			#self._last_off_board_time = time.monotonic() - 1.5
			#print("jumped")
		
		return return_value
	
