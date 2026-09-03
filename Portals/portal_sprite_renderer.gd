class_name PortalSpriteRenderer extends Node2D

var intermediate_bodies: Dictionary[Portal, Array] = {}:
	set(v):
		intermediate_bodies = v
		# not really necessary
		queue_redraw()

var last = false

func _process(_delta):
	queue_redraw()
		
func _draw():
	for portal in intermediate_bodies:
		for body in intermediate_bodies[portal]:
			var sprites = body.find_children("*", "Sprite2D", true, false)

			for sprite in sprites:
				draw_set_transform_matrix(
					global_transform.affine_inverse() * 
					Transform2D(
						deg_to_rad(
							portal.port_rot(sprite.global_rotation_degrees)
						), 
						portal.port_scale(sprite.global_scale),
						sprite.global_skew,
						portal.port_pos(sprite.global_position)
					)
				)
				draw_texture(sprite.texture, Vector2.ZERO - sprite.texture.get_size() / 2)
