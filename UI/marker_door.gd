extends Node3D

var room = 0
var door = 0

@onready var front = $front
@onready var back = $back

func _on_front_mouse_entered():
	Utils.UI.map.door_mouse_entered(self, true)


func _on_front_mouse_exited():
	Utils.UI.map.door_mouse_exited(self, true)


func _on_back_mouse_entered():
	Utils.UI.map.door_mouse_entered(self, false)


func _on_back_mouse_exited():
	Utils.UI.map.door_mouse_exited(self, false)
