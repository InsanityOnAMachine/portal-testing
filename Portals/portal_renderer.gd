class_name PortalRenderer extends Node2D

var meshes: Array[ViewMesh]:
	set(v):
		meshes = v
		meshes.sort_custom(func(a, b): return b.y > a.y)
		queue_redraw()

func _draw():
	draw_set_transform_matrix(global_transform.affine_inverse())

	for x in meshes:
		draw_mesh(x.get_mesh(), x.room.texture, Transform2D(0, Vector2.ZERO))
	# sometimes the draw system needs an extra slap in the face to remember to draw the meshes above
	# this non-circle does the job somehow
	draw_circle(Vector2.ZERO, 0, Color.RED)
