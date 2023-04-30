extends Camera3D


var click_event
const ray_length = 1000.0
var casting_ray =false
var mouse_motion=false
var last_result



func _input(event):
	
	if Input.is_action_just_pressed("mouse_left"):
		print(event.position)
		click_event=event
		casting_ray=true
	if event is InputEventMouseMotion:
		click_event=event
		casting_ray=true
		mouse_motion=true
		

func _physics_process(_delta):
	if casting_ray:
		var space_state = get_world_3d().direct_space_state
		var from = self.project_ray_origin(click_event.position)
		var to = from + self.project_ray_normal(click_event.position) * ray_length
		var ray = PhysicsRayQueryParameters3D.create(from,to)
		ray.exclude = [self]
		ray.collide_with_areas=true
		var result=space_state.intersect_ray(ray)
		

		print("click_position:"+ str(click_event.position))
		var from2 = self.project_ray_origin(click_event.position)
		var to2 = from + self.project_ray_normal(click_event.position) * ray_length
		var ray2 = PhysicsRayQueryParameters3D.create(from2,to2)
		
		ray2.exclude = [self]
		ray2.collide_with_bodies=false
		ray2.collide_with_areas=true
		var result2=space_state.intersect_ray(ray2)
		
		if result:
			if mouse_motion:
				Signals.hover.emit(result,click_event)
				mouse_motion=false
			else:
				Signals.hit.emit(result,click_event)
				#print("result:" + str(result))
				#print(result.collider.get_parent())
			last_result=result
		casting_ray=false
		#space_state.intersect_ray(transform.origin,)
