class_name PortalUtils

# along the shortest polar distance between the two, is b > a?
static func compare_angles(a: float, b: float):
	var i = 0
	while abs(a - b) > 180 and i < 100:
		if a > b:
			b += 360
		else:
			a += 360
	if i == 100:
		print("Fuse (in angle comparison) blew!")
		
	return b > a
	

static func test_angle_comparisons():
	assert(compare_angles(1, 10) == true)
	assert(compare_angles(1, 100) == true)
	assert(compare_angles(170, -170) == true)
	assert(compare_angles(200, -140) == true)
	assert(compare_angles(-170, -140) == true)
	assert(compare_angles(200, 230) == true)
	assert(compare_angles(10, 1) == false)
	assert(compare_angles(100, 1) == false)
	assert(compare_angles(-170, 170) == false)
	assert(compare_angles(-140, 200) == false)
	assert(compare_angles(-140, -170) == false)
	assert(compare_angles(230, 200) == false)
