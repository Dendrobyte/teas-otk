extends Node3D
class_name GameScene

signal character_initialized

func character_is_loaded():
    character_initialized.emit()