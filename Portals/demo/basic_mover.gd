# Ignore the warning that says this should be a @tool.
# https://github.com/godotengine/godot/issues/76566
extends PortalOrigin

@onready var sprite = $Sprite2D
@onready var shape = $CollisionShape2D
@onready var cam = $Camera2D

@export var speed: float

func point_is_ok(pos: Vector2):
	var sqparams = PhysicsShapeQueryParameters2D.new()
	sqparams.collision_mask = 0b00000000_00000000_00000000_00000001
	sqparams.shape = shape.shape
	sqparams.transform = Transform2D(shape.global_rotation, shape.global_scale, 0, pos)

	return get_viewport().get_world_2d().get_direct_space_state().intersect_shape(sqparams).size() == 0
	
# SO portal renderers can detect it	
func _physics_process(delta):
	
	var any_pressed = false
	
	if Input.is_key_pressed(KEY_A): 
		any_pressed = true;
		if Input.is_key_pressed(KEY_W):
			sprite.rotation_degrees = 180 + 45
		elif Input.is_key_pressed(KEY_S):
			sprite.rotation_degrees = 180 - 45
		else:
			sprite.rotation_degrees = 180;
	elif Input.is_key_pressed(KEY_D):
		any_pressed = true
		if Input.is_key_pressed(KEY_W):
			sprite.rotation_degrees = - 45
		elif Input.is_key_pressed(KEY_S):
			sprite.rotation_degrees = 45
		else:
			sprite.rotation_degrees = 0;
	elif Input.is_key_pressed(KEY_W):
		sprite.rotation_degrees = -90; any_pressed = true
	elif Input.is_key_pressed(KEY_S):
		sprite.rotation_degrees = 90; any_pressed = true
		
	if !any_pressed: return
		
	var movement = Vector2.from_angle(sprite.global_rotation) * speed * delta
	var move = get_move(movement)
	
	if !point_is_ok(move.pos): return
	
	# we emit the signal later, after we move. Could pass the move as the signal arg, but later.
	# We check position change; you can be teleported and still have your room and rotation be the same
	var should_tp = move.pos != global_position + movement

	global_position = move.pos
	global_rotation_degrees = move.rot
	cam.zoom *= global_scale / move.scl
	speed /= (global_scale / move.scl).x
	global_scale = move.scl
	
	if should_tp: teleport.emit(self);
	
	current_room = move.room
	gen_portals()
