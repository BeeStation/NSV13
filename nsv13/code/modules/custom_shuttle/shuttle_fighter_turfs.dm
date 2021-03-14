/turf/closed/indestructible/shuttle_border
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	name = "\proper space"
	intact = 0
	flags_1 = NOJAUNT_1
	plane = PLANE_SPACE
	layer = SPACE_LAYER

//No entering this place.
/turf/closed/indestructible/shuttle_border/Enter(atom/movable/mover, atom/oldloc)
	return FALSE

/turf/open/indestructible/shuttle_bottom_place
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	name = "\proper space"
	intact = 0
	flags_1 = NOJAUNT_1
	plane = PLANE_SPACE
	layer = SPACE_LAYER
	var/obj/structure/overmap/fighter/custom_shuttle/linked_shuttle

/turf/open/indestructible/shuttle_bottom_place/Entered(atom/movable/AM)
	. = ..()
	//Teleport back to safety
	if(linked_shuttle)
		AM.forceMove(get_turf(linked_shuttle))
	else
		AM.forceMove(SSmapping.get_station_center())
