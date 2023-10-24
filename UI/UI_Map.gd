extends SubViewport

@export var markers_rooms: Array[Node3D]
@export var marker_door_src: Resource
@export var marker_arrow_src: Resource
@export var floors: Array[Node3D]

var active = false
var look_dir: Vector2
var last_pos = Vector3.ZERO
var doors = {}
var visited = {}
var floor_shown = -1

@onready var elevator = $rotate_x/rotate_y/map/floor_0/CSGBox3D3

func _ready():
	own_world_3d = true
	for r in markers_rooms:
		r.hide()


func _process(delta):
	if active:
		_handle_joypad_camera_rotation(delta)


func _on_show():
	update_player_position()
	update_doors()
	update_camera()
	
	
func set_room(ID: int):
	visited[ID] = true
	markers_rooms[ID].show()
	markers_rooms[ID].get_child(0).text = Utils.World.rooms[ID].title
	room_create_doors()


func add_connection(room_from, door_from, room_to, door_to):
	draw_arrow(doors[room_from][door_from], doors[room_to][door_to])

func show_floor(floor):
	floor_shown = floor
	for f in floors.size():
		if floor == -1: floors[f].show()
		else:
			floors[f].visible = f == floor
	Utils.UI.set_floor_title(floor if floor != -1 else Utils.UI.current_floor)
	update_camera()


func update_player_position():
	if last_pos != Vector3.ZERO:
		$rotate_x/rotate_y/map/marker_player_last.position = last_pos
	last_pos = Utils.World.current_room.to_local(Utils.World.player.global_position)
	last_pos = Vector3(last_pos.x/100,-0.005,last_pos.z/100)
	last_pos = floors[Utils.UI.current_floor].position + markers_rooms[Utils.World.current_room.ID].position + last_pos
	$rotate_x/rotate_y/map/marker_player.position = last_pos
	$rotate_x/rotate_y/map/marker_player.rotation_degrees.y = Utils.World.player.camera.rotation_degrees.y - Utils.World.current_room.global_rotation_degrees.y


func room_create_doors():
	if !(Utils.World.current_room.ID in doors):
		doors[Utils.World.current_room.ID] = []
		for d in Utils.World.current_room.doors:
			var door = marker_door_src.instantiate()
			markers_rooms[Utils.World.current_room.ID].add_child(door)
			door.get_child(1).material_override.albedo_color = Color.RED if d.locked else Color.WHITE
			var pos = Utils.World.current_room.to_local(d.global_position)
			pos = Vector3(pos.x/100,-0.005,pos.z/100)
			door.position = pos
			door.rotation_degrees.y = abs(d.rotation_degrees.y) - 90
			doors[Utils.World.current_room.ID].append(door)
	
func update_doors():
	for r in doors:
		if r in Utils.World.door_locks:
			for d in Utils.World.door_locks[r]:
				doors[r][d].get_child(1).material_override.albedo_color = Color.RED if Utils.World.door_locks[r][d] else Color.WHITE
	
	
func update_camera():
	var bounds = null
	for r in Utils.find_node_descendants_in_group($rotate_x/rotate_y/map, "room_markers"):
		var aabb: AABB = r.get_aabb()
		aabb.position = r.position
		if bounds == null: bounds = aabb
		else:
			if r.visible && r.get_parent().visible: bounds = bounds.merge(aabb)
	$rotate_x/rotate_y/map.position = bounds.size / -2


func update_elevator(floor):
	elevator.reparent(floors[floor])
	elevator.position.y = 0


func set_data(data):
	match(data):
		"know_screw":
			$rotate_x/rotate_y/map/screw.show()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if active:
		if event is InputEventMouseMotion:
			look_dir = event.relative * 0.001
			_rotate()
		if event is InputEventKey:
			if event.pressed:
				if Input.is_key_pressed(KEY_0):
					show_floor(-1)
				elif Input.is_key_pressed(KEY_1):
					show_floor(0)
				elif Input.is_key_pressed(KEY_2):
					show_floor(1)
				elif Input.is_key_pressed(KEY_3):
					show_floor(2)
	

func _handle_joypad_camera_rotation(delta, sens_mod: float = 3.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate(sens_mod)
		look_dir = Vector2.ZERO

func _rotate(sens_mod: float = 1.0) -> void:
	$rotate_x/rotate_y.rotation.y += look_dir.x * sens_mod
	$rotate_x.rotation.x = clamp($rotate_x.rotation.x + look_dir.y * sens_mod, 0, 1.5)


func draw_arrow(a: Node3D, b: Node3D):
	#var point_a: Vector3 = $rotate_x/rotate_y/map.to_local(a.global_position)
	#var point_b: Vector3 = $rotate_x/rotate_y/map.to_local(b.global_position)
	var point_a = a.global_position
	var point_b = b.global_position
	print(point_a)
	print(point_b)
	var dir = point_b - point_a
	var arrow_l = 0.02
	#var up = Vector3.UP
	var line:Node3D = marker_arrow_src.instantiate()
	var mesh = line.find_child("line").mesh
	mesh.height = dir.length() - arrow_l
	$rotate_x/rotate_y/map/lines.add_child(line)
	line.global_position = point_a + dir/2
	line.find_child("cone").position = Vector3(0,0,-dir.length()/2 + arrow_l/2)
	#line.global_rotation_degrees = rot.to_euler()
	if Vector3(0, 1, 0).cross(point_b - (point_a + dir/2)) == Vector3.ZERO:
		line.look_at(point_b + Vector3(0.0, 0.0, 0.0001), Vector3.UP)
	else:
		line.look_at(point_b, Vector3.UP)
