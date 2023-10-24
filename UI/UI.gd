extends Control


var map_shown = false
var secrets_total = 12
var secrets_found = 0
var current_floor = 0

@onready var message_panel_size = $MessageSecret/PanelContainer.size
@onready var map = $Map/map_holder/Map


func _ready():
	set_window_size(2560, 1440)
	#set_window_size(0,0,true)
	show_map(false)

func set_window_size(x = 0, y = 0, fullscreen = false):
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(x, y))
		var screen_size = DisplayServer.screen_get_size()
		var center = Vector2i((screen_size.x - x)/2, (screen_size.y - y)/2)
		DisplayServer.window_set_position(center)


func _process(delta):
	pass


func set_cursor(type):
	for c in $cursor.get_children():
		c.visible = c.name == type
	
	
func show_map(show):
	map_shown = show
	get_tree().paused = map_shown
	$Map.visible = map_shown
	map.active = map_shown
	if map_shown:
		map._on_show()
		update_progress()
	
	
func set_room(ID: int):
	$Map/Label2.text = Utils.World.rooms[ID].title
	map.set_room(ID)
	set_floor(Utils.World.rooms[ID].floor)


func set_floor_title(floor: int):
	$Map/Label3.text = "Этаж " + str(floor + 1)


func set_floor(floor: int, is_elevator = false):
	set_floor_title(floor)
	current_floor = floor
	if is_elevator:
		map.update_elevator(floor)


func show_message(text):
	$MessageSecret/PanelContainer/MarginContainer/Label.text = text
	$MessageSecret/PanelContainer.set_size(message_panel_size)
	$MessageSecret/AnimationPlayer.play("message_secret")


func update_progress():
	var rooms_total = map.markers_rooms.size()
	var rooms_visited = map.visited.size()
	var p = clamp(ceil(100.0 * (secrets_found + rooms_visited * 3) / (secrets_total + rooms_total * 3)), 0, 100)
	$Map/Label4.text = "ИССЛЕДОВАНО " + str(p) + "% (КОМНАТ: " + str(rooms_visited) + "/" + str(rooms_total) + ", СЕКРЕТОВ: " + str(secrets_found) + "/" + str(secrets_total) + ")"


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("map"): show_map(!map_shown)
	if Input.is_action_just_pressed("exit"):
		if !map_shown:
			get_tree().quit()
		else:
			show_map(false)
	#if Input.is_action_just_pressed("jump"):
	#	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
	#		Utils.World.player.release_mouse()
	#	else:
	#		Utils.World.player.capture_mouse()
