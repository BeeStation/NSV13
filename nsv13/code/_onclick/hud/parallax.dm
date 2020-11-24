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

/obj/screen/parallax_layer
	var/tesselate = TRUE

/obj/screen/parallax_layer/layer_3
 	speed = 1
 	var/next_ftl_state_check = 0

/obj/screen/parallax_layer/layer_3/update_status(mob/M)
 	. = ..()
 	update_o()

/obj/screen/parallax_layer/layer_3/update_o(view)
	check_ftl_state()
	. = ..(view)

/obj/screen/parallax_layer/layer_3/proc/check_ftl_state()
	if(!current_mob || world.time < next_ftl_state_check)
		return FALSE //Something has gone horribly wrong.
	next_ftl_state_check = world.time + 10 SECONDS //This causes some serious performance overhead so we're gonna throttle it.
	var/datum/space_level/SL = SSmapping.z_list[current_mob.z]
	icon_state = SL.parallax_property
	dir = (SL.parallax_movedir) ? SL.parallax_movedir : initial(dir)
	tesselate = (findtext(SL.parallax_property, "planet")) ? FALSE : TRUE
	return TRUE

/obj/screen/parallax_layer/planet/update_o(view)
	if(!current_mob)
		return
	update_status(current_mob)
