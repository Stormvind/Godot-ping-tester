extends Node
var Current_received_package = 0
var Travel_times = []
var Current_ping_average

func _ready():
	Travel_times.resize(100)
	for i in range(Travel_times.size()):
		Travel_times[i] = 0
	
func _physics_process(_delta):
	Send_Hailing_Timestamp(OS.get_ticks_msec())	

func Send_Hailing_Timestamp(timestamp):
	
	rpc_unreliable("Send_Response_Timestamp", timestamp)


remote func Send_Response_Timestamp(arrived_timestamp):
	rpc_unreliable("Receive_Response_Timestamp", arrived_timestamp)

remote func Receive_Response_Timestamp(arrived_timestamp):
#	if Current_received_package < Travel_times.size():
	if Current_received_package >= Travel_times.size():
		Current_received_package = 0
		get_node("../Background/Error_text").text = str(Current_ping_average) + " ms"

	Travel_times[Current_received_package] = OS.get_ticks_msec() - arrived_timestamp
	Current_received_package += 1
	var Summed_time = 0
	for current in Travel_times:
		Summed_time += current
	Current_ping_average = Summed_time / Travel_times.size()
		
#	get_node("../Background/Error_text").text = Current_ping_average
	
