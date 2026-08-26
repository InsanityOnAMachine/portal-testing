# Ignore the warning that says this should be a @tool.
# https://github.com/godotengine/godot/issues/76566
extends PortalOrigin

@onready var sprite = $Sprite2D
@onready var shape = $CollisionShape2D

@export var speed: float

func point_is_ok(pos: Vector2):
	var sqparams = PhysicsShapeQueryParameters2D.new()
	sqparams.collision_mask = 0b00000000_00000000_00000000_00000001
	sqparams.shape = shape.shape
	sqparams.transform = Transform2D(shape.global_rotation, pos)

	return get_viewport().get_world_2d().get_direct_space_state().intersect_shape(sqparams).size() == 0
	
		
func _process(delta):
	super._process(delta)
	
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
		
	var move = get_move(Vector2.from_angle(sprite.global_rotation) * speed * delta)
	
	if !point_is_ok(move.pos): return
	
	global_position = move.pos
	global_rotation_degrees = move.rot
	current_room = move.room
	gen_portals()
