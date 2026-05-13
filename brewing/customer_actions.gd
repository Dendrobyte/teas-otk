extends Node3D
class_name CustomerActions # CustomerController ...

@onready var brewing_base = get_parent()

# Start is where someone should spawn in, serve is where we serve, end is where they go (and despawn) when done
# TODO: In the future, make them go to a random untaken table position
@onready var start_pos: Vector3 = $Start.position
@onready var serve_pos: Vector3 = $Serve.position
@onready var end_pos: Vector3 = $End.position

@onready var sprite: Sprite3D = $CustomerSprite
var curr_char_idx = -1
var curr_char_name: String = "":
	get():
		return customers[curr_char_idx]
var curr_char_served = false

signal char_dialogue_action

func _ready():
	# TODO: Load the order of customers, this will be self sustaining and we'll run dialogue of the current name, etc.
	hide()

# var customers = ["OldMan", "Generic", "Driver", "Athlete"]
var customers = ["OldMan", "Mercenary", "OldMan", "OldMan"]

var tween
func trigger_next_customer():
	curr_char_idx += 1
	if curr_char_idx > len(customers)-1:
		print("All customers served!")
		return
	# Spawn in and move
	# TODO: Set up according to list and some cursor. Opp to get on those constants!
	var img_resource = load("res://assets/drawings/" + curr_char_name + ".png")
	sprite.texture = img_resource if img_resource != null else load("res://assets/drawings/NPC_NoTexture.png")
	sprite.position = start_pos
	show()

	tween = create_tween()
	tween.tween_property(sprite, "position", serve_pos, 1.5)
	await tween.finished
	tween.kill()

	# Trigger this dialogue such that "served" is false
	char_dialogue_action.emit(curr_char_name, false)

#### https://trello.com/c/dfLlErzl ####
#### TODO-IMPORTANT: I don't like these here. I think it implies that we'll calculate something here.
#### We need to either pass in the tea information when they are served, and then trigger the dialogue
#### and that's based on their preferences.
#### DO NOT LET THIS GROW! After this current camera stuff at least...
#### It's just to get momentum. I'm partial to using this class to store current NPC prefs
#### I like the idea of using the event controller and having a "serve" type action that will then
#### proceed down the sequence.
#### That makes sense. I think the problem I'm seeing is the amount of back-and-forth between
#### this and the brewing scene and the tea serve tray and blah blah blah
func trigger_current_customer_served():
	curr_char_served = true
	char_dialogue_action.emit(curr_char_name, true)

# We want to make sure we're only serving someone after they show up, until they leave
func dialogue_finished():
	if curr_char_served:
		# TODO: See note above about calculation. We're just going with default served dialogue for current ask
		curr_char_served = false
		tween = create_tween()
		end_pos = get_chair_position()
		tween.tween_property(sprite, "position", end_pos, 1.5)
		await tween.finished
		tween.kill()
		add_child(sprite.duplicate())
		# TODO: Create a sprite copy of the character at this position and put it in the scene
		# Won't be interacted with again, but we can keep the name in it in case I want to do that

		# So here would be an example of using event controller to do this
		# Could think of it like potion craft serving
		# So this script, for example, would load all the NPCs and
		# the link to YarnSpinner just as all their dialogue
		trigger_next_customer()

func get_chair_position():
	var random_chair = $ChairPositions.get_children().pick_random()
	random_chair.queue_free()
	return random_chair.global_position

	
