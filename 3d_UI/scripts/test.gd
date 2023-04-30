extends MeshInstance3D

@export var camera_caster:Camera3D
@export var subviewport:SubViewport

@onready var area3d = $Area3D
@onready var quad_mesh_size
@onready var last_mouse_pos2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.hit.connect(on_hit)
	Signals.hover.connect(on_hover)
	quad_mesh_size=self.mesh.size
	

func on_hit(result,event):
	print("hit:"+str(result))
	print("event:"+str(event.position))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_hover(result,event):
	var mouse_pos3D = result.position
	
	mouse_pos3D = area3d.global_transform.affine_inverse() * mouse_pos3D
	print("entered:"+str(mouse_pos3D))
	var mouse_pos2D = Vector2(mouse_pos3D.x, -mouse_pos3D.y)

	# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
	# We need to convert it into the following range: 0 -> quad_size
	mouse_pos2D.x += quad_mesh_size.x / 2
	mouse_pos2D.y += quad_mesh_size.y / 2
	# Then we need to convert it into the following range: 0 -> 1
	mouse_pos2D.x = mouse_pos2D.x / quad_mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / quad_mesh_size.y
	# Finally, we convert the position to the following range: 0 -> viewport.size
	mouse_pos2D.x = mouse_pos2D.x * subviewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * subviewport.size.y
	print("viewport:"+str(subviewport.name))
	print("mouse_ps2d:"+str(mouse_pos2D))
	event.position = mouse_pos2D
	event.global_position = mouse_pos2D
	if last_mouse_pos2D == null:
			event.relative = Vector2(0, 0)
		# If there is a stored previous position, then we'll calculate the relative position by subtracting
		# the previous position from the new position. This will give us the distance the event traveled from prev_pos
	else:
		event.relative = mouse_pos2D - last_mouse_pos2D
	subviewport.push_input(event)
	print("event pushed")


func find_further_distance_to(origin):
	# Find edges of collision and change to global positions
	var edges = []
	edges.append(area3d.to_global(Vector3(quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
	edges.append(area3d.to_global(Vector3(quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))
	edges.append(area3d.to_global(Vector3(-quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
	edges.append(area3d.to_global(Vector3(-quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))
	
	for edge in edges:
		print("edge:"+str(edge))
	# Get the furthest distance between the camera and collision to avoid raycasting too far or too short
	var far_dist = 0
	var temp_dist
	for edge in edges:
		temp_dist = origin.distance_to(edge)
		if temp_dist > far_dist:
			far_dist = temp_dist
	print("far_dist:"+str(far_dist))
	return far_dist
