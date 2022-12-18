/*
This datum is something you can optionally pass to the shape collision proc. If you do, it will calculate more information about the
collision and store it here
*/
/datum/collision_response
	var/overlap = INFINITY											// How far are the two shapes overlapped

	var/datum/vector2d/overlap_normal = new /datum/vector2d(0, 0)	// A normalized vector of the angle of overlap
	var/datum/vector2d/overlap_vector = new /datum/vector2d(0, 0)	// The overlap vector; subtracting this from a will cause it to no longer be colliding with b
	var/datum/vector2d/overlap_point = new/datum/vector2d(0, 0)		// The point of the collision

	var/a_in_b = TRUE												// Is a fully inside of b?
	var/b_in_a = TRUE												// Is b fully inside of a?
