extends PortalOrigin

@export var speed: float
@onready var cam = $Camera2D

# SO portal renderers can detect it	
func _physics_process(delta):
	
	var any_pressed = false
	var dir = 0
	
	if Input.is_key_pressed(KEY_A): 
		any_pressed = true;
		if Input.is_key_pressed(KEY_W):
			dir = 180 + 45
		elif Input.is_key_pressed(KEY_S):
			dir = 180 - 45
		else:
			dir = 180;
	elif Input.is_key_pressed(KEY_D):
		any_pressed = true
		if Input.is_key_pressed(KEY_W):
			dir = - 45
		elif Input.is_key_pressed(KEY_S):
			dir = 45
		else:
			dir = 0;
	elif Input.is_key_pressed(KEY_W):
		dir = -90; any_pressed = true
	elif Input.is_key_pressed(KEY_S):
		dir = 90; any_pressed = true
		
	if any_pressed:
		(self as Node2D as CharacterBody2D).velocity += Vector2.from_angle(deg_to_rad(dir)) * speed

	(self as Node2D as CharacterBody2D).velocity += Vector2.DOWN * 9.8
	(self as Node2D as CharacterBody2D).velocity.clamp(Vector2(-100, -100), Vector2(100, 100))
	
	var pos = global_position
	
	(self as Node2D as CharacterBody2D).move_and_slide()
	
	var move_delta = (self as Node2D as CharacterBody2D).get_position_delta()
	
	var end = pos + move_delta
	
	for portal in current_room.portals.filter(func(x): return x.is_in_front(pos) and not x.is_in_front(end)):
		var distance = portal.distance_to(pos)
		
		var amount_along_normal = move_delta.dot(portal.get_out_normal())
		# where on the door-line the movement hits
		var hit_point = pos + move_delta * (distance / amount_along_normal)
		
		if sign((hit_point - portal.get_start()).dot(hit_point - portal.get_end())) == -1:
			# we assume the move isn't long enough to go through another portal in the room you head into
			global_position = portal.port_pos(end)
			global_rotation_degrees = portal.port_rot(global_rotation_degrees)
			cam.zoom *= global_scale / portal.port_scale(global_scale)
			speed /= (global_scale / portal.port_scale(global_scale)).x
			global_scale = portal.port_scale(global_scale)
			
			(self as Node2D as CharacterBody2D).velocity *= global_scale / portal.port_scale(global_scale)
			(self as Node2D as CharacterBody2D).velocity = (self as Node2D as CharacterBody2D).velocity.rotated(deg_to_rad(portal.rotation_change_through()))
			
			current_room = portal.other.room
			teleport.emit(self);
			break

	gen_portals()
