/*

Welcome to off-brand collider2d!

Points are some precise pixel coordinates that are relative to the shape, counterclockwise order.

COLLISIONS MAY OR MAY NOT END UP BACKWARDS. CHECK THIS LATER.

Special thanks to qwertyquerty for explaining and dictating all this! (I've mostly translated his pseudocode into readable byond code)

*/


// UPDATE: DEPRECATED. SEE COMMENT ABOVE HOOK FUNCTIONS
GLOBAL_VAR(exmap_initialized) // Exmap is windows only until I figure out how the hell to compile it for linux
#define EXMAP_EXTOOLS_CHECK if(!GLOB.exmap_initialized){\
	GLOB.exmap_initialized=TRUE;\
	if(fexists(EXTOOLS)){\
		var/result = (world.system_type == MS_WINDOWS) ? call(EXTOOLS,"init_exmap")() : "ok";\
		if(result != "ok") {CRASH(result);}\
	} else {\
		CRASH("byond-extools.dll or libbyond-extools.so does not exist!");\
	}\
}

/datum/shape
	var/matrix/vector/position = null //Vector to represent our position in the game world. This is updated by whatever's moving us with pixelmovement.
	var/_angle = 0 //Orientation in radians. You are not meant to use this directly.
	var/list/matrix/vector/base_points = list()
	var/list/matrix/vector/rel_points = list() //The vertices that this collider holds. Relative to the position. If the shape's at 200,200, and we have a vertex at 10,5, the vertex is actually at 210,205 in world. These are pixel coordinates. Counterclockwise order.
	var/list/matrix/vector/normals = list()
	var/list/aabb = list() //Cached points from AABB collision
	var/width = 0
	var/height = 0

//All stuff that happens in C++ land must be declared here and wrapped later.
// UPDATE: These functions have been deprecated since auxtools. Reimplementation should ideally be done via auxtool hooks (Rust) or DM if the function is not too expensive
/datum/shape/proc/__foo()
/datum/shape/proc/__get_seg_intersection(matrix/vector/p0, matrix/vector/p1, matrix/vector/p2, matrix/vector/p3)
/datum/shape/proc/get_seg_intersection()
/datum/shape/proc/__is_separating_axis(a_pos_x, a_pos_y, b_pos_x, b_pos_y, range_a_x, range_a_y, range_b_x, range_b_y, axis_x, axis_y)
/datum/shape/proc/is_separating_axis()
/datum/shape/proc/__flatten_points_on(list/points, normal_x, normal_y, point_count)
/datum/shape/proc/flatten_points_on()


//Constructor for shape objects, taking in parameters they may initially need

/datum/shape/New(matrix/vector/position, list/points, _angle=0)
	. = ..()
	if(!position)
		position = new /matrix/vector()
	src.position = position
	src._angle = _angle
	set_points(points)
	//FIXME learn physics in rust

/*
Method to set our position to a new one.
*/

/datum/shape/proc/_set(_x, _y)
	position.a = _x
	position.e = _y

/*
Method to set our points to a new list of points
@param points = a list filled with pixel point coordinates
*/

/datum/shape/proc/set_points(list/points)
	if(!length(base_points) || length(base_points) != length(points))
		rel_points.len = 0
		normals.len = 0
		for (var/i in 1 to length(points))
			rel_points.Add(new /matrix/vector(0,0))
			normals.Add(new /matrix/vector(0,0))

	base_points = points
	_recalc()
	return points

/*
Method to set our angle to a new angle as required, then recalculate our points as necessary.
*/
/datum/shape/proc/set_angle(var/angle)
	if(angle == src._angle) //No need for expensive recalculation for very minor changes.
		return FALSE

	src._angle = angle
	_recalc()

/*
Method to recalculate our bounding box, adjusting the relative positions accordingly
*/

/datum/shape/proc/_recalc()
	for(var/i in 1 to src.base_points.len)
		var/matrix/vector/rel_point = src.base_points[i].clone()
		rel_point.rotate(src._angle)
		src.rel_points[i].copy(rel_point)

	//Clear out our current AABB collision box
	aabb.len = 0
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY
	//Recalculate the points
	for(var/i in 1 to length(rel_points))
		var/matrix/vector/p1 = src.rel_points[i]
		var/matrix/vector/p2 = i < src.base_points.len ? src.rel_points[i+1] : src.rel_points[1]

		if(p1.a < min_x) min_x = p1.a
		if(p1.e < min_y) min_y = p1.e
		if(p1.a > max_x) max_x = p1.a
		if(p1.e > max_y) max_y = p1.e

		var/matrix/vector/edge = p2 - p1

		src.normals[i].copy(edge.perp().normalize())
	width = max_x - min_x
	height = max_y - min_y
	aabb.Add(min_x, min_y, max_x, max_y)

/**
Simple method to calculate whether we collide with another shape object, lightweight but not hugely precise for non-rectangle colliders.
*/
/datum/shape/proc/test_aabb(datum/shape/O)
	return position.a < O.position.a + O.width && position.a + width > O.position.a && position.e < O.position.e + O.height && position.e + height > O.position.e

/datum/shape/proc/get_global_points()
	var/list/matrix/vector/global_points = list()
	for (var/matrix/vector/point as() in rel_points)
		global_points.Add(point + position)

	return global_points

/**
Method to test if two shape objects are colliding with one another. We start off with a relatively inexpensive "Axis Oriented Bounding Box" check to test a block collision. If theyre not colliding with that, then it's safe
to say that we don't need the added cost (and extra precision) of SAT.

@returns boolean true / false
*/
/datum/shape/proc/collides(var/datum/shape/other, var/datum/collision_response/c_response)
	if(!test_aabb(other))
		return FALSE

	for (var/matrix/vector/norm as() in src.normals)
		if(is_separating_axis(src.position, other.position, src.rel_points, other.rel_points, norm, c_response))
			return FALSE

	for (var/matrix/vector/norm as() in other.normals)
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
	var/matrix/vector/closest_point = new /matrix/vector()

	var/list/matrix/vector/src_points = src.get_global_points()
	var/list/matrix/vector/other_points = other.get_global_points()

	var/list/matrix/vector/collision_points = list()

	for (var/src_i = 1, src_i < length(src_points), src_i++)
		for (var/other_i = 1, other_i < length(other_points), other_i++)
			var/matrix/vector/intersection = get_seg_intersection(src_points[src_i], src_points[src_i+1], other_points[other_i], other_points[other_i+1])
			if(intersection)
				collision_points.Add(intersection)

	// For some ungodly reason we're checking for an intersection point when the two shapes don't intersect; return nothing
	var/CPL = length(collision_points)
	if(!CPL)
		return
	for (var/matrix/vector/collision_point as() in collision_points)
		closest_point += collision_point

	closest_point.a /= CPL
	closest_point.e /= CPL

	return closest_point

/datum/shape/get_seg_intersection(matrix/vector/p0, matrix/vector/p1, matrix/vector/p2, matrix/vector/p3)
	var/list/out = __get_seg_intersection(p0.a, p0.e, p1.a, p1.e, p2.a, p2.e, p3.a,p3.e)
	return out ? new /matrix/vector(out[1], out[2]) : FALSE

/datum/shape/flatten_points_on(list/points, matrix/vector/normal)
	RETURN_TYPE(/matrix/vector)
	var/list/_points = list()
	for(var/matrix/vector/point as() in points)
		_points += point.a
		_points += point.e
	var/out = __flatten_points_on(_points, normal.a, normal.e, points.len*2)
	//message_admins("Contents of [out]:")
	//message_admins("Flattened points: [out[1]], [out[2]]")
	return new /matrix/vector(out[1], out[2])

/datum/shape/is_separating_axis(matrix/vector/a_pos, matrix/vector/b_pos, list/matrix/vector/a_points, list/matrix/vector/b_points, matrix/vector/axis, datum/collision_response/c_response)
	var/matrix/vector/range_a = flatten_points_on(a_points, axis)
	var/matrix/vector/range_b = flatten_points_on(b_points, axis)
	var/out = __is_separating_axis(a_pos.a, a_pos.e, b_pos.a, b_pos.e, range_a.a, range_a.e,range_b.a, range_b.e , axis.a, axis.e)
	if(islist(out) && c_response)
		c_response.a_in_b = out[1]
		c_response.b_in_a = out[2]
		c_response.overlap = out[3]
		c_response.overlap_normal._set(out[4][1], out[4][2])
		c_response.overlap_vector._set(out[5][1], out[5][2])
		c_response.overlap_point._set(out[6][1], out[6][2])
		return FALSE
	return TRUE
