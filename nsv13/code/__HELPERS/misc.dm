///This proc takes a dir and turns it into a list of its cardinal dirs. Useful for, say, handling things on multiple cardinals, and only cardinals, in case of diagonal positioning.
/proc/dir_to_cardinal_dirs(input_dir)
	if(input_dir in list(NORTH, EAST, SOUTH, WEST))
		return list(input_dir)
	switch(input_dir)
		if(NORTHEAST)
			return list(NORTH, EAST)
		if(NORTHWEST)
			return list(NORTH, WEST)
		if(SOUTHEAST)
			return list(SOUTH, EAST)
		if(SOUTHWEST)
			return list(SOUTH, WEST)

///Whether the angle is on the port or starboard side of the ship (facing north or south on the map)
/proc/angle2dir_ship(angle)
	if(0 < angle && angle < 180)
		return SOUTH
	else
		return NORTH
