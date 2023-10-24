extends Node3D
class_name Interactive

signal on_action
signal on_touch
signal on_leave

@export var pickable = false
@export var ephemeral = false
@export var actions: Array[ActionData]
@export_enum("interact", "look", "grab") var cursor: String = "interact"
@export var cursor_holding: String = "default"
@export var hint: String

var blocked = false


func _on_touch(): on_touch.emit()
func _on_leave(): on_leave.emit()
func _on_action():
	if blocked: return
	if ephemeral: Utils.World.current_room.save_removed(self)
	on_action.emit()
	if action_override():
		for a in actions:
			if a.node == null: a.node = self
			if a.local:
				Utils.find_parent_room(self).do_action(a)
			elif a.onself:
				call("do_action", a)
			else:
				Utils.World.button_action(a)
	if ephemeral: queue_free()
func on_pick(): pass


func action_override() -> bool: return true
func save_data() -> Dictionary: return {}
func load_data(data: Dictionary): pass
