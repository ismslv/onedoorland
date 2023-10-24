extends Interactive


func _on_action():
	Utils.World.button_action(ActionData.new("message", ["secret"]))
	super._on_action()
