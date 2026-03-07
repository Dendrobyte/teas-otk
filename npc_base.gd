extends Node3D
class_name NPCBase

@export var plane_texture_img: Texture2D
var dialogue = null
var area: Area3D = null
var player: CharacterBody3D = null

signal npc_collision_enter
signal npc_collision_leave

func _ready():
	# Wire up the area 3D's signals
	area = $NPCArea3D
	area.body_entered.connect(self._on_Character_enters)
	area.body_exited.connect(self._on_Character_leaves)

	# The asset plane base should handle collision and such
	# Perhaps it can emit a signal or something that triggers a specific NPC's dialogue
	# Need to also set the asset plane's base image with the texture provide
	$AssetPlaneBase.plane_texture_img = plane_texture_img
	$AssetPlaneBase.init_texture()

	# FUTURE-TODO: Load NPC information from a file (where relevant, may not be necessary for some)
	# This way we can have each NPC with its own flags that are sent up, and then we can have our dialogue setup
	# rely on those flags. The system will certainly have to evolve but it should help avoid some confusion.
	# So like helped_skyla (or generally a pos/neg favor romance value) is sent up, and we use those same strings
	# in our dialogue setup. Instead of "if skyla.helped_skyla..." we can just pull the dialogue for what
	# flag we return? Enough thinking on that, but we'll go from there. AdventureHeart was a good learning lesson,
	# and those scenes were all the same. Anyway!

# When we enter/exit, we'll send this npc's body
# We send the WHOLE body because we may want to send other characteristics
# NOTE: Check if the body is of type Character... if there's other stuff moving around?
# NOTE: This is a place where layer and stuff probably makes sense?
func _on_Character_enters(_body):
	npc_collision_enter.emit(self)

func _on_Character_leaves(_body):
	npc_collision_leave.emit(self)