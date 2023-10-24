extends Node3D
class_name Button3D


@export var actions: Array[ActionData]
@export var locked = false
@export var one_time = false
@export var to_show_on_lock: Node = null


func _ready():
	set_lock(locked)


func set_lock(value, animated = true):
	locked = value
	$StaticBody3D.collision_layer = 3 if value else 4
	if to_show_on_lock != null:
		to_show_on_lock.visible = value
	var degree_to = 90
	if value: degree_to *= -1
	if animated:
		var tween = create_tween()
		tween.tween_property($dome, "rotation_degrees", Vector3(0,0,degree_to), 0.2)
	else:
		$dome.rotation_degrees.z = degree_to
	


func _on_interactive_on_action():
	if locked: return
	if one_time: locked = true
	var tween = create_tween()
	tween.tween_property($MeshInstance3D2, "scale", Vector3(1,0.4,1), 0.2)
	tween.tween_property($MeshInstance3D2, "scale", Vector3(1,1,1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	for a in actions:
		if a.node == null: a.node = self
		if a.local:
			Utils.find_parent_room(self).do_action(a)
		else:
			Utils.World.button_action(a)
	if one_time:
		await get_tree().create_timer(0.5).timeout
		set_lock(true)
