extends Node3D
class_name GameScene

signal character_initialized
signal npc_initialized

func character_is_loaded(body: CharacterBody3D):
    character_initialized.emit(body)

# NOTE: May turn into load_entity that takes NPC base or entity base
# or just the one if I can successfully combine them
func npc_is_loaded(npc_base: NPCBase):
    npc_initialized.emit(npc_base)

func load_scene(scene_path):
    print("Loading scene ", scene_path)

func unload_scene(scene_path):
    print("Unloading scene ", scene_path)