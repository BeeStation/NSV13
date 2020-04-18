/**

Helper methods for collision detection, implementing things like the separating axis theorem.

Special thanks to qwertyquerty for explaining and dictating all this! (I've mostly translated his pseudocode into readable byond code)

*/

/proc/is_separating_axis(datum/vector2d/a_pos, datum/vector2d/b_pos, list/datum/vector2d/a_points, list/datum/vector2d/b_points, datum/vector2d/axis, datum/collision_response/c_response)
	var/datum/vector2d/offset_v = b_pos - a_pos

	var/projected_offset = offset_v.dot(axis)

	var/datum/vector2d/range_a = flatten_points_on(a_points, axis)
	var/datum/vector2d/range_b = flatten_points_on(b_points, axis)

	range_b.x += projected_offset
	range_b.y += projected_offset

	if(range_a.x > range_b.y || range_b.x > range_a.y)
		return TRUE

	if (c_response)
		var/overlap = 0

		if(range_a.x < range_b.x)
			c_response.a_in_b = FALSE

			if(range_a.y < range_b.y)
				overlap = range_a.y - range_b.x
				c_response.b_in_a = FALSE
			else
				var/option_1 = range_a.y - range_b.x
				var/option_2 = range_b.y - range_a.x
				overlap = option_1 < option_2 ? option_1 : -option_2
		else
			c_response.b_in_a = FALSE

			if (range_a.y > range_b.y)
				overlap = range_a.x - range_b.y
				c_response.a_in_b = FALSE
			else
				var/option_1 = range_a.y - range_b.x
				var/option_2 = range_b.y - range_a.x
				overlap = option_1 < option_2 ? option_1 : -option_2

		if (abs(overlap) < c_response.overlap)
			c_response.overlap = abs(overlap)
			c_response.overlap_normal.copy(axis)
			if (overlap < 0)
				c_response.overlap_normal.reverse()

	return FALSE

/proc/flatten_points_on(list/points, datum/vector2d/normal)
	var/minpoint = INFINITY
	var/maxpoint = -INFINITY

	for (var/datum/vector2d/point in points)
		var/dot = point.dot(normal)
		if (dot < minpoint)
			minpoint = dot

		if (dot > maxpoint)
			maxpoint = dot

	return new /datum/vector2d(minpoint, maxpoint)
