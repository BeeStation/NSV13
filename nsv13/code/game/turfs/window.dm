/obj/structure/window/fulltile
	alpha = 200
	color = "#94bbd1"
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon_state = "window"
	icon = 'nsv13/icons/obj/window.dmi'

/obj/structure/window/reinforced/fulltile
	alpha = 200
	color = "#94bbd1"
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon_state = "rwindow"
	icon = 'nsv13/icons/obj/window.dmi'

/obj/structure/window/plasma/fulltile
	alpha = 200
	color = "#EE82EE"
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon_state = "window"
	icon = 'nsv13/icons/obj/window.dmi'

/obj/structure/window/plasma/reinforced/fulltile
	alpha = 200
	color = "#EE82EE"
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon_state = "rwindow"
	icon = 'nsv13/icons/obj/window.dmi'

//"wall grilles" that smooth like regular walls do because why not

/obj/structure/grille/wall
	color = "#707070" //So close to being "nice" that it hurts.
	smooth = SMOOTH_TRUE
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	icon = 'nsv13/icons/obj/grille.dmi'
	canSmoothWith = list(/turf/closed/wall,/obj/machinery/door,/obj/structure/window/fulltile,/obj/structure/window/reinforced/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/falsewall)

//Credit to baystation for this mess.

/obj/structure/legacy_smooth()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	. = ..()
	if(!can_visually_connect())
		return
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

/obj/structure
	var/list/connections = list("0", "0", "0", "0")
	var/list/other_connections = list("0", "0", "0", "0")

/obj/structure/proc/can_visually_connect_to(obj/structure/S)
	return istype(S, src)

/obj/structure/proc/can_visually_connect()
	return anchored

/obj/structure/window/can_visually_connect()
	return anchored && fulltile

/obj/structure/proc/update_connections()
	var/list/dirs = list()
	var/list/other_dirs = list()

	for(var/obj/structure/S in orange(src, 1))
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