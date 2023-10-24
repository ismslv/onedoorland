extends Interactive


var light_on = false
@export var charge = 100.0
var charging = false

func _ready():
	set_code(Utils.World.puzzle_code)


func _process(delta):
	if light_on:
		if charge > 0:
			charge -= delta * 10
		else:
			charge = 0
			Utils.UI.show_message("Фонарик разряжен")
			onoff()


func save_data():
	return {
		"charge": charge,
		"charging": charging
	}


func load_data(data):
	charge = data["charge"]
	if data["charging"]:
		self.freeze = true


func on_pick():
	charging = false
	

func set_code(code):
	$SubViewport/code_projector_view/Label2.text = code
	($SubViewport as SubViewport).render_target_update_mode = SubViewport.UPDATE_ONCE


func onoff():
	if !light_on && charge == 0:
		Utils.UI.show_message("Фонарик разряжен")
	else:
		light_on = !light_on
		$SpotLight3D.visible = light_on
		$MeshInstance3D.visible = light_on
		$SpotLight3D.light_projector = null
		if light_on:
			charge -= 1
			$SpotLight3D.light_projector = $TextureRect.texture


func action_override():
	onoff()
	return true


func do_action(action: ActionData):
	match action.action:
		"onoff": onoff()
