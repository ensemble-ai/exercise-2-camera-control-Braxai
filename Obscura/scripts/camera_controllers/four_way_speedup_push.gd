class_name FourWaySpeedupPushBox
extends CameraControllerBase


@export var push_ratio: float = 1.5 
@export var pushbox_top_left: Vector2 
@export var pushbox_bottom_right: Vector2 
@export var speedup_zone_top_left: Vector2
@export var speedup_zone_bottom_right: Vector2 


var stop_timer: float = 0.0

func _ready() -> void:
	super()
	position = target.global_position


func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()

	var tpos = target.global_position
	var cpos = global_position
	
	# dimensions of the pushbox and speedup zone 
	var pushbox_width = pushbox_bottom_right.x - pushbox_top_left.x
	var pushbox_height = pushbox_bottom_right.y - pushbox_top_left.y
	var speedup_zone_width = speedup_zone_bottom_right.x - speedup_zone_top_left.x
	var speedup_zone_height = speedup_zone_bottom_right.y - speedup_zone_top_left.y

	# Pushbox Boundary checks
	# movement direction 
	var is_moving_x_and_y = target.velocity.x != 0 and target.velocity.z != 0

	# Pushbox Left edge
	var pushbox_diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - pushbox_width / 2.0)
	if pushbox_diff_between_left_edges < 0:
		global_position.x += pushbox_diff_between_left_edges
		# if player is moving in both directions we want to move them 
		# in the direction other than the touched edge by push_ratio
		if is_moving_x_and_y:
			global_position.z += push_ratio * target.velocity.z * delta

	# Pushbox Right edge
	var pushbox_diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + pushbox_width / 2.0)
	if pushbox_diff_between_right_edges > 0:
		global_position.x += pushbox_diff_between_right_edges
		if is_moving_x_and_y:
			global_position.z += push_ratio * target.velocity.z * delta

	# Pushbox Top edge
	var pushbox_diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - pushbox_height / 2.0)
	if pushbox_diff_between_top_edges < 0:
		global_position.z += pushbox_diff_between_top_edges
		if is_moving_x_and_y:
			global_position.x += push_ratio * target.velocity.x * delta

	# Pushbox Bottom edge
	var pushbox_diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + pushbox_height / 2.0)
	if pushbox_diff_between_bottom_edges > 0:
		global_position.z += pushbox_diff_between_bottom_edges
		if is_moving_x_and_y:
			global_position.x += push_ratio * target.velocity.x * delta
	

	# scaled velocity for the speedup zone 
	var scaled_velocity = target.velocity.normalized() * (push_ratio * target.velocity.length())

	# Speedupzone Boundary checks 
	# Speedupzone Left Edge
	var speedup_diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - speedup_zone_width / 2.0)
	if speedup_diff_between_left_edges < 0:
		target.global_position += scaled_velocity * delta

	# Speedupzone Right Edge
	var speedup_diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + speedup_zone_width / 2.0)
	if speedup_diff_between_right_edges > 0:
		target.global_position += scaled_velocity * delta

	# Speedupzone Top Edge
	var speedup_diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - speedup_zone_height / 2.0)
	if speedup_diff_between_top_edges < 0:
		target.global_position += scaled_velocity * delta

	# Speedupzone Bottom Edge
	var speedup_diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + speedup_zone_height / 2.0)
	if speedup_diff_between_bottom_edges > 0:
		target.global_position += scaled_velocity * delta

	super(delta)


func is_player_moving() -> bool:
	return target.velocity.length() > 0


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# Draw outer pushbox
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	_draw_box(immediate_mesh, pushbox_top_left, pushbox_bottom_right)
	immediate_mesh.surface_end()

	# Draw inner speedup zone
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	_draw_box(immediate_mesh, speedup_zone_top_left, speedup_zone_bottom_right)
	immediate_mesh.surface_end()

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()

# Helper function to draw a box given its corners
func _draw_box(immediate_mesh: ImmediateMesh, top_left: Vector2, bottom_right: Vector2) -> void:
	var top = top_left.y
	var bottom = bottom_right.y
	var left = top_left.x
	var right = bottom_right.x
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
