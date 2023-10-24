extends Node3D
class_name Room

var title: String
var ID: int = 0
var floor: int
@export var doors: Array[Door]

var removed = []


func get_door(door_number):
	var door = doors[door_number]
	return door


func getNodeID(node: Node):
	return get_path_to(node, true)


func save_removed(node):
	var _id = getNodeID(node)
	if node is Interactive && node.pickable:
		if node.has_meta("pickable_dropped"):
			return
	if !(_id in removed):
		removed.append(_id)


func save_data():
	var data = {}
	var added = []
	for n in Utils.find_node_descendants_in_group(self, "persistent"):
		var _id = getNodeID(n)
		if n is Button3D:
			data[_id] = {
				"locked": n.locked
			}
		elif n is RigidBody3D:
			data[_id] = {
				"position": n.position,
				"rotation": n.rotation
			}
			if n.has_meta("pickable_dropped"):
				if _id in removed:
					removed.erase(_id)
				else:
					added.append(n.get_meta("tag", ""))
			if n is Interactive:
				var _d = n.save_data()
				if !_d.is_empty():
					data[_id]["data"] = _d
	if !removed.is_empty():
		data["removed"] = removed
	if !added.is_empty():
		data["added"] = added
	return data


func load_data(data: Dictionary):
	if "added" in data:
		for a in data["added"]:
			spawn_added(a)
	for n in Utils.find_node_descendants_in_group(self, "persistent"):
		var _id = getNodeID(n)
		if _id in data:
			if n is Button3D:
				n.set_lock(data[_id]["locked"], false)
			elif n is RigidBody3D:
				n.position = data[_id]["position"]
				n.rotation = data[_id]["rotation"]
				if n is Interactive:
					if "data" in data[_id]:
						n.load_data(data[_id]["data"])
		if "removed" in data:
			if _id in data["removed"]:
				n.queue_free()
	if "removed" in data:
		removed = data["removed"]


func spawn_added(added):
	var obj_src = load("res://" + added + ".tscn")
	var obj: Node3D = obj_src.instantiate()
	obj.set_meta("pickable_dropped", true)
	add_child(obj)


func on_created(): pass
