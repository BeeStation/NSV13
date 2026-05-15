
//Should never actually exist outside of a ship, this is used for ships to have a mob to fire their guns.
/mob/living/dummy_pilot
	name = "Dummy AI pilot"
	mouse_opacity = FALSE
	alpha = 0

///Registers a dummy AI pilot's ship being destroyed and removes them.
/mob/living/dummy_pilot/proc/destroy_dummy_pilot(obj/structure/overmap/piloted_overmap)
	SIGNAL_HANDLER
	UnregisterSignal(piloted_overmap, COMSIG_PARENT_QDELETING)
	piloted_overmap.pilot = null
	piloted_overmap.gunner = null
	overmap_ship = null
	qdel(src)
