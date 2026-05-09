extends Node3D
class_name CustomerActions # CustomerController ...

@onready var brewing_base = get_parent()

# Start is where someone should spawn in, serve is where we serve, end is where they go (and despawn) when done
# TODO: In the future, make them go to a random untaken table position
@onready var start_pos: Vector3 = $Start.position
@onready var serve_pos: Vector3 = $Serve.position
@onready var end_pos: Vector3 = $End.position

@onready var sprite: Sprite3D = $CustomerSprite
var curr_char_name: String = ""

signal char_dialogue_action

func _ready():
	# TODO: Load the order of customers, this will be self sustaining and we'll run dialogue of the current name, etc.
	hide()

func _input(event):
	# up arrow for now. just triggers respawn, eventually will go down the list
	# TODO: maybe set up a debug flag or whatnot as you test serving a few different characters
	if event.is_action_pressed("brewing_skip"):
		print("Triggering skip")
		trigger_next_customer()
var tween
func trigger_next_customer():
	# Spawn in and move
	# TODO: Set up according to list and some cursor. Opp to get on those constants!
	var char_name = "OldMan"
	curr_char_name = char_name
	sprite.texture = load("res://assets/drawings/old_man_nolines.png")
	sprite.position = start_pos
	show()

	tween = create_tween()
	tween.tween_property(sprite, "position", serve_pos, 1.5)
	await tween.finished
	tween.kill()

	# Trigger this dialogue such that "served" is false
	char_dialogue_action.emit(char_name, false)
