extends Room

@export var action: ActionData

var buttons:Array[Node3D]
var labels:Array[Label3D]
@export var code = "0000"
var numbers = [0,1,2,3,4,5,6,7,8,9]

var steps = []
var result:String
var step = 0

@onready var label_result: Label3D = $StaticBody3D13/Label3D
@onready var hintC: MeshInstance3D = $StaticBody3D13/MeshInstance3D4
@onready var hints = $StaticBody3D13.find_children("hint*")

func _ready():
	for b in $buttons.get_children():
		buttons.append(b)
		labels.append(b.find_child("Label3D"))
	code = Utils.World.puzzle_code
	reset()

func reset():
	result = ""
	steps.clear()
	step = -1
	label_result.text = ""
	for h in hints: h.material_override.albedo_color = Color.BLACK
	hintC.material_override.albedo_color = Color.BLACK
	for i in range(10):
		labels[i].text = str(i + 1) if i < 9 else "0"

func shuffle():
	numbers.shuffle()
	steps.append([])
	for i in range(10):
		steps[step].append(numbers[i])
		labels[i].text = str(numbers[i])


func press_button(b):
	var tw = create_tween()
	tw.tween_property(buttons[b], "position:z", -0.01, 0.2)
	tw.tween_property(buttons[b], "position:z", 0, 0.1)
	if step == code.length() + 2:
		reset()
		return
	step += 1
	if step < 4:
		hints[step].material_override.albedo_color = Color.DODGER_BLUE
	if step >= 3:
		result += str(steps[step - 3][b])
		label_result.text = get_pass_result()
		#label_result.text = result
	shuffle()
	if step == code.length() + 2:
		for i in range(code.length()):
			var _r = code[i] == result[i]
			hints[i].material_override.albedo_color = Color.GREEN if _r else Color.RED
		var r = result == code
		var color = Color.GREEN if r else Color.RED
		hintC.material_override.albedo_color = color
		if r && action != null:
			if action.node == null: action.node = self
			if action.local:
				Utils.find_parent_room(self).do_action(action)
			else:
				Utils.World.button_action(action)


func get_pass_result():
	var r = " "
	for i in range(result.length()): r += "* "
	return r


func do_action(action: ActionData):
	match action.action:
		"num_button":
			press_button(buttons.find(action.node))
		"reset_button":
			reset()
