extends Area3D

signal npc_collision_entered
signal npc_collision_leave

func _on_Character_enters(body):
    print("Body entered")
    npc_collision_entered.emit(body)

func _on_Character_leaves(body):
    npc_collision_leave.emit(body)