extends Node3D
class_name Door

@export var room_to_load: int = 0
@export var door_to_load: int = 0
@export var room_to_load_correct: int = 0
@export var door_to_load_correct: int = 0
@export var label: String = "Door"
@export var locked = false

var ID = 0
var entered_times = 0
var player_inside = false
var door_from: Door = null
var linked = false
var opened = false
@onready var room: int = owner.ID
var room_to: Room = null

var easings = [Tween.TRANS_BOUNCE, Tween.TRANS_EXPO]

func _ready():
	$door_body/RigidBody3D/MeshInstance3D2/Label3D.text = label
	set_lock(locked)


func set_lock(value):
	locked = value
	$door_body/RigidBody3D/lock.visible = value


func set_label(text):
	label = text
	$door_body/RigidBody3D/MeshInstance3D2/Label3D.text = label

	
func establish_link(door):
	door_from = door
	
	
func open_door():
	if locked:
		var tween = create_tween()
		tween.tween_property($door_body/RigidBody3D/lock, "scale", Vector3(0.35,0.35,0.35), 0.1)
		tween.tween_property($door_body/RigidBody3D/lock, "scale", Vector3(0.3,0.3,0.3), 0.05)
		return
	if !linked:
		linked = true
		if owner.doors.size() > 1:
			for _d in owner.doors:
				if _d != self:
					_d.close_and_remove()
		if !Utils.World.doors_repaired:
			room_to = Utils.World.load_room(self, room_to_load, door_to_load)
		else:
			room_to = Utils.World.load_room(self, room_to_load_correct, door_to_load_correct)
	animate_door(true, true, false)


func close_and_remove():
	animate_door(false, true, false)
	await get_tree().create_timer(0.5).timeout
	if linked:
		linked = false
		room_to.queue_free()
	
	
func first_enter():
	if door_from != null:
		Utils.World.room_entered(room)
		Utils.World.set_connection(door_from.room, door_from.ID, room, self.ID)
		animate_door(false, true, true)
		await get_tree().create_timer(0.5).timeout
		if door_from != null:
			Utils.World.unload_room(door_from.room)
			door_from = null
	
	
func animate_door(to_open, animated, inverted):
	var x_to = -1.48 if to_open else -0.5
	if to_open && inverted: x_to *= -1
	opened = to_open
	if !animated:
		$door_body.position.x = x_to
	else:
		var tween = create_tween()
		tween.tween_property($door_body, "position", Vector3(x_to,-0.025,0), 0.5).set_ease(Tween.EASE_OUT).set_trans(easings[randi_range(0, easings.size() - 1)])


func _on_area_3d_body_entered(body):
	if body.name == "Player":
		if entered_times == 0: first_enter()
		entered_times += 1
		player_inside = true

func _on_area_3d_body_exited(body):
	if body.name == "Player":
		player_inside = false
		#if opened:
		#	animate_door(false, true, false)


func _on_interactive_on_action(): open_door()
