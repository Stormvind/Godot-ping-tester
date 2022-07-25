extends Control

var Start_menu = preload("res://Scenes/StartMenu.tscn")
var Travel_time_tester = preload("res://Scenes/TravelTimeTester.tscn")
var Current_travel_time_estimation
var error
var Start_menu_instance
var Travel_time_tester_instance

func _ready():
	Start_menu_instance = Start_menu.instance()
	Start_menu_instance.set_name("Start_menu")
	add_child(Start_menu_instance)
	get_node("Background/Disconnect").disabled = true
	
	error = get_node("Background/Exit").connect("button_up", get_tree(), "quit")
	if error != OK:
		print("Error connecting signal 'button_up' in target 'get_tree()' to function 'quit'. Error code: " + error)
	
	error = get_node("Background/Disconnect").connect("button_up", self, "Disconnect")
	if error != OK:
		print("Error connecting signal 'button_up' in target 'self' to function 'Disconnect'. Error code: " + str(error))

func Disconnect():
	get_node("Background/Console").text += "You have disconnected.\n"
	get_node("Background/Disconnect").disabled = true
	get_node("Background/Host").disabled = false
	get_node("Background/Join").disabled = false
	if (get_node_or_null("Start_menu/Travel_time_calibrator")):
		get_node("Start_menu/Travel_time_calibrator").queue_free()
	if (get_node_or_null("Travel_time_tester")):
		get_node("Travel_time_tester").queue_free()
		get_node("Background/Error_text").text = ""
	get_node("Start_menu").enet.close_connection()
	
func Start_pinging_regularly():
	get_node("Start_menu/Travel_time_calibrator").queue_free()
	get_node("Background/Console").text += "Measuring pinging times.\n"
	Travel_time_tester_instance = Travel_time_tester.instance()
	Travel_time_tester_instance.set_name("Travel_time_tester")
	add_child(Travel_time_tester_instance)
