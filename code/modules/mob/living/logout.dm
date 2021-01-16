/mob/living/Logout()
	update_z(null)
	//I still need their clients in tact to do this stuff.
	var/datum/component/overmap_gunning/OG = GetComponent(/datum/component/overmap_gunning)
	if(OG && istype(OG))
		OG.end_gunning()
	if(src.overmap_ship)
		overmap_ship.stop_piloting(src)
	..()
	if(!key && mind)	//key and mind have become separated.
		mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.

