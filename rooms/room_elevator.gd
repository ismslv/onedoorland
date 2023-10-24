extends Room


var state_poster = false
var moving = 0

func save_data():
	var data = super.save_data()
	data["floor"] = floor
	data["state_poster"] = state_poster
	return data


func load_data(data):
	super.load_data(data)
	if "floor" in data:
		floor = data["floor"]
	if "state_poster" in data:
		state_poster = data["state_poster"]
		if state_poster:
			$poster/AnimationPlayer.play("paper_roll")
			$poster/AnimationPlayer.seek(0.4167, true)


func on_created():
	super.on_created()
	set_door_exit(0)


func set_door_exit(_floor):
	match _floor:
		0:
			doors[0].room_to_load = 12
			doors[0].door_to_load = 0
			doors[0].room_to_load_correct = 6
			doors[0].door_to_load_correct = 2
		1:
			doors[0].room_to_load = 11
			doors[0].door_to_load = 0
			doors[0].room_to_load_correct = 7
			doors[0].door_to_load_correct = 0
		2:
			doors[0].room_to_load = 9
			doors[0].door_to_load = 1
			doors[0].room_to_load_correct = 11
			doors[0].door_to_load_correct = 1


func set_door(_floor):
	if _floor != floor:
		$CSGBox3D4/Button.locked = true
		$CSGBox3D4/Button2.locked = true
		var _l = $CSGBox3D4/Button3.locked
		$CSGBox3D4/Button3.locked = true
		doors[0].locked = true
		if doors[0].opened:
			doors[0].close_and_remove()
		set_door_exit(_floor)
		var color_to = Color.hex(0xff333dff) if _floor > floor else Color.hex(0x3e8cffff)
		moving = 1 if _floor > floor else -1
		create_tween().tween_property($CSGBox3D.material_override, "albedo_color", color_to, 2)
		var t = $Area3D.check_body()
		await get_tree().create_timer(1).timeout
		if t != null: t.switch(moving == 1)
		await get_tree().create_timer(2).timeout
		create_tween().tween_property($CSGBox3D.material_override, "albedo_color", Color.WHITE, 0.3)
		moving = 0
		$CSGBox3D4/Button.locked = false
		$CSGBox3D4/Button2.locked = false
		$CSGBox3D4/Button3.locked = _l
		doors[0].locked = false
		floor = _floor
		Utils.UI.set_floor(floor, true)
	doors[0].open_door()


func do_action(action: ActionData):
	match action.action:
		"to_floor":
			set_door(int(action.args[0]))
		"try_poster":
			if (!state_poster):
				Utils.World.button_action(ActionData.new("message", ["СЛИШКОМ ПРИКЛЕЕНО"]))
			else:
				Utils.World.button_action(ActionData.new("message", ["secret"]))
		"try_teapot":
			await get_tree().create_timer(1).timeout
			var t = $Area3D.check_body()
			if t != null && moving != 0: t.switch(moving == 1)
		"poster_teapot":
			if !state_poster:
				if $Area3D2.check_body().find_child("GPUParticles3D").emitting:
					$poster/AnimationPlayer.play("paper_roll")
					state_poster = true
					$secret_item2.ephemeral = true
