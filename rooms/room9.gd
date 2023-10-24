extends Room


func do_action(action):
	match(action.action):
		"unlock_box":
			$CSGBox3D6.position.y += 2
			$button1/CSGBox3D/Button.set_lock(false)
