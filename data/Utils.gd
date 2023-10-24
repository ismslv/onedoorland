extends Node

@onready var World = get_tree().root.get_node("World")
@onready var UI = get_tree().root.get_node("World/UI")

func find_node_descendants_in_group(node: Node, groupName: String) -> Array:
	var descendantsInGroup := []
	for child in node.get_children():
		if child.is_in_group(groupName):
			descendantsInGroup.append(child)
		descendantsInGroup += find_node_descendants_in_group(child, groupName)
	return descendantsInGroup


func find_parent_of_type(node: Node, cls) -> Node:
	var p = node.get_parent()
	if p.is_class("Window"): return null
	if p.is_class(cls): return p
	else: return find_parent_of_type(p, cls)


func find_parent_room(node: Node) -> Node:
	var p = node.get_parent()
	if p is Room: return p
	else: return find_parent_room(p)
