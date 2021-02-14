#! /usr/bin/env python
""" Wii Fit Balance Board (WBB) in python

usage: wiiboard.py [-d] [address] 2> wiiboard.log > wiiboard.txt
tip: use `hcitool scan` to get a list of devices addresses

You only need to install `python-bluez` or `python-bluetooth` package.

LICENSE LGPL <http://www.gnu.org/licenses/lgpl.html>
		(c) Nedim Jackman 2008 (c) Pierrick Koch 2016
"""
import time
import collections
import bluetooth
import socket
import threading

# Wiiboard Parameters
CONTINUOUS_REPORTING    = b'\x04'
COMMAND_LIGHT           = b'\x11'
COMMAND_REPORTING       = b'\x12'
COMMAND_REQUEST_STATUS  = b'\x15'
COMMAND_REGISTER        = b'\x16'
COMMAND_READ_REGISTER   = b'\x17'
INPUT_STATUS            = b'\x20'
INPUT_READ_DATA         = b'\x21'
EXTENSION_8BYTES        = b'\x32'
BUTTON_DOWN_MASK        = 0x08
LED1_MASK               = 0x10
BATTERY_MAX             = 200.0
TOP_RIGHT               = 0
BOTTOM_RIGHT            = 1
TOP_LEFT                = 2
BOTTOM_LEFT             = 3
BLUETOOTH_NAME          = "Nintendo RVL-WBC-01"
# WiiboardSampling Parameters
N_SAMPLES               = 200
N_LOOP                  = 10
T_SLEEP                 = 2

status = "searching"
board_obj = None
tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

def socket_thread():
	# TODO(Bobby): Move binding to discover process for more communication
	tcp_socket.bind(("127.0.0.1", 7375))
	tcp_socket.listen(1)
	
	connection, address = tcp_socket.accept()
	
	while True:
		data = connection.recv(1024).decode("ascii")
		
		if data == "ping":
			if board_obj is None:
				connection.send(str(status + "_").encode("ascii"))
			else:
				connection.send(str(status + "_" + str(board_obj.comx) + "_" + str(board_obj.comy)).encode("ascii"))

b2i = lambda b: int(b.encode("hex"), 16)
socket_thread_object = threading.Thread(target=socket_thread)


def discover(duration=6, prefix=BLUETOOTH_NAME):
	print("Scan Bluetooth devices for %i seconds...", duration)
	devices = bluetooth.discover_devices(duration=duration, lookup_names=True)
	print("Found devices: %s", str(devices))
	return [address for address, name in devices if name.startswith(prefix)]

class Wiiboard:
	def __init__(self, address=None):
		self.controlsocket = bluetooth.BluetoothSocket(bluetooth.L2CAP)
		self.receivesocket = bluetooth.BluetoothSocket(bluetooth.L2CAP)
		self.calibration = [[1e4]*4]*3
		self.calibration_requested = False
		self.light_state = False
		self.button_down = False
		self.battery = 0.0
		self.running = True
		if address is not None:
			self.connect(address)
	def connect(self, address):
		print("Connecting to %s", address)
		self.controlsocket.connect((address, 0x11))
		self.receivesocket.connect((address, 0x13))
		print("Sending mass calibration request")
		self.send(COMMAND_READ_REGISTER, b"\x04\xA4\x00\x24\x00\x18")
		self.calibration_requested = True
		print("Wait for calibration")
		print("Connect to the balance extension, to read mass data")
		self.send(COMMAND_REGISTER, b"\x04\xA4\x00\x40\x00")
		print("Request status")
		self.status()
		self.light(0)
	def send(self, *data):
		self.controlsocket.send(b'\x52'+b''.join(data))
	def reporting(self, mode=CONTINUOUS_REPORTING, extension=EXTENSION_8BYTES):
		self.send(COMMAND_REPORTING, mode, extension)
	def light(self, on_off=True):
		self.send(COMMAND_LIGHT, b'\x10' if on_off else b'\x00')
	def status(self):
		self.send(COMMAND_REQUEST_STATUS, b'\x00')
	def calc_mass(self, raw, pos):
		# Calculates the Kilogram weight reading from raw data at position pos
		# calibration[0] is calibration values for 0kg
		# calibration[1] is calibration values for 17kg
		# calibration[2] is calibration values for 34kg
		if raw < self.calibration[0][pos]:
			return 0.0
		elif raw < self.calibration[1][pos]:
			return 17 * ((raw - self.calibration[0][pos]) /
						 float((self.calibration[1][pos] -
								self.calibration[0][pos])))
		else: # if raw >= self.calibration[1][pos]:
			return 17 + 17 * ((raw - self.calibration[1][pos]) /
							  float((self.calibration[2][pos] -
									 self.calibration[1][pos])))
	def check_button(self, state):
		if state == BUTTON_DOWN_MASK:
			if not self.button_down:
				self.button_down = True
				self.on_pressed()
		elif self.button_down:
			self.button_down = False
			self.on_released()
	def get_mass(self, data):
		return {
			'top_right':    self.calc_mass(b2i(data[0:2]), TOP_RIGHT),
			'bottom_right': self.calc_mass(b2i(data[2:4]), BOTTOM_RIGHT),
			'top_left':     self.calc_mass(b2i(data[4:6]), TOP_LEFT),
			'bottom_left':  self.calc_mass(b2i(data[6:8]), BOTTOM_LEFT),
		}
	def loop(self):
		print("Starting the receive loop")
		while self.running and self.receivesocket:
			data = self.receivesocket.recv(25)
			#print("socket.recv(25): %r", data)
			if len(data) < 2:
				print("continuing")
				continue
			input_type = data[1]
			
			#print("input status:", input_type)
			
			if input_type == INPUT_STATUS:
				print("status input")
				self.battery = b2i(data[7:9]) / BATTERY_MAX
				# 0x12: on, 0x02: off/blink
				self.light_state = b2i(data[4]) & LED1_MASK == LED1_MASK
				self.on_status()
			elif input_type == INPUT_READ_DATA:
				print("Got calibration data")
				if self.calibration_requested:
					length = b2i(data[4]) / 16 + 1
					data = data[7:7 + length]
					cal = lambda d: [b2i(d[j:j+2]) for j in [0, 2, 4, 6]]
					if length == 16: # First packet of calibration data
						self.calibration = [cal(data[0:8]), cal(data[8:16]), [1e4]*4]
					elif length < 16: # Second packet of calibration data
						self.calibration[2] = cal(data[0:8])
						self.calibration_requested = False
						self.on_calibrated()
			elif input_type == EXTENSION_8BYTES:
				#print("extension 8bytes")
				
				self.check_button(b2i(data[2:4]))
				self.on_mass(self.get_mass(data[4:12]))
	def on_status(self):
		self.reporting() # Must set the reporting type after every status report
		print("Status: battery: %.2f%% light: %s", self.battery*100.0,
					'on' if self.light_state else 'off')
		self.light(1)
	def on_calibrated(self):
		print("Board calibrated: %s", str(self.calibration))
		self.light(1)
	def on_mass(self, mass):
		print("New mass data: %s", str(mass))
	def on_pressed(self):
		print("Button pressed")
	def on_released(self):
		print("Button released")
	def close(self):
		self.running = False
		if self.receivesocket: self.receivesocket.close()
		if self.controlsocket: self.controlsocket.close()
	def __del__(self):
		self.close()
	#### with statement ####
	def __enter__(self):
		return self
	def __exit__(self, exc_type, exc_val, exc_tb):
		self.close()
		return not exc_type # re-raise exception if any

class WiiboardSampling(Wiiboard):
	def __init__(self, address=None, nsamples=N_SAMPLES):
		Wiiboard.__init__(self, address)
		self.samples = collections.deque([], nsamples)
	def on_mass(self, mass):
		self.samples.append(mass)
		self.on_sample()
	def on_sample(self):
		time.sleep(0.01)

# client class where we can re-define callbacks
class WiiboardPrint(WiiboardSampling):
	def __init__(self, address=None, nsamples=N_SAMPLES):
		WiiboardSampling.__init__(self, address, nsamples)
		self.nloop = 0
	def on_sample(self):
		if len(self.samples) == N_SAMPLES:
			samples = [sum(sample.values()) for sample in self.samples]
			print("%.3f %.3f"%(time.time(), sum(samples) / len(samples)))
			self.samples.clear()
			self.status() # Stop the board from publishing mass data
			self.nloop += 1
			if self.nloop > N_LOOP:
				return self.close()
			self.light(0)
			time.sleep(T_SLEEP)

class WiiboardCOM(Wiiboard):
	comx = 0
	comy = 0
	
	def __init__(self, address=None, nsamples=N_SAMPLES):
		Wiiboard.__init__(self, address)
		self.samples = collections.deque([], nsamples)
	
	def on_mass(self, mass):
		self.comx = 1.0
		self.comy = 1.0
		try:
			total_right  = mass['top_right']   + mass['bottom_right']
			total_left   = mass['top_left']    + mass['bottom_left']
			self.comx = total_right / total_left
			if self.comx > 1:
				self.comx = 1 - total_right / total_left
			else:
				self.comx -= 1
			total_bottom = mass['bottom_left'] + mass['bottom_right']
			total_top    = mass['top_left']    + mass['top_right']
			self.comy = total_bottom / total_top
			if self.comy > 1:
				self.comy = 1 - total_top / total_bottom
			else:
				self.comy -= 1
		except:
			pass
		
		print("Center of mass: %s"%str({'x': self.comx, 'y': self.comy}))
	def on_sample(self):
		time.sleep(0.01)

if __name__ == '__main__':
	import sys
	
	socket_thread_object.start()
	wiiboards = None
	if '-d' in sys.argv:
		sys.argv.remove('-d')
	if len(sys.argv) > 1:
		address = sys.argv[1]
	else:
		while not wiiboards:
			wiiboards = discover()
			print("Found wiiboards: %s", str(wiiboards))
		address = wiiboards[0]
		status = "connecting"
		
	with WiiboardCOM(address) as wiiprint:
		board_obj = wiiprint
		
		wiiprint.loop()
