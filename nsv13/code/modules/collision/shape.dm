/*

Welcome to off-brand collider2d!

Points are some precise pixel coordinates that are relative to the shape, counterclockwise order.

COLLISIONS MAY OR MAY NOT END UP BACKWARDS. CHECK THIS LATER.

Special thanks to qwertyquerty for explaining and dictating all this! (I've mostly translated his pseudocode into readable byond code)

*/

/datum/shape
	var/datum/vector2d/position = null //Vector to represent our position in the game world. This is updated by whatever's moving us with pixelmovement.
	var/_angle = 0 //Orientation in radians. You are not meant to use this directly.
	var/list/base_points = list()
	var/list/rel_points = list() //The vertices that this collider holds. Relative to the position. If the shape's at 200,200, and we have a vertex at 10,5, the vertex is actually at 210,205 in world. These are pixel coordinates. Counterclockwise order.
	var/list/normals = list()
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
	to_chat(world, "set points BEGIN")
	if(!src.base_points.len || src.base_points.len != points.len){
		src.rel_points.Cut()
		src.normals.Cut()
		for (var/i in 1 to points.len){
			src.rel_points.Add(new /datum/vector2d(0,0))
			src.normals.Add(new /datum/vector2d(0,0))
		}
		to_chat(world, "DONE LIST INIT")
	}
	to_chat(world, "REL_POINTS: [src.rel_points.len], FRST: [src.rel_points[1].x],[src.rel_points[1].y]")
	to_chat(world, "NORMS: [src.normals.len], FRST: [src.normals[1].x],[src.normals[1].y]")
	src.base_points = points
	src._recalc()
	return points

/*
Method to set our angle to a new angle as required, then recalculate our points as necessary.
*/
/datum/shape/proc/set_angle(var/angle)
	if(angle == src._angle){ //No need for expensive recalculation for very minor changes.
		return FALSE
	}
	src._angle = angle
	src._recalc()

/*
Method to recalculate our bounding box, adjusting the relative positions accordingly
*/

/datum/shape/proc/_recalc()
	to_chat(world, "STARTING RELPOINT CALC")
	for(var/i in 1 to src.base_points.len){
		to_chat(world, "BASEPOINT [i]: [src.base_points[i].x],[src.base_points[i].y]")
		src.rel_points[i]._set(src.base_points[i].clone().rotate(src._angle))
		to_chat(world, "CLONED [src.base_points[i].clone().x],[src.base_points[i].clone().y]")
		to_chat(world, "ROTATED [src.base_points[i].clone().rotate(src._angle).x],[src.base_points[i].clone().rotate(src._angle).y]")
		to_chat(world, "TO RELPOINT [i]: [src.rel_points[i].x],[src.rel_points[i].y]")
	}
	//Clear out our current AABB collision box
	src.aabb.Cut()
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY
	//Recalculate the points
	for(var/i in 1 to src.rel_points.len){
		var/datum/vector2d/p1 = src.rel_points[i]
		var/datum/vector2d/p2 = i < src.base_points.len ? src.rel_points[i+1] : src.rel_points[1]

		to_chat(world, "P1: [p1.x],[p1.y]")
		to_chat(world, "P2: [p2.x],[p2.y]")

		if(p1.x < min_x){
			min_x = p1.x
		}
		if(p1.y < min_y){
			min_y = p1.y
		}
		if(p1.x > max_x){
			max_x = p1.x
		}
		if(p1.y > max_y){
			max_y = p1.y
		}

		var/datum/vector2d/edge = p2 - p1
		to_chat(world, "EDGE: [edge.x],[edge.y]")
		to_chat(world, "EDGE PERP: [edge.clone().perp().x],[edge.clone().perp().y]")
		to_chat(world, "EDGE PERP NORM: [edge.clone().perp().normalize().x],[edge.clone().perp().normalize().y]")
		src.normals[i]._set(edge.perp().normalize())
	}
	aabb.Add(min_x)
	aabb.Add(min_y)
	aabb.Add(max_x)
	aabb.Add(max_y)

/**

Simple method to calculate whether we collide with another shape object, lightweight but not hugely precise.

*/

/datum/shape/proc/test_aabb(var/datum/shape/other)
	return ((src.aabb[1] + src.position.x) <= (other.aabb[3] + other.position.x)) && ((src.aabb[2] + src.position.y) <= (other.aabb[4] + other.position.y)) && ((src.aabb[3] + src.position.x) >= (other.aabb[1] + other.position.x)) && ((src.aabb[4] + src.position.y) >= (other.aabb[2] + other.position.y))

/**

Method to test if two shape objects are colliding with one another. We start off with a relatively inexpensive "Axis Oriented Bounding Box" check to test a block collision. If theyre not colliding with that, then it's safe
to say that we don't need the added cost (and extra precision) of SAT.

@returns boolean true / false

*/

/datum/shape/proc/collides(var/datum/shape/other)
	if(!src.test_aabb(other)){
		return FALSE
	}
	for (var/norm in src.normals){
		if(is_separating_axis(src.position, other.position, src.rel_points, other.rel_points, norm)){
			return FALSE
		}
	}
	for (var/norm in other.normals){
		if(is_separating_axis(src.position, other.position, src.rel_points, other.rel_points, norm)){
			return FALSE
		}
	}
	return TRUE