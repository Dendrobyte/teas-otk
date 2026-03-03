extends Node3D

@export var plane_texture_img: Texture2D

func _ready():

    # The asset plane base should handle collision and such
    # Perhaps it can emit a signal or something that triggers a specific NPC's dialogue
    # Need to also set the asset plane's base image with the texture provide
    $AssetPlaneBase.plane_texture_img = plane_texture_img
    $AssetPlaneBase.init_texture()
    print("Loaded up npc base for: ", name)
