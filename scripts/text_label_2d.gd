tool

extends Spatial


class_name TextLabel2D


var ui_mesh : PlaneMesh = null;
var prev_text : String
var prev_font_color : Color
var prev_background_color: Color
var prev_resize_mode
var prev_font_size_multiplier : float
var prev_scale_x : float
var prev_scale_y : float
var prev_h_align : int
var prev_v_align : int

export (String, MULTILINE) var text = "I am a Label\nWith a new line" setget set_text
export var margin = 16;
export var billboard = false;

enum ResizeModes {AUTO_RESIZE, FIXED}
export (ResizeModes) var resize_mode = ResizeModes.FIXED

export var font_size_multiplier = 1.0 setget set_font_size_multiplier
export (Color) var font_color = Color(1, 1, 1, 1) setget set_font_color
export (Color) var background_color = Color(0, 0, 0, 1) setget set_background_color

enum Align {ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_FILL}
export (Align) var h_align setget set_h_align
enum VAlign {VALIGN_TOP, VALIGN_CENTER, VALIGN_BOTTOM, VALIGN_FILL}
export (VAlign) var v_align setget set_v_align

onready var ui_label = $Viewport/ColorRect/Label
onready var ui_color_rect : ColorRect = $Viewport/ColorRect
onready var ui_viewport : Viewport = $Viewport
onready var mesh_instance : MeshInstance = $MeshInstance


func set_text(new_value):
	text = new_value
	set_label_text(text)


func set_font_size_multiplier(new_value):
	font_size_multiplier = new_value
	resize()


func set_h_align(new_value):
	h_align = new_value
	set_alignment()


func set_v_align(new_value):
	v_align = new_value
	set_alignment()


func set_font_color(new_value):
	font_color = new_value
	if ui_label:
		ui_label.add_color_override("font_color", font_color)


func set_background_color(new_value):
	background_color = new_value
	if ui_color_rect:
		ui_color_rect.color = background_color


func _ready():
	connect("visibility_changed", self, "_on_Text_Label_2D_visibility_changed")
	
	if !is_visible_in_tree():
		set_process(false)
		
	ui_mesh = mesh_instance.mesh;
	
	set_alignment()
	
	if (billboard):
		mesh_instance.mesh.surface_get_material(0).set_billboard_mode(SpatialMaterial.BILLBOARD_FIXED_Y);
	
	ui_label.add_color_override("font_color", font_color)
	ui_color_rect.color = background_color
	
	mesh_instance.mesh.surface_get_material(0).set_feature(SpatialMaterial.FEATURE_TRANSPARENT, true)
	
	set_label_text(text)
	
	#if (line_to_parent):
		#var p = get_parent();
		#$LineMesh.visible = true;
		#var center = (global_transform.origin + p.global_transform.origin) * 0.5;
		#$LineMesh.global_transform.origin = center;
		#$LineMesh.look_at_from_position()


func _process(delta):
	# only execute while in editor
	if Engine.editor_hint:
		if !ui_viewport:
			get_required_nodes()
			
		if text != prev_text:
			set_label_text(text)
	
		if font_color != prev_font_color:
			ui_label.add_color_override("font_color", font_color)
	
		if background_color != prev_background_color:
			ui_color_rect.color = background_color
	
		if resize_mode != prev_resize_mode:
			resize()
	
		if font_size_multiplier != prev_font_size_multiplier:
			resize()
	
		if scale.x != prev_scale_x or scale.y != prev_scale_y:
			resize()
		
		if h_align != prev_h_align or v_align != prev_v_align:
			set_alignment()
		
		prev_text = text
		prev_font_color = font_color
		prev_background_color = background_color
		prev_resize_mode = resize_mode
		prev_font_size_multiplier = font_size_multiplier
		prev_scale_x = scale.x
		prev_scale_y = scale.y
		prev_h_align = h_align
		prev_v_align = v_align
	
	if text != prev_text:
		resize()


func _on_Text_Label_2D_visibility_changed():
	# make sure we can't interact with this button if invisible
	if !is_visible_in_tree():
		set_process(false)
	else:
		set_process(true)
#		set_physics_process(true)

func resize():
	match resize_mode:
		ResizeModes.AUTO_RESIZE:
			#resize_auto()
			pass
		ResizeModes.FIXED:
			resize_fixed()


# turned off for now
#func resize_auto():
#	# make sure parent is at uniform scale
#	scale = Vector3(1, 1, 1)
#
#	var size = ui_label.get_minimum_size()
#	var res = Vector2(size.x + margin * 2, size.y + margin * 2)
#
#	#ui_container.set_size(res)
#	ui_viewport.set_size(res)
#	ui_color_rect.set_size(res)
#
#	var aspect = res.x / res.y
#
#	ui_mesh.size.x = font_size_multiplier * res.x / 1024
#	ui_mesh.size.y = font_size_multiplier * res.y / 1024


func resize_fixed():
	# resize container and viewport while parent and mesh stay fixed
	var parent_width = scale.x
	var parent_height = scale.y
	
	var new_size = Vector2(parent_width * 1024 / font_size_multiplier, parent_height * 1024 / font_size_multiplier)
	
	if !ui_viewport:
		return
	
	ui_viewport.set_size(new_size)
	ui_color_rect.set_size(new_size)
	ui_label.set_size(new_size)
	
	#ui_container.set_size(new_size)

#	if new_size.x < ui_container.get_size().x or new_size.y < ui_container.get_size().y:
#		print("Your labels text is too large and therefore might look weird. Consider decreasing the font_size_multiplier.")
	

func set_label_text(t: String):
	if !ui_label:
		return
	
	ui_label.set_text(t)


func set_alignment():
	if ui_label:
		ui_label.set_align(h_align)
		ui_label.set_valign(v_align)
		

# this is only required if run in the editor
func get_required_nodes():
	ui_label = $Viewport/ColorRect/Label
	#ui_container = $Viewport/ColorRect/CenterContainer
	ui_color_rect = $Viewport/ColorRect
	ui_viewport = $Viewport
	mesh_instance = $MeshInstance
	ui_mesh = mesh_instance.mesh;
