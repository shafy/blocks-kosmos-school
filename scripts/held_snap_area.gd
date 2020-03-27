extends Area

# this area snaps the building block (which needs to be its parent) to another snap area
class_name HeldSnapArea


signal moved_to_snap

var snap_area_other_area : Area
var other_area_parent_block
var snapping := false
var snap_particles_node
var overlapping := false setget , get_overlapping

onready var parent_block := get_parent().get_parent()
onready var snap_sound := parent_block.get_node("AudioStreamPlayer3DSnap")
onready var magnet_hum_sound := parent_block.get_node("AudioStreamPlayer3DMagnetHum")

enum LocationOnBlock {LENGTH, WIDTH}
export (LocationOnBlock) var location_on_block


func get_overlapping():
	return overlapping


# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "HeldSnapArea" or .is_class(type)


func _ready():
	connect("area_entered", self, "_on_Held_Snap_Area_area_entered")
	connect("area_exited", self, "_on_Held_Snap_Area_area_exited")
	connect("visibility_changed", self, "_on_Held_Snap_Area_visibility_changed")
	
	if !is_visible_in_tree():
		set_process(false)
		set_physics_process(false)
		set_monitoring(false)


func _process(delta):
	check_for_removal()
	
	if !snap_area_other_area:
		return
	
	# we have to do this check because it's possible the other area was deleted in the meantime
	if !is_instance_valid(snap_area_other_area):
		return
	
	if !snapping and !parent_block.is_grabbed and !parent_block.get_moving_to_snap():
		snapping = true

	
	# snapping has started
	if snapping:
		vibrate_controller(false)
		destroy_particles()
		snapping = false
		parent_block.snap_to_block(self, snap_area_other_area)


func _on_Held_Snap_Area_visibility_changed():
	# make sure we can't interact with this button if invisible
	if !is_visible_in_tree():
		set_process(false)
		set_physics_process(false)
		set_monitoring(false)
		pass
	else:
		set_process(true)
		set_physics_process(true)
		set_monitoring(true)


func _on_Held_Snap_Area_area_entered(area):
	# it's grabbed otherwise we woudln't show the HeldSnapArea, just to be sure
	if !parent_block.is_grabbed:
		return
		
	if parent_block.get_overlapping():
		return
	
	if !area.is_class("SnapArea"):
		return
	
	if area.snapped:
		return
	
	if parent_block.get_moving_to_snap() or parent_block.get_snapped():
		return
	
	if overlapping:
		return
	
	# don't allow adding length to length
	if area.location_on_block == LocationOnBlock.LENGTH and location_on_block == LocationOnBlock.LENGTH:
		return
	
	snap_area_other_area = area
	other_area_parent_block = snap_area_other_area.get_parent()
	
	# if the other block is grabbed, don't do anything after all
	if other_area_parent_block.is_grabbed:
		snap_area_other_area = null
		other_area_parent_block = null
		return
	
	# if all tests pass, do this
	overlapping = true
	parent_block.set_overlapping(true)
	vibrate_controller(true)
	spawn_particles()
	if magnet_hum_sound:
		magnet_hum_sound.play()


func _on_Held_Snap_Area_area_exited(area):
	pass
#	if !area.is_class("SnapArea"):
#		return
#
#	vibrate_controller(false)
#	destroy_particles()
#	if magnet_hum_sound:
#		magnet_hum_sound.stop()
#
#	snap_area_other_area = null
#	other_area_parent_block = null
#	overlapping = false
#	parent_block.update_overlapping()


func check_for_removal():
	if !snap_area_other_area:
		return
	
	# we have to do this check because it's possible the other area was deleted in the meantime
	if !is_instance_valid(snap_area_other_area):
		return

	
	if other_area_distance() < 0.05:
		return
	
	vibrate_controller(false)
	destroy_particles()
	if magnet_hum_sound:
		magnet_hum_sound.stop()
	
	snap_area_other_area = null
	other_area_parent_block = null
	overlapping = false
	parent_block.update_overlapping()


func other_area_distance() -> float:
	return get_global_transform().origin.distance_to(snap_area_other_area.get_global_transform().origin)


func vibrate_controller(vibrate : bool):
	if vibrate:
		if !parent_block:
			return
			
		var grabbed_by = parent_block.grabbed_by
		if !grabbed_by:
			return
			
		var current_controller = global_functions.controller_node_from_child(grabbed_by)
		global_functions.vibrate_controller(0.3, current_controller)
	else:
		global_functions.stop_all_vibration()


func spawn_particles():
	if !snap_particles_node and parent_block.snap_particles_scene:
		snap_particles_node = parent_block.snap_particles_scene.instance()
		parent_block.add_child(snap_particles_node)
		snap_particles_node.global_transform.origin = global_transform.origin


func destroy_particles():
	if snap_particles_node:
		snap_particles_node.queue_free()
		snap_particles_node = null
