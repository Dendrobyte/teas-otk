extends Sprite3D
class_name EntityBase

# TODO: Animations, etc. some day
var area: Area3D = null
# Like an NPC is interactable
@export var collectable: bool = true

signal entity_collision_enter
signal entity_collision_leave

func _ready():
	var x_rotation = deg_to_rad(-1*GlobalState.ROTATION_ANGLE[GlobalState.GameMode.OVERWORLD])
	global_rotate(Vector3(1.0, 0.0, 0.0), x_rotation)

	# Wire up the area 3Ds
	# NOTE: Yea this is a lot of repetition from NPC base, maybe something new will come out of it
	area = $EnvironmentArea3D
	area.body_entered.connect(self._on_Character_enters)
	area.body_exited.connect(self._on_Character_leaves)

	# Get the "game scene" node and quit if it fails while testing
	# NOTE: Yoinked from npc_base
	var game_scene: GameScene = null
	var game_scene_group = get_tree().get_nodes_in_group("game_scene")
	if game_scene_group.is_empty():
		push_error("NO GAME SCENE FOUND IN ", self, "!")
		get_tree().quit()
	else:
		game_scene = game_scene_group[0]
		game_scene.entity_is_loaded(self)

func _on_Character_enters(_body):
	if collectable:
		entity_collision_enter.emit(self)

func _on_Character_leaves(_body):
	if collectable:
		entity_collision_leave.emit(self)
