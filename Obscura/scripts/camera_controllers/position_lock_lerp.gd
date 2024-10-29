class_name PositionLockAndLerpSmoothing
extends CameraControllerBase


# USER NOTE : Feels much better when zoomed out a bit

@export var follow_speed: float = 100.0
@export var catchup_speed: float = 150.0
@export var leash_distance: float = 60.0

func _ready() -> void:
	super()
	position = target.position


func _process(delta: float) -> void:
	if !current:
		return

	if draw_camera_logic:
		draw_logic()

	# variables for calculating the relationships between the camera and vessel
	var direction_to_target = target.position - position
	var distance_to_target = direction_to_target.length()
	var player_moving = is_player_moving()

	# If the camera is beyond the leash distance from the player
	if distance_to_target > leash_distance && player_moving:
		# camera is leash_distance to player
		position = target.position - direction_to_target.normalized() * leash_distance
	# If the player is moving and within leash distance, follow_speed
	elif player_moving:
		position += direction_to_target.normalized() * follow_speed * delta
	# If the player is not moving, catch up at catchup_speed    
	else:
		position += direction_to_target.normalized() * catchup_speed * delta

	global_position = position
	super(delta)


func is_player_moving() -> bool:
	return target.velocity.length() > 0


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
