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

/obj/screen/parallax_layer/layer_3
 	speed = 1

/obj/screen/parallax_layer/layer_3/update_status(mob/M)
 	check_ftl_state()
 	. = ..()
 	update_o()

/obj/screen/parallax_layer/layer_3/update_o(view)
	check_ftl_state()
	. = ..(view)

/obj/screen/parallax_layer/layer_3/proc/check_ftl_state()
	if(!current_mob)
		return //Something has gone horribly wrong.
	var/datum/space_level/SL = SSmapping.z_list[current_mob.z]
	icon_state = SL.parallax_property
	dir = (SL.parallax_movedir) ? SL.parallax_movedir : initial(dir)

/obj/screen/parallax_layer/planet/update_o(view)
	if(!current_mob)
		return
	update_status(current_mob)

/obj/screen/parallax_layer/planet/update_status(mob/M) //Planet will be used as our "system" parallax layer. Some systems may have rocks, others planets, who knows!
	current_mob = M //Nsv13 - FTL parallax
	var/turf/T = get_turf(M)
	var/obj/structure/overmap/OM = current_mob?.get_overmap()
	if(!istype(OM, /obj/structure/overmap))
		return
	var/area/AR = get_area(current_mob)
	if(is_station_level(T.z) && !OM?.current_system?.parallax_property) //Hide if there's a parallax override coming from a system
		invisibility = 0
	else
		invisibility = INVISIBILITY_ABSTRACT
	if(OM && AR.parallax_movedir) //Hide it if the ship is in FTL
		invisibility = INVISIBILITY_ABSTRACT