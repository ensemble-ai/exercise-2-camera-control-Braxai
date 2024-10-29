class_name AutoScroll
extends CameraControllerBase


@export var top_left: Vector2 
@export var bottom_right: Vector2  
@export var autoscroll_speed: Vector3 = Vector3(8, 0, 0)  

var box_size: Vector2 

func _ready() -> void:
	super()
	position = target.position
	box_size = bottom_right - top_left  # Calculate the size of the bounding box


func _process(delta: float) -> void:
	if !current: 
		return

	if draw_camera_logic: 
		draw_logic()
	
	# Move the camera forward based on autoscroll speed
	position += Vector3(autoscroll_speed.x * delta, 0, 0)

	# Define the bounding box in world coordinates
	var left_edge = position.x - box_size.x / 2
	var right_edge = position.x + box_size.x / 2
	var top_edge = position.z - box_size.y / 2
	var bottom_edge = position.z + box_size.y / 2 

	# Check if the player is lagging behind and push them forward if necessary
	if target.global_position.x < left_edge:
		target.global_position.x = left_edge

	# Prevent the player from leaving the screen via the top, bottom, or right edges
	if target.global_position.x > right_edge:
		target.global_position.x = right_edge

	if target.global_position.z < top_edge:
		target.global_position.z = top_edge

	if target.global_position.z > bottom_edge:
		target.global_position.z = bottom_edge

	super(delta)


func draw_logic() -> void:
	# Create a new MeshInstance3D for the border
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()  # Use StandardMaterial3D for better compatibility

	# Set up the MeshInstance3D properties
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# Calculate the bounding box dimensions
	var box_width: float = box_size.x
	var box_height: float = box_size.y
	
	# Define corner points based on the box size
	var left: float = -box_width / 2
	var right: float = box_width / 2
	var top: float = -box_height / 2
	var bottom: float = box_height / 2
	
	# Start adding lines to the ImmediateMesh
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	# Define the edges of the bounding box
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	
	# End the surface definition
	immediate_mesh.surface_end()

	# Set the material properties for the lines
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	# Add the mesh instance to the scene tree
	add_child(mesh_instance)

	# Position the mesh instance at the appropriate location
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	# Free the mesh after one frame
	await get_tree().process_frame
	mesh_instance.queue_free()
