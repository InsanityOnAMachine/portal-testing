@tool
class_name Portal extends Area2D

## The Portal class is basically just a plane that connects to another Portal,
## And handles transforms between the two.
## A Portable queries the Portals in the room it's in to manage teleportation
## A PortalOrigin uses the Portals in the room it's in to collect and render out ViewMeshes

# The collider used for sprite clipping detecting
@onready var collider = $CollisionShape2D

@export var renderer: PortalSpriteRenderer

## The PortalRoom this Portal belongs to
@export var room: PortalRoom:
	set(new_room):
		var old_room = room
		room = new_room
		
		if old_room != null and old_room.portals.has(self):
			old_room.portals.remove_at(old_room.portals.find(self))

		if new_room != null and !new_room.portals.has(self):
			new_room.portals.append(self)

## The Portal this one links to
@export var other: Portal:
	set(v):
		if v == other: return
		# we check this after setting other to =v, otherwise an infinite loop'll occur.
		var old_other = other

		other = v
		
		if old_other != null and old_other.other == self:
			old_other.other = null
			
		if other != null and other.other != self:
			v.other = self
		if debug: queue_redraw()

## The width of the Portal; independent of any actual scaling in-game
@export var width: float = 64:
	set(v):
		width = v
		if collider: calibrate_collider()
		queue_redraw()

@export var debug: bool = true:
	set(v):
		debug = v
		queue_redraw()
		
func _ready():
	if Engine.is_editor_hint(): return
	assert(other != null, "Portal %s's 'other' parameter is null" % self)
	assert(other.other == self, "Portal %s's 'other' doesn't connect back to it" % self)
	assert(room != null, "Portal %s's 'room' parameter is null" % self)
	assert(room.portals.has(self), "Portal %s's 'room' parameter doesn't have the portal in its 'portals' array" % self)
	calibrate_collider()
	
# https://github.com/godotengine/godot-proposals/discussions/11599
static func get_global_z_index(target: CanvasItem) -> int:
	var global_z_index: int = 0
	while target and target is CanvasItem:
		global_z_index += target.z_index      
		if not target.z_as_relative:
			break
		var parent = target.get_parent()
		if not parent or parent is not CanvasItem:
			break
		target = parent
	return global_z_index
	
# https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html
func _draw():
	if !debug: return
	
	# https://www.reddit.com/r/godot/comments/9aaejq/how_do_i_draw_in_global_coordinates_from_a_node2d/
	# https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-method-draw-set-transform
	draw_set_transform_matrix(global_transform.affine_inverse())
	
	if other:
		var c = Color.GREEN
		draw_line(
			global_position,
			global_position + (other.global_position - global_position) / 2,
			c, 2
		)
		
		if other.other != self:
			c = Color.RED
		
		draw_line(
			global_position + (other.global_position - global_position) / 2,
			other.global_position,
			c, 2
		)
	
	draw_circle(get_start(), 3, Color.AZURE)
	draw_circle(get_end(), 3, Color.AZURE)
	draw_line(get_start(), get_end(), Color.WHITE)
	
	var line_end = global_position + get_normal() * 16
	draw_line(global_position, line_end, Color.WHITE)
	draw_circle(line_end, 3, Color.AZURE)

## Process intersecting Portables' Sprites

func _process(_delta):
	if Engine.is_editor_hint(): return
	process_colliding_portables()

func process_colliding_portables():
	if !renderer: return
	
	var params = PhysicsShapeQueryParameters2D.new()
	params.collide_with_areas = true
	params.shape = collider.shape
	params.transform = collider.global_transform
	
	var results = get_world_2d().direct_space_state.intersect_shape(params)
	var current_colliding_portables: Array[Portable] = []
	
	for collision_info in results:
		var body = collision_info.collider
		if body is not Portable: continue
		if current_colliding_portables.has(body): return
		current_colliding_portables.append(body as Portable)
		
		if !renderer.intermediate_bodies.get_or_add(self, []).has(body): 
			if !body.teleport.is_connected(transfer_portable):
				body.teleport.connect(transfer_portable)
		
	current_colliding_portables.sort()
	
	if renderer.intermediate_bodies.get_or_add(self, []) != current_colliding_portables:	
		renderer.intermediate_bodies[self] = current_colliding_portables

func transfer_portable(body: Portable):
	renderer.intermediate_bodies[other].append(body)
	body.teleport.disconnect(transfer_portable)
	if !body.teleport.is_connected(other.transfer_portable):
		body.teleport.connect(other.transfer_portable)

## Makes the collider match the portal's range in world space [br]
## This might have all sorts of problems with scaling;
## I.E. DOES IT DETECT POS CHANGE?! 
func calibrate_collider():
	# remove this later
	if !collider: return
	collider.shape.a = to_local(get_start())
	collider.shape.b = to_local(get_end())

## Takes a Vector2 and transforms it through the portal
func port_pos(pos: Vector2) -> Vector2:
	return other.global_position + (pos - global_position).rotated(deg_to_rad(rotation_change_through())) * scale_change_through()
	
## Takes a rotation (in degrees) and transforms it through the portal
func port_rot(rot: float) -> float:
	return rot + rotation_change_through()

## Takes a scale (Vector2 or float) and transforms it through the portal
func port_scale(s):
	return s * scale_change_through()
	
func port_transform(t: Transform2D):
	return Transform2D(
		deg_to_rad(port_rot(rad_to_deg(t.get_rotation()))),
		port_scale(t.get_scale()),
		t.get_skew(),
		port_pos(t.get_origin())
	)
	
## If you walk through the portal, this is how many degrees you'll have to turn 
## to be facing the same direction relative to the portal you come out of
func rotation_change_through():
	return fmod((other.global_rotation_degrees + 180) - global_rotation_degrees, 360)

## If you walk through the portal, this is how much your scale will be multiplied by
func scale_change_through():
	return other.width / width


## Is this point in front of the portal? Points right on the portal are considered behind it.
## This doesn't take width into account; the portal is considered an infinite line
## splitting the world in twain
func is_in_front(pos: Vector2):
	return Vector2.from_angle(global_rotation + deg_to_rad(90)).dot(pos - global_position) > 0

## A normalized vector pointing 'forwards' out of the portal; When is_in_front() is true,
## that means this vector is pointing roughly at you
func get_normal():
	return Vector2.from_angle(global_rotation + PI / 2)
	
## A normalized vector pointing 'out' of the portal; when you are walking towards a portal,
## you are walking in roughly the same direction as this vector
func get_out_normal():
	return get_normal() * -1

## The distance from a point to the portal; this imagines the portal as an infinite line
## and the distance is to the nearest point on that line. 
## If you are behind the portal, the distance is negative.	
func distance_to(point: Vector2) -> float:
	return (global_position - point).dot(get_out_normal())

## Gets a point and a direction and finds where the point will hit the portal
## if it continues in that direction. It imagines the portal as an infinite line.
## Allows you to pass on extra arguments so you can cache 'em yourself.
func cast_on(point: Vector2, dir: Vector2, distance = null, distance_along_self = null) -> Vector2:
	if !distance: distance = distance_to(point)
	if !distance_along_self: distance_along_self = dir.dot(get_out_normal())
	return point + dir * (distance / distance_along_self)

## Gets a normalized vector from the start of the portal to the end; 
## if your portal is a door, the direction from the hinges to the handle (assuming the door's closed).
func get_vec_along():
	return (get_end() - get_start()).normalized()
	
## The starting point of the portal; if your portal is a door, the side where the hinges are
func get_start():
	return global_position - (Vector2.from_angle(global_rotation) * (width / 2) * .99)

## The ending point of the portal; if your portal is a door, the side where the handle is
func get_end():
	return global_position + (Vector2.from_angle(global_rotation) * (width / 2) * .99)
