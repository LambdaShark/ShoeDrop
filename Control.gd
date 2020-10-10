extends Control
var player
var camera

func _draw():
	var color = Color(0, 1, 0)
	var start = camera.unproject_position(player.global_transform.origin)
	var end = camera.unproject_position(player.global_transform.origin + player.velocity)
	node.draw_line(start, end, color, width)
	node.draw_triangle(end, start.direction_to(end), width*2, color)

func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))
