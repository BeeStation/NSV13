/*

Welcome to off-brand collider2d!

Points are some precise pixel coordinates that are relative to the shape, counterclockwise order.

COLLISIONS MAY OR MAY NOT END UP BACKWARDS. CHECK THIS LATER.

Special thanks to qwertyquerty for explaining and dictating all this! (I've mostly translated his pseudocode into readable byond code)

*/

/datum/shape
	var/datum/vector2d/position = null //Vector to represent our position in the game world. This is updated by whatever's moving us with pixelmovement.
	var/_angle = 0 //Orientation in radians. You are not meant to use this directly.
	var/list/datum/vector2d/base_points = list()
	var/list/datum/vector2d/rel_points = list() //The vertices that this collider holds. Relative to the position. If the shape's at 200,200, and we have a vertex at 10,5, the vertex is actually at 210,205 in world. These are pixel coordinates. Counterclockwise order.
	var/list/datum/vector2d/normals = list()
	var/list/aabb = list() //Cached points from AABB collision

//Constructor for shape objects, taking in parameters they may initially need

/datum/shape/New(datum/vector2d/position, list/points, _angle=0)
	. = ..()
	if(!position)
		position = new /datum/vector2d()
	src.position = position
	src._angle = _angle
	set_points(points)

/*
Method to set our position to a new one.
*/

/datum/shape/proc/_set(_x, _y)
	position.x = _x
	position.y = _y

/*
Method to set our points to a new list of points
@param points = a list filled with pixel point coordinates
*/

/datum/shape/proc/set_points(list/points)
	if(!src.base_points.len || src.base_points.len != points.len)
		src.rel_points.Cut()
		src.normals.Cut()
		for (var/i in 1 to points.len)
			src.rel_points.Add(new /datum/vector2d(0,0))
			src.normals.Add(new /datum/vector2d(0,0))

	src.base_points = points
	src._recalc()
	return points

/*
Method to set our angle to a new angle as required, then recalculate our points as necessary.
*/
/datum/shape/proc/set_angle(var/angle)
	if(angle == src._angle) //No need for expensive recalculation for very minor changes.
		return FALSE

	src._angle = angle
	src._recalc()

/*
Method to recalculate our bounding box, adjusting the relative positions accordingly
*/

/datum/shape/proc/_recalc()
	for(var/i in 1 to src.base_points.len)
		var/datum/vector2d/rel_point = src.base_points[i].clone()
		rel_point.rotate(src._angle)
		src.rel_points[i].copy(rel_point)

	//Clear out our current AABB collision box
	src.aabb.Cut()
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY
	//Recalculate the points
	for(var/i in 1 to src.rel_points.len)
		var/datum/vector2d/p1 = src.rel_points[i]
		var/datum/vector2d/p2 = i < src.base_points.len ? src.rel_points[i+1] : src.rel_points[1]

		if(p1.x < min_x) min_x = p1.x
		if(p1.y < min_y) min_y = p1.y
		if(p1.x > max_x) max_x = p1.x
		if(p1.y > max_y) max_y = p1.y

		var/datum/vector2d/edge = p2 - p1

		src.normals[i].copy(edge.perp().normalize())

	aabb.Add(min_x)
	aabb.Add(min_y)
	aabb.Add(max_x)
	aabb.Add(max_y)

/**
Simple method to calculate whether we collide with another shape object, lightweight but not hugely precise.
*/
/datum/shape/proc/test_aabb(var/datum/shape/other)
	return	((src.aabb[1] + src.position.x) <= (other.aabb[3] + other.position.x)) && \
			((src.aabb[2] + src.position.y) <= (other.aabb[4] + other.position.y)) && \
			((src.aabb[3] + src.position.x) >= (other.aabb[1] + other.position.x)) && \
			((src.aabb[4] + src.position.y) >= (other.aabb[2] + other.position.y))


/datum/shape/proc/get_global_points()
	var/list/datum/vector2d/global_points = list()
	for (var/datum/vector2d/point in src.rel_points)
		global_points.Add(point + src.position)

	return global_points

/**
Method to test if two shape objects are colliding with one another. We start off with a relatively inexpensive "Axis Oriented Bounding Box" check to test a block collision. If theyre not colliding with that, then it's safe
to say that we don't need the added cost (and extra precision) of SAT.

@returns boolean true / false
*/
/datum/shape/proc/collides(var/datum/shape/other, var/datum/collision_response/c_response)
	if(!src.test_aabb(other))
		return FALSE

	for (var/datum/vector2d/norm in src.normals)
		if(is_separating_axis(src.position, other.position, src.rel_points, other.rel_points, norm, c_response))
			return FALSE

	for (var/datum/vector2d/norm in other.normals)
		if(is_separating_axis(src.position, other.position, src.rel_points, other.rel_points, norm, c_response))
			return FALSE

	if (c_response)
		c_response.overlap_vector.copy(c_response.overlap_normal)
		c_response.overlap_vector *= c_response.overlap

	return TRUE

// Could probably use some heavy optimization
/**
Find the average collision point between two shapes. Usually ends up being pretty darn close to the point of collision

@returns vector2d of closest point
*/
/datum/shape/proc/get_collision_point(var/datum/shape/other)
	var/datum/vector2d/closest_point = new /datum/vector2d()

	var/list/datum/vector2d/src_points = src.get_global_points()
	var/list/datum/vector2d/other_points = other.get_global_points()

	var/list/datum/vector2d/collision_points = list()

	for (var/src_i = 1, src_i < src_points.len, src_i++)
		for (var/other_i = 1, other_i < other_points.len, other_i++)
			var/datum/vector2d/intersection = get_seg_intersection(src_points[src_i], src_points[src_i+1], other_points[other_i], other_points[other_i+1])
			if(intersection)
				collision_points.Add(intersection)

	// For some ungodly reason we're checking for an intersection point when the two shapes don't intersect; return nothing
	if(!collision_points.len)
		return

	for (var/datum/vector2d/collision_point in collision_points)
		closest_point += collision_point

	// BYOND WHHHY CAN'T WE HAVE /=
	closest_point.x = closest_point.x / collision_points.len
	closest_point.y = closest_point.y / collision_points.len

	return closest_point




