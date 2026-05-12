@tool
extends Sprite3D
class_name NPCBase

@export var start_interactable: bool = true
var dialogue = null
var area: Area3D = null
var player: CharacterBody3D = null
var interactable = true # Assume NPCs start as interactable

signal npc_collision_enter
signal npc_collision_leave

@export_tool_button("Reload Image", "Callable") var reload_image = reload_npc_image

# All NPC images will match on name and I want to be able to see them in-editor
# There may be exception in future
func reload_npc_image():
	var img_resource = load("res://assets/drawings/" + name + ".png")
	texture = img_resource if img_resource != null else load("res://assets/drawings/NPC_NoTexture.png")

	# You're not supposed to modify the root node of a scene so we'll have that adjustment here
	scale = Vector3(0.3, 0.3, 0.3)
	# TODO: Make sure it makes contact with ground plane properly
	# 		Editor can be rough, in-game should be precise

func _ready():
	# Guard to not load this in-editor. Needed because I made this a tool script.
	if Engine.is_editor_hint():
		reload_npc_image()
		return

	# Wire up the area 3D's signals
	area = $NPCArea3D
	area.body_entered.connect(self._on_Character_enters)
	area.body_exited.connect(self._on_Character_leaves)

	if !start_interactable:
		disable()

	# TODO: Figure out how to 'inherit' the asset sprite base on npc base, especially if we add more to the asset plane base
	var x_rotation = deg_to_rad(-1*GlobalState.ROTATION_ANGLE[GlobalState.GameMode.OVERWORLD])
	global_rotate(Vector3(1.0, 0.0, 0.0), x_rotation)

	# Get the "game scene" node and quit if it fails while testing
	var game_scene: GameScene = null
	var game_scene_group = get_tree().get_nodes_in_group("game_scene")
	if game_scene_group.is_empty():
		push_error("NO GAME SCENE FOUND IN ", self, "!")
		get_tree().quit()
	else:
		game_scene = game_scene_group[0]
		game_scene.npc_is_loaded(self)

# When we enter/exit, we'll send this npc's body
# We send the WHOLE body because we may want to send other characteristics
# NOTE: This is a place where layer and stuff probably makes sense?
func _on_Character_enters(_body):
	if interactable:
		npc_collision_enter.emit(self)

func _on_Character_leaves(_body):
	if interactable:
		npc_collision_leave.emit(self)

# Some NPCs will be enabled/disabled when certain events happen
func enable():
	interactable = true
	self.modulate.a = 1.0
	# show()

func disable():
	interactable = false
	self.modulate.a = 0.3
	# hide()

# Sometimes we keep them shown but don't want to re-initialize dialogue until a flag has been changed
# NOTE: We could do this with the flags and just not have the button show up, but this works too? I'm not sure if one is better than the other
func set_interactable(new_value: bool):
	interactable = new_value
