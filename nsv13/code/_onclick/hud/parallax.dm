////////////////////////////////////////////////////////////////////
// PARALLAX DOCUMENTATION BECAUSE MONSTER DIDNT DOCUMENT ANYTHING!//
// update_status: checks whether it should be visible or not      //
// update_o: scales the parallax to fit your viewport             //
////////////////////////////////////////////////////////////////////

/datum/space_level
	var/parallax_movedir = null //Which way doth the parallax go?
	var/parallax_property = null //A wacky parallax space background character! Used for system parallax.

/datum/space_level/proc/set_parallax(parallax_property, parallax_movedir = null)
	src.parallax_property = parallax_property
	src.parallax_movedir = parallax_movedir

/area/maintenance/ship_exterior //Used so that the FTL effect doesnt go away when you step outside.
	name = "Ship exterior"
	icon_state = "space_near"
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT

/atom/movable/screen/parallax_layer/ftl_parallax
 	speed = 1

/atom/movable/screen/parallax_layer/ftl_parallax/update_status(mob/M)
 	. = ..()
 	update_o()

/atom/movable/screen/parallax_layer/ftl_parallax/update_o(view)
	check_ftl_state()
	. = ..(view)

/atom/movable/screen/parallax_layer/ftl_parallax/proc/check_ftl_state()
	if(!current_mob)
		return FALSE //Something has gone horribly wrong.
	var/datum/space_level/SL = SSmapping.z_list[current_mob.z]
	var/in_transit = current_mob.get_overmap() && (SSstar_system.ships[current_mob.get_overmap()]["target_system"] != null)
	//FTL transit parallax takes priority.
	if(in_transit)
		if(SL.parallax_movedir != dir)
			dir = (SL.parallax_movedir) ? SL.parallax_movedir : initial(dir)
		icon_state = "transit"
		tesselate = TRUE
		return TRUE

	if(SL.parallax_property != icon_state || SL.parallax_movedir != dir)
		icon_state = SL.parallax_property
		dir = (SL.parallax_movedir) ? SL.parallax_movedir : initial(dir)
		tesselate = (findtext(SL.parallax_property, "planet")) ? FALSE : TRUE
		return TRUE
