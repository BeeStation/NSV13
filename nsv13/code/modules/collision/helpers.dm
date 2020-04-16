/**

Helper methods for collision detection, implementing things like the separating axis theorem.

Special thanks to qwertyquerty for explaining and dictating all this! (I've mostly translated his pseudocode into readable byond code)

*/

/proc/is_separating_axis(a_pos, b_pos, a_points, b_points, axis)
	var/datum/offset_v = b_pos.minus(a_pos)
	var/datum/projected_offset = offset_v.dot(axis)
	var/datum/vector/range_a = flatten_points_on(a_points, axis)
	var/datum/vector/range_b = flatten_points_on(b_points, axis)
	range_b.x += projected_offset
	range_b.y += projected_offset
	if (range_a.x > range_b.y or range_b.x > range_a.y){
		return TRUE
	}
	return FALSE

/proc/flatten_points_on(list/points, normal)
	var/minpoint = INFINITY
	var/maxpoint = -INFINITY
	for (point in points){
		var/dot = point.dot(normal)
		if (dot < minpoint){
			minpoint = dot
		}
		if (dot > maxpoint){
			maxpoint = dot
		}
	}
	return new /datum/vector2d(minpoint, maxpoint)