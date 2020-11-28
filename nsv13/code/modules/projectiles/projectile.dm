//The collider for projectiles is universal. We can keep this as a singleton and scrape off an load of memory usage ~K
GLOBAL_LIST_INIT(projectile_hitbox, list(new /datum/vector2d(-2,16),\
										new /datum/vector2d(2,16),\
										new /datum/vector2d(2,-15),\
										new /datum/vector2d(-2,-15)))

/obj/item/projectile
	var/datum/component/physics2d/physics2d = null
	var/obj/structure/overmap/overmap_firer = null

/obj/item/projectile/proc/setup_collider()
	physics2d = AddComponent(/datum/component/physics2d)
	physics2d.setup(GLOB.projectile_hitbox, Angle)

/obj/item/projectile/proc/check_faction(atom/movable/A)
	var/obj/structure/overmap/OM = A
	if(!istype(OM))
		return TRUE
	if(faction != OM.faction)
		return TRUE
	return FALSE
