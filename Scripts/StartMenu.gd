extends Node

var IP_adress_label
var tree
var error
var Error_text
var calibrate_travel_time = preload("res://Scenes/CalibrateTravelTime.tscn")
var enet
var Travel_time_calibrator

func _ready():
	
	Error_text = get_node("../Background/Error_text")
	
	IP_adress_label = get_node("../Background/IP_Adress")
	tree = get_tree()
	
	error = tree.connect("network_peer_connected", self, "User_connected")
	if error != OK:
		print("Error connecting signal 'network_peer_connected' in target 'self' to function 'User_connected'. Error code: " + str(error))
		
	error = tree.connect("server_disconnected", self, "Server_disconnected")
	if error != OK:
		print("Error connecting signal 'Server_disconnected' in target 'self' to function 'Server_disconnected'. Error code: " + str(error))
	
	error = tree.connect("network_peer_disconnected", self, "User_disconnected")
	if error != OK:
		print("Error connecting signal 'network_peer_disconnected' in target 'self' to function 'User_disconnected'. Error code: " + str(error))
	
	error = tree.connect("connected_to_server", self, "Announce_Join")
	if error != OK:
		print("Error connecting signal 'connected_to_server' in target 'self' to function 'Announce_Join'. Error code: " + error)
		
	error = get_node("../Background/Host").connect("button_up", self, "Host")
	if error != OK:
		print("Error connecting signal 'button_up' in target 'self' to function 'Host'. Error code: " + error)
	
	error = get_node("../Background/Join").connect("button_up", self, "Connect_to_host")
	if error != OK:
		print("Error connecting signal 'button_up' in target 'self' to function 'Connect_to_host'. Error code: " + error)
	
	error = get_node("Connection_Failure_Timer").connect("timeout", self, "Connection_attempt_timed_out")
	if error != OK:
		print("Error connecting signal 'timeout' in target 'self' to function 'Connection_attempt_timed_out'. Error code: " + error)

	error = get_node("Connection_Failure_Timer_Animator").connect("timeout", self, "Animate_Connection_Attempt")
	if error != OK:
		print("Error connecting signal 'timeout' in target 'self' to function 'Animate_Connection_Attempt'. Error code: " + error)
	
	
func Host():
	enet = NetworkedMultiplayerENet.new()
	
	var host_attempt = enet.create_server(3000, 1)
	if host_attempt == OK:
		tree.set_network_peer(enet)
		get_node("../Background/Console").text += "You have hosted and are waiting for connection requests.\n"
		get_node("../Background/Host").disabled = true
		get_node("../Background/Join").disabled = true
		get_node("../Background/Disconnect").disabled = false
		
		
func Connect_to_host():
	var IP_adress = IP_adress_label.text
	enet = NetworkedMultiplayerENet.new()
	enet.create_client(IP_adress, 3000)
	tree.set_network_peer(enet)
	# When this timer expires, check if there is no connection. If there is no connection, display
	# a message to the user
	get_node("Connection_Failure_Timer").start(5)
	Error_text.text = "Attempting to connect."
	get_node("Connection_Failure_Timer_Animator").start()
	
func Connection_attempt_timed_out():
		get_node("Connection_Failure_Timer_Animator").stop()
		Error_text.text = "Unable to connect to that IP adress"
		enet.close_connection()
		
func Announce_Join():
	get_node("Connection_Failure_Timer_Animator").stop()
	Error_text.text = ""
	get_node("../Background/Console").text += "You have connected to a host.\n"
	Travel_time_calibrator = calibrate_travel_time.instance()
	Travel_time_calibrator.set_name("Travel_time_calibrator")
	add_child(Travel_time_calibrator)
	
#remote func User_Connected(id):
#	get_node("../Background/Console").text += str(id) + " has connected.\n"
#	var Ping_calibrator = calibrate_ping.instance()
#	add_child(Ping_calibrator)
			
func Animate_Connection_Attempt():
	if (Error_text.text.length() < 26):
		Error_text.text += " ."
	else:
		Error_text.text = "Attempting to connect."
	
func User_connected(id):
	get_node("../Background/Disconnect").disabled = false
	get_node("../Background/Join").disabled = true
	get_node("../Background/Host").disabled = true
		
		
	if tree.get_network_unique_id() == 1:
		get_node("../Background/Console").text += str(id) + " has connected.\n"
		Travel_time_calibrator = calibrate_travel_time.instance()
		Travel_time_calibrator.set_name("Travel_time_calibrator")
		add_child(Travel_time_calibrator)
	else:
		get_node("Connection_Failure_Timer").stop()

func User_disconnected(id):
	get_node("../Background/Console").text += str(id) + " has disconnected.\n"
	if get_node_or_null("Travel_time_calibrator"):
		Travel_time_calibrator.queue_free()
	if get_node_or_null("../Travel_time_tester"):
		get_node("../Travel_time_tester").queue_free()
		get_node("../Background/Error_text").text = ""

func Server_disconnected():
	get_node("../Background/Disconnect").disabled = true
	get_node("../Background/Host").disabled = false
	get_node("../Background/Join").disabled = false
	get_node("../Background/Console").text += "The host has disconnected.\n"
	if get_node_or_null("Travel_time_calibrator"):
		Travel_time_calibrator.queue_free()
	if get_node_or_null("../Travel_time_tester"):
		get_node("../Travel_time_tester").queue_free()
		get_node("../Background/Error_text").text = ""
