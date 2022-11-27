//Credit to baystation for this mess.

/atom/proc/legacy_smooth()
	return //Only implemented on fucky 3/4 stuff

#define CORNER_NONE 0
#define CORNER_COUNTERCLOCKWISE 1
#define CORNER_DIAGONAL 2
#define CORNER_CLOCKWISE 4

/proc/dirs_to_corner_states(list/dirs)
	if(!istype(dirs)) return

	var/list/ret = list(NORTHWEST, SOUTHEAST, NORTHEAST, SOUTHWEST)

	for(var/i = 1 to ret.len)
		var/dir = ret[i]
		. = CORNER_NONE
		if(dir in dirs)
			. |= CORNER_DIAGONAL
		if(turn(dir,45) in dirs)
			. |= CORNER_COUNTERCLOCKWISE
		if(turn(dir,-45) in dirs)
			. |= CORNER_CLOCKWISE
		ret[i] = "[.]"

	return ret

#undef CORNER_NONE
#undef CORNER_COUNTERCLOCKWISE
#undef CORNER_DIAGONAL
#undef CORNER_CLOCKWISE

///////////////////////////
// To the window
///////////////////////////

/obj/structure/window
	var/list/connections = list("0", "0", "0", "0")
	var/list/other_connections = list("0", "0", "0", "0")

/obj/structure/window/legacy_smooth()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	. = ..()
	if(!can_visually_connect())
		icon_state = initial(icon_state)
		return
	icon_state = ""
	update_connections()
	var/basestate = initial(icon_state)
	overlays.Cut()

	var/image/I = null
	for(var/i = 1 to 4)
		if(other_connections[i] != "0")
			I = image(icon, "[basestate]_other[connections[i]]", dir = 1<<(i-1))
		else
			I = image(icon, "[basestate][connections[i]]", dir = 1<<(i-1))
		overlays += I

/obj/structure/window/proc/can_visually_connect_to(obj/structure/S)
	return istype(S, src)

/obj/structure/window/proc/can_visually_connect()
	return anchored && fulltile

/obj/structure/window/proc/update_connections()
	var/list/dirs = list()
	var/list/other_dirs = list()

	for(var/obj/structure/window/S in orange(src, 1))
		if(can_visually_connect_to(S))
			if(S.can_visually_connect())
				dirs += get_dir(src, S)

	if(!can_visually_connect())
		connections = list("0", "0", "0", "0")
		other_connections = list("0", "0", "0", "0")
		return FALSE

	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		var/success = 0
		for(var/b_type in canSmoothWith)
			if(istype(T, b_type))
				success = 1
				if(success)
					break
			if(success)
				break
		if(!success)
			for(var/obj/O in T)
				for(var/b_type in canSmoothWith)
					if(istype(O, b_type))
						success = 1
						for(var/obj/structure/S in T)
							if(istype(S, src))
								success = 0
					if(success)
						break
				if(success)
					break

		if(success)
			dirs += get_dir(src, T)
			other_dirs += get_dir(src, T)

	connections = dirs_to_corner_states(dirs)
	other_connections = dirs_to_corner_states(other_dirs)
	return TRUE

///////////////////////////
// To the wall
///////////////////////////

#define CAN_SMOOTH_FULL 1 //Able to fully smooth, no "connection" states.
#define CAN_SMOOTH_HALF 2 //Able to half smooth, will spawn "connector" states.

/turf/closed/wall/legacy_smooth()
	update_connections()
	update_icon()

/turf/closed/wall/proc/update_connections()
	var/list/wall_dirs = list()
	var/list/other_dirs = list()

	for(var/atom/W in orange(src, 1))
		switch(can_join_with(W))
			if(FALSE)
				continue
			if(CAN_SMOOTH_FULL)
				wall_dirs += get_dir(src, W)
			if(CAN_SMOOTH_HALF)
				wall_dirs += get_dir(src, W)
				other_dirs += get_dir(src, W)

	wall_connections = dirs_to_corner_states(wall_dirs)
	other_connections = dirs_to_corner_states(other_dirs)
	return

/turf/closed/wall/proc/can_join_with(atom/movable/W)
	if(ismob(W) || istype(W, /obj/machinery/door/window) || istype(W, /turf/closed/wall/mineral/titanium)) //Just...trust me on this
		return FALSE
	if(istype(W, src.type))
		return CAN_SMOOTH_FULL
	for(var/_type in canSmoothWith)
		if(istype(W, _type))
			return CAN_SMOOTH_HALF
	return FALSE

/turf/closed/wall/update_icon()
	if(legacy_smooth)
		cut_overlays()
		var/image/I = null
		for(var/i = 1 to 4)
			I = image(icon, "[initial(icon_state)][wall_connections[i]]", dir = 1<<(i-1))
			add_overlay(I)
			if(other_connections[i] != "0")
				I = image(icon, "[initial(icon_state)]_other[wall_connections[i]]", dir = 1<<(i-1))
				add_overlay(I)
		if(texture)
			add_overlay(texture)
	else
		..()

/obj/structure/falsewall/legacy_smooth()
	update_connections()
	update_icon()

/obj/structure/falsewall/proc/update_connections()
	var/list/wall_dirs = list()
	var/list/other_dirs = list()

	for(var/atom/W in orange(src, 1))
		switch(can_join_with(W))
			if(FALSE)
				continue
			if(CAN_SMOOTH_FULL)
				wall_dirs += get_dir(src, W)
			if(CAN_SMOOTH_HALF)
				wall_dirs += get_dir(src, W)
				other_dirs += get_dir(src, W)

	wall_connections = dirs_to_corner_states(wall_dirs)
	other_connections = dirs_to_corner_states(other_dirs)
	return

/obj/structure/falsewall/proc/can_join_with(atom/movable/W)
	if(ismob(W) || istype(W, /obj/machinery/door/window) || istype(W, /turf/closed/wall/mineral/titanium)) //Just...trust me on this
		return FALSE
	if(istype(W, src.type))
		return CAN_SMOOTH_FULL
	for(var/_type in canSmoothWith)
		if(istype(W, _type))
			return CAN_SMOOTH_HALF
	return FALSE

/obj/structure/falsewall/update_icon()
	var/image/I = null
	if(opening)
		if(density)
			smooth = SMOOTH_FALSE
			cut_overlays()
			icon_state = "[initial(icon_state)]fwall_opening"
		else
			icon_state = "[initial(icon_state)]fwall_closing"
			smooth = SMOOTH_TRUE
			clear_smooth_overlays()
	else
		if(density)
			clear_smooth_overlays()
			for(var/i = 1 to 4)
				I = image(icon, "[initial(icon_state)][wall_connections[i]]", dir = 1<<(i-1))
				add_overlay(I)
				if(other_connections[i] != "0")
					I = image(icon, "[initial(icon_state)]_other[wall_connections[i]]", dir = 1<<(i-1))
					add_overlay(I)
			if(texture)
				add_overlay(texture)
		else
			icon_state = "[initial(icon_state)]fwall_open"
			clear_smooth_overlays()
	return


/obj/structure/grille
	var/list/connections = list("0", "0", "0", "0")
	var/list/other_connections = list("0", "0", "0", "0")

/obj/structure/grille/legacy_smooth()
	. = ..()
	if(!can_visually_connect())
		icon_state = initial(icon_state)
		return
	icon_state = ""
	update_connections()
	var/basestate = initial(icon_state)
	overlays.Cut()

	var/image/I = null
	for(var/i = 1 to 4)
		if(other_connections[i] != "0")
			I = image(icon, "[basestate]_other[connections[i]]", dir = 1<<(i-1))
		else
			I = image(icon, "[basestate][connections[i]]", dir = 1<<(i-1))
		overlays += I

/obj/structure/grille/proc/can_visually_connect_to(obj/structure/S)
	return istype(S, src)

/obj/structure/grille/proc/can_visually_connect()
	return anchored

/obj/structure/grille/proc/update_connections()
	var/list/dirs = list()
	var/list/other_dirs = list()

	for(var/obj/structure/grille/S in orange(src, 1))
		if(can_visually_connect_to(S))
			if(S.can_visually_connect())
				dirs += get_dir(src, S)

	if(!can_visually_connect())
		connections = list("0", "0", "0", "0")
		other_connections = list("0", "0", "0", "0")
		return FALSE

	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		var/success = 0
		for(var/b_type in canSmoothWith)
			if(istype(T, b_type))
				success = 1
				if(success)
					break
			if(success)
				break
		if(!success)
			for(var/obj/O in T)
				for(var/b_type in canSmoothWith)
					if(istype(O, b_type))
						success = 1
						for(var/obj/structure/S in T)
							if(istype(S, src))
								success = 0
					if(success)
						break
				if(success)
					break

		if(success)
			dirs += get_dir(src, T)
			other_dirs += get_dir(src, T)

	connections = dirs_to_corner_states(dirs)
	other_connections = dirs_to_corner_states(other_dirs)
	return TRUE
#undef CAN_SMOOTH_FULL
#undef CAN_SMOOTH_HALF
