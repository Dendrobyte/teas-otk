extends Node3D

# Randomize scatter count around these two numbers
@export var scatter_count_min: int = 8
@export var scatter_count_max: int = 16
@export var scatter_dist_min: int = 3
@export var scatter_dist_max: int = 5

# TODO: Can refactor to use something in the editor as the parent, or just a more generic naming scheme
func _ready():
	# We will scatter every child in this node. Try to group organizationally in the editor
	for original in self.get_children():
		var copy_count = randi_range(scatter_count_min, scatter_count_max) 
		for n in range(copy_count):
			var scatter_dist = randi_range(scatter_dist_min, scatter_dist_max)
			var copy = original.duplicate()
			var original_pos = Vector3i(original.global_position)
			# Tweak these
			var new_x = randi_range(original_pos.x-scatter_dist, original_pos.x+scatter_dist)
			var new_z = randi_range(original_pos.z-scatter_dist, original_pos.z+scatter_dist)
			# The rotation when we add from the asset-plane-base script affects the weird placement I think
			add_child(copy)
			copy.name = original.name + str(n)
			copy.global_position.x = new_x
			copy.global_position.y = original.global_position.y # Sometimes it's a little off from the bottom of asset_plane
			copy.global_position.z = new_z
