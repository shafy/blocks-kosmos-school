extends ButtonScreenNav


# button used to navigate between screens on tablet
class_name ChallengeSelectButton


export var challenge_index : int
export (Material) var challenge_finished_material_0
export (Material) var challenge_finished_material_1

onready var challenge_system = get_node(global_vars.CHALLENGE_SYSTEM_PATH)


func _ready():
	challenge_system.connect("challenge_completed", self, "_on_Challenge_System_challenge_completed")
	if challenge_system.challenge_done(challenge_index) == true:
		button_change()


func _on_Challenge_System_challenge_completed(finished_challenge_index):
	if finished_challenge_index == challenge_index:
		button_change()


func button_change():
	button_mesh.set_surface_material(0, challenge_finished_material_0)
	button_mesh.set_surface_material(1, challenge_finished_material_1)
	$MeshInstance2.set_visible(true)
