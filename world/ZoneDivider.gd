extends Area3D

signal zone_changed(forward)

var entered = false
var dir_prev = 0


func _ready():
	pass


func process_movement(pos, enter):
	var dir = pos > 0
	if !entered && enter:
		entered = true
		dir_prev = dir
		pass
	elif entered && !enter:
		if dir != dir_prev:
			zone_changed.emit(dir)
		entered = false
		dir_prev = 0


func _on_body_entered(body):
	if body.name == "Player":
		process_movement(to_local(body.global_position).z, true)


func _on_body_exited(body):
	if body.name == "Player":
		process_movement(to_local(body.global_position).z, false)
