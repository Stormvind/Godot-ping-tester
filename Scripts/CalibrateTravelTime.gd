extends Node

var Last_sent_package
var Current_received_package
var Travel_times = []
var error
remote var Done_sending = false

signal Calibrator_done



func _ready():
	Last_sent_package = 0
	Current_received_package = 0
	Travel_times.resize(3)
	
	error = connect("Calibrator_done", get_node("../../"), "Start_pinging_regularly")
	if error != OK:
		print("Error connecting signal 'Calibrator_done' in target '../../' to function 'Start_pinging_regularly'. Error code: " + str(error))
	
	
#func _enter_tree():
#	Current_frame = 0
#	Travel_times.resize(100)
	
	
func _physics_process(_delta):
	if Done_sending == false:
		Send_Hailing_Timestamp(OS.get_ticks_msec())
	if Done_sending == true && Current_received_package >= Travel_times.size() - 1:
		emit_signal("Calibrator_done")
		
		
		

func Send_Hailing_Timestamp(timestamp):
	
	rpc_unreliable("Send_Response_Timestamp", timestamp)


remote func Send_Response_Timestamp(arrived_timestamp):
	rpc_unreliable("Receive_Response_Timestamp", arrived_timestamp)

remote func Receive_Response_Timestamp(arrived_timestamp):
#	print("__________________________")
#	print(((OS.get_ticks_msec() - arrived_timestamp) / 2)/16)
#	print("__________________________")
	if Current_received_package < Travel_times.size():
		Travel_times[Current_received_package] = OS.get_ticks_msec() - arrived_timestamp
	if (Current_received_package == Travel_times.size() - 1):
		rset("Done_sending", true)
		var Summed_time = 0
		for current in Travel_times:
			Summed_time += current
#		print(summed_time)
		get_node("../../").Current_travel_time_estimation = (Summed_time / Travel_times.size())
	Current_received_package += 1
