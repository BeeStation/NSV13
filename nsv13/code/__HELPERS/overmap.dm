/atom/proc/get_overmap() //Helper proc to get the overmap ship representing a given area.
	RETURN_TYPE(/obj/structure/overmap)
	if(!z)
		return FALSE
	var/datum/space_level/SL = SSmapping.z_list[z]
	if(SL?.linked_overmap)
		return SL.linked_overmap
	if(istype(loc, /obj/structure/overmap))
		return loc
	var/area/AR = get_area(src)
	return AR.overmap_fallback

/**
Helper method to get what ship an observer belongs to for stuff like parallax.
*/

/mob/proc/find_overmap()
	var/obj/structure/overmap/OM = loc.get_overmap() //Accounts for things like fighters and for being in nullspace because having no loc is bad.
	if(OM == last_overmap)
		return
	else
		last_overmap?.mobs_in_ship -= src
		last_overmap = OM
		OM?.mobs_in_ship += src

/**
A more accurate get_dist, that takes into account the looping edges of the overmap.  
[Here's the algorithm in desmos](https://www.desmos.com/calculator/6akddpjzio)
*/

/proc/overmap_dist(atom/A,atom/B)
	if (!A || !B)
		return 0
	var/T = 127.5 - (TRANSITIONEDGE + 1)
	var/CX = A.x - B.x
	var/CY = A.y - B.y
	if (CX < -T)
		CX = ((-CX % T) - T)
	else if (CX > T)
		CX = (T - (CX % T))
	
	if (CY < -T)
		CY = ((-CY % T) - T)
	else if (CY > T)
		CY = (T - (CY % T))
	
	return sqrt(CX**2 + CY**2)

/**
Another get_angle that works better with the looping edges of the overmap
*/

/proc/overmap_angle(atom/A,atom/B)
	if (!A || !B)
		return 0
	var/T = 127.5 - (TRANSITIONEDGE + 1)
	var/CX = A.x - B.x//most of this is copied from the above proc
	var/CY = A.y - B.y
	if (CX < -T)
		CX = ((-CX % T) - T)
	else if (CX > T)
		CX = (T - (CX % T))
	else 
		CX = -CX
	
	if (CY < -T)
		CY = ((-CY % T) - T)
	else if (CY > T)
		CY = (T - (CY % T))
	else 
		CY = -CY

	if(!CY)//straight up copied from Get_Angle
		return (CX>=0)?90:270
	.=arctan(CX/CY)
	if(CY<0)
		.+=180
	else if(CX<0)
		.+=360
