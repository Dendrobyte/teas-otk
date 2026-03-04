extends Node3D

@export var plane_texture_img: Texture2D
var dialogue = null
var area: Area3D = null
var player: CharacterBody3D = null

func _ready():
	# # TODO: I hate this!!!! It just feels wrong, especially since this is unreliable if the node order changes
	# # and I want to do it for multiple nodes, so it might be better to 
	# player = get_parent().get_node("Character")
	# Can I just emit the signal and ignore this actually?

	# The asset plane base should handle collision and such
	# Perhaps it can emit a signal or something that triggers a specific NPC's dialogue
	# Need to also set the asset plane's base image with the texture provide
	$AssetPlaneBase.plane_texture_img = plane_texture_img
	$AssetPlaneBase.init_texture()

	# Get the collider from our asset plane
	# NOTE: We may want to give NPC base its own collider of sorts, or scale it properly
	# It's possible not every asset plane will have its own collision. Nonetheless, the code flow doesn't change that much aside from
	# where we fetch the node from
	# area = $NPCArea3D

	# Load dialogue
	# TODO: LOAD THIS FROM A FILE!!!!!!!!!!!!!!!!!!!!!!
	# I like having each NPC have its own loaded dialogue, the asset name just has to match up with a chapter's
	# json file or some shit. The files should be big, and I think per-chapter is fine. Not coming
	# up with that now, but just... know!!!!
	dialogue = GlobalState.DIALOGUE_FILE_PATH[name]
