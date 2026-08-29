class_name PortalSpriteRenderer extends Node2D

var intermediate_bodies: Array[IntermediateBody]:
	set(v):
		intermediate_bodies = v
		# not really necessary
		queue_redraw()
		
## Handles a Portable that is between two portals
class IntermediateBody:
	var portable: Portable
	var portal: Portal
	
	func _init(_portable: Portable, _portal: Portal):
		portable = _portable
		portal = _portal
		
func _process(_delta):
	queue_redraw()
		
func _draw():
	for body in intermediate_bodies:
		var sprites = body.portable.find_children("*", "Sprite2D", true, false)

		for sprite in sprites:
			draw_set_transform_matrix(
				global_transform.affine_inverse() * 
				Transform2D(
					deg_to_rad(
						sprite.global_rotation_degrees + body.portal.rotation_change_through()
					), 
					sprite.scale,
					sprite.skew,
					body.portal.port_pos(sprite.global_position)
				)
			)
			draw_texture(sprite.texture, Vector2.ZERO - sprite.texture.get_size() / 2)
