extends Interactive


@onready var target = get_parent().get_node("target")
var p = null
var state = 0
var timer = 0


func _process(delta):
	if p != null:
		match(state):
			1:
				if p.position.y > target.position.y - 0.176:
					p.position.y -= delta/2
				else:
					timer = 0
					state = 2
			2:
				if timer < 2:
					p.rotation_degrees.y += delta * 100
					timer += delta
				else:
					Utils.UI.show_message("Фонарик заряжен")
					state = 3
			3:
				if p.position.y < target.position.y:
					p.position.y += delta/4
				else:
					state = 0
					p = null
	

func action_override():
	if Utils.World.player.in_hand != null:
		if Utils.World.player.in_hand.get_meta("tag") == "projector":
			Utils.World.player.drop_object()
			p = Utils.World.current_room.get_node("Projector")
			p.position = target.position
			p.rotation_degrees = Vector3(90,0,0)
			p.freeze = true
			p.charge = 100.0
			p.charging = true
			state = 1
			return
	Utils.UI.show_message("Вам нечего сюда вставить")
			
