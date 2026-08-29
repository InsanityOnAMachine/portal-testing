class_name Portable extends Node2D

## A Node2D that can be teleported between PortalRooms and tracks what room it's in

@export var current_room: PortalRoom

## Represents a movement; what room you end up in,
## where you end up in global space, and
## in what direction (degrees) you're pointing in.
class RoomMovement:
	var room: PortalRoom
	var pos: Vector2
	var rot: float
	
	func _init(_room: PortalRoom, _pos: Vector2, _rot: float):
		room = _room
		pos = _pos
		rot = _rot
		

func _ready():
	if current_room == null:
		push_warning("Portable ", self, "'s 'current_room' parameter is null")

## Returns an RoomMovement of where you should end up if you move along this vector
func get_move(movement: Vector2):
	var end = global_position + movement
	for portal in current_room.portals.filter(func(x): return x.is_in_front(global_position) and not x.is_in_front(end)):
		var distance = portal.distance_to(global_position)
		
		var amount_along_normal = movement.dot(portal.get_out_normal())
		# where on the door-line the movement hits
		var hit_point = global_position + movement * (distance / amount_along_normal)
		
		if sign((hit_point - portal.get_start()).dot(hit_point - portal.get_end())) == -1:
			# we assume the move isn't long enough to go through another portal in the room you head into
			return RoomMovement.new(
				portal.other.room,
				portal.port_pos(end),
				global_rotation_degrees + portal.rotation_change_through()
			)
			
	return RoomMovement.new(current_room, end, global_rotation_degrees)
