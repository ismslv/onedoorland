extends Room

@export var doors_0: Array[Door]
@export var doors_1: Array[Door]
@export var doors_2: Array[Door]

var know_screw = false
var state_poster = false

func _on_zone_changed_1(forward):
	for _d in doors: _d.close_and_remove()
	ID = 4 if forward else 3
	update_doors()
	Utils.World.room_entered_mutation(ID)
	
func _on_zone_changed_2(forward):
	for _d in doors: _d.close_and_remove()
	ID = 5 if forward else 4
	update_doors()
	Utils.World.room_entered_mutation(ID)


func update_doors():
	match(ID):
		3: doors = doors_0
		4: doors = doors_1
		5: doors = doors_2


func on_created():
	super.on_created()
	update_doors()


func save_data():
	var data = super.save_data()
	data["know_screw"] = know_screw
	data["state_poster"] = state_poster
	return data


func load_data(data):
	super.load_data(data)
	if "know_screw" in data:
		know_screw = data["know_screw"]
		if know_screw:
			$CSGCylinder3D3/CSGBox3D2/StaticBody3D.collision_layer = 1
	if "state_poster" in data:
		state_poster = data["state_poster"]
		if state_poster:
			($CSGCylinder3D3/CSGBox3D2/StaticBody3D/poster/AnimationPlayer as AnimationPlayer).play("paper_roll")
			if $CSGCylinder3D3/CSGBox3D2/secret_item != null:
				$CSGCylinder3D3/CSGBox3D2/secret_item.collision_layer = 1
			$CSGCylinder3D3/CSGBox3D2/StaticBody3D/poster/AnimationPlayer.seek(0.4167, true)


func do_action(action: ActionData):
	match(action.action):
		"know_screw":
			know_screw = true
			$CSGCylinder3D3/CSGBox3D2/StaticBody3D.collision_layer = 1
			Utils.UI.map.set_data("know_screw")
		"poster_teapot":
			if !state_poster:
				if $CSGCylinder3D3/CSGBox3D2/Area3D2.check_body().find_child("GPUParticles3D").emitting:
					$CSGCylinder3D3/CSGBox3D2/secret_item.collision_layer = 4
					$CSGCylinder3D3/CSGBox3D2/StaticBody3D/poster/AnimationPlayer.play("paper_roll")
					state_poster = true
			
