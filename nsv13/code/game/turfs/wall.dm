#define CAN_SMOOTH_FULL 1 //Able to fully smooth, no "connection" states.
#define CAN_SMOOTH_HALF 2 //Able to half smooth, will spawn "connector" states.

/atom/proc/legacy_smooth()
	return //Only implemented on fucky 3/4 stuff

/turf/closed/wall
	icon_state = "solid"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	legacy_smooth = TRUE //Override /tg/ iconsmooths
	canSmoothWith = list(/turf/closed/wall,/obj/machinery/door,/obj/structure/window/fulltile,/obj/structure/window/reinforced/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/falsewall)
	var/list/wall_connections = list("0", "0", "0", "0")
	var/list/other_connections = list("0", "0", "0", "0")
	var/image/texture = null //EG: Concrete. Lets you texture a wall with one texture tile rather than making a new wall..every..single...time
	var/texture_state = null

/turf/closed/wall/Initialize()
	. = ..()
	if(texture_state)
		texture = image(icon, texture_state)
		texture.blend_mode = BLEND_MULTIPLY

/turf/closed/wall/steel
	color = "#787878"

/turf/closed/wall/r_wall
	icon_state = "reinf"
	texture = "reinf_over"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	color = "#787878"

/turf/closed/wall/mineral
	icon_state = "mineral"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/cult
	icon_state = "cult"
	color = "#4C4343"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/gold
	color = "#FFD700"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	icon_state = "metal"

/turf/closed/wall/mineral/silver
	icon_state = "metal"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/snow
	icon_state = "metal"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/copper
	icon_state = "metal"
	color = "#b87333"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/diamond
	icon_state = "metal"
	color = "#b9f2ff"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/sandstone
	icon_state = "metal"
	color = "#AA9F91"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	texture_state = "concrete"

/turf/closed/wall/mineral/bananium
	icon_state = "metal"
	color = "#FFFF33"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/uranium
	icon_state = "metal"
	color = "#228B22"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	texture_state = "concrete"

/turf/closed/wall/mineral/plasma
	icon_state = "metal"
	color = "#EE82EE"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/iron
	icon_state = "metal"
	color = "#808080"
	icon = 'nsv13/icons/turf/wall_masks.dmi'

/turf/closed/wall/mineral/wood
	icon_state = "wood"
	icon = 'nsv13/icons/turf/wall_masks.dmi'
	color = "#C19A6B"

//Turfs that are still oblique. Fix these later.

/turf/closed/wall/mineral/titanium
	legacy_smooth = FALSE

/turf/closed/wall/mineral/plastitanium
	legacy_smooth = FALSE

/turf/closed/wall/mineral/abductor
	legacy_smooth = FALSE

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
	return

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


#undef CAN_SMOOTH_FULL
#undef CAN_SMOOTH_HALF
