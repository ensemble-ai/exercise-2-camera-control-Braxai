class_name HorizontalAutoScroll
extends CameraControllerBase

@export var top_left: Vector2 
@export var bottom_right: Vector2  
@export var autoscroll_speed: Vector3 = Vector3(50, 0, 50)  

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
	position += Vector3(autoscroll_speed.x * delta, 0, autoscroll_speed.z * delta)

	# Update target position based on camera position
	var target_pos = target.global_position

	# Define the bounding box in world coordinates
	var left_edge = position.x + top_left.x
	var right_edge = position.x + bottom_right.x
	var top_edge = position.z + top_left.y
	var bottom_edge = position.z + bottom_right.y

	# Check if the player is lagging behind and push them forward if necessary
	if target_pos.x < left_edge:
		target_pos.x = left_edge
	elif target_pos.x > right_edge:
		target_pos.x = right_edge

	if target_pos.z < top_edge:
		target_pos.z = top_edge
	elif target_pos.z > bottom_edge:
		target_pos.z = bottom_edge

	# Update the target's position
	target.global_position = target_pos

	# Update camera position to follow the target vertically
	position.y = target.global_position.y + dist_above_target

	super(delta)

func draw_logic() -> void:
    var immediate_mesh = ImmediateMesh.new()
    var material = BaseMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.albedo_color = Color(1, 1, 1)  # Color for the box

    immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)

    # Draw the edges of the bounding box
    var top_left_world = position + Vector3(top_left.x, 0, top_left.y)
    var bottom_right_world = position + Vector3(bottom_right.x, 0, bottom_right.y)

    immediate_mesh.surface_add_vertex(top_left_world)
    immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, top_left.y))  # Top edge
    immediate_mesh.surface_add_vertex(bottom_right_world)
    immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, bottom_right.y))  # Bottom edge
    immediate_mesh.surface_add_vertex(top_left_world)
    immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, bottom_right.y))  # Left edge
    immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, top_left.y))
    immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, bottom_right.y))  # Right edge

    immediate_mesh.surface_end()

    add_child(immediate_mesh)
    await get_tree().process_frame
    immediate_mesh.queue_free()