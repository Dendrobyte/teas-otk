extends Node3D

# TODO: Can refactor to use something in the editor as the parent, or just a more generic naming scheme
func _ready():
	var original = $Bush
	var copy_count = randi() % 17 + 6
	for n in range(copy_count):
		var copy = original.duplicate()
		var original_pos_ints = Vector3i(original.global_position)
		# Tweak these
		var new_x = randf() % (original_pos_ints.x-1) + 1
		var new_z = randf() % (original_pos_ints.z-1) + 1
		# The rotation when we add from the asset-plane-base script affects the weird placement I think
		copy.global_position = Vector3(new_x, original_pos_ints.y, new_z)
		add_child(copy)
	print("Spawned ", copy_count, " copies")
