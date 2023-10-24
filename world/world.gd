extends Node3D

@export_group("Resources")

var current_room: Room = null
var door_locks = {}

@export var rooms: Array[RoomData]

@onready var player: Node3D = $Node3D/Player
var puzzle_code: String
var doors_repaired = false
var rooms_data = {}
var discovered_connections = []


func _ready():
	rooms_data = load_data()
	puzzle_code = str(randi_range(0, 9)) + str(randi_range(0, 9)) + str(randi_range(0, 9)) + str(randi_range(0, 9))
	rooms[0].scene = $Node3D/room1
	rooms[0].scene.on_created()
	room_entered(0)


func _process(delta):
	pass


func load_data():
	var file = FileAccess.open("res://data/rooms.txt", FileAccess.READ)
	var data = {}
	var obj_1 = data
	var list_1 = data
	var level = 0
	while not file.eof_reached():
		var line = file.get_line()
		var s1 = line.left(1) == " "
		line = line.strip_edges(true, true)
		if line == "":
			obj_1 = data
			continue
		if line.left(1) == "#": continue
		if !line.contains(":"):
			if line.contains(" "):
				var _s = line.split(" ")
				if !s1:
					level = 0
					list_1 = data
				else:
					if level == 0:
						level = 1
						list_1 = obj_1
				if !(_s[0] in list_1):
					list_1[_s[0]] = {}
				list_1[_s[0]][_s[1]] = {}
				list_1[_s[0]][_s[1]]["id"] = _s[1]
				obj_1 = list_1[_s[0]][_s[1]]
			else:
				data[line] = {}
				obj_1 = data[line]
		else:
			var _s = line.split(":")
			_s[1] = _s[1].strip_edges(true, true)
			
			# try bool
			if _s[1].to_lower() in ["true", "yes", "on", "☑", "☒", "✓"]:
				obj_1[_s[0]] = true
				continue
			elif _s[1].to_lower() in ["false", "no", "non", "not", "off", "☐", "×"]:
				obj_1[_s[0]] = false
				continue
			
			# try int
			var _i = _s[1].to_int()
			if !(_i == 0 && _s[1] != "0"):
				obj_1[_s[0]] = _i
				continue
			
			# try float
			if _s[1].contains("."):
				var _f = _s[1].to_float()
				if !(_f == 0.0 && _s[1] != "0.0"):
					obj_1[_s[0]] = _f
					continue
			
			# string
			obj_1[_s[0]] = _s[1]
	
	return data
	
	
	#var file = FileAccess.open("res://data/rooms.json", FileAccess.READ)
	#var data_raw = file.get_as_text()
	#var json = JSON.new()
	#var data = json.parse_string(data_raw)


func load_room(door_from, room_id, door_number):
	var room_object = load(rooms[room_id].scene_file)
	var room = room_object.instantiate()
	room.title = rooms[room_id].title
	room.ID = room_id
	room.floor = rooms[room_id].floor
	room.on_created()
	add_child(room)
	var door_to = room.get_door(door_number)
	door_to.establish_link(door_from)
	#door_from.forward_door = door_to
	door_to.animate_door(true, false, true)
	room.global_rotation_degrees.y = door_from.global_rotation_degrees.y + 180 - door_to.global_rotation_degrees.y
	var door_from_pos = door_from.global_position
	#door_from_pos.y = 0
	var door_to_pos = door_to.global_position
	#door_to_pos.y = 0
	room.global_position = door_from_pos - door_to_pos
	room.load_data(rooms[room.ID].save_data)
	rooms[room_id].scene = room
	return room


func unload_room(ID: int):
	rooms[ID].save_data = rooms[ID].scene.save_data()
	rooms[ID].scene.queue_free()


func room_entered(ID: int):
	current_room = rooms[ID].scene
	var _ID = str(ID)
	if _ID in rooms_data.room:
		current_room.title = rooms_data.room[_ID].name
		rooms[ID].title = current_room.title
		if "door" in rooms_data.room[_ID]:
			for d in rooms_data.room[_ID].door.size():
				var _d = str(d)
				current_room.doors[d].ID = d
				current_room.doors[d].room_to_load = rooms_data.room[_ID].door[_d].room
				current_room.doors[d].door_to_load = rooms_data.room[_ID].door[_d].door
				current_room.doors[d].set_lock(!rooms_data.room[_ID].door[_d].open)
				if "label" in rooms_data.room[_ID].door[_d]:
					current_room.doors[d].set_label(rooms_data.room[_ID].door[_d].label)
	
	if ID in door_locks:
		for d in door_locks[ID]:
			rooms[ID].scene.doors[d].set_lock(door_locks[ID][d])
	
	Utils.UI.set_room(ID)

func set_connection(room_from, door_from, room_to, door_to):
	if !([room_from, door_from] in discovered_connections):
		discovered_connections.append([room_from, door_from])
		Utils.UI.map.add_connection(room_from, door_from, room_to, door_to)

func room_entered_mutation(ID: int):
	rooms[ID].scene = current_room
	current_room.ID = ID
	current_room.floor = rooms[ID].floor
	room_entered(ID)

func button_action(action: ActionData):
	match action.action:
		"unlock_door":
			if !(int(action.args[0]) in door_locks): door_locks[int(action.args[0])] = {}
			door_locks[int(action.args[0])][int(action.args[1])] = bool(int(action.args[2]))
			if int(action.args[0]) == current_room.ID:
				current_room.doors[int(action.args[1])].set_lock(bool(int(action.args[2])))
		"message":
			if action.args[0] == "secret":
				Utils.UI.show_message("НАЙДЕН СЕКРЕТ!")
				Utils.UI.secrets_found += 1
			else:
				Utils.UI.show_message(action.args[0])
		"repair_doors":
			doors_repaired = true
			for d in current_room.doors:
				if d.opened:
					d.close_and_remove()
