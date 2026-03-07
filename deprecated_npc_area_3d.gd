extends Area3D

# This is redundant here, so I set it up in npc_base instead.
# We can probably just delete this script.
# signal npc_collision_entered
# signal npc_collision_leave

# func _ready():
#     body_entered.connect(self._on_Character_enters)
#     body_exited.connect(self._on_Character_leaves)

# func _on_Character_enters(body):
#     print("Body entered")
#     npc_collision_entered.emit(body)

# func _on_Character_leaves(body):
#     npc_collision_leave.emit(body)