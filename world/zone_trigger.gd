extends Area3D

@export var actions: Array[ActionData]
@export var target_name: String = ""
@export var target_tag: String = ""


func _ready():
	body_entered.connect(_entered)


func filter(body: Node3D) -> bool:
	return (!target_name.is_empty() && body.name == target_name) || (!target_tag.is_empty() && body.get_meta("tag", "") == target_tag)


func _entered(body: Node3D):
	if filter(body):
		for a in actions:
			if a.local:
				Utils.find_parent_room(self).do_action(a)
			else:
				Utils.World.button_action(a)


func check_body():
	for b in get_overlapping_bodies():
		if filter(b):
			return b
	return null
