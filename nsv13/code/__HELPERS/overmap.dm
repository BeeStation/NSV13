/atom/proc/get_overmap(failsafe = FALSE) //Helper proc to get the overmap ship representing a given area.
	RETURN_TYPE(/obj/structure/overmap)
	if(isovermap(loc))
		return loc
	if(!z) // We're in something's contents
		if(!loc) // Or not...
			return FALSE
		return loc.get_overmap() // Begin recursion!
	if(!SSmapping.z_list) //Being called by pre-mapping init call
		if(!failsafe) //Only retry once
			addtimer(CALLBACK(src, PROC_REF(get_overmap), TRUE), 30 SECONDS)
		return FALSE
	var/datum/space_level/SL = SSmapping.z_list[z] // Overmaps linked to Zs, like the main ship
	if(SL?.linked_overmap)
		return SL.linked_overmap
	if(SSmapping.level_trait(z, ZTRAIT_RESERVED)) // Overmaps using reserved turfs, like dropships and asteroids
		var/datum/turf_reservation/reserved = SSmapping.used_turfs[get_turf(src)]
		if(reserved && reserved.overmap_fallback)
			return reserved.overmap_fallback

/**
Helper method to get what ship an observer belongs to for stuff like parallax.
*/

/mob/proc/update_overmap()
	var/obj/structure/overmap/OM = loc.get_overmap() //Accounts for things like fighters and for being in nullspace because having no loc is bad.
	if(OM == last_overmap)
		return
	if(last_overmap)
		last_overmap.mobs_in_ship -= src
	last_overmap = OM
	if(OM)
		OM.mobs_in_ship += src
	SEND_SIGNAL(src, COMSIG_MOB_OVERMAP_CHANGE, src, OM)

/// Finds a turf outside of the overmap
/proc/GetSafeLoc(atom/A)
	if ( !A ) // play stupid games win stupid prizes
		return
	if(!SSmapping.level_trait(A.z, ZTRAIT_OVERMAP))
		return A

	var/max = world.maxx - TRANSITIONEDGE
	var/min = TRANSITIONEDGE + 1
	var/list/possible_transitions = SSmapping.levels_by_trait(ZTRAIT_STATION)
	var/_z = pick(possible_transitions)
	var/_x
	var/_y
	switch(A.dir)
		if(SOUTH)
			_x = rand(min,max)
			_y = max
		if(WEST)
			_x = max
			_y = rand(min,max)
		if(EAST)
			_x = min
			_y = rand(min,max)
		else
			_x = rand(min,max)
			_y = min
	return locate(_x, _y, _z) //Where are we putting you

/**
A more accurate get_dist, that takes into account the looping edges of the overmap.
[Here's the algorithm in desmos](https://www.desmos.com/calculator/6akddpjzio)
*/

/proc/overmap_dist(atom/A,atom/B)
	if (!A || !B)
		return 0
	var/TX = (world.maxx / 2) - (TRANSITIONEDGE + 1)
	var/TY = (world.maxy / 2) - (TRANSITIONEDGE + 1)
	var/CX = A.x - B.x
	var/CY = A.y - B.y
	if (CX < -TX)
		CX = ((-CX % TX) - TX)
	else if (CX > TX)
		CX = (TX - (CX % TX))

	if (CY < -TY)
		CY = ((-CY % TY) - TY)
	else if (CY > TY)
		CY = (TY - (CY % TY))

	return sqrt(CX**2 + CY**2)

/**
Another get_angle that works better with the looping edges of the overmap
*/

/proc/overmap_angle(atom/A,atom/B)
	if (!A || !B)
		return 0
	var/TX = (world.maxx / 2) - (TRANSITIONEDGE + 1)
	var/TY = (world.maxy / 2) - (TRANSITIONEDGE + 1)
	var/CX = A.x - B.x//most of this is copied from the above proc
	var/CY = A.y - B.y
	if (CX < -TX)
		CX = ((-CX % TX) - TX)
	else if (CX > TX)
		CX = (TX - (CX % TX))
	else
		CX = -CX

	if (CY < -TY)
		CY = ((-CY % TY) - TY)
	else if (CY > TY)
		CY = (TY - (CY % TY))
	else
		CY = -CY

	if(!CY)//straight up copied from Get_Angle
		return (CX>=0)?90:270
	.=arctan(CX/CY)
	if(CY<0)
		.+=180
	else if(CX<0)
		.+=360

/datum/controller/subsystem/mapping/proc/add_new_initialized_zlevel(name, traits = list(), z_type = /datum/space_level, orbital_body_type)
	add_new_zlevel(name, traits)
	SSatoms.InitializeAtoms(block(locate(1,1,world.maxz),locate(world.maxx,world.maxy,world.maxz)))
	setup_map_transitions(z_list[world.maxz])
