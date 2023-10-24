class_name Player extends RigidBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var crouching: bool = false
var mouse_captured: bool = false
var raycasting = true

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

@onready var camera: Camera3D = $Camera
@onready var hand: Node3D = $Camera/Arm/Hand

var current_raycast = null
var interactive: Interactive
var holding = false
var in_hand: RigidBody3D = null
var repeat_click_blocker = false

func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("crouch"):
		if crouching:
			stop_crouch()
		else:
			start_crouch()
	if Input.is_action_just_pressed("interact"):
		if repeat_click_blocker: return
		repeat_click_blocker = true
		if current_raycast != null && interactive != null:
			raycasting = false
			if interactive.pickable:
				Utils.World.current_room.save_removed(current_raycast)
				pick_object(current_raycast)
			else:
				interactive._on_action()
			raycasting = true
		elif in_hand != null:
			in_hand._on_action()
	if Input.is_action_just_released("interact"):
		repeat_click_blocker = false
	if Input.is_action_just_pressed("drop"):
		if in_hand != null:
			drop_object()
			


func _physics_process(delta: float):
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	position += _walk(delta) * 0.01
	if in_hand != null:
		in_hand.global_position = hand.global_position + Vector3(0,-0.2,0)
		in_hand.rotation_degrees = Vector3(10,20,0)
	#linear_velocity = _walk(delta) + _gravity(delta)
	#move_and_slide()
	if raycasting:
		if $Camera/RayCast3D.is_colliding():
			var collider = $Camera/RayCast3D.get_collider()
			if collider == null: _on_raycast_leave()
			else:
				if current_raycast == collider:
					_on_raycast_touching()
				else:
					_on_raycast_touch(collider)
		else:
			if current_raycast != null: _on_raycast_leave()


func _on_raycast_touch(collider: Object):
	current_raycast = collider
	interactive = current_raycast if current_raycast is Interactive else current_raycast.find_child("Interactive")
	if interactive != null:
		
		Utils.UI.set_cursor(interactive.cursor)

func _on_raycast_leave():
	current_raycast = null
	if !in_hand:
		Utils.UI.set_cursor("default")
	else:
		Utils.UI.set_cursor(in_hand.cursor_holding)

func _on_raycast_touching():
	pass
	
	
func pick_object(obj: RigidBody3D):
	obj.freeze = false
	obj.reparent(hand)
	obj.collision_layer = 8
	obj.collision_mask = 1
	obj.linear_velocity = Vector3.ZERO
	obj.angular_velocity = Vector3.ZERO
	obj.global_position = hand.global_position + Vector3(0,-0.2,0)
	obj.rotation_degrees = Vector3(10,20,0)
	obj.on_pick()
	#obj.gravity_scale = 0
	#hand_joint.node_b = obj.get_path()
	in_hand = obj
	holding = true


func drop_object():
	#hand_joint.node_b = ""
	in_hand.collision_layer = 4
	in_hand.collision_mask = 1
	in_hand.linear_velocity = Vector3.ZERO
	in_hand.angular_velocity = Vector3.ZERO
	holding = false
	#in_hand.freeze = false
	in_hand.reparent(Utils.World.current_room, true)
	in_hand.set_meta("pickable_dropped", true)
	Utils.UI.set_cursor("default")
	#in_hand.gravity_scale = 1
	in_hand = null


func start_crouch():
	crouching = true
	$CShape.shape.height = 1
	$CShape.position.y = 0.5
	create_tween().tween_property(camera, "position:y", 0.9, 0.2)


func stop_crouch():
	crouching = false
	$CShape.shape.height = 1.8
	$CShape.position.y = 0.9
	create_tween().tween_property(camera, "position:y", 1.7, 0.1)


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

#func _gravity(delta: float) -> Vector3:
	#grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	#return grav_vel

#func _jump(delta: float) -> Vector3:
#	if jumping:
#		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
#		jumping = false
#		return jump_vel
#	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
#	return jump_vel
