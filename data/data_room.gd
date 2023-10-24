extends Resource

class_name RoomData

@export var title: String
@export var floor: int
@export_file("*.tscn") var scene_file

var scene: Room = null
var save_data = {}
