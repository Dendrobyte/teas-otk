extends Node3D
class_name NPCBase

@export var plane_texture_img: Texture2D
@export var start_interactable: bool = true
var dialogue = null
var area: Area3D = null
var player: CharacterBody3D = null
var interactable = true # Assume NPCs start as interactable

signal npc_collision_enter
signal npc_collision_leave

func _ready():
	# Wire up the area 3D's signals
	area = $NPCArea3D
	area.body_entered.connect(self._on_Character_enters)
	area.body_exited.connect(self._on_Character_leaves)

	if !start_interactable:
		disable()

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
	show()

func disable():
	interactable = false
	hide()

# Sometimes we keep them shown but don't want to re-initialize dialogue until a flag has been changed
# NOTE: We could do this with the flags and just not have the button show up, but this works too? I'm not sure if one is better than the other
func set_interactable(new_value: bool):
	interactable = new_value
