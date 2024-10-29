class_name LerpSmoothingFocus
extends CameraControllerBase


# lead speed is used as a multipler of the target speed to handle base and hyper speed movement
@export var lead_speed: float = 3.0
@export var catchup_delay_duration: float = 0.05
@export var catchup_speed: float = 150.0
@export var leash_distance: float = 20.0


var stop_timer: float = 0.0
var last_target_position: Vector3


func _ready() -> void:
	super()
	position = target.position
	last_target_position = target.position


func _process(delta: float) -> void:
	if !current:
		return

	if draw_camera_logic:
		draw_logic()

	# varaibles for calculating relationships between vessel and camera
	var lead_speed_adjusted = lead_speed * target.velocity.length()
	var direction_to_target = target.position - position
	var distance_to_target = direction_to_target.length()
	var player_moving = is_player_moving()

	# Camera lead logic based on if the player is moving 
	if player_moving:
		# Reset the stop timer since the player is moving
		stop_timer = 0.0

		# Move the camera in the direction of player movement with a lead effect
		var lead_direction = (target.position - last_target_position).normalized()
		position += lead_direction * lead_speed_adjusted * delta

		# Keep the camera at leash distance 
		if distance_to_target > leash_distance:
			# Calculate the target position at the edge of the leash distance
			var leash_position = target.position - direction_to_target.normalized() * leash_distance
			# Using lerp to avoid creating too much jitter 
			position = position.lerp(leash_position, 0.1)

	else:
		# If the player isn't moving increment stop timer
		stop_timer += delta
		if stop_timer >= catchup_delay_duration:
			# Apply catchup when delay duration has passed
			position += direction_to_target.normalized() * catchup_speed * delta

	# Update global position and store the last target position
	global_position = position
	last_target_position = target.position
	super(delta)


func is_player_moving() -> bool:
	return target.velocity.length() > 0


func draw_logic() -> void:
	var cross_size = 2.5  # Half of the 5x5 cross size
	var line_color = Color(1, 0, 0)

	# Create material and mesh for drawing cross lines
	var material = ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = line_color

	var immediate_mesh = ImmediateMesh.new()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)

	# Draw the horizontal line of the cross
	immediate_mesh.surface_add_vertex(Vector3(-cross_size, target.global_position.y + 1.0, 0))
	immediate_mesh.surface_add_vertex(Vector3(cross_size, target.global_position.y + 1.0, 0))

	# Draw the vertical line of the cross
	immediate_mesh.surface_add_vertex(Vector3(0, target.global_position.y + 1.0, -cross_size))
	immediate_mesh.surface_add_vertex(Vector3(0, target.global_position.y + 1.0, cross_size))

	immediate_mesh.surface_end()

	# Add and position the mesh
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, 0, global_position.z)

	# Clean up after one frame
	await get_tree().process_frame
	mesh_instance.queue_free()
