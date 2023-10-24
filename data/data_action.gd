extends Resource

class_name ActionData

@export var action: String = ""
@export var args: Array[String]
@export var local: bool = false
@export var onself: bool = false
@export var node: Node = null

func _init(a = "", ar: Array[String] = [], l = false, s = false):
	action = a
	args = ar
	local = l
	onself = s
