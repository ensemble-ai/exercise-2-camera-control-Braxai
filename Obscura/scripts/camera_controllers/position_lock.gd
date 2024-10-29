class_name PositionLock
extends CameraControllerBase

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current: 
		return

	if draw_camera_logic: 
		draw_logic()

	global_position = target.global_position

	super(delta)
	

func draw_logic() -> void:
	var cross_size = 2.5 # half of 5
	var line_color = Color(1, 1, 1)

	# Define a material for the mesh lines
	var material = ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = line_color

	# Create the ImmediateMesh and MeshInstance3D
	var immediate_mesh = ImmediateMesh.new()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Begin the mesh with the specified material
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)

	# Draw the horizontal line of the cross
	immediate_mesh.surface_add_vertex(Vector3(-cross_size, target.global_position.y + 1.0, 0))
	immediate_mesh.surface_add_vertex(Vector3(cross_size, target.global_position.y + 1.0, 0))

	# Draw the vertical line of the cross
	immediate_mesh.surface_add_vertex(Vector3(0, target.global_position.y + 1.0, -cross_size))
	immediate_mesh.surface_add_vertex(Vector3(0, target.global_position.y + 1.0, cross_size))

	# End mesh definition
	immediate_mesh.surface_end()

	# Add the mesh to the scene and set position
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, 0, global_position.z)

	# Clean up the mesh after one frame to keep it temporary
	await get_tree().process_frame
	mesh_instance.queue_free()
