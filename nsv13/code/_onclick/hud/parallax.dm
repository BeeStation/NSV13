////////////////////////////////////////////////////////////////////
// PARALLAX DOCUMENTATION BECAUSE MONSTER DIDNT DOCUMENT ANYTHING!//
// update_status: checks whether it should be visible or not      //
// update_o: scales the parallax to fit your viewport             //
////////////////////////////////////////////////////////////////////

/area/maintenance/ship_exterior //Used so that the FTL effect doesnt go away when you step outside.
	name = "Ship exterior"
	icon_state = "space_near"

/obj/screen/parallax_layer/layer_3
 	speed = 1
 	layer = 2

/obj/screen/parallax_layer/layer_3/update_status(mob/M)
 	. = ..()
 	update_o()

/obj/screen/parallax_layer/layer_3/update_o(view)
	check_ftl_state()
	. = ..(view)

/obj/screen/parallax_layer/layer_3/proc/check_ftl_state()
	if(!current_mob)
		return
	var/obj/structure/overmap/OM = current_mob.get_overmap()
	var/area/AR = get_area(current_mob)
	if(OM && AR.parallax_movedir)
		icon_state = "transit"
		dir = AR.parallax_movedir
		return
	if(OM?.current_system.parallax_property)
		icon_state = OM.current_system.parallax_property
		dir = initial(dir)
		return
	icon_state = "layer3"
	dir = initial(dir)

/obj/screen/parallax_layer/planet/update_o(view) //FOR NOW, we don't want the planet to scale with view. Change this when the "planet" layer becomes the "system" trait layer
	if(!current_mob)
		return
	update_status(current_mob)

/obj/screen/parallax_layer/planet/update_status(mob/M) //Planet will be used as our "system" parallax layer. Some systems may have rocks, others planets, who knows!
	current_mob = M //Nsv13 - FTL parallax
	var/turf/T = get_turf(M)
	var/obj/structure/overmap/OM = current_mob.get_overmap()
	var/area/AR = get_area(current_mob)
	if(is_station_level(T.z) && !OM?.current_system?.parallax_property) //Hide if there's a parallax override coming from a system
		invisibility = 0
	else
		invisibility = INVISIBILITY_ABSTRACT
	if(OM && AR.parallax_movedir) //Hide it if the ship is in FTL
		invisibility = INVISIBILITY_ABSTRACT