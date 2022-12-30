/**

Helper methods for collision detection, implementing things like the separating axis theorem.

Special thanks to qwertyquerty for explaining and dictating all this! (I've mostly translated his pseudocode into readable byond code)

*/
/*
/proc/is_separating_axis(matrix/vector/a_pos, matrix/vector/b_pos, list/matrix/vector/a_points, list/matrix/vector/b_points, matrix/vector/axis, datum/collision_response/c_response)
	var/matrix/vector/offset_v = b_pos - a_pos

	var/projected_offset = offset_v.dot(axis)

	var/matrix/vector/range_a = flatten_points_on(a_points, axis)
	var/matrix/vector/range_b = flatten_points_on(b_points, axis)

	range_b.a += projected_offset
	range_b.e += projected_offset

	if(range_a.a > range_b.e || range_b.a > range_a.e)
		return TRUE

	if (c_response)
		var/overlap = 0

		if(range_a.a < range_b.a)
			c_response.a_in_b = FALSE

			if(range_a.e < range_b.e)
				overlap = range_a.e - range_b.a
				c_response.b_in_a = FALSE
			else
				var/option_1 = range_a.e - range_b.a
				var/option_2 = range_b.e - range_a.a
				overlap = option_1 < option_2 ? option_1 : -option_2
		else
			c_response.b_in_a = FALSE

			if (range_a.e > range_b.e)
				overlap = range_a.a - range_b.e
				c_response.a_in_b = FALSE
			else
				var/option_1 = range_a.e - range_b.a
				var/option_2 = range_b.e - range_a.a
				overlap = option_1 < option_2 ? option_1 : -option_2

		if (abs(overlap) < c_response.overlap)
			c_response.overlap = abs(overlap)
			c_response.overlap_normal.copy(axis)
			if (overlap < 0)
				c_response.overlap_normal.reverse()

	return FALSE

/proc/flatten_points_on(list/points, matrix/vector/normal)
	var/minpoint = INFINITY
	var/maxpoint = -INFINITY

	for (var/matrix/vector/point in points)
		var/dot = point.dot(normal)
		if (dot < minpoint)
			minpoint = dot

		if (dot > maxpoint)
			maxpoint = dot

	return new /matrix/vector(minpoint, maxpoint)
*/
/*
/datum/shape/get_seg_intersection(matrix/vector/p0, matrix/vector/p1, matrix/vector/p2, matrix/vector/p3)
	var/matrix/vector/s10 = p1 - p0
	var/matrix/vector/s32 = p3 - p2

	var/denom = s10.cross(s32)

	if (denom == 0)
		return FALSE

	var/denom_is_positive = denom > 0

	var/matrix/vector/s02 = p0 - p2

	var/s_numer = s10.cross(s02)

	if ((s_numer < 0) == denom_is_positive)
		return FALSE

	var/t_numer = s32.cross(s02)

	if ((t_numer < 0) == denom_is_positive)
		return FALSE

	if ((s_numer > denom) == denom_is_positive || (t_numer > denom) == denom_is_positive)
		return FALSE

	var/t = t_numer / denom

	return new /matrix/vector(p0.a + (t * s10.a), p0.e + (t * s10.e))
*/
