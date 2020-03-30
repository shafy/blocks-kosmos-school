extends Spatial


class_name HintScreen

var hints
var current_page = 1

onready var challenge_system = get_node(global_vars.CHALLENGE_SYSTEM_PATH)
onready var title_label = $TitleLabel
onready var description_label = $DescriptionLabel
onready var blocks_button_next = $BlocksButtonNext
onready var blocks_button_previous = $BlocksButtonPrevious


# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	connect("visibility_changed", self, "_on_Hint_Screen_visibility_changed")
#	challenge_system.connect("challenge_completed", self, "_on_Challenge_System_challenge_completed")
#	challenge_system.connect("challenge_stopped", self, "_on_Challenge_System_challenge_stopped")
	set_defaults()


func _on_Hint_Screen_visibility_changed():
	if is_visible_in_tree():
		hints = challenge_system.challenge_hints()
		if hints:
			update_text()
		else:
			set_defaults()


func set_defaults():
	update_text_default()
	blocks_button_next.visible = false
	blocks_button_previous.visible = false
	current_page = 1

func _on_Challenge_System_challenge_completed(_challenge_index):
	set_defaults()


func _on_Challenge_System_challenge_stopped(_challenge_index):
	set_defaults()


func next_page():
	current_page += 1
	
	update_text()


func previous_page():
	current_page -= 1
	
	update_text()


func update_text():
	var new_text : String
	
	if hints.size() < current_page:
		return
	
	new_text = hints[current_page-1].description
	description_label.set_label_text(new_text)
	if current_page == hints.size():
		blocks_button_next.visible = false
	else:
		blocks_button_next.visible = true
	
	if current_page == 1:
		blocks_button_previous.visible = false
	else:
		blocks_button_previous.visible = true


func update_text_default():
	title_label.set_label_text("Hints")
	description_label.set_label_text("Start a challenge to see hints")
